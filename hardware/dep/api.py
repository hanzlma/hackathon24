import requests

class api:
    def __init__(self,url ="https://server-gedu3pbu3q-lm.a.run.app/" ):
        self.url = url

    def getStops(self,trip,station,sequence):
        resp = requests.get(self.url+f"trip/nextstopsstate/trip={trip}&curr_stop={station}")
        if not resp.json():
            return []
        return resp.json()
