import sqlite3

class DB:
    def __init__(self):
        self.conn = sqlite3.connect('../db.sqlite3')
    def __del__(self):
        self.conn.close()
    def checkLine(self,line):
        res = self.conn.execute(f"select * from main.routes where id =={line}")
        if (res.fetchall()):
            return True
        return False

if __name__ == "__main__":
    db = DB()
    print(db.checkLine(1))