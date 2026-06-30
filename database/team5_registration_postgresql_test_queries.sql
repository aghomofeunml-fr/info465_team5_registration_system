-- Team 5 Course Registration System - PostgreSQL Functional Test Queries
-- Run after team5_registration_postgresql_schema_and_data.sql

SET search_path TO course_registration;

-- Query 1: List all students registered for a specific course session.
-- Example: INFO 465, section 001, Fall 2026.
SELECT
    d.department_code,
    c.course_number,
    c.course_title,
    t.term_name,
    s.section_number,
    st.university_id,
    st.first_name,
    st.last_name,
    e.status
FROM enrollments e
JOIN students st ON e.student_id = st.student_id
JOIN sessions s ON e.session_id = s.session_id
JOIN courses c ON s.course_id = c.course_id
JOIN departments d ON c.department_id = d.department_id
JOIN terms t ON s.term_id = t.term_id
WHERE c.course_number = 'INFO 465'
  AND s.section_number = '001'
  AND t.term_name = 'Fall 2026'
  AND e.status = 'active'
ORDER BY st.last_name, st.first_name;

-- Query 2: Find all instructors teaching in the Information Systems department.
SELECT
    i.instructor_id,
    i.first_name,
    i.last_name,
    i.title,
    d.department_name,
    c.course_number,
    c.course_title,
    t.term_name,
    s.section_number
FROM instructors i
JOIN departments d ON i.department_id = d.department_id
JOIN sessions s ON i.instructor_id = s.instructor_id
JOIN courses c ON s.course_id = c.course_id
JOIN terms t ON s.term_id = t.term_id
WHERE d.department_name = 'Information Systems'
ORDER BY i.last_name, c.course_number;

-- Query 3: Retrieve the number of available slots in a specific session.
-- Example: INFO 465, section 001, Fall 2026.
SELECT
    c.course_number,
    c.course_title,
    t.term_name,
    s.section_number,
    s.max_enrollment,
    COUNT(e.enrollment_id) FILTER (WHERE e.status = 'active') AS active_enrollments,
    s.max_enrollment - COUNT(e.enrollment_id) FILTER (WHERE e.status = 'active') AS available_slots
FROM sessions s
JOIN courses c ON s.course_id = c.course_id
JOIN terms t ON s.term_id = t.term_id
LEFT JOIN enrollments e ON s.session_id = e.session_id
WHERE c.course_number = 'INFO 465'
  AND s.section_number = '001'
  AND t.term_name = 'Fall 2026'
GROUP BY c.course_number, c.course_title, t.term_name, s.section_number, s.max_enrollment;

-- Query 4: Identify students registered for more than one active session.
SELECT
    st.university_id,
    st.first_name,
    st.last_name,
    COUNT(e.session_id) AS active_session_count,
    STRING_AGG(c.course_number, ', ' ORDER BY c.course_number) AS registered_courses
FROM students st
JOIN enrollments e ON st.student_id = e.student_id
JOIN sessions s ON e.session_id = s.session_id
JOIN courses c ON s.course_id = c.course_id
WHERE e.status = 'active'
GROUP BY st.university_id, st.first_name, st.last_name
HAVING COUNT(e.session_id) > 1
ORDER BY active_session_count DESC, st.last_name;
