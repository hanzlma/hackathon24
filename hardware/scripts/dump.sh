service hackathon stop
rm db.sqlite3
mysql2sqlite -f db.sqlite3 -d hackathon -t routes stops route_stops -u root --mysql-password hackathon -h 34.118.68.104
service hackathon start
