from rpi_lcd import LCD as ldcController
from time import sleep

class lcd:
    def __init__(self):
        self.lcd = ldcController()

    def __del__(self):
        self.lcd.clear()

    def display(self, text,line,pos='left'):
        self.lcd.text(text,line,pos)

    def setNext(self,stationName,stop):
        self.display(" pristi zastavka:",2,'center')
        self.display(stationName,3,'center')
        if stop:
            self.display("zastavime",4,'center')
        else:
            self.display("nezastavime",4,'center')

    def clear(self):
        self.lcd.clear()

if __name__ == "__main__":
    display = lcd()
    display.setNext("brno",False)
    sleep(10)