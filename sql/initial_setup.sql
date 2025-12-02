-- Create database
CREATE DATABASE IF NOT EXISTS gym_management;
USE gym_management;

-- Gyms table
CREATE TABLE IF NOT EXISTS gyms (
    gym_id INT AUTO_INCREMENT PRIMARY KEY,
    gym_name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    contact_number VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL
);

-- Members table
CREATE TABLE IF NOT EXISTS members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    gym_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    gender VARCHAR(10),
    height DECIMAL(5, 2),
    weight DECIMAL(5, 2),
    join_date DATE NOT NULL,
    FOREIGN KEY (gym_id) REFERENCES gyms(gym_id) ON DELETE CASCADE
);

-- Trainers table
CREATE TABLE IF NOT EXISTS trainers (
    trainer_id INT AUTO_INCREMENT PRIMARY KEY,
    gym_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    FOREIGN KEY (gym_id) REFERENCES gyms(gym_id) ON DELETE CASCADE
);

-- Insert sample gym
INSERT INTO gyms (gym_name, location, contact_number, email) 
VALUES ('FitZone Boston', '123 Fitness St, Boston, MA', '617-555-0100', 'info@fitzone.com');

-- Insert sample members (password: 'password123' hashed with Django's make_password)
-- Note: You'll need to hash these properly using Django's make_password function
INSERT INTO members (gym_id, name, email, password, gender, height, weight, join_date)
VALUES 
(1, 'John Doe', 'john@example.com', 'pbkdf2_sha256$720000$temp$placeholder', 'Male', 180.00, 75.00, '2024-01-15'),
(1, 'Jane Smith', 'jane@example.com', 'pbkdf2_sha256$720000$temp$placeholder', 'Female', 165.00, 62.00, '2024-02-01');

-- Insert sample trainers
INSERT INTO trainers (gym_id, name, email, password, specialization)
VALUES 
(1, 'Mike Johnson', 'mike@example.com', 'pbkdf2_sha256$720000$temp$placeholder', 'Strength Training'),
(1, 'Sarah Williams', 'sarah@example.com', 'pbkdf2_sha256$720000$temp$placeholder', 'Cardio & HIIT');