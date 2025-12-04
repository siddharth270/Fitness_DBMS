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

-- ============================================================================
-- APPOINTMENT MANAGEMENT PROCEDURES
-- ============================================================================

-- a. Check Appointment Conflict by Date Time
DELIMITER $$
CREATE PROCEDURE check_appointment_conflict(
    IN p_trainer_id INT,
    IN p_start_time DATETIME,
    IN p_end_time DATETIME
)
BEGIN
    SELECT 
        a.appointment_id,
        a.start_time,
        a.end_time,
        a.status,
        m.name AS member_name,
        CASE 
            WHEN (p_start_time BETWEEN a.start_time AND a.end_time) OR
                 (p_end_time BETWEEN a.start_time AND a.end_time) OR
                 (a.start_time BETWEEN p_start_time AND p_end_time) THEN 'CONFLICT'
            ELSE 'NO CONFLICT'
        END AS conflict_status
    FROM Appointment a
    JOIN Member m ON a.member_id = m.member_id
    WHERE a.trainer_id = p_trainer_id
      AND a.status IN ('Scheduled', 'In Progress')
      AND (
          (p_start_time BETWEEN a.start_time AND a.end_time) OR
          (p_end_time BETWEEN a.start_time AND a.end_time) OR
          (a.start_time BETWEEN p_start_time AND p_end_time)
      );
    
    -- Summary Result
    SELECT 
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM Appointment a
                WHERE a.trainer_id = p_trainer_id
                  AND a.status IN ('Scheduled', 'In Progress')
                  AND (
                      (p_start_time BETWEEN a.start_time AND a.end_time) OR
                      (p_end_time BETWEEN a.start_time AND a.end_time) OR
                      (a.start_time BETWEEN p_start_time AND p_end_time)
                  )
            ) THEN 'CONFLICT DETECTED'
            ELSE 'TIME SLOT AVAILABLE'
        END AS availability_status,
        p_start_time AS requested_start_time,
        p_end_time AS requested_end_time;
END $$
DELIMITER ;

CALL check_appointment_conflict(1, '2025-11-15 10:00:00', '2025-11-15 11:00:00'); 

-- b. Return Available Hours for Trainer on Specific Date
DELIMITER $$
CREATE PROCEDURE get_trainer_available_hours(
    IN p_trainer_id INT,
    IN p_date DATE,
    IN p_start_hour INT,  -- e.g., 8 for 8 AM
    IN p_end_hour INT     -- e.g., 20 for 8 PM
)
BEGIN
    -- Get all booked time slots for that day
    SELECT 
        TIME(a.start_time) AS booked_start,
        TIME(a.end_time) AS booked_end,
        m.name AS member_name,
        a.status
    FROM Appointment a
    JOIN Member m ON a.member_id = m.member_id
    WHERE a.trainer_id = p_trainer_id
      AND DATE(a.start_time) = p_date
      AND a.status IN ('Scheduled', 'In Progress')
    ORDER BY a.start_time;
    
    -- Generate available time slots (1-hour blocks)
    WITH RECURSIVE TimeSlots AS (
        SELECT p_start_hour AS hour
        UNION ALL
        SELECT hour + 1
        FROM TimeSlots
        WHERE hour < p_end_hour - 1
    )
    SELECT 
        ts.hour,
        CONCAT(LPAD(ts.hour, 2, '0'), ':00') AS time_slot_start,
        CONCAT(LPAD(ts.hour + 1, 2, '0'), ':00') AS time_slot_end,
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM Appointment a
                WHERE a.trainer_id = p_trainer_id
                  AND DATE(a.start_time) = p_date
                  AND a.status IN ('Scheduled', 'In Progress')
                  AND (
                      (HOUR(a.start_time) <= ts.hour AND HOUR(a.end_time) > ts.hour) OR
                      (HOUR(a.start_time) < ts.hour + 1 AND HOUR(a.end_time) >= ts.hour + 1)
                  )
            ) THEN 'BOOKED'
            ELSE 'AVAILABLE'
        END AS availability_status
    FROM TimeSlots ts
    ORDER BY ts.hour;
END $$
DELIMITER ;

CALL get_trainer_available_hours(1, '2025-01-01', 8, 20); 

-- c. Book New Appointment
DELIMITER $$
CREATE PROCEDURE book_new_appointment(
    IN p_trainer_id INT,
    IN p_member_id INT,
    IN p_start_time DATETIME,
    IN p_end_time DATETIME
)
BEGIN
    DECLARE v_conflict_count INT;
    DECLARE v_appointment_id INT;
    
    -- Check for conflicts
    SELECT COUNT(*) INTO v_conflict_count
    FROM Appointment
    WHERE trainer_id = p_trainer_id
      AND status IN ('Scheduled', 'In Progress')
      AND (
          (p_start_time BETWEEN start_time AND end_time) OR
          (p_end_time BETWEEN start_time AND end_time) OR
          (start_time BETWEEN p_start_time AND p_end_time)
      );
    
    IF v_conflict_count > 0 THEN
        -- Conflict exists
        SELECT 
            'BOOKING FAILED' AS status,
            'Trainer not available at this time - conflict with existing appointment' AS message,
            v_conflict_count AS conflicting_appointments;
    ELSE
        -- No conflict, book the appointment
        INSERT INTO Appointment (trainer_id, member_id, start_time, end_time, status)
        VALUES (p_trainer_id, p_member_id, p_start_time, p_end_time, 'Scheduled');
        
        SET v_appointment_id = LAST_INSERT_ID();
        
        SELECT 
            'BOOKING SUCCESSFUL' AS status,
            v_appointment_id AS appointment_id,
            p_start_time AS start_time,
            p_end_time AS end_time,
            'Appointment booked successfully' AS message;
    END IF;
END $$
DELIMITER ;

CALL book_new_appointment(1, 1, '2025-12-05T16:00', '2025-12-05T17:00');

-- d. Change Appointment Status
DELIMITER $$
CREATE PROCEDURE change_appointment_status(
    IN p_appointment_id INT,
    IN p_new_status VARCHAR(20),  -- 'Scheduled', 'Completed', 'Cancelled', 'In Progress'
    IN p_user_id INT,
    IN p_user_type VARCHAR(10)    -- 'member' or 'trainer'
)
BEGIN
    DECLARE v_valid INT DEFAULT 0;
    
    -- Verify the user has permission to change this appointment
    IF p_user_type = 'member' THEN
        SELECT COUNT(*) INTO v_valid
        FROM Appointment
        WHERE appointment_id = p_appointment_id 
          AND member_id = p_user_id;
    ELSEIF p_user_type = 'trainer' THEN
        SELECT COUNT(*) INTO v_valid
        FROM Appointment
        WHERE appointment_id = p_appointment_id 
          AND trainer_id = p_user_id;
    END IF;
    
    IF v_valid > 0 THEN
        UPDATE Appointment
        SET status = p_new_status
        WHERE appointment_id = p_appointment_id;
        
        SELECT 
            'STATUS UPDATED' AS result,
            p_appointment_id AS appointment_id,
            p_new_status AS new_status,
            'Appointment status changed successfully' AS message;
    ELSE
        SELECT 
            'UPDATE FAILED' AS result,
            'Unauthorized access or invalid appointment' AS error_message;
    END IF;
END $$
DELIMITER ;

CALL change_appointment_status(23, 'Completed', 1, 'member'); 

-- e. Get Member's Appointments (All or by Status)
DELIMITER $$
CREATE PROCEDURE get_member_appointments(
    IN p_member_id INT,
    IN p_status VARCHAR(20)  -- 'All', 'Scheduled', 'Completed', 'Cancelled', 'In Progress'
)
BEGIN
    IF p_status = 'All' THEN
        SELECT 
            a.appointment_id,
            a.start_time,
            a.end_time,
            a.status,
            t.trainer_id,
            t.name AS trainer_name,
            t.email AS trainer_email,
            t.specialization,
            g.gym_id,
            g.gym_name,
            g.location,
            CASE 
                WHEN a.start_time > NOW() THEN CONCAT('In ', TIMESTAMPDIFF(HOUR, NOW(), a.start_time), ' hours')
                WHEN a.start_time <= NOW() AND a.end_time >= NOW() THEN 'Currently happening'
                WHEN a.end_time < NOW() THEN 'Past appointment'
                ELSE '-'
            END AS time_status
        FROM Appointment a
        JOIN Trainer t ON a.trainer_id = t.trainer_id
        JOIN Gym g ON t.gym_id = g.gym_id
        WHERE a.member_id = p_member_id
        ORDER BY a.start_time DESC;
    ELSE
        SELECT 
            a.appointment_id,
            a.start_time,
            a.end_time,
            a.status,
            t.trainer_id,
            t.name AS trainer_name,
            t.email AS trainer_email,
            t.specialization,
            g.gym_id,
            g.gym_name,
            g.location,
            CASE 
                WHEN a.start_time > NOW() THEN CONCAT('In ', TIMESTAMPDIFF(HOUR, NOW(), a.start_time), ' hours')
                WHEN a.start_time <= NOW() AND a.end_time >= NOW() THEN 'Currently happening'
                WHEN a.end_time < NOW() THEN 'Past appointment'
                ELSE '-'
            END AS time_status
        FROM Appointment a
        JOIN Trainer t ON a.trainer_id = t.trainer_id
        JOIN Gym g ON t.gym_id = g.gym_id
        WHERE a.member_id = p_member_id
          AND a.status = p_status
        ORDER BY a.start_time DESC;
    END IF;
END $$
DELIMITER ;

CALL get_member_appointments(1, 'All'); 

-- ============================================================================
-- WORKOUT PLAN MANAGEMENT PROCEDURES
-- ============================================================================

-- a. Create New Workout Plan
DELIMITER $$
CREATE PROCEDURE create_workout_plan(
    IN p_trainer_id INT,
    IN p_member_id INT,
    IN p_plan_name VARCHAR(100)
)
BEGIN
    DECLARE v_plan_id INT;
    DECLARE v_trainer_gym_id INT;
    DECLARE v_member_gym_id INT;
    
    -- Verify trainer and member are at same gym
    SELECT gym_id INTO v_trainer_gym_id FROM Trainer WHERE trainer_id = p_trainer_id;
    SELECT gym_id INTO v_member_gym_id FROM Membership WHERE member_id = p_member_id AND status = 'Active';
    
    IF v_trainer_gym_id IS NULL THEN
        SELECT 'CREATION FAILED' AS status, 'Invalid trainer ID' AS error_message;
    ELSEIF v_member_gym_id IS NULL THEN
        SELECT 'CREATION FAILED' AS status, 'Member does not have active membership' AS error_message;
    ELSEIF v_trainer_gym_id != v_member_gym_id THEN
        SELECT 'CREATION FAILED' AS status, 'Trainer and member are not at the same gym' AS error_message;
    ELSE
        INSERT INTO Workout_Plan (trainer_id, member_id, plan_name)
        VALUES (p_trainer_id, p_member_id, p_plan_name);
        
        SET v_plan_id = LAST_INSERT_ID();
        
        SELECT 
            'PLAN CREATED' AS status,
            v_plan_id AS plan_id,
            p_plan_name AS plan_name,
            p_trainer_id AS trainer_id,
            p_member_id AS member_id,
            'Workout plan created successfully' AS message;
    END IF;
END $$
DELIMITER ;

CALL create_workout_plan(1, 1, "New Plan"); 

-- b. Add Exercise to Workout Plan
DELIMITER $$
CREATE PROCEDURE add_exercise_to_plan(
    IN p_plan_id INT,
    IN p_exercise_id INT,
    IN p_target_sets INT,
    IN p_target_reps INT,
    IN p_target_weight DECIMAL(5,2),
    IN p_trainer_id INT  -- For authorization
)
BEGIN
    DECLARE v_valid INT DEFAULT 0;
    DECLARE v_plan_exercise_id INT;
    DECLARE v_exercise_name VARCHAR(100);
    
    -- Verify trainer owns this plan
    SELECT COUNT(*) INTO v_valid
    FROM Workout_Plan
    WHERE plan_id = p_plan_id AND trainer_id = p_trainer_id;
    
    IF v_valid = 0 THEN
        SELECT 
            'ADD FAILED' AS status,
            'Unauthorized - you do not own this workout plan' AS error_message;
    ELSE
        -- Get exercise name
        SELECT exercise_name INTO v_exercise_name
        FROM Exercise
        WHERE exercise_id = p_exercise_id;
        
        -- Add exercise to plan
        INSERT INTO Plan_Exercise (plan_id, exercise_id, target_sets, target_reps, target_weight)
        VALUES (p_plan_id, p_exercise_id, p_target_sets, p_target_reps, p_target_weight);
        
        SET v_plan_exercise_id = LAST_INSERT_ID();
        
        SELECT 
            'EXERCISE ADDED' AS status,
            v_plan_exercise_id AS plan_exercise_id,
            p_plan_id AS plan_id,
            v_exercise_name AS exercise_name,
            p_target_sets AS target_sets,
            p_target_reps AS target_reps,
            p_target_weight AS target_weight,
            'Exercise added to plan successfully' AS message;
    END IF;
END $$
DELIMITER ;

CALL add_exercise_to_plan(1, 1, 1, 1, 1, 1); 

-- c. Get All Exercises in a Plan with Targets
DELIMITER $$
CREATE PROCEDURE get_plan_exercises(
    IN p_plan_id INT
)
BEGIN
    -- Plan Overview
    SELECT 
        wp.plan_id,
        wp.plan_name,
        t.trainer_id,
        t.name AS trainer_name,
        t.specialization,
        m.member_id,
        m.name AS member_name,
        COUNT(pe.plan_exercise_id) AS total_exercises_in_plan
    FROM Workout_Plan wp
    JOIN Trainer t ON wp.trainer_id = t.trainer_id
    JOIN Member m ON wp.member_id = m.member_id
    LEFT JOIN Plan_Exercise pe ON wp.plan_id = pe.plan_id
    WHERE wp.plan_id = p_plan_id
    GROUP BY wp.plan_id, wp.plan_name, t.trainer_id, t.name, t.specialization, m.member_id, m.name;
    
    -- All Exercises with Targets
    SELECT 
        pe.plan_exercise_id,
        e.exercise_id,
        e.exercise_name,
        e.category,
        e.target_muscle_group,
        pe.target_sets,
        pe.target_reps,
        pe.target_weight,
        CONCAT(pe.target_sets, ' sets × ', pe.target_reps, ' reps', 
               CASE WHEN pe.target_weight > 0 THEN CONCAT(' @ ', pe.target_weight, ' kg') ELSE '' END) AS formatted_target
    FROM Plan_Exercise pe
    JOIN Exercise e ON pe.exercise_id = e.exercise_id
    WHERE pe.plan_id = p_plan_id
    ORDER BY pe.plan_exercise_id;
    
    -- Muscle Group Distribution in Plan
    SELECT 
        e.target_muscle_group,
        COUNT(pe.plan_exercise_id) AS exercises_for_muscle,
        SUM(pe.target_sets) AS total_sets_for_muscle,
        GROUP_CONCAT(e.exercise_name ORDER BY e.exercise_name SEPARATOR ', ') AS exercises
    FROM Plan_Exercise pe
    JOIN Exercise e ON pe.exercise_id = e.exercise_id
    WHERE pe.plan_id = p_plan_id
    GROUP BY e.target_muscle_group
    ORDER BY total_sets_for_muscle DESC;
END $$
DELIMITER ;

CALL get_plan_exercises(2); 

-- d. Remove Plan and Its Exercises
DELIMITER $$
CREATE PROCEDURE remove_workout_plan(
    IN p_plan_id INT,
    IN p_trainer_id INT  -- For authorization
)
BEGIN
    DECLARE v_valid INT DEFAULT 0;
    DECLARE v_plan_name VARCHAR(100);
    DECLARE v_exercise_count INT;
    DECLARE v_workouts_using_plan INT;
    
    -- Verify trainer owns this plan
    SELECT wp.plan_name, COUNT(pe.plan_exercise_id) 
    INTO v_plan_name, v_exercise_count
    FROM Workout_Plan wp
    LEFT JOIN Plan_Exercise pe ON wp.plan_id = pe.plan_id
    WHERE wp.plan_id = p_plan_id AND wp.trainer_id = p_trainer_id
    GROUP BY wp.plan_name;
    
    -- Check how many workouts are using this plan
    SELECT COUNT(*) INTO v_workouts_using_plan
    FROM Workout
    WHERE plan_id = p_plan_id;
    
    IF v_plan_name IS NULL THEN
        SELECT 
            'DELETION FAILED' AS status,
            'Unauthorized or invalid plan ID' AS error_message;
    ELSE
        -- Delete plan exercises first (due to foreign key)
        DELETE FROM Plan_Exercise
        WHERE plan_id = p_plan_id;
        
        -- Delete the plan
        DELETE FROM Workout_Plan
        WHERE plan_id = p_plan_id;
        
        SELECT 
            'DELETION SUCCESSFUL' AS status,
            p_plan_id AS deleted_plan_id,
            v_plan_name AS plan_name,
            v_exercise_count AS exercises_removed,
            v_workouts_using_plan AS workouts_that_used_plan,
            'Workout plan and all its exercises removed successfully' AS message;
    END IF;
END $$
DELIMITER ;

CALL remove_workout_plan(30, 5); 

-- ============================================================================
-- ANALYTICS PROCEDURES
-- ============================================================================

-- a. Workout Frequency Percentage (Member engagement analysis)
DELIMITER $$
CREATE PROCEDURE get_workout_frequency_percentage(
    IN p_gym_id INT,
    IN p_days INT  -- Number of days to analyze
)
BEGIN
    SELECT 
        m.member_id,
        m.name AS member_name,
        COUNT(DISTINCT w.workout_id) AS total_workouts,
        COUNT(DISTINCT DATE(w.date)) AS active_days,
        p_days AS total_days_in_period,
        ROUND((COUNT(DISTINCT DATE(w.date)) / p_days) * 100, 2) AS workout_frequency_percentage,
        CASE 
            WHEN (COUNT(DISTINCT DATE(w.date)) / p_days) * 100 >= 80 THEN 'Excellent (80%+)'
            WHEN (COUNT(DISTINCT DATE(w.date)) / p_days) * 100 >= 60 THEN 'Very Good (60-79%)'
            WHEN (COUNT(DISTINCT DATE(w.date)) / p_days) * 100 >= 40 THEN 'Good (40-59%)'
            WHEN (COUNT(DISTINCT DATE(w.date)) / p_days) * 100 >= 20 THEN 'Fair (20-39%)'
            ELSE 'Low (<20%)'
        END AS engagement_rating,
        AVG(w.duration) AS avg_workout_duration,
        SUM(w.calories_burned) AS total_calories
    FROM Member m
    JOIN Membership ms ON m.member_id = ms.member_id
    LEFT JOIN Workout w ON m.member_id = w.member_id 
        AND w.date >= DATE_SUB(CURDATE(), INTERVAL p_days DAY)
    WHERE ms.gym_id = p_gym_id
      AND ms.status = 'Active'
    GROUP BY m.member_id, m.name
    ORDER BY workout_frequency_percentage DESC, total_workouts DESC;
END $$
DELIMITER ;

CALL get_workout_frequency_percentage(1, 1); 

-- b. Most Logged Exercise at Gym
DELIMITER $$
CREATE PROCEDURE get_most_logged_exercises(
    IN p_gym_id INT,
    IN p_limit INT
)
BEGIN
    SELECT 
        e.exercise_id,
        e.exercise_name,
        e.category,
        e.target_muscle_group,
        COUNT(DISTINCT w.workout_id) AS workouts_containing_exercise,
        COUNT(DISTINCT w.member_id) AS unique_members_performing,
        COUNT(s.set_id) AS total_sets_logged,
        SUM(s.no_of_reps) AS total_reps_logged,
        AVG(s.weight) AS avg_weight_used,
        MAX(s.weight) AS max_weight_recorded,
        ROUND((COUNT(s.set_id) * 100.0 / 
              (SELECT COUNT(*) FROM `Set` s2 
               JOIN Workout w2 ON s2.workout_id = w2.workout_id 
               WHERE w2.gym_id = p_gym_id)), 2) AS percentage_of_all_sets
    FROM Exercise e
    JOIN `Set` s ON e.exercise_id = s.exercise_id
    JOIN Workout w ON s.workout_id = w.workout_id
    WHERE w.gym_id = p_gym_id
    GROUP BY e.exercise_id, e.exercise_name, e.category, e.target_muscle_group
    ORDER BY total_sets_logged DESC
    LIMIT p_limit;
END $$
DELIMITER ;

CALL get_most_logged_exercises(1, 5); 

-- c. Overall Gym Metrics
DELIMITER $$
CREATE PROCEDURE get_overall_gym_metrics(
    IN p_gym_id INT
)
BEGIN
    -- Overall Gym Statistics
    SELECT 
        g.gym_id,
        g.gym_name,
        g.location,
        g.contact_number,
        g.email,
        COUNT(DISTINCT ms.member_id) AS total_members,
        COUNT(DISTINCT CASE WHEN ms.status = 'Active' THEN ms.member_id END) AS active_members,
        COUNT(DISTINCT CASE WHEN ms.status = 'Expired' THEN ms.member_id END) AS expired_members,
        COUNT(DISTINCT t.trainer_id) AS total_trainers,
        COUNT(DISTINCT w.workout_id) AS total_workouts_logged,
        COUNT(DISTINCT a.appointment_id) AS total_appointments,
        COUNT(DISTINCT wp.plan_id) AS total_workout_plans,
        COALESCE(SUM(w.duration), 0) AS total_workout_minutes,
        COALESCE(SUM(w.calories_burned), 0) AS total_calories_burned,
        COALESCE(AVG(w.duration), 0) AS avg_workout_duration,
        SUM(CASE WHEN ms.status = 'Active' THEN ms.cost ELSE 0 END) AS total_annual_revenue,
        ROUND((COUNT(DISTINCT CASE WHEN ms.status = 'Active' THEN ms.member_id END) * 100.0 / 
              NULLIF(COUNT(DISTINCT ms.member_id), 0)), 2) AS member_retention_rate
    FROM Gym g
    LEFT JOIN Membership ms ON g.gym_id = ms.gym_id
    LEFT JOIN Trainer t ON g.gym_id = t.gym_id
    LEFT JOIN Workout w ON g.gym_id = w.gym_id
    LEFT JOIN Appointment a ON t.trainer_id = a.trainer_id
    LEFT JOIN Workout_Plan wp ON t.trainer_id = wp.trainer_id
    WHERE g.gym_id = p_gym_id
    GROUP BY g.gym_id, g.gym_name, g.location, g.contact_number, g.email;
    
    -- Monthly Trends (last 6 months)
    SELECT 
        DATE_FORMAT(w.date, '%Y-%m') AS month,
        COUNT(DISTINCT w.workout_id) AS workouts,
        COUNT(DISTINCT w.member_id) AS active_members,
        SUM(w.duration) AS total_minutes,
        SUM(w.calories_burned) AS total_calories,
        COUNT(DISTINCT s.exercise_id) AS unique_exercises_used
    FROM Workout w
    LEFT JOIN `Set` s ON w.workout_id = s.workout_id
    WHERE w.gym_id = p_gym_id
      AND w.date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
    GROUP BY DATE_FORMAT(w.date, '%Y-%m')
    ORDER BY month DESC;
    
    -- Top Muscle Groups Trained
    SELECT 
        e.target_muscle_group,
        COUNT(DISTINCT s.set_id) AS total_sets,
        COUNT(DISTINCT w.member_id) AS members_training,
        COUNT(DISTINCT e.exercise_id) AS different_exercises
    FROM Workout w
    JOIN `Set` s ON w.workout_id = s.workout_id
    JOIN Exercise e ON s.exercise_id = e.exercise_id
    WHERE w.gym_id = p_gym_id
    GROUP BY e.target_muscle_group
    ORDER BY total_sets DESC
    LIMIT 10;
    
    -- Trainer Performance Summary
    SELECT 
        t.trainer_id,
        t.name AS trainer_name,
        t.specialization,
        COUNT(DISTINCT a.member_id) AS total_clients,
        COUNT(DISTINCT a.appointment_id) AS total_appointments,
        COUNT(DISTINCT CASE WHEN a.status = 'Completed' THEN a.appointment_id END) AS completed_appointments,
        COUNT(DISTINCT wp.plan_id) AS workout_plans_created
    FROM Trainer t
    LEFT JOIN Appointment a ON t.trainer_id = a.trainer_id
    LEFT JOIN Workout_Plan wp ON t.trainer_id = wp.trainer_id
    WHERE t.gym_id = p_gym_id
    GROUP BY t.trainer_id, t.name, t.specialization
    ORDER BY total_clients DESC;
END $$
DELIMITER ;

CALL get_overall_gym_metrics(1); 

-- d. Top Performers on an Exercise
DELIMITER $$
CREATE PROCEDURE get_top_performers_on_exercise(
    IN p_exercise_id INT,
    IN p_limit INT
)
BEGIN
    -- Top by Max Weight
    SELECT 
        m.member_id,
        m.name AS member_name,
        m.age,
        m.gender,
        g.gym_name,
        MAX(s.weight) AS max_weight,
        MAX(s.no_of_reps) AS max_reps,
        COUNT(DISTINCT w.workout_id) AS times_performed,
        COUNT(s.set_id) AS total_sets,
        AVG(s.weight) AS avg_weight,
        MIN(w.date) AS first_performed,
        MAX(w.date) AS last_performed
    FROM `Set` s
    JOIN Workout w ON s.workout_id = w.workout_id
    JOIN Member m ON w.member_id = m.member_id
    JOIN Membership ms ON m.member_id = ms.member_id
    JOIN Gym g ON ms.gym_id = g.gym_id
    WHERE s.exercise_id = p_exercise_id
      AND s.weight > 0
    GROUP BY m.member_id, m.name, m.age, m.gender, g.gym_name
    ORDER BY max_weight DESC, max_reps DESC
    LIMIT p_limit;
    
    -- Exercise Information
    SELECT 
        e.exercise_id,
        e.exercise_name,
        e.category,
        e.target_muscle_group,
        COUNT(DISTINCT w.member_id) AS total_members_performing,
        COUNT(DISTINCT w.workout_id) AS total_workouts_logged,
        COUNT(s.set_id) AS total_sets_all_time,
        MAX(s.weight) AS all_time_max_weight,
        AVG(s.weight) AS all_time_avg_weight
    FROM Exercise e
    LEFT JOIN `Set` s ON e.exercise_id = s.exercise_id
    LEFT JOIN Workout w ON s.workout_id = w.workout_id
    WHERE e.exercise_id = p_exercise_id
    GROUP BY e.exercise_id, e.exercise_name, e.category, e.target_muscle_group;
END $$
DELIMITER ;

CALL get_top_performers_on_exercise(1, 5); 

-- e. Progress Over Time (Individual Member)
DELIMITER $$
CREATE PROCEDURE get_member_progress_over_time(
    IN p_member_id INT,
    IN p_exercise_id INT,
    IN p_num_months INT
)
BEGIN
    -- Weekly progress data
    SELECT 
        DATE_FORMAT(w.date, '%Y-%U') AS year_week,
        DATE_SUB(w.date, INTERVAL WEEKDAY(w.date) DAY) AS week_start_date,
        e.exercise_name,
        COUNT(DISTINCT w.workout_id) AS workouts_this_week,
        COUNT(s.set_id) AS sets_this_week,
        MAX(s.weight) AS max_weight_this_week,
        AVG(s.weight) AS avg_weight_this_week,
        MAX(s.no_of_reps) AS max_reps_this_week,
        AVG(s.no_of_reps) AS avg_reps_this_week,
        LAG(MAX(s.weight)) OVER (ORDER BY DATE_FORMAT(w.date, '%Y-%U')) AS previous_week_max_weight,
        (MAX(s.weight) - LAG(MAX(s.weight)) OVER (ORDER BY DATE_FORMAT(w.date, '%Y-%U'))) AS weight_improvement,
        CASE 
            WHEN MAX(s.weight) > LAG(MAX(s.weight)) OVER (ORDER BY DATE_FORMAT(w.date, '%Y-%U')) THEN 'Improved'
            WHEN MAX(s.weight) = LAG(MAX(s.weight)) OVER (ORDER BY DATE_FORMAT(w.date, '%Y-%U')) THEN 'Maintained'
            WHEN MAX(s.weight) < LAG(MAX(s.weight)) OVER (ORDER BY DATE_FORMAT(w.date, '%Y-%U')) THEN 'Decreased'
            ELSE 'First Week'
        END AS progress_trend
    FROM Workout w
    JOIN `Set` s ON w.workout_id = s.workout_id
    JOIN Exercise e ON s.exercise_id = e.exercise_id
    WHERE w.member_id = p_member_id
      AND s.exercise_id = p_exercise_id
      AND w.date >= DATE_SUB(CURDATE(), INTERVAL p_num_months MONTH)
    GROUP BY DATE_FORMAT(w.date, '%Y-%U'), week_start_date, e.exercise_name
    ORDER BY year_week DESC;
    
    -- Summary statistics
    SELECT 
        m.name AS member_name,
        e.exercise_name,
        COUNT(DISTINCT w.workout_id) AS total_workouts,
        COUNT(s.set_id) AS total_sets,
        (SELECT MAX(s2.weight) 
         FROM `Set` s2 
         JOIN Workout w2 ON s2.workout_id = w2.workout_id
         WHERE s2.exercise_id = p_exercise_id 
           AND w2.member_id = p_member_id
         ORDER BY w2.date ASC LIMIT 1) AS starting_weight,
        MAX(s.weight) AS current_max_weight,
        (MAX(s.weight) - (SELECT MAX(s2.weight) 
                          FROM `Set` s2 
                          JOIN Workout w2 ON s2.workout_id = w2.workout_id
                          WHERE s2.exercise_id = p_exercise_id 
                            AND w2.member_id = p_member_id
                          ORDER BY w2.date ASC LIMIT 1)) AS total_weight_improvement,
        ROUND(((MAX(s.weight) - (SELECT MAX(s2.weight) 
                                  FROM `Set` s2 
                                  JOIN Workout w2 ON s2.workout_id = w2.workout_id
                                  WHERE s2.exercise_id = p_exercise_id 
                                    AND w2.member_id = p_member_id
                                  ORDER BY w2.date ASC LIMIT 1)) / 
               NULLIF((SELECT MAX(s2.weight) 
                       FROM `Set` s2 
                       JOIN Workout w2 ON s2.workout_id = w2.workout_id
                       WHERE s2.exercise_id = p_exercise_id 
                         AND w2.member_id = p_member_id
                       ORDER BY w2.date ASC LIMIT 1), 0)) * 100, 2) AS percentage_improvement
    FROM Member m
    JOIN Workout w ON m.member_id = w.member_id
    JOIN `Set` s ON w.workout_id = s.workout_id
    JOIN Exercise e ON s.exercise_id = e.exercise_id
    WHERE m.member_id = p_member_id
      AND s.exercise_id = p_exercise_id
      AND w.date >= DATE_SUB(CURDATE(), INTERVAL p_num_months MONTH)
    GROUP BY m.member_id, m.name, e.exercise_id, e.exercise_name;
END $$
DELIMITER ;

CALL get_member_progress_over_time(5, 5, 5); 

-- ============================================================================
-- VALIDATION AND MEMBER STATISTICS PROCEDURES
-- ============================================================================

-- a. Validate Appointment Doesn't Conflict (Returns boolean-style result)
DELIMITER $$
CREATE PROCEDURE validate_appointment_no_conflict(
    IN p_trainer_id INT,
    IN p_start_time DATETIME,
    IN p_end_time DATETIME,
    IN p_exclude_appointment_id INT  -- NULL for new appointments, or appointment_id when rescheduling
)
BEGIN
    DECLARE v_conflict_count INT;
    
    -- Check for conflicts, excluding specific appointment if rescheduling
    IF p_exclude_appointment_id IS NULL THEN
        SELECT COUNT(*) INTO v_conflict_count
        FROM Appointment
        WHERE trainer_id = p_trainer_id
          AND status IN ('Scheduled', 'In Progress')
          AND (
              (p_start_time BETWEEN start_time AND end_time) OR
              (p_end_time BETWEEN start_time AND end_time) OR
              (start_time BETWEEN p_start_time AND p_end_time)
          );
    ELSE
        SELECT COUNT(*) INTO v_conflict_count
        FROM Appointment
        WHERE trainer_id = p_trainer_id
          AND appointment_id != p_exclude_appointment_id
          AND status IN ('Scheduled', 'In Progress')
          AND (
              (p_start_time BETWEEN start_time AND end_time) OR
              (p_end_time BETWEEN start_time AND end_time) OR
              (start_time BETWEEN p_start_time AND p_end_time)
          );
    END IF;
    
    -- Return validation result
    SELECT 
        CASE WHEN v_conflict_count = 0 THEN 'VALID' ELSE 'CONFLICT' END AS validation_status,
        v_conflict_count AS conflicting_appointments,
        p_trainer_id AS trainer_id,
        p_start_time AS requested_start_time,
        p_end_time AS requested_end_time,
        CASE 
            WHEN v_conflict_count = 0 THEN 'Appointment time is available'
            ELSE CONCAT(v_conflict_count, ' conflicting appointment(s) found')
        END AS message;
    
    -- If conflicts exist, show them
    IF v_conflict_count > 0 THEN
        IF p_exclude_appointment_id IS NULL THEN
            SELECT 
                a.appointment_id,
                a.start_time AS conflicting_start,
                a.end_time AS conflicting_end,
                m.name AS member_name,
                a.status
            FROM Appointment a
            JOIN Member m ON a.member_id = m.member_id
            WHERE a.trainer_id = p_trainer_id
              AND a.status IN ('Scheduled', 'In Progress')
              AND (
                  (p_start_time BETWEEN a.start_time AND a.end_time) OR
                  (p_end_time BETWEEN a.start_time AND a.end_time) OR
                  (a.start_time BETWEEN p_start_time AND p_end_time)
              );
        ELSE
            SELECT 
                a.appointment_id,
                a.start_time AS conflicting_start,
                a.end_time AS conflicting_end,
                m.name AS member_name,
                a.status
            FROM Appointment a
            JOIN Member m ON a.member_id = m.member_id
            WHERE a.trainer_id = p_trainer_id
              AND a.appointment_id != p_exclude_appointment_id
              AND a.status IN ('Scheduled', 'In Progress')
              AND (
                  (p_start_time BETWEEN a.start_time AND a.end_time) OR
                  (p_end_time BETWEEN a.start_time AND a.end_time) OR
                  (a.start_time BETWEEN p_start_time AND p_end_time)
              );
        END IF;
    END IF;
END $$
DELIMITER ;

CALL validate_appointment_no_conflict(1, '2025-12-01 00:00', '2025-12-01 12:00', null); 

-- b. Update Member Statistics or Log Activity
DELIMITER $$
CREATE PROCEDURE update_member_statistics(
    IN p_member_id INT
)
BEGIN
    -- This calculates and returns updated member statistics
    -- In a real system, you might store these in a separate stats table
    
    SELECT 
        m.member_id,
        m.name,
        m.age,
        m.gender,
        m.height,
        m.weight,
        m.join_date,
        DATEDIFF(CURDATE(), m.join_date) AS days_as_member,
        COUNT(DISTINCT w.workout_id) AS total_workouts,
        COUNT(DISTINCT DATE(w.date)) AS total_active_days,
        COALESCE(SUM(w.duration), 0) AS total_minutes_exercised,
        COALESCE(AVG(w.duration), 0) AS avg_workout_duration,
        COALESCE(SUM(w.calories_burned), 0) AS total_calories_burned,
        COALESCE(AVG(w.calories_burned), 0) AS avg_calories_per_workout,
        COUNT(DISTINCT s.exercise_id) AS unique_exercises_performed,
        COUNT(s.set_id) AS total_sets_performed,
        SUM(s.no_of_reps) AS total_reps_performed,
        MAX(w.date) AS last_workout_date,
        DATEDIFF(CURDATE(), MAX(w.date)) AS days_since_last_workout,
        COUNT(DISTINCT a.appointment_id) AS total_appointments_booked,
        COUNT(DISTINCT wp.plan_id) AS workout_plans_assigned,
        ROUND((COUNT(DISTINCT DATE(w.date)) / GREATEST(DATEDIFF(CURDATE(), m.join_date), 1)) * 100, 2) AS workout_frequency_percentage
    FROM Member m
    LEFT JOIN Workout w ON m.member_id = w.member_id
    LEFT JOIN `Set` s ON w.workout_id = s.workout_id
    LEFT JOIN Appointment a ON m.member_id = a.member_id
    LEFT JOIN Workout_Plan wp ON m.member_id = wp.member_id
    WHERE m.member_id = p_member_id
    GROUP BY m.member_id, m.name, m.age, m.gender, m.height, m.weight, m.join_date;
END $$
DELIMITER ;

CALL update_member_statistics(1); 

-- Log Member Activity (Track important member actions)
DELIMITER $$
CREATE PROCEDURE log_member_activity(
    IN p_member_id INT,
    IN p_activity_type VARCHAR(50),  -- 'workout_completed', 'appointment_booked', 'plan_assigned', etc.
    IN p_activity_description VARCHAR(255)
)
BEGIN
    -- This would typically insert into an activity log table
    -- For now, we'll create a summary of recent activities
    
    SELECT 
        p_member_id AS member_id,
        p_activity_type AS activity_type,
        p_activity_description AS description,
        NOW() AS activity_timestamp,
        'Activity logged successfully' AS message;
    
    -- Show recent member activities summary
    SELECT 
        'Recent Activities Summary' AS section,
        COUNT(DISTINCT w.workout_id) AS workouts_last_30_days,
        COUNT(DISTINCT a.appointment_id) AS appointments_last_30_days,
        MAX(w.date) AS last_workout,
        MAX(a.start_time) AS last_appointment
    FROM Member m
    LEFT JOIN Workout w ON m.member_id = w.member_id 
        AND w.date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    LEFT JOIN Appointment a ON m.member_id = a.member_id 
        AND a.start_time >= DATE_SUB(NOW(), INTERVAL 30 DAY)
    WHERE m.member_id = p_member_id;
END $$
DELIMITER ;

CALL log_member_activity(1, 'workout_completed', 'Workout is completed!'); 

-- c. Check Membership Dates Are Valid
DELIMITER $$
CREATE PROCEDURE validate_membership_dates(
    IN p_member_id INT
)
BEGIN
    SELECT 
        m.member_id,
        m.name AS member_name,
        ms.gym_id,
        g.gym_name,
        ms.start_date,
        ms.end_date,
        ms.status,
        DATEDIFF(ms.end_date, ms.start_date) AS membership_duration_days,
        DATEDIFF(ms.end_date, CURDATE()) AS days_remaining,
        DATEDIFF(CURDATE(), ms.start_date) AS days_active,
        CASE 
            WHEN ms.start_date > CURDATE() THEN 'INVALID - Start date is in the future'
            WHEN ms.end_date < ms.start_date THEN 'INVALID - End date before start date'
            WHEN ms.end_date < CURDATE() AND ms.status = 'Active' THEN 'INVALID - Expired but marked active'
            WHEN ms.end_date >= CURDATE() AND ms.status = 'Expired' THEN 'INVALID - Active but marked expired'
            WHEN ms.status = 'Active' AND ms.end_date >= CURDATE() THEN 'VALID - Active membership'
            WHEN ms.status = 'Expired' AND ms.end_date < CURDATE() THEN 'VALID - Properly expired'
            ELSE 'UNKNOWN STATUS'
        END AS validation_status,
        CASE 
            WHEN ms.end_date >= CURDATE() THEN 'Active'
            ELSE 'Expired'
        END AS should_be_status
    FROM Member m
    JOIN Membership ms ON m.member_id = ms.member_id
    JOIN Gym g ON ms.gym_id = g.gym_id
    WHERE m.member_id = p_member_id;
END $$
DELIMITER ;

CALL validate_membership_dates(1); 

-- ============================================================================
-- SCHEDULED TASKS - PROCEDURES AND EVENTS
-- ============================================================================

-- a. Daily Check to Mark Expired Memberships (Procedure)
DELIMITER $$
CREATE PROCEDURE mark_expired_memberships()
BEGIN
    DECLARE v_updated_count INT;
    
    -- Update expired memberships
    UPDATE Membership
    SET status = 'Expired'
    WHERE end_date < CURDATE()
      AND status = 'Active';
    
    SET v_updated_count = ROW_COUNT();
    
    -- Return results
    SELECT 
        'MEMBERSHIPS UPDATED' AS status,
        v_updated_count AS memberships_marked_expired,
        CURDATE() AS check_date,
        NOW() AS execution_time;
    
    -- Show details of newly expired memberships
    SELECT 
        m.member_id,
        m.name AS member_name,
        m.email,
        g.gym_name,
        ms.end_date,
        ms.status,
        DATEDIFF(CURDATE(), ms.end_date) AS days_expired
    FROM Member m
    JOIN Membership ms ON m.member_id = ms.member_id
    JOIN Gym g ON ms.gym_id = g.gym_id
    WHERE ms.status = 'Expired'
      AND ms.end_date >= DATE_SUB(CURDATE(), INTERVAL 1 DAY)
      AND ms.end_date < CURDATE()
    ORDER BY ms.end_date DESC;
END $$
DELIMITER ;

CALL mark_expired_memberships(); 

-- b. Check for Appointments in Next 24 Hours (Procedure)
DELIMITER $$
CREATE PROCEDURE check_upcoming_appointments()
BEGIN
    -- Get all appointments in next 24 hours
    SELECT 
        a.appointment_id,
        a.start_time,
        a.end_time,
        a.status,
        TIMESTAMPDIFF(HOUR, NOW(), a.start_time) AS hours_until_appointment,
        TIMESTAMPDIFF(MINUTE, NOW(), a.start_time) AS minutes_until_appointment,
        m.member_id,
        m.name AS member_name,
        m.email AS member_email,
        t.trainer_id,
        t.name AS trainer_name,
        t.email AS trainer_email,
        g.gym_name,
        g.location,
        CASE 
            WHEN TIMESTAMPDIFF(HOUR, NOW(), a.start_time) <= 1 THEN 'URGENT - Within 1 hour'
            WHEN TIMESTAMPDIFF(HOUR, NOW(), a.start_time) <= 3 THEN 'SOON - Within 3 hours'
            WHEN TIMESTAMPDIFF(HOUR, NOW(), a.start_time) <= 12 THEN 'TODAY - Within 12 hours'
            ELSE 'TOMORROW - Within 24 hours'
        END AS urgency_level
    FROM Appointment a
    JOIN Member m ON a.member_id = m.member_id
    JOIN Trainer t ON a.trainer_id = t.trainer_id
    JOIN Gym g ON t.gym_id = g.gym_id
    WHERE a.status = 'Scheduled'
      AND a.start_time BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 24 HOUR)
    ORDER BY a.start_time ASC;
    
    -- Summary count
    SELECT 
        COUNT(*) AS total_appointments_next_24h,
        COUNT(CASE WHEN TIMESTAMPDIFF(HOUR, NOW(), a.start_time) <= 1 THEN 1 END) AS within_1_hour,
        COUNT(CASE WHEN TIMESTAMPDIFF(HOUR, NOW(), a.start_time) <= 3 THEN 1 END) AS within_3_hours,
        COUNT(CASE WHEN TIMESTAMPDIFF(HOUR, NOW(), a.start_time) <= 12 THEN 1 END) AS within_12_hours,
        NOW() AS check_time
    FROM Appointment a
    WHERE a.status = 'Scheduled'
      AND a.start_time BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 24 HOUR);
END $$
DELIMITER ;

CALL check_upcoming_appointments(); 