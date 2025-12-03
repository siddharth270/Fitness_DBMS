-- MEMBER

-- 1. Get Total Workouts Completed by Member
DELIMITER $$
CREATE PROCEDURE get_member_total_workouts(
    IN p_member_id INT
)
BEGIN
    SELECT 
        m.member_id,
        m.name,
        COUNT(w.workout_id) AS total_workouts_completed
    FROM Member m
    LEFT JOIN Workout w ON m.member_id = w.member_id
    WHERE m.member_id = p_member_id
    GROUP BY m.member_id, m.name;
END $$
DELIMITER ;

CALL get_member_total_workouts(5); 

-- 2. Get Sum of All Calories Burned by Member
DELIMITER $$
CREATE PROCEDURE get_member_total_calories(
    IN p_member_id INT
)
BEGIN
    SELECT 
        m.member_id,
        m.name,
        COALESCE(SUM(w.calories_burned), 0) AS total_calories_burned
    FROM Member m
    LEFT JOIN Workout w ON m.member_id = w.member_id
    WHERE m.member_id = p_member_id
    GROUP BY m.member_id, m.name;
END $$
DELIMITER ;

CALL get_member_total_calories(5); 

-- 3. Get Most Recent Workout Date for Member
DELIMITER $$
CREATE PROCEDURE get_member_most_recent_workout(
    IN p_member_id INT
)
BEGIN
    SELECT 
        m.member_id,
        m.name,
        MAX(w.date) AS most_recent_workout_date,
        DATEDIFF(CURDATE(), MAX(w.date)) AS days_since_last_workout
    FROM Member m
    LEFT JOIN Workout w ON m.member_id = w.member_id
    WHERE m.member_id = p_member_id
    GROUP BY m.member_id, m.name;
END $$
DELIMITER ;

CALL get_member_most_recent_workout(5); 

-- 4. Get Active Gym Membership Name for Member
DELIMITER $$
CREATE PROCEDURE get_member_active_gym(
    IN p_member_id INT
)
BEGIN
    SELECT 
        m.member_id,
        m.name AS member_name,
        g.gym_id,
        g.gym_name,
        g.location,
        ms.status AS membership_status,
        ms.start_date,
        ms.end_date,
        DATEDIFF(ms.end_date, CURDATE()) AS days_remaining
    FROM Member m
    JOIN Membership ms ON m.member_id = ms.member_id
    JOIN Gym g ON ms.gym_id = g.gym_id
    WHERE m.member_id = p_member_id
      AND ms.status = 'Active';
END $$
DELIMITER ;

CALL get_member_active_gym(10); 

-- 5. Get Number of Active Workout Plans for Member
DELIMITER $$
CREATE PROCEDURE get_member_active_plans_count(
    IN p_member_id INT
)
BEGIN
    SELECT 
        m.member_id,
        m.name,
        COUNT(wp.plan_id) AS number_of_active_workout_plans
    FROM Member m
    LEFT JOIN Workout_Plan wp ON m.member_id = wp.member_id
    WHERE m.member_id = p_member_id
    GROUP BY m.member_id, m.name;
END $$
DELIMITER ;

CALL get_member_active_plans_count(11); 

-- 6. Get Recent Workouts with Details
DELIMITER $$
CREATE PROCEDURE get_member_recent_workouts(
    IN p_member_id INT,
    IN p_limit INT
)
BEGIN
    SELECT 
        w.workout_id,
        w.date,
        w.duration AS duration_minutes,
        w.calories_burned,
        g.gym_name,
        wp.plan_name,
        t.name AS trainer_name,
        COUNT(DISTINCT s.exercise_id) AS unique_exercises_performed,
        COUNT(s.set_id) AS total_sets_performed,
        GROUP_CONCAT(DISTINCT e.exercise_name ORDER BY e.exercise_name SEPARATOR ', ') AS exercises_list
    FROM Workout w
    JOIN Gym g ON w.gym_id = g.gym_id
    LEFT JOIN Workout_Plan wp ON w.plan_id = wp.plan_id
    LEFT JOIN Trainer t ON wp.trainer_id = t.trainer_id
    LEFT JOIN `Set` s ON w.workout_id = s.workout_id
    LEFT JOIN Exercise e ON s.exercise_id = e.exercise_id
    WHERE w.member_id = p_member_id
    GROUP BY w.workout_id, w.date, w.duration, w.calories_burned, g.gym_name, wp.plan_name, t.name
    ORDER BY w.date DESC
    LIMIT p_limit;
END $$
DELIMITER ;

CALL get_member_recent_workouts(1, 10);

-- 7. Get All Workout Plans Assigned to Member
DELIMITER $$
CREATE PROCEDURE get_member_all_workout_plans(
    IN p_member_id INT
)
BEGIN
    SELECT 
        wp.plan_id,
        wp.plan_name,
        t.trainer_id,
        t.name AS trainer_name,
        t.specialization AS trainer_specialization,
        COUNT(pe.plan_exercise_id) AS total_exercises_in_plan,
        GROUP_CONCAT(DISTINCT e.exercise_name ORDER BY e.exercise_name SEPARATOR ', ') AS exercises_list,
        COUNT(DISTINCT w.workout_id) AS times_used_in_workouts,
        MAX(w.date) AS last_used_date
    FROM Workout_Plan wp
    JOIN Trainer t ON wp.trainer_id = t.trainer_id
    LEFT JOIN Plan_Exercise pe ON wp.plan_id = pe.plan_id
    LEFT JOIN Exercise e ON pe.exercise_id = e.exercise_id
    LEFT JOIN Workout w ON wp.plan_id = w.plan_id AND w.member_id = p_member_id
    WHERE wp.member_id = p_member_id
    GROUP BY wp.plan_id, wp.plan_name, t.trainer_id, t.name, t.specialization
    ORDER BY wp.plan_id DESC;
END $$
DELIMITER ;

CALL get_member_all_workout_plans(11);

-- 8. Get Monthly Workout Stats for Member
DELIMITER $$
CREATE PROCEDURE get_member_monthly_stats(
    IN p_member_id INT,
    IN p_num_months INT
)
BEGIN
    SELECT 
        DATE_FORMAT(w.date, '%Y-%m') AS month,
        COUNT(w.workout_id) AS workouts_this_month,
        COUNT(DISTINCT DATE(w.date)) AS active_days,
        SUM(w.duration) AS total_minutes,
        AVG(w.duration) AS avg_workout_duration,
        SUM(w.calories_burned) AS total_calories,
        AVG(w.calories_burned) AS avg_calories_per_workout,
        COUNT(DISTINCT w.plan_id) AS different_plans_used,
        COUNT(DISTINCT s.exercise_id) AS unique_exercises_performed,
        COUNT(s.set_id) AS total_sets_performed
    FROM Workout w
    LEFT JOIN `Set` s ON w.workout_id = s.workout_id
    WHERE w.member_id = p_member_id
      AND w.date >= DATE_SUB(CURDATE(), INTERVAL p_num_months MONTH)
    GROUP BY DATE_FORMAT(w.date, '%Y-%m')
    ORDER BY month DESC;
END $$
DELIMITER ;

CALL get_member_monthly_stats(5, 20);

-- TRAINER



