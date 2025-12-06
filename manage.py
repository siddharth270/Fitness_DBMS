#!/usr/bin/env python

import os
import sys
import getpass


def main():

    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'gym_project.settings')

    db_commands = ['runserver', 'migrate', 'start', 'create_test_users', 'hash_passwords']
    

    needs_credentials = any(cmd in sys.argv for cmd in db_commands)
    
    if needs_credentials and 'DB_USER' not in os.environ:
        username = input("Enter your database username: ")
        password = getpass.getpass("Enter your database password: ")
        os.environ['DB_USER'] = username
        os.environ['DB_PASSWORD'] = password
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)


if __name__ == '__main__':
    main()