from django.core.management.base import BaseCommand
from accounts.models import Member, Trainer

class Command(BaseCommand):
    help = 'Debug login issues for a specific user'

    def add_arguments(self, parser):
        parser.add_argument('email', type=str, help='Email address to debug')
        parser.add_argument('password', type=str, help='Password to test')

    def handle(self, *args, **options):
        email = options['email']
        password = options['password']
        
        self.stdout.write(self.style.WARNING(f'\n=== Debugging Login for {email} ===\n'))
        

        try:
            member = Member.objects.get(email=email)
            self.stdout.write(self.style.SUCCESS(f'✅ Member found!'))
            self.stdout.write(f'   Name: {member.name}')
            self.stdout.write(f'   Email: {member.email}')
            self.stdout.write(f'   Password hash: {member.password[:50]}...')
            self.stdout.write(f'   Hash length: {len(member.password)}')
            self.stdout.write(f'   Starts with pbkdf2?: {member.password.startswith("pbkdf2_sha256")}')
            

            self.stdout.write(f'\n🔐 Testing password: "{password}"')
            result = member.check_password(password)
            
            if result:
                self.stdout.write(self.style.SUCCESS(f'✅ PASSWORD CORRECT! Login should work.'))
            else:
                self.stdout.write(self.style.ERROR(f'❌ PASSWORD INCORRECT!'))
                self.stdout.write(self.style.WARNING(f'\nTrying to fix it...'))
                

                member.set_password(password)
                member.save()
                

                result2 = member.check_password(password)
                if result2:
                    self.stdout.write(self.style.SUCCESS(f'✅ Password fixed! Try logging in now.'))
                else:
                    self.stdout.write(self.style.ERROR(f'❌ Still not working. Something is wrong.'))
            
            return
            
        except Member.DoesNotExist:
            self.stdout.write(self.style.WARNING(f'⚠️  Not found as Member, checking Trainers...'))
        

        try:
            trainer = Trainer.objects.get(email=email)
            self.stdout.write(self.style.SUCCESS(f'✅ Trainer found!'))
            self.stdout.write(f'   Name: {trainer.name}')
            self.stdout.write(f'   Email: {trainer.email}')
            self.stdout.write(f'   Password hash: {trainer.password[:50]}...')
            

            self.stdout.write(f'\n🔐 Testing password: "{password}"')
            result = trainer.check_password(password)
            
            if result:
                self.stdout.write(self.style.SUCCESS(f'✅ PASSWORD CORRECT! Login should work.'))
            else:
                self.stdout.write(self.style.ERROR(f'❌ PASSWORD INCORRECT!'))
                self.stdout.write(self.style.WARNING(f'\nTrying to fix it...'))
                

                trainer.set_password(password)
                trainer.save()
                

                result2 = trainer.check_password(password)
                if result2:
                    self.stdout.write(self.style.SUCCESS(f'✅ Password fixed! Try logging in now.'))
                else:
                    self.stdout.write(self.style.ERROR(f'❌ Still not working. Something is wrong.'))
            
            return
            
        except Trainer.DoesNotExist:
            self.stdout.write(self.style.ERROR(f'❌ User not found as Member or Trainer!'))
            

            self.stdout.write(f'\n📋 All members in database:')
            for m in Member.objects.all()[:10]:
                self.stdout.write(f'   - {m.email}')