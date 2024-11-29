import pymysql.cursors
from google.cloud.sql.connector import Connector
from config import db_connection_name, db_pwd
from gmaps import Cords

def getConnection() -> pymysql.connections.Connection:
    return Connector().connect(
        db_connection_name,
        "pymysql",
        user="root",
        password=db_pwd,
        db="hackathon"
    )
    
def getClosestStation(cords: Cords):
    connection = getConnection()
    with connection:
        with connection.cursor() as cursor:
            sql = "SELECT id, name, latitude, longitude FROM hackathon.stops ORDER BY (latitude - %s) * (latitude - %s) + (longitude - %s) * (longitude - %s) LIMIT 3;"
            cursor.execute(sql, (cords.lat, cords.lat, cords.lng, cords.lng))
            result = cursor.fetchall()
            return result
        
def getPath(start: str, end:str):
    connection = getConnection()
    with connection:
        with connection.cursor() as cursor:
            sql = "SELECT * FROM routes WHERE start_id = %s AND end_id = %s"
            cursor.execute(sql, (start['node_id'], end['node_id']))
            result = cursor.fetchall()
            return result
