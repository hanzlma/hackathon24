import sqlite3

class DB:
    def __init__(self):
        self.conn = sqlite3.connect('../db.sqlite3')
    def __del__(self):
        self.conn.close()
    def checkLine(self,line):
        res = self.conn.execute("select * from main.routes where id ==?",(line,))
        if (res.fetchall()):
            return True
        return False

    def getLineID(self,id):
        res = self.conn.execute("select * from main.routes where name ==?",(id,))
        try:
            toRet = res.fetchone()[0]
        except TypeError:
            toRet = None
        return toRet

    def getStopFromLine(self,lineID,dirr,stop):
        res = self.conn.execute("select * from main.route_stops where route_id == ? and direction == ? and stop_sequence == ?",(lineID,dirr,stop))
        try:
            toRet = res.fetchone()[1]
        except TypeError:
            toRet = None
        return toRet

    def getStopName(self,stopID):
        res = self.conn.execute(f"select * from main.stops where id == ?",(stopID,))
        return res.fetchone()[2]
if __name__ == "__main__":
    db = DB()
    print(db.checkLine(1))