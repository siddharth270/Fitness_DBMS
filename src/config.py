import os
import pymysql
from dotenv import load_dotenv

load_dotenv()  # Load variables from .env file

# Database Configuration
def get_db_connection():
    try:
        connection = pymysql.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            user=os.getenv('DB_USER', 'root'),
            password=os.getenv('DB_PASSWORD', 'your_password'), # CHANGE THIS or use .env
            database=os.getenv('DB_NAME', 'gym_management_db'),
            cursorclass=pymysql.cursors.DictCursor  # Important: Returns data as dictionaries!
        )
        return connection
    except pymysql.MySQLError as e:
        print(f"Error connecting to MySQL: {e}")
        return None