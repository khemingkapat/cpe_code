using DataFrames

df = DataFrame(
    Turning=["Left", "Right", "No", "Left", "Left", "No", "Left", "No", "Left", "No", "Right", "Right", "Left", "Right", "No", "Left", "No", "Right", "No", "No"],
    CarAheadMoving=["No", "No", "No", "No", "No", "Yes", "Yes", "Yes", "Yes", "Yes", "Yes", "Yes", "No", "No", "No", "Yes", "Yes", "Yes", "Yes", "Yes"],
    OncomingTraffic=["No", "No", "Yes", "Yes", "Yes", "No", "No", "Yes", "Yes", "Yes", "Yes", "Yes", "No", "No", "Yes", "No", "No", "Yes", "Yes", "Yes"],
    IntersectionBlocked=["No", "No", "No", "No", "No", "Yes", "No", "No", "No", "No", "No", "Yes", "No", "No", "No", "No", "No", "No", "No", "No"],
    CrossTraffic=["Yes", "No", "Yes", "No", "No", "No", "No", "No", "No", "Yes", "No", "Yes", "No", "No", "No", "No", "No", "No", "Yes", "No"],
    FrontOfQueue=["Yes", "Yes", "No", "No", "Yes", "Yes", "Yes", "No", "Yes", "Yes", "Yes", "Yes", "Yes", "Yes", "Yes", "Yes", "Yes", "Yes", "No", "No"],
    Cyclist=["No", "Yes", "No", "Yes", "Yes", "No", "Yes", "No", "Yes", "Yes", "Yes", "Yes", "No", "No", "No", "Yes", "Yes", "No", "No", "Yes"],
    Pedestrians=["Yes", "No", "Yes", "No", "No", "No", "Yes", "Yes", "No", "No", "No", "Yes", "No", "No", "No", "No", "No", "No", "Yes", "No"],
    MoveTheCar=["No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "No", "Yes", "Yes", "Yes", "Yes", "Yes", "Yes", "Yes", "Yes"]
)

