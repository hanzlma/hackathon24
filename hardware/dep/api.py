import requests

class api:
    def __init__(self,url ="https://server-gedu3pbu3q-lm.a.run.app/" ):
        self.url = url

    def getStops(self,trip,station,sequence):
        print("aaaaaaa")
        resp = requests.get(self.url+f"trip/nextstopsstate/trip={trip}&curr_stop={station}&seq={sequence}")
        print(resp.url)
        if not resp.json():
            return []
        print(resp.json()[0])
        return resp.json()[0]
