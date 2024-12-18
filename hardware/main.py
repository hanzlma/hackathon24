from dep.keypad import Keypad,rpi_gpio
from dep.db import DB
from dep.lcd import lcd
from dep.api import api
from time import sleep
from unidecode import unidecode

lcd = lcd()
db = DB()
keypad = Keypad()
api = api()

def enterRoute():
    lcd.clear()
    lcd.display("zadej linku:",1,"center")
    user= ""
    while True:
        lcd.display(user, 2, "center")
        key = keypad.getKey()
        print(key)
        if key =="D":
            user+="S"
            continue
        if key == "*":
            user = ""
            lcd.display("        ", 2, "center")
            continue
        if key == "#":
            break
        user += str(key)
    return user

def enterTrip():
    lcd.display("zadej trip:", 3, "center")
    user = ""
    while True:
        lcd.display(user, 4, "center")
        key = keypad.getKey()
        print(key)
        if key == "A":
            user += "_"
            continue
        if key == "*":
            if user == "":
                return "",False
            user = ""
            lcd.display("        ", 4, "center")
            continue
        if key == "#":
            break
        user += str(key)
    return user,True

def getLineAndDir(line):
    dir = 0 if line[-1]=="A" else 1
    return line[:-1],dir

def processTrip(trip,line):
    return line+"_"+trip


if __name__ == "__main__":
    try:
        normalend = 0
        while True:
            if normalend == 0:
                linka = enterRoute()
                try:
                    if not (linka[-1] in ["A","B"]):
                        continue
                except IndexError:
                    continue
                line , direction = getLineAndDir(linka)
            else:
                if(direction == 0):
                    direction = 1
                    linka = line+"B"
                else:
                    direction = 2
                    linka = line + "A"
                normalend = 0
                lcd.display("linka :" + linka,1)
            print(linka)
            trip,success = enterTrip()
            if not success:
                continue
            print(line,direction)
            trip = processTrip(trip,line)
            print(trip)
            lineID = db.getLineID(line)
            if not lineID:
                continue

            stopCount = 1
            requested_stops= []
            while True:
                stopID = db.getStopFromLine(lineID,direction,stopCount)
                if not stopID:
                    normalend = 1
                    break
                print(stopID)
                requested_stops = api.getStops(trip,stopID,stopCount-1)
                stop,zone = db.getStopName(stopID)
                if not zone:
                    zone =0
                print(stop)
                lcd.display("linka :" + linka+"  zona:"+zone, 1, )
                print(requested_stops)
                print()
                lcd.setNext(unidecode(stop),True if stopID in requested_stops else False)
                if keypad.getKey()=="*":
                    break
                stopCount += 1
    except KeyboardInterrupt:
        rpi_gpio.GPIO.cleanup()
        exit(0)