-- Member/Trainer Login
DELIMITER //
CREATE PROCEDURE sp_login(
    IN p_email VARCHAR(100),
    IN p_password VARCHAR(255),
    IN p_user_type VARCHAR(10)  -- 'member' or 'trainer'
)
BEGIN
    IF p_user_type = 'member' THEN
        SELECT 
            m.member_id AS user_id,
            m.name,
            m.email,
            'member' AS user_type,
            ms.gym_id,
            ms.status AS membership_status
        FROM Member m
        LEFT JOIN Membership ms ON m.member_id = ms.member_id
        WHERE m.email = p_email AND m.password = p_password;
    ELSEIF p_user_type = 'trainer' THEN
        SELECT 
            t.trainer_id AS user_id,
            t.name,
            t.email,
            'trainer' AS user_type,
            t.gym_id,
            t.specialization
        FROM Trainer t
        WHERE t.email = p_email AND t.password = p_password;
    ELSE
        SELECT 'Invalid user type' AS error_message;
    END IF;
END //
DELIMITER ;

-- Member Registration
DELIMITER //
CREATE PROCEDURE sp_register_member(
    IN p_name VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_password VARCHAR(255),
    IN p_age INT,
    IN p_gender VARCHAR(10),
    IN p_height DECIMAL(5,2),
    IN p_weight DECIMAL(5,2),
    IN p_gym_id INT,
    IN p_membership_cost DECIMAL(10,2)
)
BEGIN
    DECLARE v_member_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Registration failed' AS error_message;
    END;
    
    START TRANSACTION;
    
    -- Insert member
    INSERT INTO `Member` (name, email, password, age, gender, height, weight, join_date)
    VALUES (p_name, p_email, p_password, p_age, p_gender, p_height, p_weight, CURDATE());
    
    SET v_member_id = LAST_INSERT_ID();
    
    -- Create membership
    INSERT INTO Membership (member_id, gym_id, start_date, end_date, status, cost)
    VALUES (v_member_id, p_gym_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), 'Active', p_membership_cost);
    
    COMMIT;
    
    SELECT v_member_id AS member_id, 'Registration successful' AS message;
END //
DELIMITER ;