CREATE DATABASE IF NOT EXISTS examportal;
USE examportal;

CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(100) NOT NULL,
  role ENUM('admin','student') DEFAULT 'student',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE exams (
  id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(200) NOT NULL,
  subject VARCHAR(100) NOT NULL,
  duration_minutes INT DEFAULT 30,
  total_marks INT DEFAULT 0,
  created_by INT,
  is_active TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE questions (
  id INT PRIMARY KEY AUTO_INCREMENT,
  exam_id INT NOT NULL,
  question_text TEXT NOT NULL,
  option_a VARCHAR(300) NOT NULL,
  option_b VARCHAR(300) NOT NULL,
  option_c VARCHAR(300) NOT NULL,
  option_d VARCHAR(300) NOT NULL,
  correct_option CHAR(1) NOT NULL,
  marks INT DEFAULT 1,
  FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE
);

CREATE TABLE results (
  id INT PRIMARY KEY AUTO_INCREMENT,
  student_id INT NOT NULL,
  exam_id INT NOT NULL,
  score INT DEFAULT 0,
  total_marks INT DEFAULT 0,
  percentage DECIMAL(5,2) DEFAULT 0,
  submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES users(id),
  FOREIGN KEY (exam_id) REFERENCES exams(id)
);

CREATE TABLE answers (
  id INT PRIMARY KEY AUTO_INCREMENT,
  result_id INT NOT NULL,
  question_id INT NOT NULL,
  selected_option CHAR(1),
  is_correct TINYINT(1) DEFAULT 0,
  FOREIGN KEY (result_id) REFERENCES results(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

-- Default admin user (password: admin123)
INSERT INTO users (name, email, password, role) VALUES
('Admin', 'admin@exam.com', 'admin123', 'admin');

-- Sample student (password: student123)
INSERT INTO users (name, email, password, role) VALUES
('John Doe', 'john@exam.com', 'student123', 'student');

-- Sample exam
INSERT INTO exams (title, subject, duration_minutes, total_marks, created_by) VALUES
('Java Basics', 'Java Programming', 30, 5, 1);

-- Sample questions
INSERT INTO questions (exam_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks) VALUES
(1, 'Which keyword is used to create a class in Java?', 'class', 'Class', 'define', 'struct', 'A', 1),
(1, 'What is the size of int in Java?', '2 bytes', '4 bytes', '8 bytes', '16 bytes', 'B', 1),
(1, 'Which method is the entry point of a Java program?', 'start()', 'run()', 'main()', 'init()', 'C', 1),
(1, 'Which of these is NOT a Java primitive type?', 'int', 'boolean', 'String', 'char', 'C', 1),
(1, 'What does JVM stand for?', 'Java Virtual Machine', 'Java Variable Method', 'Java Verified Module', 'None', 'A', 1);
