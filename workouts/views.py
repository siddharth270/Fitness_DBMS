from django.shortcuts import render, redirect
from django.contrib import messages
from django.db import connection
from datetime import date
from .models import Exercise, Workout, Set
from accounts.models import Member

def call_procedure(procedure_name, params=[]):
    """Helper function to call stored procedures"""
    with connection.cursor() as cursor:
        cursor.callproc(procedure_name, params)
        return cursor.fetchall()


def workout_list(request):
    """Display member's workout history"""
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    member_id = request.session.get('user_id')
    
    workouts_data = call_procedure('get_member_recent_workouts', [member_id, 20])
    
    workouts = []
    for row in workouts_data:
        workouts.append({
            'workout_id': row[0],
            'date': row[1],
            'duration': row[2],
            'calories_burned': row[3],
            'gym_name': row[4],
            'exercise_count': row[7] if len(row) > 7 else 0
        })
    
    total_workouts = call_procedure('get_member_total_workouts', [member_id]) or 0
    total_calories = call_procedure('get_member_total_calories', [member_id]) or 0
    avg_duration = call_procedure('get_member_avg_workout_duration', [member_id]) or 0
    
    context = {
        'workouts': workouts,
        'total_workouts': total_workouts[0][2] if total_workouts else 0,
        'total_calories': total_calories[0][2] if total_calories else 0,
        'avg_duration': round(avg_duration[0][3], 1) if avg_duration else 0,
    }
    
    return render(request, 'workouts/workout_list.html', context)


def workout_detail(request, workout_id):
    """View details of a specific workout"""
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    with connection.cursor() as cursor:
        cursor.callproc('get_full_workout_details', [workout_id])
        workout_overview = cursor.fetchall()
        
        if not workout_overview:
            messages.error(request, 'Workout not found')
            return redirect('workout_list')
        
        first_row = workout_overview[0]
        workout = {
            'workout_id': first_row[0],
            'date': first_row[1],
            'duration': first_row[2],
            'calories_burned': first_row[3],
            'gym_name': first_row[7],
            'plan_name': first_row[9],
            'trainer_name': first_row[10],
            'total_exercises': first_row[11],
            'total_sets': first_row[12],
        }
        
        cursor.nextset()
        sets_data = cursor.fetchall()
        
        exercises = {}
        for row in sets_data:
            exercise_name = row[2]
            if exercise_name not in exercises:
                exercises[exercise_name] = {
                    'name': row[2],
                    'category': row[3],
                    'muscle_group': row[4],
                    'sets': []
                }
            exercises[exercise_name]['sets'].append({
                'set_number': row[7],
                'reps': row[5],
                'weight': row[6]
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
    
    # Check if there's already an active workout
    if request.session.get('current_workout_id'):
        return redirect('active_workout')
    
    gym_data = call_procedure('get_member_active_gym', [member_id])
    
    if not gym_data:
        messages.error(request, 'No active gym membership found')
        return redirect('member_dashboard')
    
    if request.method == 'POST':
        gym_id = gym_data[0][2]
        
        with connection.cursor() as cursor:
            cursor.callproc('create_new_workout', [member_id, gym_id, None, date.today(), None, None])
            cursor.execute("SELECT LAST_INSERT_ID()")
            workout_id = cursor.fetchone()[0]
        
        request.session['current_workout_id'] = workout_id
        request.session['workout_start_time'] = str(date.today())
        messages.success(request, 'Workout started!')
        return redirect('active_workout')
    
    context = {
        'gym_name': gym_data[0][3]
    }
    
    return render(request, 'workouts/new_workout.html', context)


def active_workout(request):
    """Main active workout page - shows exercises and sets"""
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    workout_id = request.session.get('current_workout_id')
    if not workout_id:
        messages.error(request, 'No active workout session')
        return redirect('new_workout')
    
    # Get workout info (including plan_id if from a plan)
    workout_info = call_procedure('get_workout_info', [workout_id])
    plan_id = None
    plan_name = None
    if workout_info and workout_info[0][3]:
        plan_id = workout_info[0][3]
        plan_name = workout_info[0][5]
    
    # Get all exercises and sets for this workout
    sets_data = call_procedure('get_workout_exercise_sets', [workout_id])
    
    # Group by exercise
    exercises = {}
    logged_exercise_ids = set()
    
    for row in sets_data:
        exercise_id = row[0]
        logged_exercise_ids.add(exercise_id)
        
        if exercise_id not in exercises:
            exercises[exercise_id] = {
                'exercise_id': row[0],
                'name': row[1],
                'category': row[2],
                'muscle_group': row[3],
                'sets': [],
                'total_weight': 0,
                'total_reps': 0,
                'target_sets': None,
                'target_reps': None,
                'target_weight': None,
                'from_plan': False
            }
        
        weight = float(row[6]) if row[6] else 0
        reps = row[5] if row[5] else 0
        
        exercises[exercise_id]['sets'].append({
            'set_id': row[4],
            'reps': reps,
            'weight': weight,
            'set_number': row[7]
        })
        exercises[exercise_id]['total_weight'] += weight * reps
        exercises[exercise_id]['total_reps'] += reps
    
    # If workout is from a plan, get plan exercises and add those not yet started
    plan_exercises = []
    if plan_id:
        plan_exercise_data = call_procedure('get_plan_exercise_list', [plan_id])
        
        for row in plan_exercise_data:
            exercise_id = row[0]
            
            # Add target info to exercises that are already logged
            if exercise_id in exercises:
                exercises[exercise_id]['target_sets'] = row[4]
                exercises[exercise_id]['target_reps'] = row[5]
                exercises[exercise_id]['target_weight'] = row[6]
                exercises[exercise_id]['from_plan'] = True
            else:
                # Add exercises from plan that haven't been started yet
                plan_exercises.append({
                    'exercise_id': row[0],
                    'name': row[1],
                    'category': row[2],
                    'muscle_group': row[3],
                    'target_sets': row[4],
                    'target_reps': row[5],
                    'target_weight': row[6],
                    'from_plan': True,
                    'not_started': True
                })
    
    # Calculate averages for logged exercises
    for ex_id in exercises:
        ex = exercises[ex_id]
        if ex['total_reps'] > 0:
            ex['avg_weight'] = round(ex['total_weight'] / ex['total_reps'], 1)
        else:
            ex['avg_weight'] = 0
    
    context = {
        'workout_id': workout_id,
        'exercises': exercises.values(),
        'plan_exercises': plan_exercises,
        'plan_id': plan_id,
        'plan_name': plan_name
    }
    
    return render(request, 'workouts/active_workout.html', context)


def start_workout_from_plan(request, plan_id):
    """Start a new workout based on a workout plan"""
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    member_id = request.session.get('user_id')
    
    # Check if there's already an active workout
    if request.session.get('current_workout_id'):
        messages.warning(request, 'You already have an active workout. Finish or cancel it first.')
        return redirect('active_workout')
    
    # Get member's gym
    gym_data = call_procedure('get_member_active_gym', [member_id])
    
    if not gym_data:
        messages.error(request, 'No active gym membership found')
        return redirect('member_dashboard')
    
    gym_id = gym_data[0][2]
    
    # Create workout from plan
    result = call_procedure('start_workout_from_plan', [member_id, plan_id, gym_id, date.today()])
    
    if result and result[0][1] == 'WORKOUT STARTED':
        workout_id = result[0][0]
        request.session['current_workout_id'] = workout_id
        messages.success(request, 'Workout started from plan!')
        return redirect('active_workout')
    else:
        messages.error(request, 'Failed to start workout')
        return redirect('member_plan_detail', plan_id=plan_id)


def search_exercises(request):
    """Search exercises (returns results for modal)"""
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    workout_id = request.session.get('current_workout_id')
    if not workout_id:
        messages.error(request, 'No active workout session')
        return redirect('new_workout')
    
    search_query = request.GET.get('search', '')
    category_filter = request.GET.get('category', '')
    muscle_group = request.GET.get('muscle_group', '')
    show_results = request.GET.get('show_results', False)
    
    exercises = []
    if show_results or search_query or category_filter or muscle_group:
        exercises_data = call_procedure('find_exercises_by_criteria', [
            search_query or None, 
            category_filter or None, 
            muscle_group or None
        ])
        
        for row in exercises_data:
            exercises.append({
                'exercise_id': row[0],
                'name': row[1],
                'category': row[2],
                'muscle_group': row[3]
            })
    
    # Get categories for filter dropdown
    categories_data = call_procedure('get_all_exercise_categories', [])
    categories = [row[0] for row in categories_data]
    
    muscle_groups_data = call_procedure('get_all_muscle_groups', [])
    muscle_groups = [row[0] for row in muscle_groups_data]
    
    context = {
        'workout_id': workout_id,
        'exercises': exercises,
        'categories': categories,
        'muscle_groups': muscle_groups,
        'search_query': search_query,
        'category_filter': category_filter,
        'muscle_group_filter': muscle_group,
        'show_results': bool(exercises)
    }
    
    return render(request, 'workouts/search_exercises.html', context)


def add_exercise_to_workout(request, exercise_id):
    """Add an exercise to the current workout (creates first set)"""
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    workout_id = request.session.get('current_workout_id')
    if not workout_id:
        messages.error(request, 'No active workout session')
        return redirect('new_workout')
    
    # Get exercise name for message
    exercise = Exercise.objects.get(exercise_id=exercise_id)
    
    # Store the exercise to add sets to
    request.session['current_exercise_id'] = exercise_id
    request.session['current_exercise_name'] = exercise.exercise_name
    
    messages.success(request, f'{exercise.exercise_name} added! Now log your sets.')
    return redirect('active_workout')


def log_set(request, exercise_id):
    """Log a set for an exercise"""
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    workout_id = request.session.get('current_workout_id')
    if not workout_id:
        messages.error(request, 'No active workout session')
        return redirect('new_workout')
    
    if request.method == 'POST':
        reps = request.POST.get('reps')
        weight = request.POST.get('weight') or 0
        
        call_procedure('add_set_to_workout', [workout_id, exercise_id, reps, weight])
        
        messages.success(request, 'Set logged!')
        return redirect('active_workout')
    
    # GET request - show the log set form
    exercise = Exercise.objects.get(exercise_id=exercise_id)
    
    # Get existing sets for this exercise in this workout
    sets_data = call_procedure('get_workout_exercise_sets', [workout_id])
    
    existing_sets = []
    for row in sets_data:
        if row[0] == exercise_id:
            existing_sets.append({
                'set_id': row[4],
                'reps': row[5],
                'weight': row[6],
                'set_number': row[7]
            })
    
    # Check if workout is from a plan and get target info
    target_info = None
    workout_info = call_procedure('get_workout_info', [workout_id])
    if workout_info and workout_info[0][3]:  # has plan_id
        plan_id = workout_info[0][3]
        plan_exercises = call_procedure('get_plan_exercise_list', [plan_id])
        for row in plan_exercises:
            if row[0] == exercise_id:
                target_info = {
                    'sets': row[4],
                    'reps': row[5],
                    'weight': row[6]
                }
                break
    
    # Get previous performance
    member_id = request.session.get('user_id')
    history_data = call_procedure('get_exercise_progress', [member_id, exercise_id])
    
    previous_sets = []
    if history_data:
        for row in history_data[:5]:
            previous_sets.append({
                'date': row[1],
                'reps': row[5],
                'weight': row[6]
            })
    
    context = {
        'exercise': exercise,
        'workout_id': workout_id,
        'existing_sets': existing_sets,
        'previous_sets': previous_sets,
        'next_set_number': len(existing_sets) + 1,
        'target_info': target_info
    }
    
    return render(request, 'workouts/log_set.html', context)


def delete_set(request, set_id):
    """Delete a set from the workout"""
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    workout_id = request.session.get('current_workout_id')
    if not workout_id:
        messages.error(request, 'No active workout session')
        return redirect('new_workout')
    
    if request.method == 'POST':
        result = call_procedure('delete_set_from_workout', [set_id, workout_id])
        
        if result and result[0][0] == 'DELETE SUCCESS':
            messages.success(request, 'Set removed')
        else:
            messages.error(request, 'Failed to remove set')
    
    return redirect('active_workout')


def finish_workout(request):
    """Finish and save the workout"""
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    workout_id = request.session.get('current_workout_id')
    if not workout_id:
        messages.error(request, 'No active workout session')
        return redirect('workout_list')
    
    if request.method == 'POST':
        duration = request.POST.get('duration')
        calories = request.POST.get('calories') or 0
        
        call_procedure('complete_workout_session', [workout_id, duration, calories])
        
        # Clear session
        if 'current_workout_id' in request.session:
            del request.session['current_workout_id']
        if 'current_exercise_id' in request.session:
            del request.session['current_exercise_id']
        if 'current_exercise_name' in request.session:
            del request.session['current_exercise_name']
        if 'workout_start_time' in request.session:
            del request.session['workout_start_time']
        
        messages.success(request, 'Workout completed! Great job!')
        return redirect('workout_list')
    
    # GET - show summary
    stats_data = call_procedure('get_workout_stats', [workout_id])
    
    stats = {
        'exercise_count': 0,
        'total_sets': 0,
        'total_reps': 0,
        'total_volume': 0
    }
    
    if stats_data and stats_data[0]:
        stats = {
            'exercise_count': stats_data[0][0] or 0,
            'total_sets': stats_data[0][1] or 0,
            'total_reps': stats_data[0][2] or 0,
            'total_volume': stats_data[0][3] or 0
        }
    
    context = {
        'workout_id': workout_id,
        'stats': stats
    }
    
    return render(request, 'workouts/finish_workout.html', context)


def cancel_workout(request):
    """Cancel/discard the current workout"""
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    workout_id = request.session.get('current_workout_id')
    member_id = request.session.get('user_id')
    
    if workout_id and request.method == 'POST':
        # Use stored procedure to cancel workout
        result = call_procedure('cancel_workout_session', [workout_id, member_id])
        
        # Clear session
        if 'current_workout_id' in request.session:
            del request.session['current_workout_id']
        if 'current_exercise_id' in request.session:
            del request.session['current_exercise_id']
        if 'current_exercise_name' in request.session:
            del request.session['current_exercise_name']
        if 'workout_start_time' in request.session:
            del request.session['workout_start_time']
        
        if result and result[0][0] == 'CANCEL SUCCESS':
            messages.info(request, 'Workout cancelled')
        else:
            messages.error(request, 'Failed to cancel workout')
    
    return redirect('workout_list')