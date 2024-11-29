import googlemaps
import requests
import time
#from config import gmapsapikey #fill
gmapsapikey = 'AIzaSyBYFgfjnBJ1iPgmWEW5XiJDxbGEyfl_jxQ'

gmaps = googlemaps.Client(gmapsapikey)

class Cords(tuple[float, float]):
    def __getattribute__(self, name: str):
        if name == 'lat':
            return self[0]
        elif name == 'lng':
            return self[1]
        if name == 'tuple':
            return (self.lat, self.lng)
        return super().__getattribute__(name)
class Maps:
    def ConvertAddressToCords(addres: str) -> Cords:
        gmaps = googlemaps.Client(gmapsapikey)
        response = gmaps.geocode(addres)[0]
        return Cords((response['geometry']['location']['lat'], response['geometry']['location']['lng']))

    def CreateRoute(start:Cords, dest:Cords, travelmode: str):
        return f"https://www.google.com/maps/dir/?api=1&origin={start.lat},{start.lng}&destination={dest.lat},{dest.lng}&travelmode={travelmode}"

    def GetRoute(start:Cords, dest:Cords, departure_time: str):
        t = int(time.mktime(time.strptime(departure_time, "%d. %m. %Y %H:%M")) + 3600)
        res = requests.get(f"https://maps.googleapis.com/maps/api/directions/json?destination={dest.lat},{dest.lng}&origin={start.lat},{start.lng}&mode=transit&departure_time={t}&key={gmapsapikey}")
        routes = []
        [routes.append(x['transit_details']) if 'transit_details' in x.keys() else None for x in res.json()['routes'][0]['legs'][0]['steps']]
        return routes

