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

-- 9. Get Average Duration of Workouts for Member
DELIMITER $$
CREATE PROCEDURE get_member_avg_workout_duration(
    IN p_member_id INT
)
BEGIN
    SELECT 
        m.member_id,
        m.name AS member_name,
        COUNT(w.workout_id) AS total_workouts,
        COALESCE(AVG(w.duration), 0) AS average_duration_minutes,
        COALESCE(MIN(w.duration), 0) AS shortest_workout_minutes,
        COALESCE(MAX(w.duration), 0) AS longest_workout_minutes
    FROM Member m
    LEFT JOIN Workout w ON m.member_id = w.member_id
    WHERE m.member_id = p_member_id
    GROUP BY m.member_id, m.name;
END $$
DELIMITER ;

CALL get_member_avg_workout_duration(2); 

-- TRAINER

-- ============================================================================
-- TRAINER STATISTICS PROCEDURES
-- ============================================================================

-- 1. Get Total Clients for Trainer
DELIMITER $$
CREATE PROCEDURE get_trainer_total_clients(
    IN p_trainer_id INT
)
BEGIN
    SELECT 
        t.trainer_id,
        t.name AS trainer_name,
        t.specialization,
        COUNT(DISTINCT a.member_id) AS total_clients
    FROM Trainer t
    LEFT JOIN Appointment a ON t.trainer_id = a.trainer_id
    WHERE t.trainer_id = p_trainer_id
    GROUP BY t.trainer_id, t.name, t.specialization;
END $$
DELIMITER ;

CALL get_trainer_total_clients(10); 

-- 2. Get Count of Scheduled Appointments for Trainer
DELIMITER $$
CREATE PROCEDURE get_trainer_scheduled_appointments_count(
    IN p_trainer_id INT
)
BEGIN
    SELECT 
        t.trainer_id,
        t.name AS trainer_name,
        COUNT(a.appointment_id) AS scheduled_appointments_count
    FROM Trainer t
    LEFT JOIN Appointment a ON t.trainer_id = a.trainer_id
    WHERE t.trainer_id = p_trainer_id
      AND a.status = 'Scheduled'
      AND a.start_time >= NOW()
    GROUP BY t.trainer_id, t.name;
END $$
DELIMITER ;

CALL get_trainer_scheduled_appointments_count(5); 

-- 3. Get Number of Workout Plans Created by Trainer
DELIMITER $$
CREATE PROCEDURE get_trainer_workout_plans_count(
    IN p_trainer_id INT
)
BEGIN
    SELECT 
        t.trainer_id,
        t.name AS trainer_name,
        t.specialization,
        COUNT(wp.plan_id) AS workout_plans_created
    FROM Trainer t
    LEFT JOIN Workout_Plan wp ON t.trainer_id = wp.trainer_id
    WHERE t.trainer_id = p_trainer_id
    GROUP BY t.trainer_id, t.name, t.specialization;
END $$
DELIMITER ;

CALL get_trainer_workout_plans_count(5); 

-- 4. Get List of Appointments by Status for Trainer
DELIMITER $$
CREATE PROCEDURE get_trainer_appointments_by_status(
    IN p_trainer_id INT,
    IN p_status VARCHAR(20)  -- 'Scheduled', 'Completed', 'Cancelled', 'All'
)
BEGIN
    IF p_status = 'All' THEN
        SELECT 
            a.appointment_id,
            a.start_time,
            a.end_time,
            a.status,
            m.member_id,
            m.name AS member_name,
            m.email AS member_email,
            m.age,
            m.gender,
            g.gym_name,
            CASE 
                WHEN a.start_time > NOW() THEN CONCAT('In ', TIMESTAMPDIFF(HOUR, NOW(), a.start_time), ' hours')
                WHEN a.start_time < NOW() AND a.status = 'Scheduled' THEN 'Overdue'
                ELSE '-'
            END AS time_status
        FROM Appointment a
        JOIN Member m ON a.member_id = m.member_id
        JOIN Trainer t ON a.trainer_id = t.trainer_id
        JOIN Gym g ON t.gym_id = g.gym_id
        WHERE a.trainer_id = p_trainer_id
        ORDER BY a.start_time DESC;
    ELSE
        SELECT 
            a.appointment_id,
            a.start_time,
            a.end_time,
            a.status,
            m.member_id,
            m.name AS member_name,
            m.email AS member_email,
            m.age,
            m.gender,
            g.gym_name,
            CASE 
                WHEN a.start_time > NOW() THEN CONCAT('In ', TIMESTAMPDIFF(HOUR, NOW(), a.start_time), ' hours')
                WHEN a.start_time < NOW() AND a.status = 'Scheduled' THEN 'Overdue'
                ELSE '-'
            END AS time_status
        FROM Appointment a
        JOIN Member m ON a.member_id = m.member_id
        JOIN Trainer t ON a.trainer_id = t.trainer_id
        JOIN Gym g ON t.gym_id = g.gym_id
        WHERE a.trainer_id = p_trainer_id
          AND a.status = p_status
        ORDER BY a.start_time DESC;
    END IF;
END $$
DELIMITER ;

CALL get_trainer_appointments_by_status(5, 'Scheduled'); 

-- 5. Get All Members Assigned to a Trainer
DELIMITER $$
CREATE PROCEDURE get_trainer_all_members(
    IN p_trainer_id INT
)
BEGIN
    SELECT DISTINCT
        m.member_id,
        m.name AS member_name,
        m.email,
        m.age,
        m.gender,
        m.height,
        m.weight,
        m.join_date,
        COUNT(DISTINCT a.appointment_id) AS total_appointments,
        COUNT(DISTINCT CASE WHEN a.status = 'Completed' THEN a.appointment_id END) AS completed_appointments,
        COUNT(DISTINCT wp.plan_id) AS workout_plans_created,
        MAX(a.start_time) AS last_appointment_date,
        COUNT(DISTINCT w.workout_id) AS total_workouts_logged,
        MAX(w.date) AS last_workout_date,
        ms.status AS membership_status
    FROM Appointment a
    JOIN Member m ON a.member_id = m.member_id
    LEFT JOIN Workout_Plan wp ON m.member_id = wp.member_id AND a.trainer_id = wp.trainer_id
    LEFT JOIN Workout w ON m.member_id = w.member_id
    LEFT JOIN Membership ms ON m.member_id = ms.member_id
    WHERE a.trainer_id = p_trainer_id
    GROUP BY m.member_id, m.name, m.email, m.age, m.gender, m.height, m.weight, m.join_date, ms.status
    ORDER BY last_appointment_date DESC;
END $$
DELIMITER ;

CALL get_trainer_all_members(5); 

-- 6. Get Each Member's Progress (for specific member)
DELIMITER $$
CREATE PROCEDURE get_member_progress_for_trainer(
    IN p_trainer_id INT,
    IN p_member_id INT
)
BEGIN
    -- Member Overview
    SELECT 
        m.member_id,
        m.name AS member_name,
        m.email,
        m.age,
        m.gender,
        m.height,
        m.weight,
        COUNT(DISTINCT w.workout_id) AS total_workouts,
        SUM(w.duration) AS total_minutes,
        SUM(w.calories_burned) AS total_calories,
        MAX(w.date) AS last_workout_date,
        DATEDIFF(CURDATE(), MAX(w.date)) AS days_since_last_workout,
        COUNT(DISTINCT a.appointment_id) AS appointments_with_trainer,
        MAX(a.start_time) AS last_appointment_with_trainer
    FROM Member m
    LEFT JOIN Workout w ON m.member_id = w.member_id
    LEFT JOIN Appointment a ON m.member_id = a.member_id AND a.trainer_id = p_trainer_id
    WHERE m.member_id = p_member_id
    GROUP BY m.member_id, m.name, m.email, m.age, m.gender, m.height, m.weight;
    
    -- Workout Plans Created by This Trainer for This Member
    SELECT 
        wp.plan_id,
        wp.plan_name,
        COUNT(pe.plan_exercise_id) AS exercises_in_plan,
        COUNT(DISTINCT w.workout_id) AS times_used,
        MAX(w.date) AS last_used_date
    FROM Workout_Plan wp
    LEFT JOIN Plan_Exercise pe ON wp.plan_id = pe.plan_id
    LEFT JOIN Workout w ON wp.plan_id = w.plan_id AND w.member_id = p_member_id
    WHERE wp.trainer_id = p_trainer_id
      AND wp.member_id = p_member_id
    GROUP BY wp.plan_id, wp.plan_name;
    
    -- Recent Workout Performance
    SELECT 
        w.workout_id,
        w.date,
        w.duration,
        w.calories_burned,
        COUNT(DISTINCT s.exercise_id) AS exercises_performed,
        COUNT(s.set_id) AS total_sets
    FROM Workout w
    LEFT JOIN `Set` s ON w.workout_id = s.workout_id
    WHERE w.member_id = p_member_id
    GROUP BY w.workout_id, w.date, w.duration, w.calories_burned
    ORDER BY w.date DESC
    LIMIT 10;
    
    -- Exercise Progress (showing strength gains)
    SELECT 
        e.exercise_name,
        e.target_muscle_group,
        COUNT(DISTINCT w.workout_id) AS times_performed,
        MAX(s.weight) AS max_weight,
        AVG(s.weight) AS avg_weight,
        MAX(s.no_of_reps) AS max_reps,
        AVG(s.no_of_reps) AS avg_reps,
        MIN(w.date) AS first_performed,
        MAX(w.date) AS last_performed
    FROM Workout w
    JOIN `Set` s ON w.workout_id = s.workout_id
    JOIN Exercise e ON s.exercise_id = e.exercise_id
    WHERE w.member_id = p_member_id
      AND s.weight > 0
    GROUP BY e.exercise_id, e.exercise_name, e.target_muscle_group
    ORDER BY max_weight DESC
    LIMIT 10;
END $$
DELIMITER ;

CALL get_member_progress_for_trainer(1, 1); 

-- 7. Get Daily Appointment Schedule for Trainer
DELIMITER $$
CREATE PROCEDURE get_trainer_daily_schedule(
    IN p_trainer_id INT,
    IN p_date DATE
)
BEGIN
    SELECT 
        a.appointment_id,
        a.start_time,
        a.end_time,
        a.status,
        TIME(a.start_time) AS start_time_only,
        TIME(a.end_time) AS end_time_only,
        TIMESTAMPDIFF(MINUTE, a.start_time, a.end_time) AS duration_minutes,
        m.member_id,
        m.name AS member_name,
        m.email AS member_email,
        m.age,
        m.gender,
        g.gym_name,
        CASE 
            WHEN a.start_time > NOW() THEN 'Upcoming'
            WHEN a.end_time < NOW() AND a.status = 'Scheduled' THEN 'Missed'
            WHEN a.start_time <= NOW() AND a.end_time >= NOW() THEN 'In Progress'
            ELSE a.status
        END AS appointment_state
    FROM Appointment a
    JOIN Member m ON a.member_id = m.member_id
    JOIN Trainer t ON a.trainer_id = t.trainer_id
    JOIN Gym g ON t.gym_id = g.gym_id
    WHERE a.trainer_id = p_trainer_id
      AND DATE(a.start_time) = p_date
    ORDER BY a.start_time ASC;
END $$
DELIMITER ;

CALL get_trainer_daily_schedule(4, '2025-12-06'); 

-- Workout

-- a. Create New Workout
DELIMITER $$
CREATE PROCEDURE create_new_workout(
    IN p_member_id INT,
    IN p_gym_id INT,
    IN p_plan_id INT,  -- Can be NULL for freestyle workout
    IN p_date DATE,
    IN p_duration INT,
    IN p_calories_burned INT
)
BEGIN
    DECLARE v_workout_id INT;
    
    INSERT INTO Workout (member_id, gym_id, plan_id, date, duration, calories_burned)
    VALUES (p_member_id, p_gym_id, p_plan_id, p_date, p_duration, p_calories_burned);
    
    SET v_workout_id = LAST_INSERT_ID();
    
    SELECT 
        v_workout_id AS workout_id,
        'Workout created successfully' AS message,
        p_date AS workout_date,
        CASE WHEN p_plan_id IS NOT NULL THEN 'Following Plan' ELSE 'Freestyle' END AS workout_type;
END $$
DELIMITER ;

CALL create_new_workout(1, 1, null, '2025-12-03', 65, 450); 

-- b. Add Sets to a Workout
DELIMITER $$
CREATE PROCEDURE add_set_to_workout(
    IN p_workout_id INT,
    IN p_exercise_id INT,
    IN p_reps INT,
    IN p_weight DECIMAL(5,2)
)
BEGIN
    DECLARE v_set_id INT;
    DECLARE v_exercise_name VARCHAR(100);
    
    -- Get exercise name for confirmation
    SELECT exercise_name INTO v_exercise_name
    FROM Exercise
    WHERE exercise_id = p_exercise_id;
    
    -- Insert the set
    INSERT INTO `Set` (workout_id, exercise_id, no_of_reps, weight)
    VALUES (p_workout_id, p_exercise_id, p_reps, p_weight);
    
    SET v_set_id = LAST_INSERT_ID();
    
    SELECT 
        v_set_id AS set_id,
        p_workout_id AS workout_id,
        v_exercise_name AS exercise_name,
        p_reps AS reps,
        p_weight AS weight,
        'Set added successfully' AS message;
END $$
DELIMITER ;

CALL add_set_to_workout(1, 1, 6, 80.0); 

-- c. Get Full Workout with All Sets and Exercises
DELIMITER $$
CREATE PROCEDURE get_full_workout_details(
    IN p_workout_id INT
)
BEGIN
    -- Workout Overview
    SELECT 
        w.workout_id,
        w.date AS workout_date,
        w.duration AS duration_minutes,
        w.calories_burned,
        m.member_id,
        m.name AS member_name,
        g.gym_id,
        g.gym_name,
        wp.plan_id,
        wp.plan_name,
        t.name AS trainer_name,
        COUNT(DISTINCT s.exercise_id) AS total_exercises,
        COUNT(s.set_id) AS total_sets,
        SUM(s.no_of_reps) AS total_reps
    FROM Workout w
    JOIN Member m ON w.member_id = m.member_id
    JOIN Gym g ON w.gym_id = g.gym_id
    LEFT JOIN Workout_Plan wp ON w.plan_id = wp.plan_id
    LEFT JOIN Trainer t ON wp.trainer_id = t.trainer_id
    LEFT JOIN `Set` s ON w.workout_id = s.workout_id
    WHERE w.workout_id = p_workout_id
    GROUP BY w.workout_id, w.date, w.duration, w.calories_burned, 
             m.member_id, m.name, g.gym_id, g.gym_name, wp.plan_id, wp.plan_name, t.name;
    
    -- All Sets and Exercises Performed
    SELECT 
        s.set_id,
        e.exercise_id,
        e.exercise_name,
        e.category,
        e.target_muscle_group,
        s.no_of_reps AS reps,
        s.weight,
        ROW_NUMBER() OVER (PARTITION BY e.exercise_id ORDER BY s.set_id) AS set_number_for_exercise
    FROM `Set` s
    JOIN Exercise e ON s.exercise_id = e.exercise_id
    WHERE s.workout_id = p_workout_id
    ORDER BY e.exercise_name, s.set_id;
    
    -- Exercise Summary (grouped by exercise)
    SELECT 
        e.exercise_id,
        e.exercise_name,
        e.target_muscle_group,
        COUNT(s.set_id) AS sets_performed,
        SUM(s.no_of_reps) AS total_reps,
        AVG(s.no_of_reps) AS avg_reps,
        MAX(s.weight) AS max_weight,
        AVG(s.weight) AS avg_weight
    FROM `Set` s
    JOIN Exercise e ON s.exercise_id = e.exercise_id
    WHERE s.workout_id = p_workout_id
    GROUP BY e.exercise_id, e.exercise_name, e.target_muscle_group
    ORDER BY e.exercise_name;
END $$
DELIMITER ;

CALL get_full_workout_details(1); 

-- d. Get Progress on Specific Exercise
DELIMITER $$
CREATE PROCEDURE get_exercise_progress(
    IN p_member_id INT,
    IN p_exercise_id INT
)
BEGIN
    SELECT 
        w.workout_id,
        w.date AS workout_date,
        e.exercise_id,
        e.exercise_name,
        e.target_muscle_group,
        s.set_id,
        s.no_of_reps AS reps,
        s.weight,
        ROW_NUMBER() OVER (PARTITION BY w.workout_id ORDER BY s.set_id) AS set_number,
        MAX(s.weight) OVER (PARTITION BY w.workout_id) AS max_weight_that_day,
        MAX(s.no_of_reps) OVER (PARTITION BY w.workout_id) AS max_reps_that_day,
        COUNT(s.set_id) OVER (PARTITION BY w.workout_id) AS total_sets_that_day
    FROM Workout w
    JOIN `Set` s ON w.workout_id = s.workout_id
    JOIN Exercise e ON s.exercise_id = e.exercise_id
    WHERE w.member_id = p_member_id
      AND s.exercise_id = p_exercise_id
    ORDER BY w.date DESC, s.set_id;
    
    -- Summary Statistics
    SELECT 
        e.exercise_name,
        COUNT(DISTINCT w.workout_id) AS times_performed,
        COUNT(s.set_id) AS total_sets_all_time,
        SUM(s.no_of_reps) AS total_reps_all_time,
        MAX(s.weight) AS all_time_max_weight,
        AVG(s.weight) AS avg_weight_all_time,
        MAX(s.no_of_reps) AS all_time_max_reps,
        AVG(s.no_of_reps) AS avg_reps_all_time,
        MIN(w.date) AS first_performed_date,
        MAX(w.date) AS most_recent_date,
        DATEDIFF(MAX(w.date), MIN(w.date)) AS training_duration_days
    FROM Workout w
    JOIN `Set` s ON w.workout_id = s.workout_id
    JOIN Exercise e ON s.exercise_id = e.exercise_id
    WHERE w.member_id = p_member_id
      AND s.exercise_id = p_exercise_id
    GROUP BY e.exercise_id, e.exercise_name;
END $$
DELIMITER ;

CALL get_exercise_progress(1, 1); 

-- e. Find Exercises by Criteria
DELIMITER $$
CREATE PROCEDURE find_exercises_by_criteria(
    IN p_search_term VARCHAR(100),
    IN p_category VARCHAR(50),
    IN p_target_muscle VARCHAR(100)
)
BEGIN
    SELECT 
        e.exercise_id,
        e.exercise_name,
        e.category,
        e.target_muscle_group,
        COUNT(DISTINCT s.workout_id) AS times_used_in_workouts,
        COUNT(DISTINCT w.member_id) AS used_by_members
    FROM Exercise e
    LEFT JOIN `Set` s ON e.exercise_id = s.exercise_id
    LEFT JOIN Workout w ON s.workout_id = w.workout_id
    WHERE 
        (p_search_term IS NULL OR p_search_term = '' OR 
         e.exercise_name LIKE CONCAT('%', p_search_term, '%'))
        AND
        (p_category IS NULL OR p_category = '' OR 
         e.category = p_category)
        AND
        (p_target_muscle IS NULL OR p_target_muscle = '' OR 
         e.target_muscle_group LIKE CONCAT('%', p_target_muscle, '%'))
    GROUP BY e.exercise_id, e.exercise_name, e.category, e.target_muscle_group
    ORDER BY e.exercise_name;
END $$
DELIMITER ;

CALL find_exercises_by_criteria('Dumbbell', 'Strength', 'Shoulders'); 
