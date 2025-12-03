from django.core.management.base import BaseCommand
from accounts.models import Member, Gym, Membership
from django.db import connection

class Command(BaseCommand):
    help = 'Check membership data in the database'

    def handle(self, *args, **kwargs):
        self.stdout.write(self.style.WARNING('\n=== Checking Memberships ===\n'))
        

        with connection.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) FROM Membership")
            total_memberships = cursor.fetchone()[0]
        
        self.stdout.write(f'Total memberships in database: {total_memberships}')
        
        if total_memberships == 0:
            self.stdout.write(self.style.ERROR('\n❌ No memberships found! Did you run the INSERT statements for Membership table?'))
            return
        

        try:
            john = Member.objects.get(email='john.smith@email.com')
            self.stdout.write(self.style.SUCCESS(f'\n✅ Found John Smith (member_id: {john.member_id})'))
            

            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT m.member_id, m.gym_id, m.start_date, m.end_date, m.status, m.cost,
                           g.gym_name, g.location
                    FROM Membership m
                    JOIN Gym g ON m.gym_id = g.gym_id
                    WHERE m.member_id = %s
                """, [john.member_id])
                
                memberships = cursor.fetchall()
                self.stdout.write(f'\nJohn\'s memberships: {len(memberships)}')
                
                for membership in memberships:
                    member_id, gym_id, start_date, end_date, status, cost, gym_name, location = membership
                    self.stdout.write(f'\n  Membership Details:')
                    self.stdout.write(f'    - Gym: {gym_name}')
                    self.stdout.write(f'    - Status: "{status}"')
                    self.stdout.write(f'    - Start: {start_date}')
                    self.stdout.write(f'    - End: {end_date}')
                    self.stdout.write(f'    - Cost: ${cost}')
            

            active = john.get_active_membership()
            if active:
                self.stdout.write(self.style.SUCCESS(f'\n✅ get_active_membership() returned: {active.gym.gym_name}'))
            else:
                self.stdout.write(self.style.ERROR(f'\n❌ get_active_membership() returned None'))
                

                self.stdout.write(self.style.WARNING(f'\nChecking all unique status values in Membership table:'))
                with connection.cursor() as cursor:
                    cursor.execute("SELECT DISTINCT status, COUNT(*) FROM Membership GROUP BY status")
                    statuses = cursor.fetchall()
                    for status, count in statuses:
                        self.stdout.write(f'  - "{status}": {count} memberships')
        
        except Member.DoesNotExist:
            self.stdout.write(self.style.ERROR('\n❌ John Smith not found!'))
        

        self.stdout.write(self.style.WARNING(f'\n=== First 10 Memberships ==='))
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT m.member_id, m.gym_id, m.status, mb.name, g.gym_name
                FROM Membership m
                JOIN Member mb ON m.member_id = mb.member_id
                JOIN Gym g ON m.gym_id = g.gym_id
                LIMIT 10
            """)
            
            memberships = cursor.fetchall()
            for membership in memberships:
                member_id, gym_id, status, member_name, gym_name = membership
                self.stdout.write(f'{member_name} -> {gym_name} (Status: "{status}")')