from django.core.management.base import BaseCommand
from accounts.models import Gym, Member, Trainer, Membership
from datetime import date

class Command(BaseCommand):
    help = 'Creates test users for development (uses existing gyms from database)'

    def handle(self, *args, **kwargs):
        # Use existing gyms from the database
        try:
            gym = Gym.objects.first()
            if not gym:
                self.stdout.write(self.style.ERROR('No gyms found in database! Please run the SQL file first.'))
                return
            
            self.stdout.write(self.style.SUCCESS(f'Using gym: {gym.gym_name}'))
        except Exception as e:
            self.stdout.write(self.style.ERROR(f'Error accessing gym: {e}'))
            return
        
        # Create test members
        members_data = [
            {
                'name': 'John Doe Test',
                'email': 'john@example.com',
                'password': 'password123',
                'age': 28,
                'gender': 'Male',
                'height': 180.50,
                'weight': 82.30,
                'join_date': date(2024, 1, 15)
            },
            {
                'name': 'Jane Smith Test',
                'email': 'jane@example.com',
                'password': 'password123',
                'age': 25,
                'gender': 'Female',
                'height': 165.00,
                'weight': 58.50,
                'join_date': date(2024, 2, 1)
            }
        ]
        
        for member_data in members_data:
            email = member_data['email']
            if not Member.objects.filter(email=email).exists():
                member = Member(
                    name=member_data['name'],
                    email=email,
                    age=member_data['age'],
                    gender=member_data['gender'],
                    height=member_data['height'],
                    weight=member_data['weight'],
                    join_date=member_data['join_date']
                )
                member.set_password(member_data['password'])
                member.save()
                
                # Create membership
                Membership.objects.create(
                    member_id=member.member_id,
                    gym_id=gym.gym_id,
                    start_date=member_data['join_date'],
                    end_date=date(2025, member_data['join_date'].month, member_data['join_date'].day),
                    status='Active',
                    cost=599.99
                )
                
                self.stdout.write(self.style.SUCCESS(f'Created member: {member.name} ({email})'))
            else:
                self.stdout.write(self.style.WARNING(f'Member already exists: {email}'))
        
        # Create test trainers
        trainers_data = [
            {
                'name': 'Mike Johnson Test',
                'email': 'mike@example.com',
                'password': 'password123',
                'specialization': 'Strength Training'
            },
            {
                'name': 'Sarah Williams Test',
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
        self.stdout.write('\nYou can also use existing members from the database (check the SQL file for emails)')