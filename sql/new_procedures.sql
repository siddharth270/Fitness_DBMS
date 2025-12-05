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