from requests import get
from zipfile import ZipFile
import io
from os import path, listdir, unlink, makedirs
from shutil import rmtree
from pandas import read_csv, read_json
import mysql.connector
from atexit import register

folder_path = './data/'
zip_url = 'https://data.pid.cz/PID_GTFS.zip'
json_url = 'https://data.pid.cz/stops/json/stops.json'

stops_path = folder_path + 'stops.txt'
routes_path = folder_path + 'routes.txt'
route_stops_path = folder_path + 'route_stops.txt'
stop_times_path = folder_path + 'stop_times.txt'
trips_path = folder_path + 'trips.txt'
transfers_path = folder_path + 'transfers.txt'

stops_index = 0; routes_index = 1; route_stops_index = 2; stop_times_index = 3; trips_index = 4; transfers_index = 5

file_paths = [stops_path, routes_path, route_stops_path, stop_times_path, trips_path, transfers_path]

config = {
    'user': 'root',
    'password': 'hackathon',
    'host': '34.118.68.104',
    'database': 'hackathon'
}

def clean_up():
    for filename in listdir(folder_path):
        file_path = path.join(folder_path, filename)
        try:
            if (path.isfile(file_path) or path.islink(file_path)):
                unlink(file_path)
            elif path.isdir(file_path):
                rmtree(file_path)
        except Exception as e:
            print('Failed to delete %s. Reason: %s' % (file_path, e))

def get_stops():
    try:
        data = read_csv(stops_path, usecols=['stop_id', 'stop_name', 'stop_lat', 'stop_lon', 'zone_id', 'wheelchair_boarding', 'platform_code', 'asw_node_id', 'asw_stop_id'])
        return data
    except FileNotFoundError:
        print(f"The file at {stops_path} was not found.")
        exit()
    except Exception as e:
        print(f"An error occurred: {e}")
        exit()

def get_routes():
    try:
        data = read_csv(routes_path, usecols=['route_id', 'route_short_name', 'route_type', 'is_night'])
        return data
    except FileNotFoundError:
        print(f"The file at {routes_path} was not found.")
        exit()
    except Exception as e:
        print(f"An error occurred: {e}")
        exit()

def get_route_stops():
    try:
        data = read_csv(route_stops_path, usecols=['route_id', 'stop_id', 'direction_id', 'stop_sequence'])
        return data
    except FileNotFoundError:
        print(f"The file at {route_stops_path} was not found.")
        exit()
    except Exception as e:
        print(f"An error occurred: {e}")
        exit()

def get_stop_times():
    try:
        data = read_csv(stop_times_path, usecols=['trip_id', 'arrival_time', 'departure_time', 'stop_id', 'stop_sequence', 'pickup_type', 'drop_off_type', 'trip_operation_type', 'bikes_allowed'])
        return data
    except FileNotFoundError:
        print(f"The file at {stop_times_path} was not found.")
        exit()
    except Exception as e:
        print(f"An error occurred: {e}")
        exit()

def get_trips():
    try:
        data = read_csv(trips_path, usecols=['trip_id', 'route_id', 'block_id', 'shape_id'])
        return data
    except FileNotFoundError:
        print(f"The file at {trips_path} was not found.")
        exit()
    except Exception as e:
        print(f"An error occurred: {e}")
        exit()

def get_transfers():
    try:
        data = read_csv(transfers_path, usecols=['from_stop_id', 'to_stop_id', 'transfer_type', 'min_transfer_time', 'max_waiting_time', 'from_trip_id', 'to_trip_id'])
        return data
    except FileNotFoundError:
        print(f"The file at {transfers_path} was not found.")
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
                        aws_id VARCHAR(255),
                        aws_part_id VARCHAR(255),
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
    cursor_obj.execute('''CREATE TABLE IF NOT EXISTS stop_groups(
                        uniqueName VARCHAR(255),
                        stop_id VARCHAR(255),
                        PRIMARY KEY(uniqueName, stop_id)
                       );''')
    cursor_obj.execute('''CREATE TABLE IF NOT EXISTS nodes(
                        node_id INTEGER,
                        stop_ids TEXT,
                        PRIMARY KEY(node_id)
                        );''')

def import_stops(dataframe):
    dataframe.fillna('', inplace=True)
    print('Importing stops...')
    cursor_obj.execute('DELETE FROM stops')
    cursor_obj.executemany('''INSERT INTO stops (id, name, latitude, longitude, zone_id, wheelchair, platform_code, aws_id, aws_part_id)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)''',
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

def import_stop_groups():
    print('Importing stop groups...')
    cursor_obj.execute('DELETE FROM stop_groups')
    json = read_json(json_url)
    group_data = []
    for grop in json['stopGroups']:
        uniqueName = grop['uniqueName']
        for stop in grop['stops']:
            group_data.append((uniqueName, stop['id']))
    cursor_obj.executemany('INSERT INTO stop_groups (uniqueName, stop_id) VALUES (%s, %s)', group_data)
    db.commit()

def get_valid_groups():
    print("Getting valid groups...")
    cursor_obj.execute("SELECT uniqueName, id FROM hackathon.stops INNER JOIN hackathon.stop_groups ON stop_id = CONCAT(LEFT(aws_id, LOCATE('.', aws_id) - 1), '/', LEFT(aws_part_id, LOCATE('.', aws_part_id) - 1)) WHERE zone_id IN ('P', 'B', '0');")
    result = cursor_obj.fetchall()
    return result

def create_nodes():
    print('Creating nodes...')
    cursor_obj.execute('DELETE FROM nodes')
    dict = {}
    row_counter = {}
    result = get_valid_groups()
    counter = 0
    for row in result:
        if row[0] not in row_counter:
            dict[counter] = []
            row_counter[row[0]] = counter
            counter += 1
        dict[row_counter[row[0]]].append(row[1])
    node_data = []
    for group_name, aws_ids in dict.items():
        aws_ids_data = ""
        for aws_id in aws_ids:
            aws_ids_data += aws_id + ","
        node_data.append((group_name, aws_ids_data))
    cursor_obj.executemany('INSERT INTO nodes (node_id, stop_ids) VALUES (%s, %s)', node_data)
    db.commit()
    

def prepare_database():
    global db
    db = mysql.connector.connect(**config)
    global cursor_obj
    cursor_obj = db.cursor()


def get_from_cords(coordinates):
    prepare_database()

    in_lat = "("
    in_lng = "("
    for coord in coordinates:
        in_lat += f"{coord.lat},"
        in_lng += f"{coord.lng},"
    in_lat = in_lat[:-1] + ")"
    in_lng = in_lng[:-1] + ")"
    
    cursor_obj.execute(f"SELECT * FROM stops WHERE latitude IN {in_lat} AND longitude IN {in_lng}")
    return cursor_obj.fetchall()





def update_database():
    register(clean_up)

    if not path.exists(folder_path):
        makedirs(folder_path)

    # Download the zip file
    r = get(zip_url)
    z = ZipFile(io.BytesIO(r.content))
    z.extractall(folder_path)

    # Load the extracted files
    dataframes = get_csvs(file_paths)
    
    prepare_database()

    # Import to database
    create_tables()

    print('Filling NaN values...')

    import_stops(dataframes[stops_index])
    import_routes(dataframes[routes_index])
    import_route_stops(dataframes[route_stops_index])
    import_stop_times(dataframes[stop_times_index])
    import_trips(dataframes[trips_index])
    import_transfers(dataframes[transfers_index])
    
    import_stop_groups()

    create_nodes()