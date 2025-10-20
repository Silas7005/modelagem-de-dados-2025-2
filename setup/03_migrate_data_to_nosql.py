import mysql.connector
from mysql.connector import errorcode
from couchbase.cluster import Cluster
from couchbase.options import ClusterOptions
from couchbase.auth import PasswordAuthenticator
from couchbase.exceptions import CouchbaseException
import json
from datetime import date, timedelta, datetime
from decimal import Decimal


"""
Esse script está enviando diretamente pro nosso banco em nuvem, sinta-se a vontade para testá-lo
"""
CONFIG = {
    "mysql": {
        "host": "187.87.135.20",
        "user": "root",
        "password": "Model@2025",
        "database": "DB_CRIMES_LA"
    },
    "couchbase": {
        "connection_string": "couchbase://187.87.135.20",
        "username": "Administrator",
        "password": "Model@2025",
        "bucket_name": "crimes_la_bucket",
        "scope_name": "_default",
        "collection_name": "crimes"
    }
}

def format_db_object(obj):
    if isinstance(obj, (date, datetime)):
        return obj.isoformat()
    
    if isinstance(obj, timedelta):
        return str(obj) 

    if isinstance(obj, Decimal):
        return float(obj)
        
    raise TypeError(f"Object of type {type(obj).__name__} is not JSON serializable")

def build_crime_document(crime_dr_no, cursor):
    main_query = """
        SELECT
            c.DR_NO, c.Date_Rptd, c.DATE_OCC, c.TIME_OCC,
            s.Status AS status_code, s.Status_Desc AS status_description,
            v.Vict_Age, v.Vict_Sex, v.Vict_Descent,
            l.LOCATION AS location_address, l.AREA_NAME AS location_area_name,
            l.LAT AS location_lat, l.LON AS location_lon,
            lt.Location_Type_Cd AS location_type_code, lt.Location_Type_Desc AS location_type_description,
            w.Weapon_Used_Cd AS weapon_code, w.Weapon_Desc AS weapon_description
        FROM CRIME c
        LEFT JOIN STATUS s ON c.Status_FK = s.Status
        LEFT JOIN VICTIM v ON c.DR_NO = v.DR_NO
        LEFT JOIN CRIME_LOCATION cl ON c.DR_NO = cl.DR_NO_FK
        LEFT JOIN LOCATION l ON cl.Location_ID_FK = l.Location_ID
        LEFT JOIN LOCATION_TYPE lt ON c.Location_Type_Cd_FK = lt.Location_Type_Cd
        LEFT JOIN WEAPON w ON c.Weapon_Used_Cd_FK = w.Weapon_Used_Cd
        WHERE c.DR_NO = %s
    """
    cursor.execute(main_query, (crime_dr_no,))
    main_data = cursor.fetchone()

    if not main_data:
        return None

    crime_codes_query = "SELECT ct.Crm_Cd, ct.Crm_Cd_Desc, ct.Part_1_2 FROM CRIME_CODE cc JOIN CRIME_TYPE ct ON cc.Crm_Cd_FK = ct.Crm_Cd WHERE cc.DR_NO_FK = %s"
    cursor.execute(crime_codes_query, (crime_dr_no,))
    crime_codes = cursor.fetchall()

    mo_codes_query = "SELECT mo.MO_Code, mo.MO_Desc FROM CRIME_MOCODE cmo JOIN MODUS_OPERANDI mo ON cmo.MO_Code_FK = mo.MO_Code WHERE cmo.DR_NO_FK = %s"
    cursor.execute(mo_codes_query, (crime_dr_no,))
    mo_codes = cursor.fetchall()

    document = {
        "type": "crime", "dr_no": main_data['DR_NO'], "date_reported": main_data['Date_Rptd'],
        "date_occurred": main_data['DATE_OCC'], "time_occurred": main_data['TIME_OCC'],
        "status": {"code": main_data['status_code'], "description": main_data['status_description']},
        "victim": {"age": main_data['Vict_Age'], "sex": main_data['Vict_Sex'], "descent": main_data['Vict_Descent']},
        "location": {
            "address": main_data['location_address'], "area_name": main_data['location_area_name'],
            "coordinates": {"lat": main_data['location_lat'], "lon": main_data['location_lon']},
            "type": {"code": main_data['location_type_code'], "description": main_data['location_type_description']}
        },
        "weapon": {"code": main_data['weapon_code'], "description": main_data['weapon_description']},
        "crime_codes": [{"code": row['Crm_Cd'], "description": row['Crm_Cd_Desc'], "part": row['Part_1_2']} for row in crime_codes],
        "modus_operandi": [{"code": row['MO_Code'], "description": row['MO_Desc']} for row in mo_codes]
    }

    return json.loads(json.dumps(document, default=format_db_object))

def main():
    mysql_conn = None
    couchbase_cluster = None
    try:
        print("Conectando ao MySQL...")
        mysql_conn = mysql.connector.connect(**CONFIG['mysql'])
        cursor = mysql_conn.cursor(dictionary=True)
        print("Conexão com MySQL bem-sucedida.")

        print("Conectando ao Couchbase...")
        auth = PasswordAuthenticator(CONFIG['couchbase']['username'], CONFIG['couchbase']['password'])

        from couchbase.options import ClusterTimeoutOptions
        
        timeout_options = ClusterTimeoutOptions(kv_timeout=timedelta(seconds=20))

        couchbase_cluster = Cluster(
            CONFIG['couchbase']['connection_string'],
            ClusterOptions(auth, timeout_options=timeout_options)
        )

        couchbase_cluster.wait_until_ready(timedelta(seconds=5))
        bucket = couchbase_cluster.bucket(CONFIG['couchbase']['bucket_name'])
        scope = bucket.scope(CONFIG['couchbase']['scope_name'])
        collection = scope.collection(CONFIG['couchbase']['collection_name'])
        print("Conexão com Couchbase bem-sucedida.")

        print("\nBuscando todos os registros de crimes (DR_NOs)...")
        cursor.execute("SELECT DR_NO FROM CRIME")
        all_crime_drs = cursor.fetchall()

        total_crimes = len(all_crime_drs)
        print(f"Total de {total_crimes} crimes encontrados. Iniciando a migração...")

        for i, row in enumerate(all_crime_drs):
            crime_dr_no = row['DR_NO']
            document = build_crime_document(crime_dr_no, cursor)
            if document:
                doc_key = f"crime::{crime_dr_no}"
                collection.upsert(doc_key, document)
                print(f"({i+1}/{total_crimes}) Migrado crime DR_NO: {crime_dr_no}", end="\r")

        print(f"\n\nMigração concluída com sucesso! {total_crimes} documentos migrados.")

    except mysql.connector.Error as err:
        print(f"\nErro de MySQL: {err}")
    except CouchbaseException as err:
        print(f"\nErro de Couchbase: {err}")
    except Exception as err:
        print(f"\nUm erro inesperado ocorreu: {err}")
    finally:
        if mysql_conn and mysql_conn.is_connected():
            mysql_conn.close()
            print("Conexão com MySQL fechada.")
        if couchbase_cluster:
            couchbase_cluster.close()
            print("Conexão com Couchbase fechada.")

if __name__ == "__main__":
    main()
    
