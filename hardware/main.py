from dep.keypad import Keypad
from dep.db import DB
from dep.lcd import lcd
from time import sleep

lcd = lcd()
db = DB()
keypad = Keypad()

def enterRoute():
    lcd.clear()
    lcd.display("zadej linku:",1,"center")
    user= ""
    while True:
        key = keypad.getKey()
        print(key)
        if key == "*":
            user = ""
            lcd.display("        ", 2, "center")
            continue
        if key == "#":
            break
        user += str(key)
        lcd.display(user,2,"center")
    return user

if __name__ == "__main__":
    user = enterRoute()
    lcd.display("linka "+user,1,"center")
    lcd.setNext("chodov",True)
    sleep(500)