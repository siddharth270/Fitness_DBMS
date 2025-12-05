from django.core.management.base import BaseCommand
from django.core.management import call_command


class Command(BaseCommand):
    help = 'Run migrations, setup test data, and start the server'

    def handle(self, *args, **options):
        self.stdout.write(self.style.WARNING('Running migrations...'))
        call_command('migrate')
        
        self.stdout.write(self.style.WARNING('\nCreating test users...'))
        try:
            call_command('create_test_users')
        except Exception as e:
            self.stdout.write(self.style.NOTICE(f'Note: {e}'))
        
        self.stdout.write(self.style.WARNING('\nHashing passwords...'))
        try:
            call_command('hash_passwords')
        except Exception as e:
            self.stdout.write(self.style.NOTICE(f'Note: {e}'))
        
        self.stdout.write(self.style.SUCCESS('\n✅ Setup complete! Starting server...\n'))
        call_command('runserver')