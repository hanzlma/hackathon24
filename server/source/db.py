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
    
class Route:
    def __init__(self, start, end, start_t, end_t, short_name):
        self.start = start
        self.end = end
        self.start_t = start_t
        self.end_t = end_t
        self.short_name = short_name


def parse_json(json):
    routes = []
    for step in json:
        routes.append(Route(step['departure_stop']['name'], step['arrival_stop']['name'], step['departure_time'], step['arrival_time'], step['line']['short_name']))
    return routes

def getClosestStation(cords: Cords):
    connection = getConnection()
    with connection:
        with connection.cursor() as cursor:
            sql = "SELECT id, name, latitude, longitude FROM hackathon.stops ORDER BY (latitude - %s) * (latitude - %s) + (longitude - %s) * (longitude - %s) LIMIT 1;"
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
