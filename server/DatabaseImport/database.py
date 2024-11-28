import requests, zipfile, io
import os, shutil
import pandas as pd
import mysql.connector
import atexit

folder_path = './data/'
zip_url = 'https://data.pid.cz/PID_GTFS.zip'

stops_path = folder_path + 'stops.txt'
routes_path = folder_path + 'routes.txt'
route_stops_path = folder_path + 'route_stops.txt'
stop_times_path = folder_path + 'stop_times.txt'
trips_path = folder_path + 'trips.txt'
transfers_path = folder_path + 'transfers.txt'

stops_index = 0; routes_index = 1; route_stops_index = 2; stop_times_index = 3; trips_index = 4; transfers_index = 5

file_paths = [stops_path, routes_path, route_stops_path, stop_times_path, trips_path, transfers_path]

sqlite_path = '../db.sqlite3'

config = {
    'user': 'root',
    'password': 'hackathon',
    'host': '34.118.68.104',
    'database': 'hackathon'
}

def clean_up():
    for filename in os.listdir(folder_path):
        file_path = os.path.join(folder_path, filename)
        try:
            if (os.path.isfile(file_path) or os.path.islink(file_path)):
                os.unlink(file_path)
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
        except Exception as e:
            print('Failed to delete %s. Reason: %s' % (file_path, e))

def get_stops():
    try:
        data = pd.read_csv(stops_path, usecols=['stop_id', 'stop_name', 'stop_lat', 'stop_lon', 'zone_id', 'wheelchair_boarding', 'platform_code'])
        return data
    except FileNotFoundError:
        print(f"The file at {stops_path} was not found.")
        exit()
    except Exception as e:
        print(f"An error occurred: {e}")
        exit()

def get_routes():
    try:
        data = pd.read_csv(routes_path, usecols=['route_id', 'route_short_name', 'route_type', 'is_night'])
        return data
    except FileNotFoundError:
        print(f"The file at {stops_path} was not found.")
        exit()
    except Exception as e:
        print(f"An error occurred: {e}")
        exit()

def get_route_stops():
    try:
        data = pd.read_csv(route_stops_path, usecols=['route_id', 'stop_id', 'direction_id', 'stop_sequence'])
        return data
    except FileNotFoundError:
        print(f"The file at {stops_path} was not found.")
        exit()
    except Exception as e:
        print(f"An error occurred: {e}")
        exit()

def get_stop_times():
    try:
        data = pd.read_csv(stop_times_path, usecols=['trip_id', 'arrival_time', 'departure_time', 'stop_id', 'stop_sequence', 'pickup_type', 'drop_off_type', 'trip_operation_type', 'bikes_allowed'])
        return data
    except FileNotFoundError:
        print(f"The file at {stops_path} was not found.")
        exit()
    except Exception as e:
        print(f"An error occurred: {e}")
        exit()

def get_trips():
    try:
        data = pd.read_csv(trips_path, usecols=['trip_id', 'route_id', 'block_id', 'shape_id'])
        return data
    except FileNotFoundError:
        print(f"The file at {stops_path} was not found.")
        exit()
    except Exception as e:
        print(f"An error occurred: {e}")
        exit()

def get_transfers():
    try:
        data = pd.read_csv(transfers_path, usecols=['from_stop_id', 'to_stop_id', 'transfer_type', 'min_transfer_time', 'max_waiting_time', 'from_trip_id', 'to_trip_id'])
        return data
    except FileNotFoundError:
        print(f"The file at {stops_path} was not found.")
        exit()
    except Exception as e:
        print(f"An error occurred: {e}")
        exit()

def get_csvs(file_path):
    return [get_stops(), get_routes(), get_route_stops(), get_stop_times(), get_trips(), get_transfers()]

db = None
cursor_obj = None

def create_tables():
    print('Creating tables...')
    cursor_obj.execute('''CREATE TABLE IF NOT EXISTS routes (
                        id VARCHAR(255) PRIMARY KEY,
                        name VARCHAR(255),
                        type INTEGER,
                        is_night INTEGER
                       );''')
    cursor_obj.execute('''CREATE TABLE IF NOT EXISTS stops (
                        id VARCHAR(255) PRIMARY KEY,
                        name VARCHAR(255),
                        latitude DOUBLE,
                        longitude DOUBLE,
                        zone_id VARCHAR(255),
                        wheelchair TINYINT(1),
                        platform_code VARCHAR(255)
                       );''')
    cursor_obj.execute('''CREATE TABLE IF NOT EXISTS route_stops (
                        route_id VARCHAR(255),
                        stop_id VARCHAR(255),
                        direction INTEGER,
                        stop_sequence INTEGER,
                        PRIMARY KEY (route_id, stop_id, direction, stop_sequence)
                       );''')
    cursor_obj.execute('''CREATE TABLE IF NOT EXISTS stop_times (
                        trip_id VARCHAR(255),
                        arrival_time VARCHAR(255),
                        departure_time VARCHAR(255),
                        stop_id VARCHAR(255),
                        stop_sequence INTEGER,
                        pickup_type INTEGER,
                        drop_off_type INTEGER,
                        trip_operation_type INTEGER,
                        bikes_allowed TINYINT(1),
                        PRIMARY KEY (trip_id, stop_id, arrival_time)
                       );''')
    cursor_obj.execute('''CREATE TABLE IF NOT EXISTS trips (
                        id VARCHAR(255),
                        route_id VARCHAR(255),
                        block_id VARCHAR(255),
                        shape_id VARCHAR(255),
                        PRIMARY KEY(id, block_id)
                       );''')
    cursor_obj.execute('''CREATE TABLE IF NOT EXISTS transfers (
                        from_stop_id VARCHAR(255),
                        to_stop_id VARCHAR(255),
                        transfer_type INTEGER,
                        min_transfer_time INTEGER,
                        max_waiting_time INTEGER,
                        from_trip_id VARCHAR(255),
                        to_trip_id VARCHAR(255),
                        PRIMARY KEY (from_stop_id, from_trip_id, to_trip_id)
                       );''')

def import_stops(dataframe):
    dataframe.fillna('', inplace=True)
    print('Importing stops...')
    cursor_obj.execute('DELETE FROM stops')
    cursor_obj.executemany('''INSERT INTO stops (id, name, latitude, longitude, zone_id, wheelchair, platform_code)
                        VALUES (%s, %s, %s, %s, %s, %s, %s)''',
                        dataframe.values.tolist())
    db.commit()

def import_routes(dataframe):
    dataframe.fillna('', inplace=True)
    print('Importing routes...')
    cursor_obj.execute('DELETE FROM routes')
    cursor_obj.executemany('''INSERT INTO routes (id, name, type, is_night)
                        VALUES (%s, %s, %s, %s)''',
                        dataframe.values.tolist())
    db.commit()

def import_route_stops(dataframe):
    dataframe.fillna('', inplace=True)
    print('Importing route stops...')
    cursor_obj.execute('DELETE FROM route_stops')
    cursor_obj.executemany('''INSERT INTO route_stops (route_id, direction, stop_id, stop_sequence)
                        VALUES (%s, %s, %s, %s)''',
                        dataframe.values.tolist())
    db.commit()

def import_stop_times(dataframe):
    dataframe.fillna('', inplace=True)
    print('Importing stop times...')
    cursor_obj.execute('DELETE FROM stop_times')
    part_len = len(dataframe) // 10
    for i in range(9):
        part_df = dataframe.iloc[part_len * i:part_len * (i + 1)]
        cursor_obj.executemany('''INSERT INTO stop_times (trip_id, arrival_time, departure_time, stop_id, stop_sequence, pickup_type, drop_off_type, trip_operation_type, bikes_allowed)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)''',
                        part_df.values.tolist())
    part_df = dataframe.iloc[part_len * 9:]
    cursor_obj.executemany('''INSERT INTO stop_times (trip_id, arrival_time, departure_time, stop_id, stop_sequence, pickup_type, drop_off_type, trip_operation_type, bikes_allowed)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)''',
                        part_df.values.tolist())
    db.commit()

def import_trips(dataframe):
    dataframe.fillna('', inplace=True)
    print('Importing trips...')
    cursor_obj.execute('DELETE FROM trips')
    cursor_obj.executemany('''INSERT INTO trips (route_id, id, block_id, shape_id)
                        VALUES (%s, %s, %s, %s)''',
                        dataframe.values.tolist())
    db.commit()

def import_transfers(dataframe):
    dataframe.fillna(0, inplace=True)
    print('Importing transfers...')
    cursor_obj.execute('DELETE FROM transfers')
    cursor_obj.executemany('''INSERT INTO transfers (from_stop_id, to_stop_id, transfer_type, min_transfer_time, from_trip_id, to_trip_id, max_waiting_time)
                                VALUES (%s, %s, %s, %s, %s, %s, %s)''',
                                dataframe.values.tolist())
    db.commit()

if __name__ == '__main__':
    atexit.register(clean_up)

    # Download the zip file
    r = requests.get(zip_url)
    z = zipfile.ZipFile(io.BytesIO(r.content))
    z.extractall(folder_path)

    # Load the extracted files
    dataframes = get_csvs(file_paths)

    db = mysql.connector.connect(**config)
    cursor_obj = db.cursor()

    # Import to database
    create_tables()

    print('Filling NaN values...')

    import_stops(dataframes[stops_index])
    import_routes(dataframes[routes_index])
    import_route_stops(dataframes[route_stops_index])
    import_stop_times(dataframes[stop_times_index])
    import_trips(dataframes[trips_index])
    import_transfers(dataframes[transfers_index])