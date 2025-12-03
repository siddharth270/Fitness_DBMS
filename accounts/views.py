from django.db import connection
from django.shortcuts import render, redirect
from django.contrib import messages
from .models import Member, Trainer

def login_select(request):
    """Landing page to select login type"""
    return render(request, 'login_select.html')

def call_procedure(procedure_name, params=[]):
    """Helper function to call stored procedures"""
    with connection.cursor() as cursor:
        cursor.callproc(procedure_name, params)
        return cursor.fetchall()


def member_login(request):
    """Handle member login"""
    if request.method == 'POST':
        email = request.POST.get('email')
        password = request.POST.get('password')
        
        try:
            member = Member.objects.get(email=email)
            if member.check_password(password):

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


# def member_dashboard(request):
#     """Member dashboard view"""

#     if request.session.get('user_type') != 'member':
#         messages.error(request, 'Please log in as a member')
#         return redirect('member_login')
    
#     member_id = request.session.get('user_id')
#     member = Member.objects.get(member_id=member_id)
    

#     membership = member.get_active_membership()
    
#     context = {
#         'member': member,
#         'membership': membership,
#     }
#     return render(request, 'member_dashboard.html', context)


def member_dashboard(request):
    """Member dashboard view"""
    # Check if user is logged in as member
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    member_id = request.session.get('user_id')
    member = Member.objects.get(member_id=member_id)
    
    # Call procedure: get_member_total_workouts(member_id)
    workout_data = call_procedure('get_member_total_workouts', [member_id])
    total_workouts = workout_data[0][2] if workout_data and len(workout_data[0]) > 2 else 0
    
    # Call procedure: get_member_total_calories(member_id)
    calories_data = call_procedure('get_member_total_calories', [member_id])
    total_calories = calories_data[0][2] if calories_data and len(calories_data[0]) > 2 else 0
    
    # Call procedure: get_member_active_plans_count(member_id)
    plans_data = call_procedure('get_member_active_plans_count', [member_id])
    active_plans = plans_data[0][2] if plans_data and len(plans_data[0]) > 2 else 0
    
    # Call procedure: get_member_active_gym(member_id)
    gym_data = call_procedure('get_member_active_gym', [member_id])
    
    membership = None
    if gym_data:
        # Create a simple object to hold gym data
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

    if request.session.get('user_type') != 'trainer':
        messages.error(request, 'Please log in as a trainer')
        return redirect('trainer_login')
    
    trainer_id = request.session.get('user_id')
    trainer = Trainer.objects.select_related('gym').get(trainer_id=trainer_id)
    
    context = {
        'trainer': trainer,
    }
    return render(request, 'trainer_dashboard.html', context)


def logout(request):
    """Handle logout for both member and trainer"""
    request.session.flush()
    messages.success(request, 'You have been logged out successfully')
    return redirect('login_select')