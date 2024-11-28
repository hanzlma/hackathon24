from fastapi import FastAPI
from gmaps import Maps, Cords
from db import getClosestStation
app = FastAPI()

@app.get('/')
def read_root():
    return {"message" : "Test"}

@app.get('/location/{location}')
def getStation(location:str):
    """Converts location name to coordinates

    Args:
        location (str): user prompt of location

    Returns:
        JSON: _description_
    """
    cords: Cords = Maps.ConvertAddressToCords(location)
    return {"cords": {"latitude" : cords.lat, "longitude": cords.lng}}

@app.get('/route/start_latitude={start_lat}&start_longitude={start_lng}&destination_latitude={dest_lat}&destination_longitude={dest_lng}')
def getRoute(start_lat:str, start_lng:str, dest_lat:str, dest_lng:str):
    start = Cords((float(start_lat), float(start_lng)))
    dest = Cords((float(dest_lat), float(dest_lng)))
    return {"route": Maps.CreateRoute(start, dest)}

@app.get('/closest/latitude={start_lat}&longitude={start_lng}')
def getClosest(lat: str, lng:str):
    try:
        cords = Cords((float(lat), float(lng)))
        return getClosestStation(cords)
    except:  # noqa: E722
        return 500
    
