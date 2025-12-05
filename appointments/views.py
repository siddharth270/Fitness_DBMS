from django.shortcuts import render, redirect
from django.contrib import messages
from django.db import connection
from datetime import date, datetime, timedelta
from .models import Appointment
from accounts.models import Trainer

def call_procedure(procedure_name, params=[]):
    """Helper function to call stored procedures"""
    with connection.cursor() as cursor:
        cursor.callproc(procedure_name, params)
        return cursor.fetchall()


def appointment_list(request):
    """Display member's appointments"""
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    member_id = request.session.get('user_id')
    
    with connection.cursor() as cursor:

        all_appointments = call_procedure('get_member_appointments', [member_id, 'All'])
        
        appointments = []
        for row in all_appointments:
            appointments.append({
                'appointment_id': row[0],
                'start_time': row[1],
                'end_time': row[2],
                'status': row[3],
                'trainer_id': row[4],
                'trainer_name': row[5],
                'specialization': row[6],
                'gym_name': row[7],
                'state': row[8]
            })
    scheduled_appointments = call_procedure('get_member_appointments', [member_id, 'Scheduled'])

    
    context = {
        'appointments': appointments,
        'upcoming_count': len(scheduled_appointments)
    }
    
    return render(request, 'appointments/appointment_list.html', context)


def book_appointment(request):
    """Book a new appointment with a trainer"""
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    member_id = request.session.get('user_id')

    with connection.cursor() as cursor:
        available_trainers = call_procedure('get_trainers_at_member_gym', [member_id])
        
        trainers = []
        for row in available_trainers:
            trainers.append({
                'trainer_id': row[0],
                'name': row[1],
                'specialization': row[2],
                'email': row[3],
                'gym_name': row[4],
                'total_appointments': row[5]
            })
    
    if request.method == 'POST':
        trainer_id = request.POST.get('trainer_id')
        appointment_date = request.POST.get('date')
        start_time = request.POST.get('start_time')
        

        start_datetime = datetime.strptime(f"{appointment_date} {start_time}", "%Y-%m-%d %H:%M")
        end_datetime = start_datetime + timedelta(hours=1)  # 1 hour appointment
        
        with connection.cursor() as cursor:

            call_procedure('book_new_appointment', [trainer_id, member_id, start_datetime, end_datetime])
        
        messages.success(request, 'Appointment booked successfully!')
        return redirect('appointment_list')
    
    context = {
        'trainers': trainers,
        'today': date.today().isoformat()
    }
    
    return render(request, 'appointments/book_appointment.html', context)


def cancel_appointment(request, appointment_id):
    """Cancel an appointment"""
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    member_id = request.session.get('user_id')
    
    if request.method == 'POST':

        result = call_procedure('change_appointment_status', [appointment_id, 'Cancelled', member_id, 'member'])
        
        if result:
            result_status = result[0][0]
            
            if result_status == 'STATUS UPDATED':
                messages.success(request, 'Appointment cancelled successfully')
            else:
                messages.error(request, 'Failed to cancel appointment')
    
    return redirect('appointment_list')


def trainer_detail(request, trainer_id):
    """View trainer details and availability"""
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    

    trainer = Trainer.objects.select_related('gym').get(trainer_id=trainer_id)

    with connection.cursor() as cursor:
        trainer_appointments = call_procedure('get_trainer_appointments_by_status', [trainer_id, 'Scheduled'])
        
        upcoming_appointments = []
        for row in trainer_appointments:
            upcoming_appointments.append({
                'start_time': row[0],
                'end_time': row[1],
                'status': row[2]
            })
    
    context = {
        'trainer': trainer,
        'upcoming_appointments': upcoming_appointments
    }
    
    return render(request, 'appointments/trainer_detail.html', context)


def trainer_appointments(request):
    """Display trainer's appointments"""
    if request.session.get('user_type') != 'trainer':
        messages.error(request, 'Please log in as a trainer')
        return redirect('trainer_login')
    
    trainer_id = request.session.get('user_id')
    

    status_filter = request.GET.get('status', 'All')
    
    appointments_data = call_procedure('get_trainer_appointments_by_status', [trainer_id, status_filter])
    
    appointments = []
    for row in appointments_data:
        appointments.append({
            'appointment_id': row[0],
            'start_time': row[1],
            'end_time': row[2],
            'status': row[3],
            'member_id': row[4],
            'member_name': row[5],
            'member_email': row[6],
            'age': row[7],
            'gender': row[8],
            'gym_name': row[9],
            'time_status': row[10]
        })
    
    context = {
        'appointments': appointments,
        'status_filter': status_filter
    }
    
    return render(request, 'appointments/trainer_appointments.html', context)


def trainer_schedule(request):
    """View trainer's daily schedule"""
    if request.session.get('user_type') != 'trainer':
        messages.error(request, 'Please log in as a trainer')
        return redirect('trainer_login')
    
    trainer_id = request.session.get('user_id')
    

    selected_date = request.GET.get('date', date.today().isoformat())
    

    schedule_data = call_procedure('get_trainer_daily_schedule', [trainer_id, selected_date])
    
    appointments = []
    for row in schedule_data:
        appointments.append({
            'appointment_id': row[0],
            'start_time': row[1],
            'end_time': row[2],
            'status': row[3],
            'start_time_only': row[4],
            'end_time_only': row[5],
            'duration_minutes': row[6],
            'member_id': row[7],
            'member_name': row[8],
            'member_email': row[9],
            'age': row[10],
            'gender': row[11],
            'gym_name': row[12],
            'state': row[13]
        })
    
    context = {
        'appointments': appointments,
        'selected_date': selected_date
    }
    
    return render(request, 'appointments/trainer_schedule.html', context)


def trainer_clients(request):
    """View all trainer's clients"""
    if request.session.get('user_type') != 'trainer':
        messages.error(request, 'Please log in as a trainer')
        return redirect('trainer_login')
    
    trainer_id = request.session.get('user_id')
    
    clients_data = call_procedure('get_trainer_all_members', [trainer_id])
    
    clients = []
    for row in clients_data:
        clients.append({
            'member_id': row[0],
            'name': row[1],
            'email': row[2],
            'age': row[3],
            'gender': row[4],
            'height': row[5],
            'weight': row[6],
            'join_date': row[7],
            'total_appointments': row[8],
            'completed_appointments': row[9],
            'workout_plans': row[10],
            'last_appointment': row[11],
            'total_workouts': row[12],
            'last_workout': row[13],
            'membership_status': row[14]
        })
    
    context = {
        'clients': clients
    }
    
    return render(request, 'appointments/trainer_clients.html', context)