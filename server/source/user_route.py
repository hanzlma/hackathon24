from pydantic import BaseModel

class UserRouteModel(BaseModel):
    trip_id: str
    start_stop_id: str
    end_stop_id: str
