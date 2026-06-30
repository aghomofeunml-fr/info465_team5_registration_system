-- Team 5 Course Registration System - PostgreSQL Schema and Test Data
-- Database Build Assignment aligned to Team 5 Architecture Design Document
-- Target platform: AWS RDS PostgreSQL
-- Recommended database name: team5_registration_system

DROP SCHEMA IF EXISTS course_registration CASCADE;
CREATE SCHEMA course_registration;
SET search_path TO course_registration;

-- Roles are separated from Users to match the architecture design and support 3NF.
CREATE TABLE roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(30) NOT NULL UNIQUE CHECK (role_name IN ('Student', 'Instructor', 'Administrator'))
);

-- Departments are separated from Courses and Instructors to avoid repeating department data.
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_code VARCHAR(10) NOT NULL UNIQUE,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

-- Users stores account-level information only. Role details are referenced through role_id.
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    role_id INTEGER NOT NULL REFERENCES roles(role_id),
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    account_status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (account_status IN ('active', 'inactive', 'locked')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Students stores student-specific profile data and has a one-to-one relationship with Users.
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    university_id VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    major VARCHAR(100) NOT NULL,
    class_level VARCHAR(20) NOT NULL CHECK (class_level IN ('Freshman', 'Sophomore', 'Junior', 'Senior', 'Graduate'))
);

-- Instructors stores instructor-specific profile data and references Departments and Users.
CREATE TABLE instructors (
    instructor_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    department_id INTEGER NOT NULL REFERENCES departments(department_id),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    title VARCHAR(60) NOT NULL
);

-- Courses stores catalog-level course details. Course offerings are stored separately in Sessions.
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    department_id INTEGER NOT NULL REFERENCES departments(department_id),
    course_number VARCHAR(20) NOT NULL,
    course_title VARCHAR(150) NOT NULL,
    credit_hours INTEGER NOT NULL CHECK (credit_hours BETWEEN 1 AND 6),
    course_description TEXT,
    UNIQUE (department_id, course_number)
);

-- CoursePrerequisites is an associative table that prevents repeated prerequisite text in Courses.
CREATE TABLE course_prerequisites (
    course_id INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
    prerequisite_course_id INTEGER NOT NULL REFERENCES courses(course_id) ON DELETE RESTRICT,
    PRIMARY KEY (course_id, prerequisite_course_id),
    CHECK (course_id <> prerequisite_course_id)
);

-- Terms stores academic term details so sessions do not repeat date ranges or term metadata.
CREATE TABLE terms (
    term_id SERIAL PRIMARY KEY,
    term_name VARCHAR(40) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    CHECK (end_date > start_date)
);

-- Sessions are scheduled offerings of catalog courses. Modality and capacity vary by session.
CREATE TABLE sessions (
    session_id SERIAL PRIMARY KEY,
    course_id INTEGER NOT NULL REFERENCES courses(course_id),
    instructor_id INTEGER NOT NULL REFERENCES instructors(instructor_id),
    term_id INTEGER NOT NULL REFERENCES terms(term_id),
    section_number VARCHAR(10) NOT NULL,
    modality VARCHAR(20) NOT NULL CHECK (modality IN ('In Person', 'Online', 'Hybrid')),
    meeting_days VARCHAR(20),
    start_time TIME,
    end_time TIME,
    room VARCHAR(60),
    max_enrollment INTEGER NOT NULL CHECK (max_enrollment > 0),
    UNIQUE (course_id, term_id, section_number)
);

-- Enrollments connects students to course sessions. The unique constraint prevents duplicates.
CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    session_id INTEGER NOT NULL REFERENCES sessions(session_id) ON DELETE CASCADE,
    enrollment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'dropped', 'waitlisted')),
    UNIQUE (student_id, session_id)
);

-- Indexes support common search, registration, and reporting queries.
CREATE INDEX idx_users_role ON users(role_id);
CREATE INDEX idx_instructors_department ON instructors(department_id);
CREATE INDEX idx_courses_department ON courses(department_id);
CREATE INDEX idx_sessions_course ON sessions(course_id);
CREATE INDEX idx_sessions_instructor ON sessions(instructor_id);
CREATE INDEX idx_sessions_term ON sessions(term_id);
CREATE INDEX idx_enrollments_student ON enrollments(student_id);
CREATE INDEX idx_enrollments_session ON enrollments(session_id);
CREATE INDEX idx_enrollments_status ON enrollments(status);

-- Roles required by the architecture design.
INSERT INTO roles (role_name) VALUES
('Student'),
('Instructor'),
('Administrator');

-- Departments: at least 2 required.
INSERT INTO departments (department_code, department_name) VALUES
('INFO', 'Information Systems'),
('MKTG', 'Marketing'),
('CMSC', 'Computer Science'),
('ACCT', 'Accounting');

-- Users for 10 students, 5 instructors, and 1 administrator.
INSERT INTO users (role_id, email, password_hash) VALUES
((SELECT role_id FROM roles WHERE role_name = 'Student'), 'alice.nguyen@example.edu', 'hash_placeholder'),
((SELECT role_id FROM roles WHERE role_name = 'Student'), 'ben.carter@example.edu', 'hash_placeholder'),
((SELECT role_id FROM roles WHERE role_name = 'Student'), 'chloe.martin@example.edu', 'hash_placeholder'),
((SELECT role_id FROM roles WHERE role_name = 'Student'), 'daniel.kim@example.edu', 'hash_placeholder'),
((SELECT role_id FROM roles WHERE role_name = 'Student'), 'emma.johnson@example.edu', 'hash_placeholder'),
((SELECT role_id FROM roles WHERE role_name = 'Student'), 'fatima.ali@example.edu', 'hash_placeholder'),
((SELECT role_id FROM roles WHERE role_name = 'Student'), 'gabriel.smith@example.edu', 'hash_placeholder'),
((SELECT role_id FROM roles WHERE role_name = 'Student'), 'hannah.lee@example.edu', 'hash_placeholder'),
((SELECT role_id FROM roles WHERE role_name = 'Student'), 'isaac.wilson@example.edu', 'hash_placeholder'),
((SELECT role_id FROM roles WHERE role_name = 'Student'), 'jasmine.brown@example.edu', 'hash_placeholder'),
((SELECT role_id FROM roles WHERE role_name = 'Instructor'), 'maria.garcia@example.edu', 'hash_placeholder'),
((SELECT role_id FROM roles WHERE role_name = 'Instructor'), 'james.lee@example.edu', 'hash_placeholder'),
((SELECT role_id FROM roles WHERE role_name = 'Instructor'), 'priya.shah@example.edu', 'hash_placeholder'),
((SELECT role_id FROM roles WHERE role_name = 'Instructor'), 'michael.brown@example.edu', 'hash_placeholder'),
((SELECT role_id FROM roles WHERE role_name = 'Instructor'), 'kevin.chen@example.edu', 'hash_placeholder'),
((SELECT role_id FROM roles WHERE role_name = 'Administrator'), 'admin@example.edu', 'hash_placeholder');

-- Students: at least 10 required.
INSERT INTO students (user_id, university_id, first_name, last_name, major, class_level) VALUES
(1, 'V000001', 'Alice', 'Nguyen', 'Information Systems', 'Senior'),
(2, 'V000002', 'Ben', 'Carter', 'Information Systems', 'Junior'),
(3, 'V000003', 'Chloe', 'Martin', 'Marketing', 'Senior'),
(4, 'V000004', 'Daniel', 'Kim', 'Computer Science', 'Junior'),
(5, 'V000005', 'Emma', 'Johnson', 'Information Systems', 'Senior'),
(6, 'V000006', 'Fatima', 'Ali', 'Marketing', 'Junior'),
(7, 'V000007', 'Gabriel', 'Smith', 'Computer Science', 'Sophomore'),
(8, 'V000008', 'Hannah', 'Lee', 'Information Systems', 'Senior'),
(9, 'V000009', 'Isaac', 'Wilson', 'Marketing', 'Senior'),
(10, 'V000010', 'Jasmine', 'Brown', 'Computer Science', 'Junior');

-- Instructors: at least 5 required.
INSERT INTO instructors (user_id, department_id, first_name, last_name, title) VALUES
(11, (SELECT department_id FROM departments WHERE department_code = 'INFO'), 'Maria', 'Garcia', 'Professor'),
(12, (SELECT department_id FROM departments WHERE department_code = 'INFO'), 'James', 'Lee', 'Associate Professor'),
(13, (SELECT department_id FROM departments WHERE department_code = 'MKTG'), 'Priya', 'Shah', 'Professor'),
(14, (SELECT department_id FROM departments WHERE department_code = 'MKTG'), 'Michael', 'Brown', 'Lecturer'),
(15, (SELECT department_id FROM departments WHERE department_code = 'CMSC'), 'Kevin', 'Chen', 'Assistant Professor');

-- Courses: at least 5 required.
INSERT INTO courses (department_id, course_number, course_title, credit_hours, course_description) VALUES
((SELECT department_id FROM departments WHERE department_code = 'INFO'), 'INFO 465', 'Systems Analysis and Design', 3, 'Project-based course focused on systems analysis, design, and implementation planning.'),
((SELECT department_id FROM departments WHERE department_code = 'INFO'), 'INFO 350', 'Database Systems', 3, 'Relational database design, SQL, and database implementation concepts.'),
((SELECT department_id FROM departments WHERE department_code = 'INFO'), 'INFO 361', 'Business Programming', 3, 'Programming concepts for business applications.'),
((SELECT department_id FROM departments WHERE department_code = 'MKTG'), 'MKTG 302', 'Consumer Behavior', 3, 'Analysis of consumer decision-making and marketing strategy.'),
((SELECT department_id FROM departments WHERE department_code = 'MKTG'), 'MKTG 310', 'Digital Marketing Strategy', 3, 'Digital channels, campaign planning, analytics, and marketing strategy.'),
((SELECT department_id FROM departments WHERE department_code = 'CMSC'), 'CMSC 255', 'Introduction to Programming', 4, 'Introductory programming concepts and problem solving.');

-- Course prerequisites are stored in an associative table for 3NF compliance.
INSERT INTO course_prerequisites (course_id, prerequisite_course_id) VALUES
((SELECT course_id FROM courses WHERE course_number = 'INFO 465'), (SELECT course_id FROM courses WHERE course_number = 'INFO 350')),
((SELECT course_id FROM courses WHERE course_number = 'INFO 350'), (SELECT course_id FROM courses WHERE course_number = 'INFO 361')),
((SELECT course_id FROM courses WHERE course_number = 'MKTG 310'), (SELECT course_id FROM courses WHERE course_number = 'MKTG 302'));

-- Academic terms.
INSERT INTO terms (term_name, start_date, end_date) VALUES
('Fall 2026', '2026-08-24', '2026-12-12'),
('Spring 2027', '2027-01-12', '2027-05-05');

-- Sessions: at least 5 rows referencing Courses with varying modalities and max capacities.
INSERT INTO sessions (course_id, instructor_id, term_id, section_number, modality, meeting_days, start_time, end_time, room, max_enrollment) VALUES
((SELECT course_id FROM courses WHERE course_number = 'INFO 465'), (SELECT i.instructor_id FROM instructors i JOIN users u ON i.user_id = u.user_id WHERE u.email = 'maria.garcia@example.edu'), (SELECT term_id FROM terms WHERE term_name = 'Fall 2026'), '001', 'Hybrid', 'MW', '10:00', '11:15', 'Snead Hall 201', 30),
((SELECT course_id FROM courses WHERE course_number = 'INFO 350'), (SELECT i.instructor_id FROM instructors i JOIN users u ON i.user_id = u.user_id WHERE u.email = 'james.lee@example.edu'), (SELECT term_id FROM terms WHERE term_name = 'Fall 2026'), '001', 'In Person', 'TR', '12:30', '13:45', 'Snead Hall 215', 25),
((SELECT course_id FROM courses WHERE course_number = 'MKTG 302'), (SELECT i.instructor_id FROM instructors i JOIN users u ON i.user_id = u.user_id WHERE u.email = 'priya.shah@example.edu'), (SELECT term_id FROM terms WHERE term_name = 'Fall 2026'), '001', 'Online', NULL, NULL, NULL, 'Online', 40),
((SELECT course_id FROM courses WHERE course_number = 'MKTG 310'), (SELECT i.instructor_id FROM instructors i JOIN users u ON i.user_id = u.user_id WHERE u.email = 'michael.brown@example.edu'), (SELECT term_id FROM terms WHERE term_name = 'Fall 2026'), '001', 'In Person', 'MW', '14:00', '15:15', 'Business 110', 35),
((SELECT course_id FROM courses WHERE course_number = 'CMSC 255'), (SELECT i.instructor_id FROM instructors i JOIN users u ON i.user_id = u.user_id WHERE u.email = 'kevin.chen@example.edu'), (SELECT term_id FROM terms WHERE term_name = 'Fall 2026'), '001', 'Hybrid', 'TR', '09:30', '10:45', 'Engineering 105', 20),
((SELECT course_id FROM courses WHERE course_number = 'INFO 361'), (SELECT i.instructor_id FROM instructors i JOIN users u ON i.user_id = u.user_id WHERE u.email = 'james.lee@example.edu'), (SELECT term_id FROM terms WHERE term_name = 'Fall 2026'), '001', 'Online', NULL, NULL, NULL, 'Online', 45);
-- Enrollments: one student is enrolled in two classes; at least five other students are enrolled in one class.
INSERT INTO enrollments (student_id, session_id, enrollment_date, status) VALUES
((SELECT student_id FROM students WHERE university_id = 'V000001'), (SELECT session_id FROM sessions s JOIN courses c ON s.course_id = c.course_id WHERE c.course_number = 'INFO 465' AND s.section_number = '001'), '2026-08-15', 'active'),
((SELECT student_id FROM students WHERE university_id = 'V000001'), (SELECT session_id FROM sessions s JOIN courses c ON s.course_id = c.course_id WHERE c.course_number = 'MKTG 302' AND s.section_number = '001'), '2026-08-15', 'active'),
((SELECT student_id FROM students WHERE university_id = 'V000002'), (SELECT session_id FROM sessions s JOIN courses c ON s.course_id = c.course_id WHERE c.course_number = 'INFO 465' AND s.section_number = '001'), '2026-08-16', 'active'),
((SELECT student_id FROM students WHERE university_id = 'V000003'), (SELECT session_id FROM sessions s JOIN courses c ON s.course_id = c.course_id WHERE c.course_number = 'MKTG 302' AND s.section_number = '001'), '2026-08-16', 'active'),
((SELECT student_id FROM students WHERE university_id = 'V000004'), (SELECT session_id FROM sessions s JOIN courses c ON s.course_id = c.course_id WHERE c.course_number = 'CMSC 255' AND s.section_number = '001'), '2026-08-17', 'active'),
((SELECT student_id FROM students WHERE university_id = 'V000005'), (SELECT session_id FROM sessions s JOIN courses c ON s.course_id = c.course_id WHERE c.course_number = 'INFO 350' AND s.section_number = '001'), '2026-08-17', 'active'),
((SELECT student_id FROM students WHERE university_id = 'V000006'), (SELECT session_id FROM sessions s JOIN courses c ON s.course_id = c.course_id WHERE c.course_number = 'MKTG 310' AND s.section_number = '001'), '2026-08-18', 'active'),
((SELECT student_id FROM students WHERE university_id = 'V000007'), (SELECT session_id FROM sessions s JOIN courses c ON s.course_id = c.course_id WHERE c.course_number = 'CMSC 255' AND s.section_number = '001'), '2026-08-18', 'active'),
((SELECT student_id FROM students WHERE university_id = 'V000008'), (SELECT session_id FROM sessions s JOIN courses c ON s.course_id = c.course_id WHERE c.course_number = 'INFO 465' AND s.section_number = '001'), '2026-08-19', 'active'),
((SELECT student_id FROM students WHERE university_id = 'V000009'), (SELECT session_id FROM sessions s JOIN courses c ON s.course_id = c.course_id WHERE c.course_number = 'MKTG 310' AND s.section_number = '001'), '2026-08-19', 'active'),
((SELECT student_id FROM students WHERE university_id = 'V000010'), (SELECT session_id FROM sessions s JOIN courses c ON s.course_id = c.course_id WHERE c.course_number = 'INFO 361' AND s.section_number = '001'), '2026-08-20', 'active');
