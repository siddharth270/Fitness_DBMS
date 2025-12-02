-- Insert Gyms (3 gyms in Boston)
INSERT INTO Gym (gym_name, location, contact_number, email) VALUES
('FitZone Boston', '123 Commonwealth Ave, Boston, MA 02215', '617-555-0101', 'info@fitzoneboston.com'),
('PowerHouse Fitness', '456 Newbury Street, Boston, MA 02116', '617-555-0202', 'contact@powerhousefitness.com'),
('Elite Athletics', '789 Boylston Street, Boston, MA 02199', '617-555-0303', 'hello@eliteathletics.com');

-- Insert Trainers (3 per gym = 9 total)
INSERT INTO Trainer (gym_id, name, email, password, specialization) VALUES
-- FitZone Boston trainers
(1, 'Mike Johnson', 'mike.j@fitzone.com', 'pass123', 'Strength Training'),
(1, 'Sarah Chen', 'sarah.c@fitzone.com', 'trainer456', 'Cardio'),
(1, 'David Martinez', 'david.m@fitzone.com', 'yoga789', 'Yoga'),
-- PowerHouse Fitness trainers
(2, 'Emily Rodriguez', 'emily.r@powerhouse.com', 'strong123', 'Powerlifting'),
(2, 'James Wilson', 'james.w@powerhouse.com', 'crossfit456', 'CrossFit'),
(2, 'Lisa Thompson', 'lisa.t@powerhouse.com', 'hiit789', 'HIIT'),
-- Elite Athletics trainers
(3, 'Kevin Brown', 'kevin.b@elite.com', 'boxing123', 'Boxing'),
(3, 'Amanda Lee', 'amanda.l@elite.com', 'cali456', 'Calisthenics'),
(3, 'Ryan Garcia', 'ryan.g@elite.com', 'pilates789', 'Pilates');

-- Insert Members (10 per gym = 30 total)
INSERT INTO `Member` (name, email, password, age, gender, height, weight, join_date) VALUES
-- FitZone Boston members
('John Smith', 'john.smith@email.com', 'member123', 28, 'Male', 180.5, 82.3, '2024-01-15'),
('Emma Davis', 'emma.davis@email.com', 'pass456', 25, 'Female', 165.0, 58.5, '2024-02-01'),
('Michael Brown', 'michael.brown@email.com', 'secure789', 35, 'Male', 175.0, 88.0, '2024-01-20'),
('Sophia Taylor', 'sophia.taylor@email.com', 'mypass123', 29, 'Female', 168.5, 62.0, '2024-03-10'),
('Daniel Anderson', 'daniel.a@email.com', 'dan2024', 32, 'Male', 183.0, 90.5, '2024-02-15'),
('Olivia Martinez', 'olivia.m@email.com', 'olive123', 27, 'Female', 163.0, 56.0, '2024-01-25'),
('Chris Johnson', 'chris.j@email.com', 'chris456', 31, 'Male', 178.0, 85.0, '2024-03-05'),
('Isabella White', 'isabella.w@email.com', 'bella789', 26, 'Female', 170.0, 60.5, '2024-02-20'),
('Matthew Lee', 'matthew.lee@email.com', 'matt123', 33, 'Male', 182.0, 87.5, '2024-01-10'),
('Ava Harris', 'ava.harris@email.com', 'ava2024', 24, 'Female', 167.0, 59.0, '2024-03-15'),
-- PowerHouse Fitness members
('William Clark', 'william.c@email.com', 'will123', 30, 'Male', 177.0, 83.0, '2024-01-18'),
('Mia Lewis', 'mia.lewis@email.com', 'mia456', 28, 'Female', 166.0, 57.5, '2024-02-05'),
('Alexander Walker', 'alex.walker@email.com', 'alex789', 36, 'Male', 181.0, 91.0, '2024-01-22'),
('Charlotte Hall', 'charlotte.h@email.com', 'char123', 27, 'Female', 164.0, 58.0, '2024-03-12'),
('James Young', 'james.young@email.com', 'james2024', 34, 'Male', 179.0, 86.0, '2024-02-18'),
('Amelia King', 'amelia.king@email.com', 'amy123', 25, 'Female', 169.0, 61.0, '2024-01-28'),
('Benjamin Wright', 'ben.wright@email.com', 'ben456', 29, 'Male', 184.0, 89.0, '2024-03-08'),
('Harper Scott', 'harper.s@email.com', 'harper789', 26, 'Female', 162.0, 55.5, '2024-02-22'),
('Lucas Green', 'lucas.green@email.com', 'lucas123', 31, 'Male', 176.0, 84.0, '2024-01-12'),
('Evelyn Adams', 'evelyn.a@email.com', 'eve2024', 23, 'Female', 171.0, 60.0, '2024-03-18'),
-- Elite Athletics members
('Henry Baker', 'henry.baker@email.com', 'henry123', 33, 'Male', 180.0, 88.5, '2024-01-16'),
('Abigail Nelson', 'abby.nelson@email.com', 'abby456', 27, 'Female', 165.5, 59.5, '2024-02-03'),
('Sebastian Carter', 'seb.carter@email.com', 'seb789', 35, 'Male', 178.5, 87.0, '2024-01-24'),
('Emily Mitchell', 'emily.mitch@email.com', 'emily123', 28, 'Female', 167.5, 61.5, '2024-03-14'),
('Jack Perez', 'jack.perez@email.com', 'jack2024', 32, 'Male', 182.5, 90.0, '2024-02-16'),
('Sofia Roberts', 'sofia.r@email.com', 'sofia123', 26, 'Female', 163.5, 57.0, '2024-01-26'),
('Owen Turner', 'owen.turner@email.com', 'owen456', 30, 'Male', 177.5, 85.5, '2024-03-06'),
('Scarlett Phillips', 'scarlett.p@email.com', 'scar789', 25, 'Female', 168.0, 59.0, '2024-02-24'),
('Liam Campbell', 'liam.camp@email.com', 'liam123', 34, 'Male', 181.5, 89.5, '2024-01-14'),
('Aria Parker', 'aria.parker@email.com', 'aria2024', 24, 'Female', 166.5, 58.5, '2024-03-20');

-- Insert Memberships (all 30 members have memberships)
INSERT INTO Membership (member_id, gym_id, start_date, end_date, status, cost) VALUES
-- FitZone Boston memberships
(1, 1, '2024-01-15', '2025-01-15', 'Active', 599.99),
(2, 1, '2024-02-01', '2025-02-01', 'Active', 599.99),
(3, 1, '2024-01-20', '2025-01-20', 'Active', 599.99),
(4, 1, '2024-03-10', '2025-03-10', 'Active', 599.99),
(5, 1, '2024-02-15', '2025-02-15', 'Active', 599.99),
(6, 1, '2024-01-25', '2025-01-25', 'Active', 599.99),
(7, 1, '2024-03-05', '2025-03-05', 'Active', 599.99),
(8, 1, '2024-02-20', '2025-02-20', 'Active', 599.99),
(9, 1, '2024-01-10', '2024-12-10', 'Expired', 599.99),
(10, 1, '2024-03-15', '2025-03-15', 'Active', 599.99),
-- PowerHouse Fitness memberships
(11, 2, '2024-01-18', '2025-01-18', 'Active', 699.99),
(12, 2, '2024-02-05', '2025-02-05', 'Active', 699.99),
(13, 2, '2024-01-22', '2025-01-22', 'Active', 699.99),
(14, 2, '2024-03-12', '2025-03-12', 'Active', 699.99),
(15, 2, '2024-02-18', '2025-02-18', 'Active', 699.99),
(16, 2, '2024-01-28', '2025-01-28', 'Active', 699.99),
(17, 2, '2024-03-08', '2025-03-08', 'Active', 699.99),
(18, 2, '2024-02-22', '2025-02-22', 'Active', 699.99),
(19, 2, '2024-01-12', '2025-01-12', 'Active', 699.99),
(20, 2, '2024-03-18', '2025-03-18', 'Active', 699.99),
-- Elite Athletics memberships
(21, 3, '2024-01-16', '2025-01-16', 'Active', 749.99),
(22, 3, '2024-02-03', '2025-02-03', 'Active', 749.99),
(23, 3, '2024-01-24', '2025-01-24', 'Active', 749.99),
(24, 3, '2024-03-14', '2025-03-14', 'Active', 749.99),
(25, 3, '2024-02-16', '2025-02-16', 'Active', 749.99),
(26, 3, '2024-01-26', '2025-01-26', 'Active', 749.99),
(27, 3, '2024-03-06', '2025-03-06', 'Active', 749.99),
(28, 3, '2024-02-24', '2025-02-24', 'Active', 749.99),
(29, 3, '2024-01-14', '2024-12-14', 'Expired', 749.99),
(30, 3, '2024-03-20', '2025-03-20', 'Active', 749.99);

-- Insert Exercises (comprehensive list)
INSERT INTO Exercise (exercise_name, category, target_muscle_group) VALUES
-- Strength exercises
('Bench Press', 'Strength', 'Chest'),
('Squat', 'Strength', 'Legs'),
('Deadlift', 'Strength', 'Back'),
('Shoulder Press', 'Strength', 'Shoulders'),
('Barbell Row', 'Strength', 'Back'),
('Leg Press', 'Strength', 'Legs'),
('Incline Bench Press', 'Strength', 'Chest'),
('Romanian Deadlift', 'Strength', 'Hamstrings'),
-- Cardio exercises
('Treadmill Running', 'Cardio', 'Full Body'),
('Stationary Bike', 'Cardio', 'Legs'),
('Rowing Machine', 'Cardio', 'Full Body'),
('Elliptical', 'Cardio', 'Full Body'),
('Stair Climber', 'Cardio', 'Legs'),
-- Bodyweight exercises
('Pull-ups', 'Strength', 'Back'),
('Push-ups', 'Strength', 'Chest'),
('Dips', 'Strength', 'Triceps'),
('Bodyweight Squats', 'Strength', 'Legs'),
('Lunges', 'Strength', 'Legs'),
-- Isolation exercises
('Bicep Curls', 'Strength', 'Biceps'),
('Tricep Extensions', 'Strength', 'Triceps'),
('Leg Curls', 'Strength', 'Hamstrings'),
('Leg Extensions', 'Strength', 'Quadriceps'),
('Calf Raises', 'Strength', 'Calves'),
('Lateral Raises', 'Strength', 'Shoulders'),
-- Core exercises
('Planks', 'Strength', 'Core'),
('Crunches', 'Strength', 'Abs'),
('Russian Twists', 'Strength', 'Obliques'),
('Hanging Leg Raises', 'Strength', 'Abs'),
('Cable Woodchops', 'Strength', 'Obliques');

-- Insert Appointments (mix of completed, upcoming, and cancelled)
INSERT INTO Appointment (trainer_id, member_id, start_time, end_time, status) VALUES
-- FitZone Boston appointments
(1, 1, '2024-11-15 10:00:00', '2024-11-15 11:00:00', 'Completed'),
(1, 3, '2024-11-20 14:00:00', '2024-11-20 15:00:00', 'Completed'),
(1, 5, '2024-12-05 09:00:00', '2024-12-05 10:00:00', 'Scheduled'),
(2, 2, '2024-11-18 16:00:00', '2024-11-18 17:00:00', 'Completed'),
(2, 4, '2024-12-03 10:00:00', '2024-12-03 11:00:00', 'Scheduled'),
(3, 6, '2024-11-22 15:00:00', '2024-11-22 16:00:00', 'Completed'),
(3, 8, '2024-12-04 11:00:00', '2024-12-04 12:00:00', 'Scheduled'),
-- PowerHouse Fitness appointments
(4, 11, '2024-11-16 09:00:00', '2024-11-16 10:00:00', 'Completed'),
(4, 13, '2024-11-25 13:00:00', '2024-11-25 14:00:00', 'Completed'),
(4, 15, '2024-12-06 10:00:00', '2024-12-06 11:00:00', 'Scheduled'),
(5, 12, '2024-11-19 17:00:00', '2024-11-19 18:00:00', 'Completed'),
(5, 14, '2024-12-02 15:00:00', '2024-12-02 16:00:00', 'Scheduled'),
(6, 16, '2024-11-21 10:00:00', '2024-11-21 11:00:00', 'Completed'),
(6, 18, '2024-12-07 14:00:00', '2024-12-07 15:00:00', 'Scheduled'),
-- Elite Athletics appointments
(7, 21, '2024-11-17 11:00:00', '2024-11-17 12:00:00', 'Completed'),
(7, 23, '2024-11-26 16:00:00', '2024-11-26 17:00:00', 'Completed'),
(7, 25, '2024-12-08 09:00:00', '2024-12-08 10:00:00', 'Scheduled'),
(8, 22, '2024-11-20 10:00:00', '2024-11-20 11:00:00', 'Completed'),
(8, 24, '2024-12-01 13:00:00', '2024-12-01 14:00:00', 'Cancelled'),
(9, 26, '2024-11-23 14:00:00', '2024-11-23 15:00:00', 'Completed'),
(9, 28, '2024-12-09 11:00:00', '2024-12-09 12:00:00', 'Scheduled');

-- Insert Workout Plans (created by trainers for members)
INSERT INTO Workout_Plan (trainer_id, member_id, plan_name) VALUES
-- FitZone Boston plans
(1, 1, 'Strength Building Program'),
(1, 3, 'Powerlifting Foundation'),
(1, 5, 'Upper Body Focus'),
(2, 2, 'Cardio Endurance Plan'),
(2, 4, 'Fat Loss Program'),
(3, 6, 'Flexibility and Balance'),
(3, 8, 'Yoga Strength Fusion'),
-- PowerHouse Fitness plans
(4, 11, 'Advanced Powerlifting'),
(4, 13, 'Deadlift Specialization'),
(5, 12, 'CrossFit Fundamentals'),
(5, 14, 'MetCon Mastery'),
(6, 16, 'HIIT Fat Burner'),
(6, 18, 'Interval Training Pro'),
-- Elite Athletics plans
(7, 21, 'Boxing Conditioning'),
(7, 23, 'Fighter Strength'),
(8, 22, 'Calisthenics Progression'),
(8, 24, 'Bodyweight Master'),
(9, 26, 'Pilates Core Strength'),
(9, 28, 'Functional Mobility');

-- Insert Plan Exercises (exercises within workout plans)
INSERT INTO Plan_Exercise (plan_id, exercise_id, target_sets, target_reps, target_weight) VALUES
-- Plan 1: Strength Building Program
(1, 1, 4, 8, 80.0),  -- Bench Press
(1, 2, 4, 6, 100.0), -- Squat
(1, 3, 3, 5, 120.0), -- Deadlift
(1, 5, 3, 8, 70.0),  -- Barbell Row
-- Plan 2: Powerlifting Foundation
(2, 2, 5, 5, 110.0), -- Squat
(2, 3, 5, 3, 140.0), -- Deadlift
(2, 1, 5, 5, 90.0),  -- Bench Press
(2, 4, 4, 6, 50.0),  -- Shoulder Press
-- Plan 3: Upper Body Focus
(3, 1, 4, 10, 70.0), -- Bench Press
(3, 7, 3, 10, 60.0), -- Incline Bench Press
(3, 14, 3, 12, 0.0), -- Pull-ups
(3, 19, 3, 12, 15.0), -- Bicep Curls
-- Plan 4: Cardio Endurance Plan
(4, 9, 1, 30, 0.0),  -- Treadmill Running (30 mins)
(4, 10, 1, 20, 0.0), -- Stationary Bike
(4, 11, 1, 15, 0.0), -- Rowing Machine
(4, 12, 1, 25, 0.0), -- Elliptical
-- Plan 5: Fat Loss Program
(5, 9, 1, 25, 0.0),  -- Treadmill Running
(5, 13, 1, 20, 0.0), -- Stair Climber
(5, 15, 3, 20, 0.0), -- Push-ups
(5, 17, 3, 15, 0.0), -- Bodyweight Squats
-- Plan 6: Flexibility and Balance
(6, 25, 3, 60, 0.0), -- Planks (60 seconds)
(6, 18, 3, 15, 0.0), -- Lunges
(6, 17, 3, 20, 0.0), -- Bodyweight Squats
(6, 15, 3, 15, 0.0), -- Push-ups
-- Plan 7: Yoga Strength Fusion
(7, 25, 3, 45, 0.0), -- Planks
(7, 18, 3, 12, 0.0), -- Lunges
(7, 14, 2, 8, 0.0),  -- Pull-ups
(7, 15, 3, 15, 0.0), -- Push-ups
-- Plan 8: Advanced Powerlifting
(8, 2, 6, 3, 150.0), -- Squat
(8, 3, 6, 2, 180.0), -- Deadlift
(8, 1, 6, 3, 110.0), -- Bench Press
(8, 8, 4, 5, 100.0), -- Romanian Deadlift
-- Plan 9: Deadlift Specialization
(9, 3, 6, 5, 160.0), -- Deadlift
(9, 8, 4, 8, 90.0),  -- Romanian Deadlift
(9, 5, 4, 6, 80.0),  -- Barbell Row
(9, 21, 3, 10, 40.0), -- Leg Curls
-- Plan 10: CrossFit Fundamentals
(10, 2, 5, 10, 90.0),  -- Squat
(10, 14, 5, 10, 0.0),  -- Pull-ups
(10, 15, 5, 20, 0.0),  -- Push-ups
(10, 11, 1, 15, 0.0),  -- Rowing Machine
-- Plan 11: MetCon Mastery
(11, 17, 5, 20, 0.0),  -- Bodyweight Squats
(11, 15, 5, 15, 0.0),  -- Push-ups
(11, 13, 1, 15, 0.0),  -- Stair Climber
(11, 10, 1, 10, 0.0),  -- Stationary Bike
-- Plan 12: HIIT Fat Burner
(12, 9, 8, 2, 0.0),    -- Treadmill (intervals)
(12, 15, 4, 20, 0.0),  -- Push-ups
(12, 17, 4, 25, 0.0),  -- Bodyweight Squats
(12, 18, 4, 20, 0.0),  -- Lunges
-- Plan 13: Interval Training Pro
(13, 13, 10, 2, 0.0),  -- Stair Climber
(13, 16, 5, 15, 0.0),  -- Dips
(13, 14, 5, 10, 0.0),  -- Pull-ups
(13, 10, 1, 15, 0.0),  -- Stationary Bike
-- Plan 14: Boxing Conditioning
(14, 9, 1, 20, 0.0),   -- Treadmill
(14, 15, 5, 20, 0.0),  -- Push-ups
(14, 25, 3, 60, 0.0),  -- Planks
(14, 27, 3, 20, 0.0),  -- Russian Twists
-- Plan 15: Fighter Strength
(15, 3, 4, 5, 130.0),  -- Deadlift
(15, 14, 4, 10, 0.0),  -- Pull-ups
(15, 16, 4, 12, 0.0),  -- Dips
(15, 26, 4, 20, 0.0),  -- Crunches
-- Plan 16: Calisthenics Progression
(16, 14, 5, 8, 0.0),   -- Pull-ups
(16, 15, 5, 20, 0.0),  -- Push-ups
(16, 16, 4, 12, 0.0),  -- Dips
(16, 17, 4, 25, 0.0),  -- Bodyweight Squats
-- Plan 17: Bodyweight Master
(17, 14, 6, 12, 0.0),  -- Pull-ups
(17, 16, 5, 15, 0.0),  -- Dips
(17, 18, 4, 20, 0.0),  -- Lunges
(17, 28, 3, 15, 0.0),  -- Hanging Leg Raises
-- Plan 18: Pilates Core Strength
(18, 25, 4, 60, 0.0),  -- Planks
(18, 26, 4, 25, 0.0),  -- Crunches
(18, 27, 4, 20, 0.0),  -- Russian Twists
(18, 18, 3, 15, 0.0),  -- Lunges
-- Plan 19: Functional Mobility
(19, 17, 3, 20, 0.0),  -- Bodyweight Squats
(19, 18, 3, 15, 0.0),  -- Lunges
(19, 25, 3, 45, 0.0),  -- Planks
(19, 15, 3, 15, 0.0);  -- Push-ups

-- Insert Workouts (completed workouts by members)
INSERT INTO Workout (member_id, gym_id, plan_id, date, duration, calories_burned) VALUES
-- FitZone Boston workouts
(1, 1, 1, '2024-11-16', 65, 450),
(1, 1, 1, '2024-11-18', 70, 480),
(1, 1, NULL, '2024-11-20', 55, 380),
(2, 1, 4, '2024-11-19', 45, 520),
(2, 1, 4, '2024-11-22', 50, 550),
(3, 1, 2, '2024-11-21', 75, 420),
(3, 1, 2, '2024-11-24', 80, 450),
(4, 1, 5, '2024-11-17', 40, 480),
(5, 1, 3, '2024-11-23', 60, 400),
(6, 1, 6, '2024-11-25', 50, 320),
-- PowerHouse Fitness workouts
(11, 2, 8, '2024-11-17', 90, 500),
(11, 2, 8, '2024-11-20', 95, 520),
(12, 2, 10, '2024-11-18', 60, 580),
(12, 2, 10, '2024-11-21', 65, 600),
(13, 2, 9, '2024-11-19', 85, 480),
(14, 2, 11, '2024-11-22', 55, 620),
(15, 2, NULL, '2024-11-23', 70, 450),
(16, 2, 12, '2024-11-24', 45, 680),
(17, 2, NULL, '2024-11-25', 60, 420),
(18, 2, 13, '2024-11-26', 50, 650),
-- Elite Athletics workouts
(21, 3, 14, '2024-11-18', 55, 540),
(21, 3, 14, '2024-11-21', 60, 560),
(22, 3, 16, '2024-11-19', 50, 380),
(22, 3, 16, '2024-11-22', 55, 400),
(23, 3, 15, '2024-11-20', 70, 480),
(24, 3, 17, '2024-11-23', 45, 360),
(25, 3, NULL, '2024-11-24', 65, 520),
(26, 3, 18, '2024-11-25', 40, 290),
(27, 3, NULL, '2024-11-26', 55, 410),
(28, 3, 19, '2024-11-27', 50, 340);

-- Insert Sets (actual sets performed during workouts)
INSERT INTO `Set` (workout_id, exercise_id, no_of_reps, weight) VALUES
-- Workout 1: Member 1, Plan 1 exercises
(1, 1, 8, 80.0),  -- Bench Press Set 1
(1, 1, 8, 80.0),  -- Bench Press Set 2
(1, 1, 7, 80.0),  -- Bench Press Set 3
(1, 1, 6, 80.0),  -- Bench Press Set 4
(1, 2, 6, 100.0), -- Squat Set 1
(1, 2, 6, 100.0), -- Squat Set 2
(1, 2, 5, 100.0), -- Squat Set 3
(1, 2, 5, 100.0), -- Squat Set 4
(1, 3, 5, 120.0), -- Deadlift Set 1
(1, 3, 5, 120.0), -- Deadlift Set 2
(1, 3, 4, 120.0), -- Deadlift Set 3
-- Workout 2: Member 1, Plan 1 exercises
(2, 1, 8, 82.5),  -- Bench Press (increased weight)
(2, 1, 8, 82.5),
(2, 1, 8, 82.5),
(2, 1, 7, 82.5),
(2, 2, 6, 102.5),
(2, 2, 6, 102.5),
(2, 2, 6, 102.5),
(2, 2, 5, 102.5),
(2, 5, 8, 70.0),  -- Barbell Row
(2, 5, 8, 70.0),
(2, 5, 7, 70.0),
-- Workout 3: Member 1, free workout
(3, 19, 12, 20.0), -- Bicep Curls
(3, 19, 12, 20.0),
(3, 19, 10, 20.0),
(3, 20, 12, 25.0), -- Tricep Extensions
(3, 20, 12, 25.0),
(3, 20, 10, 25.0),
-- Workout 4: Member 2, Cardio plan
(4, 9, 30, 0.0),  -- Treadmill 30 mins
(4, 10, 20, 0.0), -- Bike 20 mins
(4, 12, 25, 0.0), -- Elliptical 25 mins
-- Workout 5: Member 2, Cardio plan
(5, 9, 25, 0.0),
(5, 11, 15, 0.0), -- Rowing
(5, 13, 20, 0.0), -- Stair Climber
-- Workout 6: Member 3, Powerlifting
(6, 2, 5, 110.0), -- Squat
(6, 2, 5, 110.0),
(6, 2, 5, 110.0),
(6, 2, 4, 110.0),
(6, 2, 4, 110.0),
(6, 3, 3, 140.0), -- Deadlift
(6, 3, 3, 140.0),
(6, 3, 3, 140.0),
(6, 3, 2, 140.0),
(6, 3, 2, 140.0),
-- Workout 7: Member 3, Powerlifting
(7, 1, 5, 90.0),  -- Bench Press
(7, 1, 5, 90.0),
(7, 1, 5, 90.0),
(7, 1, 4, 90.0),
(7, 1, 4, 90.0),
(7, 4, 6, 50.0),  -- Shoulder Press
(7, 4, 6, 50.0),
(7, 4, 5, 50.0),
(7, 4, 5, 50.0),
-- Workout 8: Member 4, Fat Loss
(8, 9, 25, 0.0),  -- Treadmill
(8, 13, 20, 0.0), -- Stair Climber
(8, 15, 20, 0.0), -- Push-ups
(8, 15, 18, 0.0),
(8, 15, 15, 0.0),
-- Workout 9: Member 5, Upper Body
(9, 1, 10, 70.0), -- Bench Press
(9, 1, 10, 70.0),
(9, 1, 9, 70.0),
(9, 1, 8, 70.0),
(9, 14, 12, 0.0), -- Pull-ups
(9, 14, 10, 0.0),
(9, 14, 8, 0.0),
-- Workout 10: Member 6, Flexibility
(10, 25, 60, 0.0), -- Planks
(10, 25, 55, 0.0),
(10, 25, 50, 0.0),
(10, 18, 15, 0.0), -- Lunges
(10, 18, 15, 0.0),
(10, 18, 12, 0.0),
-- Workout 11: Member 11, Advanced Powerlifting
(11, 2, 3, 150.0), -- Squat
(11, 2, 3, 150.0),
(11, 2, 3, 150.0),
(11, 2, 2, 150.0),
(11, 2, 2, 150.0),
(11, 2, 2, 150.0),
(11, 3, 2, 180.0), -- Deadlift
(11, 3, 2, 180.0),
(11, 3, 2, 180.0),
(11, 3, 1, 180.0),
-- Workout 12: Member 11
(12, 1, 3, 110.0), -- Bench Press
(12, 1, 3, 110.0),
(12, 1, 3, 110.0),
(12, 1, 2, 110.0),
(12, 1, 2, 110.0),
(12, 1, 2, 110.0),
(12, 8, 5, 100.0), -- Romanian Deadlift
(12, 8, 5, 100.0),
(12, 8, 4, 100.0),
(12, 8, 4, 100.0),
-- Workout 13: Member 12, CrossFit
(13, 2, 10, 90.0),  -- Squat
(13, 2, 10, 90.0),
(13, 2, 9, 90.0),
(13, 2, 8, 90.0),
(13, 2, 8, 90.0),
(13, 14, 10, 0.0),  -- Pull-ups
(13, 14, 9, 0.0),
(13, 14, 8, 0.0),
(13, 14, 7, 0.0),
(13, 14, 6, 0.0),
-- Workout 14: Member 12
(14, 15, 20, 0.0),  -- Push-ups
(14, 15, 20, 0.0),
(14, 15, 18, 0.0),
(14, 15, 16, 0.0),
(14, 15, 15, 0.0),
(14, 11, 15, 0.0),  -- Rowing
-- Workout 15: Member 13, Deadlift Specialization
(15, 3, 5, 160.0),  -- Deadlift
(15, 3, 5, 160.0),
(15, 3, 5, 160.0),
(15, 3, 4, 160.0),
(15, 3, 4, 160.0),
(15, 3, 3, 160.0),
(15, 8, 8, 90.0),   -- Romanian Deadlift
(15, 8, 8, 90.0),
(15, 8, 7, 90.0),
(15, 8, 6, 90.0),
-- Workout 16: Member 14, MetCon
(16, 17, 20, 0.0),  -- Bodyweight Squats
(16, 17, 20, 0.0),
(16, 17, 20, 0.0),
(16, 17, 18, 0.0),
(16, 17, 16, 0.0),
(16, 15, 15, 0.0),  -- Push-ups
(16, 15, 15, 0.0),
(16, 15, 12, 0.0),
(16, 15, 10, 0.0),
(16, 15, 10, 0.0),
-- Workout 17: Member 15, free workout
(17, 6, 10, 120.0), -- Leg Press
(17, 6, 10, 120.0),
(17, 6, 10, 120.0),
(17, 22, 12, 35.0), -- Leg Extensions
(17, 22, 12, 35.0),
(17, 22, 10, 35.0),
-- Workout 18: Member 16, HIIT
(18, 9, 2, 0.0),    -- Treadmill intervals
(18, 9, 2, 0.0),
(18, 9, 2, 0.0),
(18, 9, 2, 0.0),
(18, 15, 20, 0.0),  -- Push-ups
(18, 15, 18, 0.0),
(18, 15, 16, 0.0),
(18, 15, 14, 0.0),
-- Workout 19: Member 17, free workout
(19, 1, 8, 75.0),   -- Bench Press
(19, 1, 8, 75.0),
(19, 1, 7, 75.0),
(19, 2, 10, 85.0),  -- Squat
(19, 2, 10, 85.0),
(19, 2, 9, 85.0),
-- Workout 20: Member 18, Interval Training
(20, 13, 2, 0.0),   -- Stair Climber
(20, 13, 2, 0.0),
(20, 13, 2, 0.0),
(20, 16, 15, 0.0),  -- Dips
(20, 16, 14, 0.0),
(20, 16, 12, 0.0),
(20, 14, 10, 0.0),  -- Pull-ups
(20, 14, 8, 0.0),
(20, 14, 7, 0.0),
-- Workout 21: Member 21, Boxing
(21, 9, 20, 0.0),   -- Treadmill
(21, 15, 20, 0.0),  -- Push-ups
(21, 15, 20, 0.0),
(21, 15, 18, 0.0),
(21, 15, 16, 0.0),
(21, 15, 15, 0.0),
(21, 25, 60, 0.0),  -- Planks
(21, 25, 55, 0.0),
(21, 25, 50, 0.0),
-- Workout 22: Member 21
(22, 27, 20, 0.0),  -- Russian Twists
(22, 27, 20, 0.0),
(22, 27, 18, 0.0),
(22, 15, 20, 0.0),  -- Push-ups
(22, 15, 18, 0.0),
(22, 15, 16, 0.0),
-- Workout 23: Member 22, Calisthenics
(23, 14, 8, 0.0),   -- Pull-ups
(23, 14, 8, 0.0),
(23, 14, 7, 0.0),
(23, 14, 6, 0.0),
(23, 14, 6, 0.0),
(23, 15, 20, 0.0),  -- Push-ups
(23, 15, 20, 0.0),
(23, 15, 18, 0.0),
(23, 15, 16, 0.0),
(23, 15, 15, 0.0),
-- Workout 24: Member 22
(24, 16, 12, 0.0),  -- Dips
(24, 16, 12, 0.0),
(24, 16, 10, 0.0),
(24, 16, 9, 0.0),
(24, 17, 25, 0.0),  -- Bodyweight Squats
(24, 17, 25, 0.0),
(24, 17, 22, 0.0),
(24, 17, 20, 0.0),
-- Workout 25: Member 23, Fighter Strength
(25, 3, 5, 130.0),  -- Deadlift
(25, 3, 5, 130.0),
(25, 3, 5, 130.0),
(25, 3, 4, 130.0),
(25, 14, 10, 0.0),  -- Pull-ups
(25, 14, 9, 0.0),
(25, 14, 8, 0.0),
(25, 14, 7, 0.0),
-- Workout 26: Member 24, Bodyweight Master
(26, 14, 12, 0.0),  -- Pull-ups
(26, 14, 11, 0.0),
(26, 14, 10, 0.0),
(26, 16, 15, 0.0),  -- Dips
(26, 16, 14, 0.0),
(26, 16, 12, 0.0),
-- Workout 27: Member 25, free workout
(27, 2, 8, 95.0),   -- Squat
(27, 2, 8, 95.0),
(27, 2, 7, 95.0),
(27, 6, 12, 140.0), -- Leg Press
(27, 6, 12, 140.0),
(27, 6, 10, 140.0),
-- Workout 28: Member 26, Pilates
(28, 25, 60, 0.0),  -- Planks
(28, 25, 60, 0.0),
(28, 25, 55, 0.0),
(28, 25, 50, 0.0),
(28, 26, 25, 0.0),  -- Crunches
(28, 26, 25, 0.0),
(28, 26, 22, 0.0),
(28, 26, 20, 0.0),
-- Workout 29: Member 27, free workout
(29, 1, 10, 72.5),  -- Bench Press
(29, 1, 10, 72.5),
(29, 1, 9, 72.5),
(29, 19, 12, 17.5), -- Bicep Curls
(29, 19, 12, 17.5),
(29, 19, 10, 17.5),
-- Workout 30: Member 28, Functional Mobility
(30, 17, 20, 0.0),  -- Bodyweight Squats
(30, 17, 20, 0.0),
(30, 17, 18, 0.0),
(30, 18, 15, 0.0),  -- Lunges
(30, 18, 15, 0.0),
(30, 18, 12, 0.0);