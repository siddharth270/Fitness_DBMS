from django.core.management.base import BaseCommand
from accounts.models import Gym, Member, Trainer

class Command(BaseCommand):
    help = 'Creates test users for development'

    def handle(self, *args, **kwargs):
        # Create or get gym
        gym, created = Gym.objects.get_or_create(
            gym_name='FitZone Boston',
            defaults={
                'location': '123 Fitness St, Boston, MA',
                'contact_number': '617-555-0100',
                'email': 'info@fitzone.com'
            }
        )
        
        if created:
            self.stdout.write(self.style.SUCCESS(f'Created gym: {gym.gym_name}'))
        else:
            self.stdout.write(self.style.WARNING(f'Gym already exists: {gym.gym_name}'))
        
        # Create test members
        members_data = [
            {
                'name': 'John Doe',
                'email': 'john@example.com',
                'password': 'password123',
                'gender': 'Male',
                'height': 180.00,
                'weight': 75.00
            },
            {
                'name': 'Jane Smith',
                'email': 'jane@example.com',
                'password': 'password123',
                'gender': 'Female',
                'height': 165.00,
                'weight': 62.00
            }
        ]
        
        for member_data in members_data:
            email = member_data['email']
            if not Member.objects.filter(email=email).exists():
                member = Member(
                    gym=gym,
                    name=member_data['name'],
                    email=email,
                    gender=member_data['gender'],
                    height=member_data['height'],
                    weight=member_data['weight']
                )
                member.set_password(member_data['password'])
                member.save()
                self.stdout.write(self.style.SUCCESS(f'Created member: {member.name} ({email})'))
            else:
                self.stdout.write(self.style.WARNING(f'Member already exists: {email}'))
        
        # Create test trainers
        trainers_data = [
            {
                'name': 'Mike Johnson',
                'email': 'mike@example.com',
                'password': 'password123',
                'specialization': 'Strength Training'
            },
            {
                'name': 'Sarah Williams',
                'email': 'sarah@example.com',
                'password': 'password123',
                'specialization': 'Cardio & HIIT'
            }
        ]
        
        for trainer_data in trainers_data:
            email = trainer_data['email']
            if not Trainer.objects.filter(email=email).exists():
                trainer = Trainer(
                    gym=gym,
                    name=trainer_data['name'],
                    email=email,
                    specialization=trainer_data['specialization']
                )
                trainer.set_password(trainer_data['password'])
                trainer.save()
                self.stdout.write(self.style.SUCCESS(f'Created trainer: {trainer.name} ({email})'))
            else:
                self.stdout.write(self.style.WARNING(f'Trainer already exists: {email}'))
        
        self.stdout.write(self.style.SUCCESS('\n=== Test Users Created ==='))
        self.stdout.write('Members:')
        self.stdout.write('  john@example.com / password123')
        self.stdout.write('  jane@example.com / password123')
        self.stdout.write('\nTrainers:')
        self.stdout.write('  mike@example.com / password123')
        self.stdout.write('  sarah@example.com / password123')