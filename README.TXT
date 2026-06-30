README.TXT
INFO 465 Team 5 - Online Course Registration System UI/UX Draft

Repository URL:
https://github.com/aghomofeunml-fr/info465_team5_registration_system.git

Team Member Contributions:
- [Eileena Doek]: Home Screen / navigation flow
- [Michael Aghomo Feungue]: Course Search Screen, Set up Github Repository, Created first drafts of screens
- [Sinneh Bangura]: Student Registration Screen
- [Eileena Doek]: Instructor Schedule Screen
- [Michael Aghomo Feungue]: Session Enrollment Screen

One-Line Screen Summaries:
- index.html: Provides the home screen with navigation to course search, student registration, instructor schedule, and support pages.
- course-search.html: Allows users to search courses by department, instructor, or course number and view course details.
- student-registration.html: Shows a student registration dashboard, enrolled sessions, quick add options, and validation for duplicate/full courses.
- instructor-schedule.html: Allows an instructor to view assigned teaching sessions and navigate to enrolled student rosters.
- session-enrollment.html: Shows the enrolled student roster for a selected course session.
- student-login.html: Provides a student login screen for entering the registration portal.
- instructor-login.html: Provides an instructor/professor login screen for accessing schedules.

HTML/CSS/JS Elements and Techniques Used:
- Semantic HTML structure, tables, forms, buttons, input fields, and hyperlinks.
- Tailwind CSS CDN styling from the Stitch-generated screens.
- Consistent top navigation bar across all pages.
- JavaScript DOM manipulation for the course search filter and student registration validation demo.
- Registration validation checks for duplicate registration and enrollment limits.
- Responsive layout techniques using grids, flexbox, and reusable visual patterns.

Design Challenges and Decisions:
- The biggest design decision was keeping the screens visually consistent while connecting separate Stitch-generated screen files into one navigable browser prototype.
- A shared navigation bar was added so the evaluator can move between all screens easily.
- The student registration page includes a simple validation demo to show how the interface prevents duplicate registrations and blocks courses that have reached maximum enrollment.
- The course search page includes a functional search demo so the evaluator can understand how users would search by department, instructor, or course number.
