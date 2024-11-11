CREATE DATABASE StudentCourseDB;
USE StudentCourseDB;

-- Step 1: Create the Database Schema
CREATE TABLE STUDENT (
    RollNo CHAR(6) PRIMARY KEY,
    StudentName VARCHAR(20) NOT NULL,
    CourseID VARCHAR(10),
    DOB DATE,
    MobileNumber CHAR(10) DEFAULT '9999999999'
);

CREATE TABLE COURSE (
    CID CHAR(6) PRIMARY KEY,
    CourseName VARCHAR(20) NOT NULL,
    CourseType CHAR(8) CHECK (CourseType IN ('Fulltime', 'Parttime')),
    TeacherInCharge VARCHAR(15),
    TotalSeats INT UNSIGNED,
    Duration INT UNSIGNED
);

CREATE TABLE ADMISSION (
    RollNo CHAR(6),
    CID CHAR(6),
    DateOfAdmission DATE,
    PRIMARY KEY (RollNo, CID),
    FOREIGN KEY (RollNo) REFERENCES STUDENT(RollNo),
    FOREIGN KEY (CID) REFERENCES COURSE(CID)
);

-- Step 2: Insert Sample Data
INSERT INTO STUDENT (RollNo, StudentName, CourseID, DOB) VALUES
('A001', 'Alice', 'C101', '2003-05-12'),
('B002', 'Bob', 'C102', '2000-08-19'),
('X003', 'Alex', 'C103', '2002-12-22'),
('Z009', 'Zara', 'C104', '1999-11-11'),
('X999', 'Xander', 'C105', '2001-03-15');

INSERT INTO COURSE (CID, CourseName, CourseType, TeacherInCharge, TotalSeats, Duration) VALUES
('C101', 'Computer Science', 'Fulltime', 'Gupta A.', 50, 4),
('C102', 'Chemistry', 'Parttime', 'Sharma B.', 30, 2),
('C103', 'Physics', 'Fulltime', 'Verma C.', 40, 3),
('C104', 'Mathematics', 'Parttime', 'Gupta D.', 25, 2),
('C105', 'Biology', 'Fulltime', 'Mehta E.', 20, 1);

INSERT INTO ADMISSION (RollNo, CID, DateOfAdmission) VALUES
('A001', 'C101', '2023-01-15'),
('B002', 'C102', '2023-02-10'),
('X003', 'C103', '2023-03-05'),
('Z009', 'C104', '2023-04-20'),
('X999', 'C105', '2023-05-25');

-- Queries
-- 1. Retrieve names of students enrolled in any course.
SELECT StudentName FROM STUDENT WHERE RollNo IN (SELECT RollNo FROM ADMISSION);

-- 2. Retrieve names of students enrolled in at least one part-time course.
SELECT DISTINCT StudentName 
FROM STUDENT 
JOIN ADMISSION ON STUDENT.RollNo = ADMISSION.RollNo
JOIN COURSE ON ADMISSION.CID = COURSE.CID
WHERE COURSE.CourseType = 'Parttime';

-- 3. Retrieve students’ names starting with the letter ‘A’.
SELECT StudentName FROM STUDENT WHERE StudentName LIKE 'A%';

-- 4. Retrieve students' details studying in courses ‘Computer Science’ or ‘Chemistry’.
SELECT STUDENT.* 
FROM STUDENT 
JOIN COURSE ON STUDENT.CourseID = COURSE.CID
WHERE CourseName IN ('Computer Science', 'Chemistry');

-- 5. Retrieve students’ names whose roll no either starts with ‘X’ or ‘Z’ and ends with ‘9’.
SELECT StudentName 
FROM STUDENT 
WHERE (RollNo LIKE 'X%' OR RollNo LIKE 'Z%') AND RollNo LIKE '%9';

-- 6. Find course details with more than N students enrolled (set N in query).
SET @N = 5;
SELECT COURSE.* 
FROM COURSE 
WHERE (SELECT COUNT(*) FROM ADMISSION WHERE ADMISSION.CID = COURSE.CID) > @N;

-- 7. Update student name.
UPDATE STUDENT SET StudentName = 'New Name' WHERE RollNo = 'A001';

-- 8. Find course names with more than five students enrolled.
SELECT CourseName 
FROM COURSE 
WHERE (SELECT COUNT(*) FROM ADMISSION WHERE ADMISSION.CID = COURSE.CID) > 5;

-- 9. Find name of the youngest student enrolled in course ‘BSc(PCS)’.
SELECT StudentName 
FROM STUDENT 
JOIN ADMISSION ON STUDENT.RollNo = ADMISSION.RollNo
JOIN COURSE ON ADMISSION.CID = COURSE.CID
WHERE CourseName = 'BSc(PCS)'
ORDER BY DOB DESC
LIMIT 1;

-- 10. Find name of the two most popular part-time courses.
SELECT CourseName 
FROM COURSE 
WHERE CourseType = 'Parttime'
ORDER BY (SELECT COUNT(*) FROM ADMISSION WHERE ADMISSION.CID = COURSE.CID) DESC
LIMIT 2;

-- 11. Find students in full-time courses only.
SELECT DISTINCT StudentName 
FROM STUDENT 
WHERE RollNo NOT IN (
    SELECT ADMISSION.RollNo 
    FROM ADMISSION 
    JOIN COURSE ON ADMISSION.CID = COURSE.CID 
    WHERE CourseType = 'Parttime'
);

-- 12. Find names of students who enrolled after 30 students took admission.
SELECT StudentName 
FROM STUDENT 
JOIN ADMISSION ON STUDENT.RollNo = ADMISSION.RollNo
WHERE ADMISSION.DateOfAdmission > (
    SELECT MIN(DateOfAdmission) 
    FROM (SELECT DateOfAdmission FROM ADMISSION ORDER BY DateOfAdmission LIMIT 30 OFFSET 29) AS Subquery
);

-- 13. Find all students who took admission and their course names.
SELECT StudentName, CourseName 
FROM STUDENT 
JOIN ADMISSION ON STUDENT.RollNo = ADMISSION.RollNo
JOIN COURSE ON ADMISSION.CID = COURSE.CID;

-- 14. Find course names with teacher-in-charge 'Gupta' for full-time courses.
SELECT CourseName 
FROM COURSE 
WHERE TeacherInCharge LIKE '%Gupta%' AND CourseType = 'Fulltime';

-- 15. Find courses with enrolled students equal to 10% of total seats.
SELECT CourseName 
FROM COURSE 
WHERE (SELECT COUNT(*) FROM ADMISSION WHERE ADMISSION.CID = COURSE.CID) <= (0.1 * TotalSeats);

-- 16. Display vacant seats for each course.
SELECT CourseName, (TotalSeats - (SELECT COUNT(*) FROM ADMISSION WHERE ADMISSION.CID = COURSE.CID)) AS VacantSeats 
FROM COURSE;

-- 17. Increase full-time course seats by 10%.
UPDATE COURSE 
SET TotalSeats = TotalSeats * 1.1 
WHERE CourseType = 'Fulltime';

-- 18. Add EnrollmentStatus field to ADMISSION.
ALTER TABLE ADMISSION ADD EnrollmentStatus CHAR(3) DEFAULT 'No';

-- 19. Update date of admission by 1 year.
UPDATE ADMISSION 
SET DateOfAdmission = DATE_ADD(DateOfAdmission, INTERVAL 1 YEAR);

-- 20. Create view for course names with total enrolled students.
CREATE VIEW CourseEnrollment AS 
SELECT CourseName, COUNT(ADMISSION.RollNo) AS TotalEnrolled 
FROM COURSE 
JOIN ADMISSION ON COURSE.CID = ADMISSION.CID 
GROUP BY CourseName;

-- 21. Count courses with more than 5 students enrolled by type.
SELECT CourseType, COUNT(*) AS CourseCount 
FROM COURSE 
WHERE (SELECT COUNT(*) FROM ADMISSION WHERE ADMISSION.CID = COURSE.CID) > 5 
GROUP BY CourseType;

-- 22. Add MobileNumber column in STUDENT table with default value.
ALTER TABLE STUDENT ADD MobileNumber CHAR(10) DEFAULT '9999999999';

-- 23. Count students older than 18.
SELECT COUNT(*) AS TotalStudents 
FROM STUDENT 
WHERE TIMESTAMPDIFF(YEAR, DOB, CURDATE()) > 18;

-- 24. Find students born in 2001 enrolled in part-time courses.
SELECT DISTINCT StudentName 
FROM STUDENT 
JOIN ADMISSION ON STUDENT.RollNo = ADMISSION.RollNo
JOIN COURSE ON ADMISSION.CID = COURSE.CID
WHERE YEAR(DOB) = 2001 AND CourseType = 'Parttime';

-- 25. Count 'BSc' courses with 'science' in the name.
SELECT COUNT(*) AS ScienceCoursesCount 
FROM COURSE 
WHERE CourseName LIKE 'BSc%' AND CourseName LIKE '%science%';