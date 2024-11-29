from fastapi import FastAPI
from typing import List
from gmaps import Maps, Cords
from user_route import UserRouteModel
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

@app.get('/navigation/start_latitude={start_lat}&start_longitude={start_lng}&destination_latitude={dest_lat}&destination_longitude={dest_lng}')
def getRoute(start_lat:str, start_lng:str, dest_lat:str, dest_lng:str):
    start = Cords((float(start_lat), float(start_lng)))
    dest = Cords((float(dest_lat), float(dest_lng)))
    return {"route": Maps.CreateRoute(start, dest, 'walking')}

@app.get('/closest/start_latitude={lat}&start_longitude={lng}')
def getClosest(lat: str, lng:str):
    try:
        cords = Cords((float(lat), float(lng)))
        result = getClosestStation(cords)
        return{"id": result[0], "name": result[1], "cords": {"lat": result[2], "lng": result[3]}}
    except:  # noqa: E722
        return 500
    
@app.get('/routes/time={time}&start_latitude={lat}&start_longitude={lng}&destination={dest}')
def getRoutesStartCords(time: str, lat: str, lng:str, dest:str):
    try:
        start_cords = Cords((float(lat), float(lng)))
        start_result = getClosestStation(start_cords)
        dest_result = getClosestStation(Maps.ConvertAddressToCords(dest))
        
        #IMPLEMENT SPF ALGORITHM
    except:  # noqa: E722
        return 500

@app.get('/routes/time={time}&start={start}&destination={dest}')
def getRoutesStartNoCords(time: str, start: str, dest:str):
    try:
        start_result = getClosestStation(Maps.ConvertAddressToCords(start))
        dest_result = getClosestStation(Maps.ConvertAddressToCords(dest))
        
        return Maps.CreateRoute(Cords((start_result[2], start_result[3])), Cords((dest_result[2], dest_result[3])), 'transit')
        
        #IMPLEMENT SPF ALGORITHM
        
        
    except:  # noqa: E722
        return 500
    
@app.post('/user/route')
def postUserRoute(routes: List[UserRouteModel]):
    """
    input json structure:{
        "trips:"[
            {
                "trip_id": str,
                "start_stop_id": str,
                "end_stop_id": str,
            },
            ...
        ]
    }
    """
    pass

@app.get('/trip/nextstopsstate/trip={trip}&curr_stop={stop}')
def getNextStopsState(trip: str, stop: str):
    pass