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

DELIMITER $$
CREATE PROCEDURE get_trainer_appointments_by_status(
    IN p_trainer_id INT,
    IN p_status VARCHAR(20)  
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

DELIMITER $$
CREATE PROCEDURE create_new_workout(
    IN p_member_id INT,
    IN p_gym_id INT,
    IN p_plan_id INT,  
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
    
    SELECT exercise_name INTO v_exercise_name
    FROM Exercise
    WHERE exercise_id = p_exercise_id;
    
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

DELIMITER $$
CREATE PROCEDURE get_full_workout_details(
    IN p_workout_id INT
)
BEGIN
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
        SELECT 
            'BOOKING FAILED' AS status,
            'Trainer not available at this time - conflict with existing appointment' AS message,
            v_conflict_count AS conflicting_appointments;
    ELSE
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

DELIMITER $$
CREATE PROCEDURE change_appointment_status(
    IN p_appointment_id INT,
    IN p_new_status VARCHAR(20),
    IN p_user_id INT,
    IN p_user_type VARCHAR(10)  
)
BEGIN
    DECLARE v_valid INT DEFAULT 0;
    
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

DELIMITER $$
CREATE PROCEDURE get_member_appointments(
    IN p_member_id INT,
    IN p_status VARCHAR(20) 
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

DELIMITER $$
CREATE PROCEDURE add_exercise_to_plan(
    IN p_plan_id INT,
    IN p_exercise_id INT,
    IN p_target_sets INT,
    IN p_target_reps INT,
    IN p_target_weight DECIMAL(5,2),
    IN p_trainer_id INT  
)
BEGIN
    DECLARE v_valid INT DEFAULT 0;
    DECLARE v_plan_exercise_id INT;
    DECLARE v_exercise_name VARCHAR(100);
    
    SELECT COUNT(*) INTO v_valid
    FROM Workout_Plan
    WHERE plan_id = p_plan_id AND trainer_id = p_trainer_id;
    
    IF v_valid = 0 THEN
        SELECT 
            'ADD FAILED' AS status,
            'Unauthorized - you do not own this workout plan' AS error_message;
    ELSE
        SELECT exercise_name INTO v_exercise_name
        FROM Exercise
        WHERE exercise_id = p_exercise_id;
        
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

DELIMITER $$
CREATE PROCEDURE get_plan_exercises(
    IN p_plan_id INT
)
BEGIN
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

DELIMITER $$
CREATE PROCEDURE remove_workout_plan(
    IN p_plan_id INT,
    IN p_trainer_id INT  
)
BEGIN
    DECLARE v_valid INT DEFAULT 0;
    DECLARE v_plan_name VARCHAR(100);
    DECLARE v_exercise_count INT;
    DECLARE v_workouts_using_plan INT;
    
    SELECT wp.plan_name, COUNT(pe.plan_exercise_id) 
    INTO v_plan_name, v_exercise_count
    FROM Workout_Plan wp
    LEFT JOIN Plan_Exercise pe ON wp.plan_id = pe.plan_id
    WHERE wp.plan_id = p_plan_id AND wp.trainer_id = p_trainer_id
    GROUP BY wp.plan_name;
    
    SELECT COUNT(*) INTO v_workouts_using_plan
    FROM Workout
    WHERE plan_id = p_plan_id;
    
    IF v_plan_name IS NULL THEN
        SELECT 
            'DELETION FAILED' AS status,
            'Unauthorized or invalid plan ID' AS error_message;
    ELSE
        DELETE FROM Plan_Exercise
        WHERE plan_id = p_plan_id;
        
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

DELIMITER $$
CREATE PROCEDURE get_trainers_at_member_gym(
    IN p_member_id INT
)
BEGIN
    SELECT DISTINCT
        t.trainer_id,
        t.name,
        t.specialization,
        t.email,
        g.gym_name,
        COUNT(DISTINCT a.appointment_id) AS total_appointments
    FROM Trainer t
    JOIN Gym g ON t.gym_id = g.gym_id
    JOIN Membership m ON g.gym_id = m.gym_id
    LEFT JOIN Appointment a ON t.trainer_id = a.trainer_id
    WHERE m.member_id = p_member_id 
    GROUP BY t.trainer_id, t.name, t.specialization, t.email, g.gym_name
    ORDER BY t.name;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE get_member_upcoming_appointments_count(
    IN p_member_id INT
)
BEGIN
    SELECT 
        m.member_id,
        m.name AS member_name,
        COUNT(a.appointment_id) AS upcoming_appointments_count
    FROM Member m
    LEFT JOIN Appointment a ON m.member_id = a.member_id
        AND a.status = 'Scheduled'
        AND a.start_time >= NOW()
    WHERE m.member_id = p_member_id
    GROUP BY m.member_id, m.name;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE get_trainer_all_plans(
    IN p_trainer_id INT
)
BEGIN
    SELECT 
        wp.plan_id,
        wp.plan_name,
        m.member_id,
        m.name AS member_name,
        COUNT(pe.plan_exercise_id) AS exercise_count
    FROM Workout_Plan wp
    JOIN Member m ON wp.member_id = m.member_id
    LEFT JOIN Plan_Exercise pe ON wp.plan_id = pe.plan_id
    WHERE wp.trainer_id = p_trainer_id
    GROUP BY wp.plan_id, wp.plan_name, m.member_id, m.name
    ORDER BY wp.plan_id DESC;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE delete_member_appointment(
    IN p_appointment_id INT,
    IN p_member_id INT
)
BEGIN
    DECLARE v_valid INT DEFAULT 0;
    DECLARE v_status VARCHAR(20);
    
    SELECT COUNT(*), status INTO v_valid, v_status
    FROM Appointment
    WHERE appointment_id = p_appointment_id 
      AND member_id = p_member_id
    GROUP BY status;
    
    IF v_valid = 0 THEN
        SELECT 
            'DELETE FAILED' AS result,
            'Unauthorized access or appointment not found' AS message;
    ELSEIF v_status = 'Completed' THEN
        SELECT 
            'DELETE FAILED' AS result,
            'Cannot delete completed appointments' AS message;
    ELSE
        DELETE FROM Appointment
        WHERE appointment_id = p_appointment_id
          AND member_id = p_member_id;
        
        SELECT 
            'DELETE SUCCESS' AS result,
            'Appointment deleted successfully' AS message,
            p_appointment_id AS deleted_appointment_id;
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE cancel_workout_session(
    IN p_workout_id INT,
    IN p_member_id INT
)
BEGIN
    DECLARE v_valid INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_valid
    FROM Workout
    WHERE workout_id = p_workout_id AND member_id = p_member_id;
    
    IF v_valid > 0 THEN
        DELETE FROM `Set` WHERE workout_id = p_workout_id;
        
        DELETE FROM Workout WHERE workout_id = p_workout_id AND member_id = p_member_id;
        
        SELECT 'CANCEL SUCCESS' AS result, 'Workout cancelled and deleted' AS message;
    ELSE
        SELECT 'CANCEL FAILED' AS result, 'Workout not found or unauthorized' AS message;
    END IF;
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE get_all_exercise_categories()
BEGIN
    SELECT DISTINCT category 
    FROM Exercise 
    ORDER BY category;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE get_all_muscle_groups()
BEGIN
    SELECT DISTINCT target_muscle_group 
    FROM Exercise 
    WHERE target_muscle_group IS NOT NULL 
    ORDER BY target_muscle_group;
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE get_workout_exercise_sets(
    IN p_workout_id INT
)
BEGIN
    SELECT 
        e.exercise_id,
        e.exercise_name,
        e.category,
        e.target_muscle_group,
        s.set_id,
        s.no_of_reps,
        s.weight,
        ROW_NUMBER() OVER (PARTITION BY e.exercise_id ORDER BY s.set_id) AS set_number
    FROM `Set` s
    JOIN Exercise e ON s.exercise_id = e.exercise_id
    WHERE s.workout_id = p_workout_id
    ORDER BY s.set_id;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE delete_set_from_workout(
    IN p_set_id INT,
    IN p_workout_id INT
)
BEGIN
    DECLARE v_deleted INT DEFAULT 0;
    
    DELETE FROM `Set`
    WHERE set_id = p_set_id AND workout_id = p_workout_id;
    
    SET v_deleted = ROW_COUNT();
    
    IF v_deleted > 0 THEN
        SELECT 'DELETE SUCCESS' AS result, p_set_id AS deleted_set_id;
    ELSE
        SELECT 'DELETE FAILED' AS result, 'Set not found or unauthorized' AS message;
    END IF;
END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE complete_workout_session(
    IN p_workout_id INT,
    IN p_duration INT,
    IN p_calories INT
)
BEGIN
    UPDATE Workout
    SET duration = p_duration, calories_burned = p_calories
    WHERE workout_id = p_workout_id;
    
    SELECT 
        'WORKOUT COMPLETED' AS result,
        p_workout_id AS workout_id,
        p_duration AS duration,
        p_calories AS calories_burned;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE get_workout_stats(
    IN p_workout_id INT
)
BEGIN
    SELECT 
        COUNT(DISTINCT s.exercise_id) AS exercise_count,
        COUNT(s.set_id) AS total_sets,
        COALESCE(SUM(s.no_of_reps), 0) AS total_reps,
        COALESCE(SUM(s.weight * s.no_of_reps), 0) AS total_volume
    FROM `Set` s
    WHERE s.workout_id = p_workout_id;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE start_workout_from_plan(
    IN p_member_id INT,
    IN p_plan_id INT,
    IN p_gym_id INT,
    IN p_date DATE
)
BEGIN
    DECLARE v_workout_id INT;
    
    INSERT INTO Workout (member_id, gym_id, plan_id, date, duration, calories_burned)
    VALUES (p_member_id, p_gym_id, p_plan_id, p_date, NULL, NULL);
    
    SET v_workout_id = LAST_INSERT_ID();
    
    SELECT 
        v_workout_id AS workout_id,
        'WORKOUT STARTED' AS result,
        p_plan_id AS plan_id;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE get_plan_exercise_list(
    IN p_plan_id INT
)
BEGIN
    SELECT 
        pe.exercise_id,
        e.exercise_name,
        e.category,
        e.target_muscle_group,
        pe.target_sets,
        pe.target_reps,
        pe.target_weight
    FROM Plan_Exercise pe
    JOIN Exercise e ON pe.exercise_id = e.exercise_id
    WHERE pe.plan_id = p_plan_id
    ORDER BY pe.plan_exercise_id;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE get_workout_info(
    IN p_workout_id INT
)
BEGIN
    SELECT 
        w.workout_id,
        w.member_id,
        w.gym_id,
        w.plan_id,
        w.date,
        wp.plan_name
    FROM Workout w
    LEFT JOIN Workout_Plan wp ON w.plan_id = wp.plan_id
    WHERE w.workout_id = p_workout_id;
END $$
DELIMITER ;