from db import getConnection

def getData():
    connection = getConnection()
    with connection:
        with connection.cursor() as cursor:
            sql_nodes = "SELECT * FROM hackathon.nodes"
            cursor.execute(sql_nodes)
            nodes = cursor.fetchall()
            sql_edges = "SELECT * FROM hackathon.edges"
            cursor.execute(sql_edges)
            edges = cursor.fetchall()
            return (nodes,edges)
class NodeGraph:
    def __init__(self, size) -> None:
        self.adj_matrix = [[0] * size for _ in range(size)]
        self.size = size
        self.vertex_data = [''] * size

    def add_vertex_data(self, vertex, data):
        if 0 <= vertex < self.size:
            self.vertex_data[vertex] = data

    def add_edge(self, a, b, weight):
        if 0 <= a < self.size and 0 <= b < self.size:
            self.adj_matrix[a][b] = weight
            self.adj_matrix[a][b] = weight
    
    def dijkstra(self, start_vertex_data):
        start_vertex = self.vertex_data.index(start_vertex_data)
        distances = [float('inf')] * self.size
        predecessors = [None] * self.size
        distances[start_vertex] = 0
        visited = [False] * self.size

        for _ in range(self.size):
            min_distance = float('inf')
            u = None
            for i in range(self.size):
                if not visited[i] and distances[i] < min_distance:
                    min_distance = distances[i]
                    u = i

            if u is None:
                break

            visited[u] = True

            for v in range(self.size):
                if self.adj_matrix[u][v] != 0 and not visited[v]:
                    alt = distances[u] + self.adj_matrix[u][v]
                    if alt < distances[v]:
                        distances[v] = alt
                        predecessors[v] = u

        return distances, predecessors

    def get_path(self, predecessors, start_vertex, end_vertex):
        path = []
        current = self.vertex_data.index(end_vertex)
        while current is not None:
            path.insert(0, self.vertex_data[current])
            current = predecessors[current]
            if current == self.vertex_data.index(start_vertex):
                path.insert(0, start_vertex)
                break
        return path

class SpfDbRecord():
    startNode: str
    endNode: str
    path: str
    
    def __init__(self, startNode: str, endNode: str, path: list[str]) -> None:
        self.startNode = startNode
        self.endNode = endNode
        self.path = ','.join(path)
    
    def __str__(self) -> str:
        return f"<{self.startNode}, {self.endNode}, {self.path}>"
    
def FillShortestPathDB():
    (nodes,edges) = getData()
    print('data received')
    g = NodeGraph(len(nodes))
    nodes2=[]
    for i in range(len(nodes)):
        node = {"node_id": str(nodes[i][0]), "stop_ids": nodes[i][1].split(',')}
        nodes2.append(node.copy())
        g.add_vertex_data(i, node)
    print('vertices added')
    print(edges)
    for i in range(len(edges)):        
        g.add_edge(edges[i][1], edges[i][2], 1 if edges[i][1] != edges[i][1] else 0) #edges[1][3]
    print('edges added')
    output: list[SpfDbRecord] = []
    
    for node in nodes2:
        distances, predecessors = g.dijkstra(node)
        for i,d in enumerate(distances):
            path = g.get_path(predecessors, node, g.vertex_data[i])
            record = SpfDbRecord(node['node_id'], g.vertex_data[i]['node_id'], [node['node_id'] for node in path])
            if len(path)>1:
                print(record)
            output.append(record)


#FillShortestPathDB()

""" connection = getConnection()
with connection:
    with connection.cursor() as cursor:
        sql = "SELECT * FROM stops where latitude = 50.05324 and longitude = 14.29106"
        cursor.execute(sql)
        output = cursor.fetchall()
        print(output) """