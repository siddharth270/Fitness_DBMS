from django.core.management.base import BaseCommand
from accounts.models import Member, Trainer

class Command(BaseCommand):
    help = 'Lists existing users in the database'

    def handle(self, *args, **kwargs):
        self.stdout.write(self.style.SUCCESS('\n=== Existing Members ==='))
        members = Member.objects.all()
        if members:
            for m in members:
                self.stdout.write(f'  {m.email} - {m.name}')
        else:
            self.stdout.write('  No members found')
        
        self.stdout.write(self.style.SUCCESS('\n=== Existing Trainers ==='))
        trainers = Trainer.objects.all()
        if trainers:
            for t in trainers:
                self.stdout.write(f'  {t.email} - {t.name} ({t.specialization})')
        else:
            self.stdout.write('  No trainers found')
        
        self.stdout.write(self.style.SUCCESS('\nUse these emails with the passwords from your SQL file to log in.'))