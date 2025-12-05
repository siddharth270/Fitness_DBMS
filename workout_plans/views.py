from django.shortcuts import render, redirect
from django.contrib import messages
from django.db import connection

def call_procedure(procedure_name, params=[]):
    with connection.cursor() as cursor:
        cursor.callproc(procedure_name, params)
        return cursor.fetchall()

def trainer_plan_list(request):
    """List all workout plans created by trainer"""
    if request.session.get('user_type') != 'trainer':
        messages.error(request, 'Please log in as a trainer')
        return redirect('trainer_login')
    
    trainer_id = request.session.get('user_id')
    
    with connection.cursor() as cursor:
        
        plans_data = call_procedure('get_trainer_all_plans', [trainer_id])
    
    plans = []
    for row in plans_data:
        plans.append({
            'plan_id': row[0],
            'plan_name': row[1],
            'member_id': row[2],
            'member_name': row[3],
            'exercise_count': row[4]
        })
    
    context = {
        'plans': plans
    }
    return render(request, 'workout_plans/trainer_plan_list.html', context)


def create_workout_plan(request):
    """Create a new workout plan for a member"""
    if request.session.get('user_type') != 'trainer':
        messages.error(request, 'Please log in as a trainer')
        return redirect('trainer_login')
    
    trainer_id = request.session.get('user_id')
    
    if request.method == 'POST':
        member_id = request.POST.get('member_id')
        plan_name = request.POST.get('plan_name')
        
        # Call stored procedure: create_workout_plan
        result = call_procedure('create_workout_plan', [trainer_id, member_id, plan_name])
        
        if result and result[0][0] == 'PLAN CREATED':
            plan_id = result[0][1]
            messages.success(request, f'Workout plan "{plan_name}" created successfully!')
            return redirect('trainer_plan_detail', plan_id=plan_id)
        else:
            error_msg = result[0][1] if result else 'Failed to create plan'
            messages.error(request, error_msg)
    
    # Get trainer's members for dropdown
    members_data = call_procedure('get_trainer_all_members', [trainer_id])
    
    members = []
    for row in members_data:
        members.append({
            'member_id': row[0],
            'name': row[1],
            'email': row[2]
        })
    
    context = {
        'members': members
    }
    return render(request, 'workout_plans/create_workout_plan.html', context)


def trainer_plan_detail(request, plan_id):
    """View details of a workout plan (trainer view)"""
    if request.session.get('user_type') != 'trainer':
        messages.error(request, 'Please log in as a trainer')
        return redirect('trainer_login')
    
    trainer_id = request.session.get('user_id')
    
    with connection.cursor() as cursor:

        cursor.callproc('get_plan_exercises', [plan_id])
        

        plan_overview = cursor.fetchall()
        
        if not plan_overview:
            messages.error(request, 'Workout plan not found')
            return redirect('trainer_plan_list')
        
        first_row = plan_overview[0]
        plan = {
            'plan_id': first_row[0],
            'plan_name': first_row[1],
            'trainer_id': first_row[2],
            'trainer_name': first_row[3],
            'specialization': first_row[4],
            'member_id': first_row[5],
            'member_name': first_row[6],
            'total_exercises': first_row[7]
        }
        

        if plan['trainer_id'] != trainer_id:
            messages.error(request, 'Unauthorized access')
            return redirect('trainer_plan_list')
        

        cursor.nextset()
        exercises_data = cursor.fetchall()
        
        exercises = []
        for row in exercises_data:
            exercises.append({
                'plan_exercise_id': row[0],
                'exercise_id': row[1],
                'exercise_name': row[2],
                'category': row[3],
                'muscle_group': row[4],
                'target_sets': row[5],
                'target_reps': row[6],
                'target_weight': row[7],
                'formatted_target': row[8]
            })
        

        cursor.nextset()
        muscle_groups = cursor.fetchall()
    
    context = {
        'plan': plan,
        'exercises': exercises,
        'muscle_groups': muscle_groups
    }
    return render(request, 'workout_plans/trainer_plan_detail.html', context)


def add_exercise_to_plan(request, plan_id):
    """Add an exercise to a workout plan"""
    if request.session.get('user_type') != 'trainer':
        messages.error(request, 'Please log in as a trainer')
        return redirect('trainer_login')
    
    trainer_id = request.session.get('user_id')
    
    if request.method == 'POST':
        exercise_id = request.POST.get('exercise_id')
        target_sets = request.POST.get('target_sets', 3)
        target_reps = request.POST.get('target_reps', 10)
        target_weight = request.POST.get('target_weight', 0)
        

        result = call_procedure('add_exercise_to_plan', [
            plan_id, exercise_id, target_sets, target_reps, target_weight, trainer_id
        ])
        
        if result and result[0][0] == 'EXERCISE ADDED':
            messages.success(request, f'Exercise added to plan!')
        else:
            error_msg = result[0][1] if result else 'Failed to add exercise'
            messages.error(request, error_msg)
        
        return redirect('trainer_plan_detail', plan_id=plan_id)
    

    search_query = request.GET.get('search', '')
    category_filter = request.GET.get('category', '')
    
    exercises_data = call_procedure('find_exercises_by_criteria', [
        search_query or None, category_filter or None, None
    ])
    
    exercises = []
    for row in exercises_data:
        exercises.append({
            'exercise_id': row[0],
            'name': row[1],
            'category': row[2],
            'muscle_group': row[3]
        })
    

    with connection.cursor() as cursor:
        cursor.execute("SELECT DISTINCT category FROM Exercise ORDER BY category")
        categories = [row[0] for row in cursor.fetchall()]
    
    context = {
        'plan_id': plan_id,
        'exercises': exercises,
        'categories': categories,
        'search_query': search_query,
        'category_filter': category_filter
    }
    return render(request, 'workout_plans/add_exercise_to_plan.html', context)


def delete_workout_plan(request, plan_id):
    """Delete a workout plan"""
    if request.session.get('user_type') != 'trainer':
        messages.error(request, 'Please log in as a trainer')
        return redirect('trainer_login')
    
    trainer_id = request.session.get('user_id')
    
    if request.method == 'POST':
        result = call_procedure('remove_workout_plan', [plan_id, trainer_id])
        
        if result and result[0][0] == 'DELETION SUCCESSFUL':
            messages.success(request, 'Workout plan deleted successfully!')
        else:
            error_msg = result[0][1] if result else 'Failed to delete plan'
            messages.error(request, error_msg)
    
    return redirect('trainer_plan_list')



def member_plan_list(request):
    """List all workout plans assigned to member"""
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    member_id = request.session.get('user_id')
    

    plans_data = call_procedure('get_member_all_workout_plans', [member_id])
    
    plans = []
    for row in plans_data:
        plans.append({
            'plan_id': row[0],
            'plan_name': row[1],
            'trainer_id': row[2],
            'trainer_name': row[3],
            'trainer_specialization': row[4],
            'total_exercises': row[5],
            'exercises_list': row[6],
            'times_used': row[7],
            'last_used': row[8]
        })
    
    context = {
        'plans': plans
    }
    return render(request, 'workout_plans/member_plan_list.html', context)


def member_plan_detail(request, plan_id):
    """View details of a workout plan (member view)"""
    if request.session.get('user_type') != 'member':
        messages.error(request, 'Please log in as a member')
        return redirect('member_login')
    
    member_id = request.session.get('user_id')
    
    with connection.cursor() as cursor:
        cursor.callproc('get_plan_exercises', [plan_id])
        

        plan_overview = cursor.fetchall()
        
        if not plan_overview:
            messages.error(request, 'Workout plan not found')
            return redirect('member_plan_list')
        
        first_row = plan_overview[0]
        plan = {
            'plan_id': first_row[0],
            'plan_name': first_row[1],
            'trainer_name': first_row[3],
            'specialization': first_row[4],
            'member_id': first_row[5],
            'total_exercises': first_row[7]
        }
        

        if plan['member_id'] != member_id:
            messages.error(request, 'Unauthorized access')
            return redirect('member_plan_list')
        

        cursor.nextset()
        exercises_data = cursor.fetchall()
        
        exercises = []
        for row in exercises_data:
            exercises.append({
                'exercise_name': row[2],
                'category': row[3],
                'muscle_group': row[4],
                'target_sets': row[5],
                'target_reps': row[6],
                'target_weight': row[7],
                'formatted_target': row[8]
            })
        

        cursor.nextset()
        muscle_groups_data = cursor.fetchall()
        
        muscle_groups = []
        for row in muscle_groups_data:
            muscle_groups.append({
                'muscle_group': row[0],
                'exercise_count': row[1],
                'total_sets': row[2]
            })
    
    context = {
        'plan': plan,
        'exercises': exercises,
        'muscle_groups': muscle_groups
    }
    return render(request, 'workout_plans/member_plan_detail.html', context)