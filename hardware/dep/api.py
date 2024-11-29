import requests

class api:
    def __init__(self,url ="https://server-gedu3pbu3q-lm.a.run.app/" ):
        self.url = url

    def getStops(self,trip,station):
        resp = requests.get(self.url+f"trip/nextstopsstate/trip={trip}&curr_stop={station}")
        return resp.json()
