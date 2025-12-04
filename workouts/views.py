from django.shortcuts import render, redirect
from django.contrib import messages
from django.db import connection
from datetime import date
from .models import Exercise, Workout, Set
from accounts.models import Member

def call_procedure(procedure_name, params=[]):
    """Helper function to call stored procedures"""
    with connection.cursor() as cursor:
        placeholders = ', '.join(['%s'] * len(params))
        cursor.callproc(procedure_name, params)
        return cursor.fetchall()

def call_function(function_name, params=[]):
    """Helper function to call stored functions"""
    with connection.cursor() as cursor:
        placeholders = ', '.join(['%s'] * len(params))
        cursor.execute(f"SELECT {function_name}({placeholders})", params)
        result = cursor.fetchone()
        return result[0] if result else None


def workout_list(request):
    """Display member's workout history"""
    # Check if user is logged in as member
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    member_id = request.session.get('user_id')
    
    # Call stored procedure: get_member_workout_history(member_id, limit)
    workouts_data = call_procedure('get_member_recent_workouts', [member_id, 20])
    
    workouts = []
    for row in workouts_data:
        workouts.append({
            'workout_id': row[0],
            'date': row[1],
            'duration': row[2],
            'calories_burned': row[3],
            'gym_name': row[4],
            'exercise_count': row[5] if len(row) > 5 else 0
        })
    
    # Call stored functions for stats
    total_workouts = call_procedure('get_member_total_workouts', [member_id]) or 0
    total_calories = call_procedure('get_member_total_calories', [member_id]) or 0
    avg_duration = call_procedure('get_member_avg_workout_duration', [member_id]) or 0
    
    context = {
        'workouts': workouts,
        'total_workouts': total_workouts[0][2],
        'total_calories': total_calories[0][2],
        'avg_duration': avg_duration[0][3],
    }
    
    return render(request, 'workouts/workout_list.html', context)


def workout_detail(request, workout_id):
    """View details of a specific workout"""
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    member_id = request.session.get('user_id')
    
    # Call stored procedure: get_workout_details(workout_id)
    workout_details = call_procedure('get_full_workout_details', [workout_id])
    
    if not workout_details:
        messages.error(request, 'Workout not found')
        return redirect('workout_list')
    
    # First row contains workout info
    first_row = workout_details[0]
    workout = {
        'workout_id': first_row[0],
        'date': first_row[1],
        'duration': first_row[2],
        'calories_burned': first_row[3],
        'gym_name': first_row[4]
    }
    
    # Group exercises and sets
    exercises = {}
    for row in workout_details:
        if len(row) > 5:  # Has exercise data
            exercise_name = row[5]
            if exercise_name not in exercises:
                exercises[exercise_name] = {
                    'name': row[5],
                    'category': row[6],
                    'muscle_group': row[7],
                    'sets': []
                }
            exercises[exercise_name]['sets'].append({
                'set_id': row[8],
                'reps': row[9],
                'weight': row[10]
            })
    
    context = {
        'workout': workout,
        'exercises': exercises.values()
    }
    
    return render(request, 'workouts/workout_detail.html', context)


def new_workout(request):
    """Start a new workout session"""
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    member_id = request.session.get('user_id')
    
    # Call function: get_member_gym_name(member_id)
    gym_name = call_procedure('get_member_active_gym', [member_id])
    
    if not gym_name:
        messages.error(request, 'No active gym membership found')
        return redirect('member_dashboard')
    
    if request.method == 'POST':
        # Call stored procedure: log_workout(member_id, gym_id, plan_id, date, duration, calories)
        # For now, we just create the workout, duration and calories added later
        with connection.cursor() as cursor:
            # Get gym_id first
            cursor.execute("""
                SELECT g.gym_id FROM Gym g
                JOIN Membership m ON g.gym_id = m.gym_id
                WHERE m.member_id = %s AND m.status = 'Active'
                LIMIT 1
            """, [member_id])
            gym_result = cursor.fetchone()
            gym_id = gym_result[0] if gym_result else None
            
            if gym_id:
                # Call procedure: create_workout(member_id, gym_id, date)
                cursor.callproc('create_new_workout', [member_id, gym_id, None, date.today(), None, None])
                
                # Get the workout_id from the procedure output or last insert
                cursor.execute("SELECT LAST_INSERT_ID()")
                workout_id = cursor.fetchone()[0]
                
                # Store workout_id in session
                request.session['current_workout_id'] = workout_id
                messages.success(request, 'Workout started! Now add exercises.')
                return redirect('add_exercise')
    
    context = {
        'gym_name': gym_name[0][3]
    }
    
    return render(request, 'workouts/new_workout.html', context)


def add_exercise(request):
    """Search and add exercises to current workout"""
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    workout_id = request.session.get('current_workout_id')
    if not workout_id:
        messages.error(request, 'No active workout session')
        return redirect('new_workout')
    
    # Search exercises
    search_query = request.GET.get('search', '')
    category_filter = request.GET.get('category', '')
    muscle_group = request.GET.get('muscle_group', '')
    
    # Call stored procedure: search_exercises(keyword, category, muscle_group)
    exercises_data = call_procedure('find_exercises_by_criteria', [search_query or None, category_filter or None, muscle_group or None])
    
    exercises = []
    for row in exercises_data:
        exercises.append({
            'exercise_id': row[0],
            'name': row[1],
            'category': row[2],
            'muscle_group': row[3]
        })
    
    # Get distinct categories - call a function or procedure
    with connection.cursor() as cursor:
        cursor.execute("SELECT DISTINCT category FROM Exercise ORDER BY category")
        categories = [row[0] for row in cursor.fetchall()]
    
    # Call stored procedure: get_workout_exercises(workout_id)
    current_exercises_data = call_procedure('get_full_workout_details', [workout_id])
    
    current_exercises = []
    for row in current_exercises_data:
        current_exercises.append({
            'exercise_id': row[0],
            'name': row[1],
            'set_count': row[2]
        })
    
    context = {
        'workout_id': workout_id,
        'exercises': exercises,
        'categories': categories,
        'current_exercises': current_exercises,
        'search_query': search_query,
        'category_filter': category_filter
    }
    
    return render(request, 'workouts/add_exercise.html', context)


def log_set(request, exercise_id):
    """Log a set for an exercise in current workout"""
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    workout_id = request.session.get('current_workout_id')
    if not workout_id:
        messages.error(request, 'No active workout session')
        return redirect('new_workout')
    
    if request.method == 'POST':
        reps = request.POST.get('reps')
        weight = request.POST.get('weight', 0)
        
        # Call stored procedure: log_exercise_set(workout_id, exercise_id, reps, weight)
        with connection.cursor() as cursor:
            cursor.callproc('add_set_to_workout', [workout_id, exercise_id, reps, weight])
        
        messages.success(request, 'Set logged successfully!')
        return redirect('add_exercise')
    
    # Get exercise details
    exercise = Exercise.objects.get(exercise_id=exercise_id)
    
    # Call stored procedure: get_exercise_history(member_id, exercise_id)
    # This shows previous performance for this exercise
    member_id = request.session.get('user_id')
    exercise_history = call_procedure('get_exercise_progress', [member_id, exercise_id])
    
    previous_sets = []
    if exercise_history:
        for row in exercise_history[:5]:  # Last 5 sets
            previous_sets.append({
                'date': row[0],
                'reps': row[1],
                'weight': row[2]
            })
    
    context = {
        'exercise': exercise,
        'workout_id': workout_id,
        'previous_sets': previous_sets
    }
    
    return render(request, 'workouts/log_set.html', context)


def complete_workout(request):
    """Complete and save the workout"""
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    workout_id = request.session.get('current_workout_id')
    if not workout_id:
        messages.error(request, 'No active workout session')
        return redirect('workout_list')
    
    if request.method == 'POST':
        duration = request.POST.get('duration')
        calories = request.POST.get('calories', 0)
        
        # Call stored procedure: complete_workout(workout_id, duration, calories)
        with connection.cursor() as cursor:
            cursor.callproc('get_full_workout_details', [workout_id])
        
        # Clear session
        del request.session['current_workout_id']
        
        messages.success(request, 'Workout completed and saved!')
        return redirect('workout_list')
    
    # Call stored procedure: get_workout_summary(workout_id)
    summary_data = call_procedure('get_full_workout_details', [workout_id])
    
    if summary_data and summary_data[0]:
        exercise_count = summary_data[0][0]
        set_count = summary_data[0][1]
    else:
        exercise_count = 0
        set_count = 0
    
    context = {
        'workout_id': workout_id,
        'exercise_count': exercise_count,
        'set_count': set_count
    }
    
    return render(request, 'workouts/complete_workout.html', context)