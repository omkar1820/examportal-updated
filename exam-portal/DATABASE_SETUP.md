# 🗄️ Database Setup Guide — Online Exam Portal

This guide covers all ways to create and configure the MySQL database for the Exam Portal.

---

## 📋 Database Overview

| Property | Value |
|---|---|
| Database Name | `examportal` |
| Engine | MySQL 8.0 |
| Default Port | `3306` |
| Default User | `root` |
| Default Password | `root123` |

### Tables

| Table | Purpose |
|---|---|
| `users` | Admin and student accounts |
| `exams` | Exam metadata (title, subject, duration, marks) |
| `questions` | MCQ questions linked to exams (4 options each) |
| `results` | Student submissions with score and percentage |
| `answers` | Per-question answers chosen by each student |

### Entity Relationship

```
users ──< exams (created_by)
users ──< results (student_id)
exams ──< questions (exam_id)
exams ──< results (exam_id)
results ──< answers (result_id)
questions ──< answers (question_id)
```

---

## 🐳 Option 1 — Docker (Recommended, Easiest)

No manual MySQL installation needed. Docker handles everything.

### Start MySQL Container

```bash
# From the project root directory
docker compose up mysql
```

This automatically:
- Pulls MySQL 8.0 image
- Creates the `examportal` database
- Runs `sql/schema.sql` (creates all tables + seed data)
- Stores data in a named volume (`mysql_data`) — survives restarts

### Connect to the Running Container

```bash
# Open MySQL shell inside the container
docker exec -it exam-mysql mysql -u root -proot123 examportal

# Verify tables
SHOW TABLES;
```

### Reset the Database (delete all data and start fresh)

```bash
docker compose down -v        # removes the mysql_data volume
docker compose up mysql       # recreates and reloads schema
```

---

## 💻 Option 2 — Local MySQL (Without Docker)

### Step 1 — Install MySQL 8.0

**Ubuntu / Debian:**
```bash
sudo apt update
sudo apt install mysql-server -y
sudo systemctl start mysql
sudo systemctl enable mysql
```

**macOS (Homebrew):**
```bash
brew install mysql
brew services start mysql
```

**Windows:**
Download the installer from https://dev.mysql.com/downloads/installer/ and run it.

---

### Step 2 — Secure the Installation (Linux only)

```bash
sudo mysql_secure_installation
```

Follow the prompts to set a root password.

---

### Step 3 — Log In to MySQL

```bash
mysql -u root -p
# Enter your root password when prompted
```

---

### Step 4 — Create the Database

```sql
CREATE DATABASE IF NOT EXISTS examportal;
USE examportal;
```

---

### Step 5 — Create All Tables

Copy and run the following SQL:

```sql
-- ── Users ──────────────────────────────────────────────────────────
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(100) NOT NULL,
  role ENUM('admin','student') DEFAULT 'student',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ── Exams ──────────────────────────────────────────────────────────
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

-- ── Questions ──────────────────────────────────────────────────────
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

-- ── Results ────────────────────────────────────────────────────────
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

-- ── Answers ────────────────────────────────────────────────────────
CREATE TABLE answers (
  id INT PRIMARY KEY AUTO_INCREMENT,
  result_id INT NOT NULL,
  question_id INT NOT NULL,
  selected_option CHAR(1),
  is_correct TINYINT(1) DEFAULT 0,
  FOREIGN KEY (result_id) REFERENCES results(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);
```

---

### Step 6 — Load Seed Data

```sql
-- Default admin account (password: admin123)
INSERT INTO users (name, email, password, role) VALUES
('Admin', 'admin@exam.com', 'admin123', 'admin');

-- Sample student account (password: student123)
INSERT INTO users (name, email, password, role) VALUES
('John Doe', 'john@exam.com', 'student123', 'student');

-- Sample exam
INSERT INTO exams (title, subject, duration_minutes, total_marks, created_by) VALUES
('Java Basics', 'Java Programming', 30, 5, 1);

-- Sample questions for the exam
INSERT INTO questions (exam_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks) VALUES
(1, 'Which keyword is used to create a class in Java?', 'class', 'Class', 'define', 'struct', 'A', 1),
(1, 'What is the size of int in Java?', '2 bytes', '4 bytes', '8 bytes', '16 bytes', 'B', 1),
(1, 'Which method is the entry point of a Java program?', 'start()', 'run()', 'main()', 'init()', 'C', 1),
(1, 'Which of these is NOT a Java primitive type?', 'int', 'boolean', 'String', 'char', 'C', 1),
(1, 'What does JVM stand for?', 'Java Virtual Machine', 'Java Variable Method', 'Java Verified Module', 'None', 'A', 1);
```

---

### Step 7 — Run the Schema File Directly (Alternative)

Instead of copy-pasting, you can run the file in one command:

```bash
mysql -u root -p < /path/to/exam-portal/sql/schema.sql
```

---

### Step 8 — Verify Setup

```sql
USE examportal;

-- Check tables exist
SHOW TABLES;

-- Check users
SELECT id, name, email, role FROM users;

-- Check exam and questions
SELECT e.title, COUNT(q.id) AS questions
FROM exams e
LEFT JOIN questions q ON q.exam_id = e.id
GROUP BY e.id;
```

Expected output:
```
+-------------+-----------+
| title       | questions |
+-------------+-----------+
| Java Basics | 5         |
+-------------+-----------+
```

---

## ☁️ Option 3 — AWS RDS MySQL

### Step 1 — Create RDS Instance

1. Open **AWS Console → RDS → Create database**
2. Settings:
   - Engine: **MySQL 8.0**
   - Template: Free tier (for dev) or Production
   - DB Instance Identifier: `exam-portal-db`
   - Master username: `admin`
   - Master password: *(choose a strong password)*
   - Instance class: `db.t3.micro`
   - Storage: 20 GiB (gp2)
   - Public access: **No** (use EC2 as a jump host)
   - VPC security group: allow port `3306` from your EC2 security group only
   - Initial database name: `examportal`
3. Click **Create database** and wait ~10 minutes.
4. Copy the **Endpoint** from the RDS details page.

---

### Step 2 — Initialize Schema on RDS

SSH into your EC2 instance first (RDS is in a private subnet), then run:

```bash
# From EC2 — upload schema file if not already there
scp -i your-key.pem sql/schema.sql ec2-user@<EC2_IP>:/home/ec2-user/

# SSH into EC2
ssh -i your-key.pem ec2-user@<EC2_IP>

# Install MySQL client (Amazon Linux)
sudo yum install mysql -y

# Run schema on RDS
mysql -h <RDS_ENDPOINT> -u admin -p examportal < /home/ec2-user/schema.sql
```

---

### Step 3 — Verify RDS Connection

```bash
mysql -h <RDS_ENDPOINT> -u admin -p examportal

# Inside MySQL shell:
SHOW TABLES;
SELECT name, role FROM users;
```

---

### Step 4 — Connect the App to RDS

Set these environment variables when running the Docker container on EC2:

```bash
docker run -d \
  --name exam-app \
  -p 8080:8080 \
  -e DB_HOST=<RDS_ENDPOINT> \
  -e DB_PORT=3306 \
  -e DB_NAME=examportal \
  -e DB_USER=admin \
  -e DB_PASS=<YOUR_RDS_PASSWORD> \
  exam-portal-app
```

Or add them to a `.env` file:

```env
DB_HOST=exam-portal-db.xxxxxxxx.ap-south-1.rds.amazonaws.com
DB_PORT=3306
DB_NAME=examportal
DB_USER=admin
DB_PASS=YourStrongPassword123
```

Then run:
```bash
docker run -d --name exam-app -p 8080:8080 --env-file .env exam-portal-app
```

---

## 🔌 Environment Variables Reference

The app (`DBConnection.java`) reads DB config from environment variables:

| Variable | Default | Description |
|---|---|---|
| `DB_HOST` | `localhost` | MySQL hostname or RDS endpoint |
| `DB_PORT` | `3306` | MySQL port |
| `DB_NAME` | `examportal` | Database name |
| `DB_USER` | `root` | MySQL username |
| `DB_PASS` | `root123` | MySQL password |

---

## 🔁 Common Database Operations

### Reset All Data (keep schema)
```sql
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE answers;
TRUNCATE TABLE results;
TRUNCATE TABLE questions;
TRUNCATE TABLE exams;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;
```

### Drop and Recreate Everything
```sql
DROP DATABASE IF EXISTS examportal;
CREATE DATABASE examportal;
USE examportal;
-- Then re-run schema.sql
```

### Add a New Admin User
```sql
INSERT INTO users (name, email, password, role)
VALUES ('New Admin', 'newadmin@exam.com', 'yourpassword', 'admin');
```

### View All Results with Student and Exam Names
```sql
SELECT
  u.name AS student,
  e.title AS exam,
  r.score,
  r.total_marks,
  r.percentage,
  r.submitted_at
FROM results r
JOIN users u ON u.id = r.student_id
JOIN exams e ON e.id = r.exam_id
ORDER BY r.submitted_at DESC;
```

---

## 🛠️ Troubleshooting

| Problem | Fix |
|---|---|
| `Access denied for user 'root'` | Use `sudo mysql -u root` on Linux without password first, then set password |
| `Can't connect to MySQL server` | Run `sudo systemctl start mysql` |
| `Table already exists` | Run `DROP DATABASE examportal;` then recreate |
| `Unknown database 'examportal'` | Run `CREATE DATABASE examportal;` manually |
| `Foreign key constraint fails` | Run schema in order — `users` table must exist before `exams` |
| RDS connection timeout from EC2 | Ensure RDS security group allows port `3306` from EC2's security group |
| Docker MySQL not initializing schema | Delete the volume: `docker compose down -v` then `docker compose up mysql` |
