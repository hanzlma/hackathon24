import pymysql.cursors
from google.cloud.sql.connector import Connector
from config import db_connection_name, db_pwd
from gmaps import Cords
from user_route import UserRouteModel
from typing import List
from datetime import datetime

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
        routes.append(Route(step['departure_stop'], step['arrival_stop'], step['departure_time'], step['arrival_time'], step['line']['short_name']))
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

def setUserTrip(routes: List[UserRouteModel]):
    connection = getConnection()
    with connection:
        with connection.cursor() as cursor:
            for route in routes:
                sql = "SELECT id FROM stops WHERE latitude IN (%s, %s) AND longitude IN (%s, %s)"
                start = getClosestStation(Cords((route.start_lat, route.start_lng)))[0]
                dest = getClosestStation(Cords((route.dest_lat, route.dest_lng)))[0]
                cursor.execute(sql, (start[2], dest[2], start[3], dest[3]))
                stops = cursor.fetchall()
                start_stop = stops[0][0]
                dest_stop = stops[1][0]
                sql = "SELECT * FROM hackathon.trips INNER JOIN (SELECT id FROM hackathon.routes WHERE name = %s) AS s ON s.id = route_id;"
                cursor.execute(sql, route.line)
                trip_id = cursor.fetchall()[0][0]
                date = datetime.now().date().isoformat()
                sql = "INSERT INTO user_trips (trip_id, start_id, dest_id, date) VALUES (%s, %s, %s, %s)"
                cursor.execute(sql, (trip_id, start_stop, dest_stop, date))
                connection.commit()
                
def nextStopsState(trip: str, stop: str, seq: int):
    connection = getConnection()
    with connection:
        with connection.cursor() as cursor:
            ret_stops = []
            stops = []
            for i in range(3):
                sql = 'SELECT stop_id FROM hackathon.stop_times WHERE trip_id = %s AND stop_sequence = %s;'
                cursor.execute(sql, (trip, seq + i))
                stops.append(cursor.fetchall()[0])
            for stop in stops:
                sql = 'SELECT * FROM hackathon.user_trips WHERE trip_id = %s AND %s IN (dest_id, start_id);'
                if len(cursor.execute(sql, (trip, stop))) > 0:
                    ret_stops.append(stop)
            return ret_stops
