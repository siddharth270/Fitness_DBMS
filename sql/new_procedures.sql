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
CREATE PROCEDURE update_workout_completion(
    IN p_workout_id INT,
    IN p_duration INT,
    IN p_calories INT
)
BEGIN
    UPDATE Workout
    SET duration = p_duration, 
        calories_burned = p_calories
    WHERE workout_id = p_workout_id;
    
    SELECT 'Workout completed successfully' AS message;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE get_workout_exercises(
    IN p_workout_id INT
)
BEGIN
    SELECT 
        e.exercise_id,
        e.exercise_name AS name,
        COUNT(s.set_id) AS set_count
    FROM `Set` s
    JOIN Exercise e ON s.exercise_id = e.exercise_id
    WHERE s.workout_id = p_workout_id
    GROUP BY e.exercise_id, e.exercise_name
    ORDER BY e.exercise_name;
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
    
    -- Verify the member owns this appointment
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
        -- Delete the appointment
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

-- Delete workout and all its sets (for canceling a workout)
DELIMITER $$
CREATE PROCEDURE cancel_workout_session(
    IN p_workout_id INT,
    IN p_member_id INT
)
BEGIN
    DECLARE v_valid INT DEFAULT 0;
    
    -- Verify the member owns this workout
    SELECT COUNT(*) INTO v_valid
    FROM Workout
    WHERE workout_id = p_workout_id AND member_id = p_member_id;
    
    IF v_valid > 0 THEN
        -- Delete all sets first
        DELETE FROM `Set` WHERE workout_id = p_workout_id;
        
        -- Delete the workout
        DELETE FROM Workout WHERE workout_id = p_workout_id AND member_id = p_member_id;
        
        SELECT 'CANCEL SUCCESS' AS result, 'Workout cancelled and deleted' AS message;
    ELSE
        SELECT 'CANCEL FAILED' AS result, 'Workout not found or unauthorized' AS message;
    END IF;
END $$
DELIMITER ;


-- Get all distinct exercise categories
DELIMITER $$
CREATE PROCEDURE get_all_exercise_categories()
BEGIN
    SELECT DISTINCT category 
    FROM Exercise 
    ORDER BY category;
END $$
DELIMITER ;

-- Get all distinct muscle groups
DELIMITER $$
CREATE PROCEDURE get_all_muscle_groups()
BEGIN
    SELECT DISTINCT target_muscle_group 
    FROM Exercise 
    WHERE target_muscle_group IS NOT NULL 
    ORDER BY target_muscle_group;
END $$
DELIMITER ;


-- 1. Get all sets for a workout grouped by exercise (for displaying the workout page)
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

-- 2. Delete a set from workout
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

-- 3. Update a set
DELIMITER $$
CREATE PROCEDURE update_set_in_workout(
    IN p_set_id INT,
    IN p_workout_id INT,
    IN p_reps INT,
    IN p_weight DECIMAL(5,2)
)
BEGIN
    DECLARE v_updated INT DEFAULT 0;
    
    UPDATE `Set`
    SET no_of_reps = p_reps, weight = p_weight
    WHERE set_id = p_set_id AND workout_id = p_workout_id;
    
    SET v_updated = ROW_COUNT();
    
    IF v_updated > 0 THEN
        SELECT 'UPDATE SUCCESS' AS result, p_set_id AS updated_set_id;
    ELSE
        SELECT 'UPDATE FAILED' AS result, 'Set not found or unauthorized' AS message;
    END IF;
END $$
DELIMITER ;

-- 4. Complete workout (update duration and calories)
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

-- 5. Get workout stats (for finish workout summary)
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




-- Start a workout from a plan
DELIMITER $$
CREATE PROCEDURE start_workout_from_plan(
    IN p_member_id INT,
    IN p_plan_id INT,
    IN p_gym_id INT,
    IN p_date DATE
)
BEGIN
    DECLARE v_workout_id INT;
    
    -- Create the workout linked to the plan
    INSERT INTO Workout (member_id, gym_id, plan_id, date, duration, calories_burned)
    VALUES (p_member_id, p_gym_id, p_plan_id, p_date, NULL, NULL);
    
    SET v_workout_id = LAST_INSERT_ID();
    
    SELECT 
        v_workout_id AS workout_id,
        'WORKOUT STARTED' AS result,
        p_plan_id AS plan_id;
END $$
DELIMITER ;

-- Get exercises from a plan (simple list for active workout)
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

-- Get workout info including plan_id
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