from django.shortcuts import render, redirect
from django.contrib import messages
from django.db import connection
from .models import Member, Trainer

def call_procedure(procedure_name, params=[]):
    """Helper function to call stored procedures"""
    with connection.cursor() as cursor:
        cursor.callproc(procedure_name, params)
        return cursor.fetchall()

def login_select(request):
    """Landing page to select login type"""
    return render(request, 'login_select.html')


def member_login(request):
    """Handle member login"""
    if request.method == 'POST':
        email = request.POST.get('email')
        password = request.POST.get('password')
        
        try:
            member = Member.objects.get(email=email)
            if member.check_password(password):
                # Store member info in session
                request.session['user_id'] = member.member_id
                request.session['user_type'] = 'member'
                request.session['user_name'] = member.name
                messages.success(request, f'Welcome back, {member.name}!')
                return redirect('member_dashboard')
            else:
                messages.error(request, 'Invalid email or password')
        except Member.DoesNotExist:
            messages.error(request, 'Invalid email or password')
    
    return render(request, 'member_login.html')


def trainer_login(request):
    """Handle trainer login"""
    if request.method == 'POST':
        email = request.POST.get('email')
        password = request.POST.get('password')
        
        try:
            trainer = Trainer.objects.get(email=email)
            if trainer.check_password(password):
                # Store trainer info in session
                request.session['user_id'] = trainer.trainer_id
                request.session['user_type'] = 'trainer'
                request.session['user_name'] = trainer.name
                messages.success(request, f'Welcome back, {trainer.name}!')
                return redirect('trainer_dashboard')
            else:
                messages.error(request, 'Invalid email or password')
        except Trainer.DoesNotExist:
            messages.error(request, 'Invalid email or password')
    
    return render(request, 'trainer_login.html')


def member_dashboard(request):
    """Member dashboard view"""
    # Check if user is logged in as member
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    member_id = request.session.get('user_id')
    member = Member.objects.get(member_id=member_id)
    
    # Call procedure: get_member_total_workouts(member_id)
    # Returns: member_id, name, total_workouts_completed
    workout_data = call_procedure('get_member_total_workouts', [member_id])
    total_workouts = workout_data[0][2] if workout_data else 0
    
    # Call procedure: get_member_total_calories(member_id)
    # Returns: member_id, name, total_calories_burned
    calories_data = call_procedure('get_member_total_calories', [member_id])
    total_calories = int(calories_data[0][2]) if calories_data else 0
    
    # Call procedure: get_member_active_plans_count(member_id)
    # Returns: member_id, name, number_of_active_workout_plans
    plans_data = call_procedure('get_member_active_plans_count', [member_id])
    active_plans = plans_data[0][2] if plans_data else 0
    
    # Call procedure: get_member_active_gym(member_id)
    # Returns: member_id, member_name, gym_id, gym_name, location, membership_status, start_date, end_date, days_remaining
    gym_data = call_procedure('get_member_active_gym', [member_id])
    
    membership = None
    if gym_data:
        membership = type('Membership', (), {
            'gym': type('Gym', (), {
                'gym_id': gym_data[0][2],
                'gym_name': gym_data[0][3],
                'location': gym_data[0][4]
            })(),
            'status': gym_data[0][5],
            'start_date': gym_data[0][6],
            'end_date': gym_data[0][7]
        })()
    
    context = {
        'member': member,
        'membership': membership,
        'total_workouts': total_workouts,
        'total_calories': total_calories,
        'active_plans': active_plans,
    }
    return render(request, 'member_dashboard.html', context)


def trainer_dashboard(request):
    """Trainer dashboard view"""
    # Check if user is logged in as trainer
    if request.session.get('user_type') != 'trainer':
        messages.error(request, 'Please log in as a trainer')
        return redirect('trainer_login')
    
    trainer_id = request.session.get('user_id')
    trainer = Trainer.objects.select_related('gym').get(trainer_id=trainer_id)
    
    # Call procedure: get_trainer_total_clients(trainer_id)
    # Returns: trainer_id, trainer_name, specialization, total_clients
    clients_data = call_procedure('get_trainer_total_clients', [trainer_id])
    total_clients = clients_data[0][3] if clients_data else 0
    
    # Call procedure: get_trainer_scheduled_appointments_count(trainer_id)
    # Returns: trainer_id, trainer_name, scheduled_appointments_count
    appointments_data = call_procedure('get_trainer_scheduled_appointments_count', [trainer_id])
    scheduled_appointments = appointments_data[0][2] if appointments_data else 0
    
    # Call procedure: get_trainer_workout_plans_count(trainer_id)
    # Returns: trainer_id, trainer_name, specialization, workout_plans_created
    plans_data = call_procedure('get_trainer_workout_plans_count', [trainer_id])
    workout_plans_created = plans_data[0][3] if plans_data else 0
    
    context = {
        'trainer': trainer,
        'total_clients': total_clients,
        'scheduled_appointments': scheduled_appointments,
        'workout_plans_created': workout_plans_created,
    }
    return render(request, 'trainer_dashboard.html', context)


def logout(request):
    """Handle logout for both member and trainer"""
    request.session.flush()
    messages.success(request, 'You have been logged out successfully')
    return redirect('login_select')