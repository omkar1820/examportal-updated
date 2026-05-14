# 📝 Online Exam Portal

A full-stack Java web application built with **JSP + Servlets + MySQL + Docker**.

## 🗂️ Project Structure

```
exam-portal/
├── src/main/
│   ├── java/com/examportal/
│   │   ├── model/         ← User, Exam, Question, Result
│   │   ├── dao/           ← UserDAO, ExamDAO, QuestionDAO, ResultDAO
│   │   ├── servlet/       ← LoginServlet, ExamServlet, TakeExamServlet...
│   │   └── util/          ← DBConnection
│   └── webapp/
│       ├── index.jsp      ← Login page
│       ├── register.jsp   ← Student registration
│       ├── admin/         ← Admin pages
│       └── student/       ← Student pages
├── sql/
│   └── schema.sql         ← Database schema + sample data
├── Dockerfile             ← Tomcat container
├── docker-compose.yml     ← App + MySQL together
└── pom.xml                ← Maven dependencies
```

---

## ✅ Prerequisites

Install these before starting:

| Tool | Download |
|---|---|
| Docker Desktop | https://www.docker.com/products/docker-desktop |
| VS Code | https://code.visualstudio.com |
| Java 17 JDK | https://adoptium.net |
| Maven | https://maven.apache.org/download.cgi |

VS Code Extensions to install:
- Extension Pack for Java (Microsoft)
- Docker (Microsoft)
- XML

---

## 🚀 Step-by-Step: Run in VS Code with Docker

### Step 1 — Open Project in VS Code

```bash
# Extract the project zip, then open in VS Code
code exam-portal
```

Or: File → Open Folder → select `exam-portal`

---

### Step 2 — Make sure Docker Desktop is running

Open Docker Desktop and wait for it to show "Engine running".

---

### Step 3 — Open VS Code Terminal

Press `` Ctrl + ` `` (backtick) to open the integrated terminal.

---

### Step 4 — Build and Start Everything

```bash
docker compose up --build
```

This will:
1. Pull MySQL 8.0 image
2. Create `examportal` database and load `schema.sql`
3. Build the Java WAR file (Maven inside Docker)
4. Start Tomcat on port 8080

**First run takes 3-5 minutes** (downloading images + Maven build).

You will see:
```
exam-mysql  | [Server] /usr/sbin/mysqld: ready for connections
exam-app    | INFO: Server startup in [XXXX] milliseconds
```

---

### Step 5 — Open in Browser

```
http://localhost:8080
```

---

## 🔑 Login Credentials

| Role | Email | Password |
|---|---|---|
| Admin | admin@exam.com | admin123 |
| Student | john@exam.com | student123 |

---

## 🎮 Features

### Admin Panel
- Dashboard with stats (exams, students, results)
- Create / Delete exams
- Add / Delete questions (MCQ with 4 options)
- View all student results

### Student Portal
- Register new account
- View available exams
- Take timed exam (auto-submits on timeout)
- View result with PASS/FAIL and score
- Can attempt each exam only once

---

## 🗄️ Database Setup (MySQL)

### Local Docker Setup

The MySQL database runs as a **separate Docker container** — fully external from the app.

Connect to it from any MySQL client (DBeaver, TablePlus, MySQL Workbench):

```
Host:     localhost
Port:     3306
Database: examportal
User:     root
Password: root123
```

Data persists in a Docker **named volume** (`mysql_data`) — survives container restarts.

---

### 📋 Database Schema

The schema is auto-loaded from `sql/schema.sql` when the MySQL container starts for the first time.

#### Tables Overview

| Table | Description |
|---|---|
| `users` | Stores admin and student accounts |
| `exams` | Exam metadata (title, subject, duration, marks) |
| `questions` | MCQ questions linked to exams |
| `results` | Student exam submission records with score |
| `answers` | Per-question answers submitted by students |

#### Table Definitions

```sql
-- Users table
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(100) NOT NULL,
  role ENUM('admin','student') DEFAULT 'student',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Exams table
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

-- Questions table
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

-- Results table
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

-- Answers table
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

#### Default Seed Data

```sql
-- Default admin (password: admin123)
INSERT INTO users (name, email, password, role)
VALUES ('Admin', 'admin@exam.com', 'admin123', 'admin');

-- Sample student (password: student123)
INSERT INTO users (name, email, password, role)
VALUES ('John Doe', 'john@exam.com', 'student123', 'student');
```

---

### 🔌 Database Connection Configuration

The app reads DB credentials from environment variables (see `DBConnection.java`):

| Variable | Default | Description |
|---|---|---|
| `DB_HOST` | `localhost` | MySQL host |
| `DB_PORT` | `3306` | MySQL port |
| `DB_NAME` | `examportal` | Database name |
| `DB_USER` | `root` | MySQL username |
| `DB_PASS` | `root123` | MySQL password |

Set these environment variables to connect to any MySQL instance (local, Docker, AWS RDS).

---

### 🛠️ Manual Database Setup (Without Docker)

If you want to run MySQL locally without Docker:

```bash
# 1. Log in to MySQL
mysql -u root -p

# 2. Run the schema file
source /path/to/exam-portal/sql/schema.sql

# 3. Verify tables were created
USE examportal;
SHOW TABLES;
```

---

## ☁️ AWS Deployment Steps

### Architecture Overview

```
Internet
   │
   ▼
[Application Load Balancer]
   │
   ▼
[EC2 Instance — Tomcat + Docker]
   │
   ▼
[AWS RDS — MySQL 8.0]
```

---

### Step 1 — Create an AWS Account & Set Up IAM

1. Go to https://aws.amazon.com and create an account.
2. In **IAM**, create a new user with programmatic access.
3. Attach the policies:
   - `AmazonEC2FullAccess`
   - `AmazonRDSFullAccess`
   - `AmazonVPCFullAccess`
4. Save the **Access Key ID** and **Secret Access Key**.

---

### Step 2 — Create a VPC and Security Groups

#### VPC Setup
1. Go to **VPC → Create VPC**.
2. Choose **VPC and more** (auto-creates subnets, route tables, internet gateway).
3. Name it `exam-portal-vpc`.
4. Use CIDR block: `10.0.0.0/16`.
5. Create **2 public subnets** and **2 private subnets** across 2 Availability Zones.

#### Security Groups

**EC2 Security Group** (`exam-app-sg`):

| Type | Protocol | Port | Source |
|---|---|---|---|
| SSH | TCP | 22 | Your IP |
| HTTP | TCP | 80 | 0.0.0.0/0 |
| Custom TCP | TCP | 8080 | 0.0.0.0/0 |

**RDS Security Group** (`exam-rds-sg`):

| Type | Protocol | Port | Source |
|---|---|---|---|
| MySQL/Aurora | TCP | 3306 | exam-app-sg |

---

### Step 3 — Launch an RDS MySQL Instance

1. Go to **RDS → Create database**.
2. Choose:
   - Engine: **MySQL 8.0**
   - Template: **Free tier** (for testing) or **Production**
   - DB Instance Identifier: `exam-portal-db`
   - Master username: `admin`
   - Master password: choose a strong password
3. Instance configuration: `db.t3.micro` (free tier)
4. Storage: 20 GiB (gp2)
5. Connectivity:
   - VPC: `exam-portal-vpc`
   - Subnet group: select private subnets
   - Public access: **No**
   - Security group: `exam-rds-sg`
6. Database name: `examportal`
7. Click **Create database** — wait 5–10 minutes.
8. Copy the **Endpoint** (e.g., `exam-portal-db.xxxxxxxx.ap-south-1.rds.amazonaws.com`).

#### Initialize the Schema on RDS

Connect to RDS through your EC2 instance (since RDS is in a private subnet):

```bash
# SSH into EC2 first (see Step 4), then:
mysql -h <RDS_ENDPOINT> -u admin -p examportal < /home/ec2-user/exam-portal/sql/schema.sql
```

---

### Step 4 — Launch an EC2 Instance

1. Go to **EC2 → Launch Instance**.
2. Choose:
   - Name: `exam-portal-server`
   - AMI: **Amazon Linux 2023** (or Ubuntu 22.04)
   - Instance type: `t2.micro` (free tier) or `t3.small`
   - Key pair: create a new key pair, download the `.pem` file
3. Network settings:
   - VPC: `exam-portal-vpc`
   - Subnet: a **public** subnet
   - Auto-assign public IP: **Enable**
   - Security group: `exam-app-sg`
4. Click **Launch Instance**.

#### SSH Into EC2

```bash
# Give the key correct permissions
chmod 400 your-key.pem

# SSH into the instance
ssh -i your-key.pem ec2-user@<EC2_PUBLIC_IP>
```

---

### Step 5 — Install Docker on EC2

```bash
# Update packages
sudo yum update -y          # Amazon Linux
# OR
sudo apt update -y          # Ubuntu

# Install Docker
sudo yum install docker -y  # Amazon Linux
# OR
sudo apt install docker.io -y  # Ubuntu

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group (no sudo needed)
sudo usermod -aG docker ec2-user

# Log out and back in, then verify
docker --version
```

---

### Step 6 — Deploy the Application on EC2

```bash
# 1. Upload the project to EC2
scp -i your-key.pem -r exam-portal/ ec2-user@<EC2_PUBLIC_IP>:/home/ec2-user/

# 2. SSH into EC2
ssh -i your-key.pem ec2-user@<EC2_PUBLIC_IP>

# 3. Navigate to the project
cd /home/ec2-user/exam-portal

# 4. Build and run (app only — RDS is the external DB)
docker build -t exam-portal-app .

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

#### Verify the container is running:
```bash
docker ps
docker logs exam-app
```

#### Access the app:
```
http://<EC2_PUBLIC_IP>:8080
```

---

### Step 7 — (Optional) Set Up Application Load Balancer

1. Go to **EC2 → Load Balancers → Create Load Balancer**.
2. Choose **Application Load Balancer**.
3. Name: `exam-portal-alb`
4. Scheme: **Internet-facing**
5. Listeners: HTTP on port 80
6. VPC: `exam-portal-vpc` → select public subnets
7. Security group: `exam-app-sg`
8. Target group:
   - Name: `exam-portal-targets`
   - Protocol: HTTP, Port: 8080
   - Health check path: `/`
   - Register your EC2 instance as a target
9. Click **Create**.

Access via ALB DNS:
```
http://exam-portal-alb-xxxxxxxx.ap-south-1.elb.amazonaws.com
```

---

### Step 8 — (Optional) Add HTTPS with ACM + Route 53

1. Request a free SSL certificate in **AWS Certificate Manager (ACM)**.
2. Add HTTPS listener (port 443) to the ALB using the ACM certificate.
3. In **Route 53**, create a hosted zone for your domain and point it to the ALB DNS name.

---

### 🔐 AWS Environment Variables Reference

When running the Docker container on EC2, set these environment variables to connect to RDS:

```bash
DB_HOST=<your-rds-endpoint>.rds.amazonaws.com
DB_PORT=3306
DB_NAME=examportal
DB_USER=admin
DB_PASS=<your-rds-password>
```

---

### 💰 AWS Free Tier Usage

| Service | Free Tier Limit |
|---|---|
| EC2 | 750 hrs/month — t2.micro |
| RDS | 750 hrs/month — db.t3.micro, 20 GB storage |
| ALB | 750 hrs/month (first 12 months) |
| Data Transfer | 1 GB/month outbound |

---

## 🛑 Stop the App

### Local Docker
```bash
docker compose down
```

To stop AND delete data:
```bash
docker compose down -v
```

### EC2
```bash
docker stop exam-app
docker rm exam-app
```

---

## 🔧 Useful Docker Commands

```bash
docker compose up --build          # Start (rebuild)
docker compose up -d               # Start in background
docker compose down                # Stop
docker compose logs -f             # Live logs
docker compose logs app            # App logs only
docker compose logs mysql          # DB logs only
docker ps                          # See running containers
```

---

## 🧪 Run Only Database (use local Tomcat)

```bash
docker compose up mysql            # Start only MySQL

# Then build and run locally:
mvn clean package
# Deploy target/exam-portal.war to local Tomcat
```

Set environment variables for local run:
```
DB_HOST=localhost
DB_PORT=3306
DB_NAME=examportal
DB_USER=root
DB_PASS=root123
```

---

## 🛠️ Troubleshooting

| Problem | Fix |
|---|---|
| Port 8080 already in use | Stop other services on 8080 or change port in docker-compose.yml |
| Port 3306 already in use | Stop local MySQL: `sudo service mysql stop` |
| App can't connect to DB | Wait 30 seconds — MySQL takes time to start |
| Build fails | Run `docker compose down -v` then `docker compose up --build` again |
| `exam-app` keeps restarting | Run `docker compose logs app` to see Java errors |
| EC2 can't reach RDS | Check that `exam-rds-sg` allows port 3306 from `exam-app-sg` |
| RDS connection timeout | Ensure EC2 and RDS are in the same VPC |
