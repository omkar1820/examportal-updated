# ♟ Chess Engine — AWS Deployment Guide

## Contents

```
ChessEngine/
├── chess.html              ← The full chess app (single file, no dependencies)
├── deploy/
│   ├── setup.sh            ← Auto-setup script for EC2
│   └── nginx/
│       └── chess.conf      ← Nginx server config
└── src/                    ← Original Java source (for reference)
```

---

## ☁️ Deploy on AWS EC2 (Quickest way)

### Step 1 — Launch an EC2 Instance
1. Go to **AWS Console → EC2 → Launch Instance**
2. Choose **Ubuntu 22.04 LTS** (free tier eligible)
3. Instance type: `t2.micro` (free tier) or larger
4. **Security Group** — add these inbound rules:
   - HTTP port **80** from `0.0.0.0/0`
   - SSH port **22** from your IP
5. Create/select a key pair and launch

### Step 2 — Copy files to EC2
```bash
# Replace YOUR_KEY.pem and EC2_IP with your values
scp -i YOUR_KEY.pem -r ChessEngine/ ubuntu@EC2_IP:~/
```

### Step 3 — SSH in and run setup
```bash
ssh -i YOUR_KEY.pem ubuntu@EC2_IP
cd ~/ChessEngine/deploy
chmod +x setup.sh
sudo ./setup.sh
```

### Step 4 — Open in browser
```
http://EC2_IP
```

That's it! The chess engine is live.

---

## ☁️ Deploy on AWS S3 (Static Hosting — even simpler)

S3 is the simplest option — no server needed.

### Step 1 — Create a bucket
```bash
aws s3 mb s3://my-chess-engine --region us-east-1
```

### Step 2 — Enable static website hosting
```bash
aws s3 website s3://my-chess-engine \
  --index-document chess.html \
  --error-document chess.html
```

### Step 3 — Make public & upload
```bash
aws s3api put-bucket-policy --bucket my-chess-engine --policy '{
  "Version":"2012-10-17",
  "Statement":[{"Effect":"Allow","Principal":"*","Action":"s3:GetObject","Resource":"arn:aws:s3:::my-chess-engine/*"}]
}'

aws s3 cp chess.html s3://my-chess-engine/chess.html --content-type text/html
```

### Step 4 — Access URL
```
http://my-chess-engine.s3-website-us-east-1.amazonaws.com
```

---

## ☁️ Deploy with AWS CloudFront (CDN — fastest globally)

After S3 setup, create a CloudFront distribution pointing to the S3 bucket for global low-latency access.

---

## 🔧 Manual Nginx Setup (if not using setup.sh)

```bash
sudo apt update && sudo apt install nginx -y
sudo mkdir -p /var/www/chess
sudo cp chess.html /var/www/chess/
sudo cp deploy/nginx/chess.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/chess.conf /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx
```

---

## 🎮 Features

- Full chess engine with Alpha-Beta search
- Human vs Human, Human vs AI, AI vs AI modes
- Adjustable AI depth (I–IV)
- Move history, undo, board flip
- Pawn promotion picker
- Check/checkmate detection with animations
- Beautiful Royal Edition UI — works on all modern browsers
- **Zero dependencies** — single HTML file, no npm, no build step
