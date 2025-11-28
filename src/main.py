from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
import json
from config import get_db_connection

app = Flask(__name__)
app.secret_key = 'supersecretkey'  # Needed for flashing error messages

# --- ROUTE: Home Page ---
@app.route('/')
def index():
    return render_template('index.html')

# --- ROUTE: View All Members (READ Operation) ---
@app.route('/members')
def members():
    conn = get_db_connection()
    members_data = []
    if conn:
        try:
            with conn.cursor() as cursor:
                # Based on your PDF schema: Member table has member_id, name, email, etc.
                sql = "SELECT member_id, name, email, status FROM Member"
                cursor.execute(sql)
                members_data = cursor.fetchall()
        finally:
            conn.close()
    
    return render_template('members.html', members=members_data)

# --- ROUTE: Add New Member (CREATE Operation) ---
@app.route('/add_member', methods=['POST'])
def add_member():
    if request.method == 'POST':
        # Get data from the HTML form
        name = request.form['name']
        email = request.form['email']
        password = request.form['password'] # In real app, hash this!
        
        conn = get_db_connection()
        if conn:
            try:
                with conn.cursor() as cursor:
                    # Execute SQL Insert
                    sql = "INSERT INTO Member (name, email, password, join_date, status) VALUES (%s, %s, %s, CURDATE(), 'Active')"
                    cursor.execute(sql, (name, email, password))
                conn.commit() # Save changes
                flash('Member added successfully!')
            except Exception as e:
                conn.rollback()
                flash(f'Error: {str(e)}')
            finally:
                conn.close()
        
        return redirect(url_for('members'))
    

@app.route('/create_plan')
def create_plan():
    conn = get_db_connection()
    exercises = []
    if conn:
        try:
            with conn.cursor() as cursor:
                # Fetch all exercises to populate the dropdown/list
                cursor.execute("SELECT * FROM Exercise ORDER BY name ASC")
                exercises = cursor.fetchall()
        finally:
            conn.close()
    return render_template('create_plan.html', exercises=exercises)

# --- ROUTE: Save the Plan (The Logic) ---
@app.route('/save_plan', methods=['POST'])
def save_plan():
    if request.method == 'POST':
        data = request.get_json() # Get data sent from JavaScript
        
        plan_name = data.get('plan_name')
        member_id = 1  # Hardcoded for demo (In real app, use session['user_id'])
        exercises = data.get('exercises') # List of {id, sets, reps}

        conn = get_db_connection()
        if conn:
            try:
                with conn.cursor() as cursor:
                    # 1. Create the Plan Header
                    sql_plan = "INSERT INTO Workout_Plan (member_id, plan_name) VALUES (%s, %s)"
                    cursor.execute(sql_plan, (member_id, plan_name))
                    new_plan_id = cursor.lastrowid # Get the ID of the plan we just made
                    
                    # 2. Add each Exercise to the plan
                    sql_details = "INSERT INTO Plan_Exercise (plan_id, exercise_id, sets, reps) VALUES (%s, %s, %s, %s)"
                    for ex in exercises:
                        cursor.execute(sql_details, (new_plan_id, ex['id'], ex['sets'], ex['reps']))
                
                conn.commit()
                return jsonify({'status': 'success', 'message': 'Plan saved successfully!'})
            except Exception as e:
                conn.rollback()
                return jsonify({'status': 'error', 'message': str(e)})
            finally:
                conn.close()
                
    return jsonify({'status': 'error', 'message': 'Invalid request'})

# --- HELPER: Seed Database (Run this once to load your JSON) ---
@app.route('/seed_db')
def seed_db():
    try:
        with open('data/exercises.json', 'r') as f:
            exercises = json.load(f)
        
        conn = get_db_connection()
        with conn.cursor() as cursor:
            sql = "INSERT INTO Exercise (name, difficulty, target_muscle, equipment) VALUES (%s, %s, %s, %s)"
            for ex in exercises:
                cursor.execute(sql, (ex['name'], ex['difficulty'], ex['target_muscle'], ex['equipment']))
        conn.commit()
        return "Database seeded with exercises!"
    except Exception as e:
        return f"Error: {e}"

if __name__ == '__main__':
    app.run(debug=True)



if __name__ == '__main__':
    app.run(debug=True)