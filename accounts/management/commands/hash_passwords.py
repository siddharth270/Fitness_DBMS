from django.core.management.base import BaseCommand
from accounts.models import Member, Trainer

class Command(BaseCommand):
    help = 'Hashes plain text passwords for existing users in the database'

    def handle(self, *args, **kwargs):

        members = Member.objects.all()
        member_fixed = 0
        member_already_hashed = 0
        
        self.stdout.write(self.style.WARNING('\n=== Processing Member Passwords ==='))
        
        for member in members:

            if not member.password.startswith('pbkdf2_sha256'):
                old_password = member.password 
                member.set_password(old_password)
                member.save()
                

                if member.check_password(old_password):
                    member_fixed += 1
                    self.stdout.write(self.style.SUCCESS(
                        f'✅ Fixed: {member.name} ({member.email}) - password: {old_password}'
                    ))
                else:
                    self.stdout.write(self.style.ERROR(
                        f'❌ FAILED: {member.name} ({member.email})'
                    ))
            else:
                member_already_hashed += 1
                self.stdout.write(self.style.WARNING(
                    f'⏭️  Already hashed: {member.name} ({member.email})'
                ))
        

        trainers = Trainer.objects.all()
        trainer_fixed = 0
        trainer_already_hashed = 0
        
        self.stdout.write(self.style.WARNING('\n=== Processing Trainer Passwords ==='))
        
        for trainer in trainers:

            if not trainer.password.startswith('pbkdf2_sha256'):
                old_password = trainer.password 
                trainer.set_password(old_password)
                trainer.save()
                

                if trainer.check_password(old_password):
                    trainer_fixed += 1
                    self.stdout.write(self.style.SUCCESS(
                        f'✅ Fixed: {trainer.name} ({trainer.email}) - password: {old_password}'
                    ))
                else:
                    self.stdout.write(self.style.ERROR(
                        f'❌ FAILED: {trainer.name} ({trainer.email})'
                    ))
            else:
                trainer_already_hashed += 1
                self.stdout.write(self.style.WARNING(
                    f'⏭️  Already hashed: {trainer.name} ({trainer.email})'
                ))
        

        self.stdout.write(self.style.SUCCESS(f'\n=== Summary ==='))
        self.stdout.write(f'Members - Total: {members.count()}, Fixed: {member_fixed}, Already hashed: {member_already_hashed}')
        self.stdout.write(f'Trainers - Total: {trainers.count()}, Fixed: {trainer_fixed}, Already hashed: {trainer_already_hashed}')
        
        if member_fixed > 0 or trainer_fixed > 0:
            self.stdout.write(self.style.SUCCESS(
                f'\n✅ Successfully fixed {member_fixed + trainer_fixed} passwords!'
            ))
            self.stdout.write(self.style.SUCCESS(
                '\n🎉 All users can now log in with their original passwords from the SQL file!'
            ))
        else:
            self.stdout.write(self.style.WARNING(
                '\n⚠️  All passwords were already hashed. No changes needed.'
            ))