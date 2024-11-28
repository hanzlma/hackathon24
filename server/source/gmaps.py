import googlemaps

from config import gmapsapikey #fill

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

    def CreateRoute(start:Cords, dest:Cords):
        return f"https://www.google.com/maps/dir/?api=1&origin={start.lat},{start.lng}&destination={dest.lat},{dest.lng}&travelmode=walking"
