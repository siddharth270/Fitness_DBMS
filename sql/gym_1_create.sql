DROP DATABASE IF EXISTS gym_db; 

CREATE DATABASE IF NOT EXISTS gym_db; 

USE gym_db; 

-- Create Gym table
CREATE TABLE Gym (
    gym_id INT PRIMARY KEY AUTO_INCREMENT,
    gym_name VARCHAR(100) NOT NULL,
    location VARCHAR(255),
    contact_number VARCHAR(20),
    email VARCHAR(100)
);

-- Create Trainer table
CREATE TABLE Trainer (
    trainer_id INT PRIMARY KEY AUTO_INCREMENT,
    gym_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    specialization VARCHAR(100),
    FOREIGN KEY (gym_id) REFERENCES Gym(gym_id) ON DELETE CASCADE
);

-- Create Member table
CREATE TABLE `Member` (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    age INT,
    gender VARCHAR(10),
    height DECIMAL(5,2),
    weight DECIMAL(5,2),
    join_date DATE NOT NULL
);

-- Create Membership table (associative entity between Member and Gym)
CREATE TABLE Membership (
    member_id INT,
    gym_id INT,
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) NOT NULL,
    cost DECIMAL(10,2),
    PRIMARY KEY (member_id, gym_id),
    FOREIGN KEY (member_id) REFERENCES `Member`(member_id) ON DELETE CASCADE,
    FOREIGN KEY (gym_id) REFERENCES Gym(gym_id) ON DELETE CASCADE
);

-- Create Appointment table
CREATE TABLE Appointment (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    trainer_id INT NOT NULL,
    member_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (trainer_id) REFERENCES Trainer(trainer_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES `Member`(member_id) ON DELETE CASCADE
);

-- Create Exercise table
CREATE TABLE Exercise (
    exercise_id INT PRIMARY KEY AUTO_INCREMENT,
    exercise_name VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(50) NOT NULL,
    target_muscle_group VARCHAR(100)
);

-- Create Workout Plan table
CREATE TABLE Workout_Plan (
    plan_id INT PRIMARY KEY AUTO_INCREMENT,
    trainer_id INT NOT NULL,
    member_id INT NOT NULL,
    plan_name VARCHAR(100) NOT NULL,
    FOREIGN KEY (trainer_id) REFERENCES Trainer(trainer_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES `Member`(member_id) ON DELETE CASCADE
);

-- Create Plan Exercise table
CREATE TABLE Plan_Exercise (
    plan_exercise_id INT PRIMARY KEY AUTO_INCREMENT,
    plan_id INT NOT NULL,
    exercise_id INT NOT NULL,
    target_sets INT,
    target_reps INT,
    target_weight DECIMAL(5,2),
    FOREIGN KEY (plan_id) REFERENCES Workout_Plan(plan_id) ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES Exercise(exercise_id) ON DELETE CASCADE
);

-- Create Workout table
CREATE TABLE Workout (
    workout_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    gym_id INT NOT NULL,
    plan_id INT NULL,
    date DATE NOT NULL,
    duration INT,
    calories_burned INT,
    FOREIGN KEY (member_id) REFERENCES `Member`(member_id) ON DELETE CASCADE,
    FOREIGN KEY (gym_id) REFERENCES Gym(gym_id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES Workout_Plan(plan_id) ON DELETE SET NULL
);

-- Create Set table
CREATE TABLE `Set` (
    set_id INT PRIMARY KEY AUTO_INCREMENT,
    workout_id INT NOT NULL,
    exercise_id INT NOT NULL,
    no_of_reps INT NOT NULL,
    weight DECIMAL(5,2),
    FOREIGN KEY (workout_id) REFERENCES Workout(workout_id) ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES Exercise(exercise_id) ON DELETE CASCADE
);