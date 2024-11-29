from pydantic import BaseModel


class UserRouteModel(BaseModel):
    line: str
    start_lat: str
    start_lng: str
    dest_lat: str
    dest_lng: str
