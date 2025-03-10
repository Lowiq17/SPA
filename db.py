import psycopg2
import psycopg2.extras

def connect():
  conn = psycopg2.connect(
    database = "postgres",
    host = "localhost",
    port = 5432,
    password = "161001",
    user = "postgres",
    cursor_factory = psycopg2.extras.NamedTupleCursor
  )
  conn.autocommit = True
  return conn
