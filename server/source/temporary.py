import pymysql.cursors
import heapq
from collections import defaultdict

def getConnection():
    connection = pymysql.connect(host='34.118.68.104',
                                 user='root',
                                 password='hackathon',
                                 db='hackathon',
                                 charset='utf8mb4',
                                 cursorclass=pymysql.cursors.DictCursor)
    return connection

def getStationGroups():
    connection = getConnection()
    dict = {}
    with connection:
        with connection.cursor() as cursor:
            sql = "SELECT uniqueName, stop_id FROM hackathon.stop_groups;"
            cursor.execute(sql)
            result = cursor.fetchall()
            for row in result:
                if row['uniqueName'] not in dict:
                    dict[row['uniqueName']] = []
                dict[row['uniqueName']].append(row['stop_id'])
    return dict

def getTripFrom(from_id, arrival_time):
    connection = getConnection()
    with connection:
        with connection.cursor() as cursor:
            sql = "SELECT * FROM (SELECT trip_id, arrival_time, departure_time, stop_id, TIMESTAMPDIFF(MINUTE, STR_TO_DATE(%s, '%%H:%%i:%%s'), STR_TO_DATE(arrival_time, '%%H:%%i:%%s')) AS span FROM hackathon.stop_times) AS subquery WHERE span > 1 AND stop_id = %s ORDER BY span;"
            cursor.execute(sql, (arrival_time, from_id))
            result = cursor.fetchall()
            return result[0]

def getAllNodes(current_time):
    connection = getConnection()
    with connection:
        with connection.cursor() as cursor:
            sql = "SELECT * FROM (SELECT trip_id, arrival_time, departure_time, stop_id, aws_id, TIMESTAMPDIFF(MINUTE, STR_TO_DATE(%s, '%%H:%%i:%%s'), STR_TO_DATE(arrival_time, '%%H:%%i:%%s')) AS span FROM hackathon.stop_times INNER JOIN hackathon.stops ON hackathon.stop_times.stop_id = hackathon.stops.id) AS subquery WHERE span > 1;"
            cursor.execute(sql, (current_time))
            result = cursor.fetchall()
            return result

def build_graph(data, groups):
    graph = defaultdict(list)
    stop_to_group = defaultdict(list)
    
    # Map aws_id to their groups for quick lookup
    aws_to_group = {}
    for group_name, aws_ids in groups.items():
        for aws_id in aws_ids:
            aws_to_group[aws_id] = group_name
    
    # Build the graph from the database data
    for row in data:
        trip_id = row['trip_id']
        stop_id = row['stop_id']
        arrival_time = row['arrival_time']
        departure_time = row['departure_time']
        aws_id = row['aws_id']
        
        # Add edges for stops in the same group
        if aws_id and aws_id in aws_to_group:
            group_name = aws_to_group[aws_id]
            stop_to_group[group_name].append((stop_id, trip_id))
        
        # Add edges for same stop, different trips
        for other_row in data:
            if other_row['stop_id'] == stop_id and other_row['trip_id'] != trip_id:
                graph[(stop_id, trip_id)].append((stop_id, other_row['trip_id']))
    
    # Add edges for stops within the same group
    for group_name, stops in stop_to_group.items():
        for i, (stop1, trip1) in enumerate(stops):
            for j, (stop2, trip2) in enumerate(stops):
                if i != j:
                    graph[(stop1, trip1)].append((stop2, trip2))
    
    return graph

def find_possible_end_nodes(data, stop_id, aws_id, groups):
    possible_end_nodes = []
    if aws_id:  # If aws_id is provided, match within the group
        for row in data:
            if row['stop_id'] == stop_id and row['aws_id'] == aws_id:
                possible_end_nodes.append((row['stop_id'], row['trip_id']))
    else:  # If no aws_id, match only on stop_id
        for row in data:
            if row['stop_id'] == stop_id:
                possible_end_nodes.append((row['stop_id'], row['trip_id']))
    return possible_end_nodes

def dijkstra(graph, start, possible_ends):
    # Priority queue for Dijkstra's algorithm
    queue = [(0, start)]  # (cost, node)
    distances = {start: 0}
    previous_nodes = {start: None}
    visited = set()
    
    while queue:
        current_distance, current_node = heapq.heappop(queue)
        
        # Stop if we reach any of the possible end nodes
        if current_node in possible_ends:
            path = []
            node = current_node
            while node:
                path.append(node)
                node = previous_nodes[node]
            return path[::-1]  # Return reversed path
        
        if current_node in visited:
            continue
        visited.add(current_node)
        
        for neighbor in graph[current_node]:
            distance = current_distance + 1  # Each edge has equal weight
            if neighbor not in distances or distance < distances[neighbor]:
                distances[neighbor] = distance
                previous_nodes[neighbor] = current_node
                heapq.heappush(queue, (distance, neighbor))
    
    return None  # No path found


def getPossibleEnds(stop_id):
    connection = getConnection()
    with connection:
        with connection.cursor() as cursor:
            sql = "SELECT trip_id, arrival_time, departure_time, stop_id, aws_id FROM hackathon.stop_times INNER JOIN hackathon.stops ON hackathon.stop_times.stop_id = hackathon.stops.id WHERE stop_id = %s;"
            cursor.execute(sql, (stop_id))
            result = cursor.fetchall()
            return result

def spfAlgorithm(start_node, end_node, start_time):
    print("Getting all nodes")
    nodes = getAllNodes(start_time)
    print("Getting trip from")
    start = getTripFrom(start_node, start_time)
    print("Getting possible ends")
    ends = getPossibleEnds(end_node)

    print("Building graph")
    graph = build_graph(nodes, getStationGroups())
    print("Running dijkstra")
    paths = dijkstra(graph, (start['stop_id'], start['trip_id']), (ends, None))
    return paths


spfAlgorithm('U15Z1P','U521Z1P','7:14:00')