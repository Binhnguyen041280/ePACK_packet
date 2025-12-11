# ePACK - Installation Guide

## System Requirements

- Docker Desktop (latest version)
- macOS 11+, Windows 10/11, or Ubuntu 20.04+
- 8GB RAM minimum
- 20GB free disk space

---

## Package Structure

```
ePACK/
├── images/
│   ├── epack-backend.tar       (1.1GB)
│   └── epack-frontend.tar      (207MB)
├── scripts/
│   ├── setup_prod.sh           ⭐ RUN THIS FIRST
│   ├── start.sh                ⭐ RUN AFTER setup
│   ├── stop.sh
│   ├── update.sh
│   └── ...
├── docker-compose.yml
├── .env.docker.example
├── INSTALLATION.md             (Vietnamese)
└── INSTALLATION_EN.md          (English - this file)
```

---

## Step 1: Extract Package

Extract ePACK.zip to your preferred location:
- macOS/Linux: ~/ePACK or /opt/epack
- Windows: C:\ePACK

---

## Step 2: Open Terminal / Command Prompt

### 🍎 macOS:
1. **Option 1:** Press `Cmd + Space`, type "Terminal", press Enter
2. **Option 2:** Open Finder → Applications → Utilities → Terminal
3. **Option 3 (recommended):** Right-click on ePACK folder → *"New Terminal at Folder"*

### 🪟 Windows:
1. **Option 1:** Press `Win + R`, type "cmd", press Enter
2. **Option 2:** Click on address bar in File Explorer → type "cmd" → press Enter
3. **Option 3:** Right-click on ePACK folder → *"Open in Terminal"*

---

## Step 3: Run Setup (One-time only)

### macOS/Linux:
```bash
cd ~/ePACK
./scripts/setup_prod.sh
```

### Windows:
```batch
cd C:\ePACK
.\scripts\setup_prod.bat
```

**The script will automatically:**
- ✅ Create .env file from template
- ✅ Generate SECRET_KEY (64 characters)
- ✅ Generate ENCRYPTION_KEY (44 characters)
- ✅ Configure data directory: ~/docker/volumes/epack

**Expected output:**
```
Working directory: /path/to/ePACK
=== ePACK Production Setup ===
Creating .env from template...
Generating security keys...
Securing .env file...
=== Setup Complete! ===
```

---

## Step 4: Start ePACK

### macOS/Linux:
```bash
./scripts/start.sh
```

### Windows:
```batch
.\scripts\start.bat
```

**The script will:**
- ✅ Load images from tar files (first time ~2-3 minutes)
- ✅ Create Docker network: epack-network
- ✅ Start containers: epack-backend, epack-frontend
- ✅ Perform health checks
- ✅ Create runtime folders at ~/docker/volumes/epack/

**Expected output:**
```
Working directory: /path/to/ePACK
🚀 ePACK Docker - Starting Application Stack

📦 Checking Docker images...
📦 Loading backend image from tar...
Loaded image: epack-backend:latest
✅ Backend image loaded
📦 Loading frontend image from tar...
Loaded image: epack-frontend:latest
✅ Frontend image loaded
✅ Docker images ready

🚀 Starting ePACK Application...

✅ ePACK stack started successfully

📊 Container Status:
NAME             IMAGE                   STATUS
epack-backend    epack-backend:latest    Up (healthy)
epack-frontend   epack-frontend:latest   Up (healthy)

🌐 Access URLs:
   Frontend:  http://localhost:3000
   Backend:   http://localhost:8080

🎉 ePACK is ready!
```

---

## Step 5: Access Application

Open browser: **http://localhost:3000**

You will see the signup/authentication page on first access.

---

## Step 6: Stop ePACK (When Needed)

### macOS/Linux:
```bash
./scripts/stop.sh
```

### Windows:
```batch
.\scripts\stop.bat
```

**Data will be preserved** at ~/docker/volumes/epack/

---

## Step 7: Restart

After stopping, simply run again:

```bash
./scripts/start.sh
```

**NO NEED** to run setup_prod.sh again!

---

## Useful Commands

### View logs:
```bash
./scripts/logs.sh           # All logs
./scripts/logs.sh backend   # Backend only
./scripts/logs.sh frontend  # Frontend only
```

### Check status:
```bash
./scripts/status.sh
```

### Update/Restart:
```bash
./scripts/update.sh
```

---

## Data Directory

After first start, data is stored at:

### macOS/Linux:
```
~/docker/volumes/epack/
├── database/           # SQLite databases
├── logs/              # Application logs
├── sessions/          # User sessions
├── cache/             # Cache files
├── uploads/           # Uploaded files
├── output/            # Processed videos
└── input/             # Video sources (configured later)
```

### Windows:
```
C:\Users\<YourName>\docker\volumes\epack\
```

---

## Troubleshooting

### Error: "Docker is not running"
**Solution:** Open Docker Desktop and wait for it to start

### Error: "Port 3000 already in use"
**Solution:** Stop the application using port 3000
```bash
# macOS/Linux:
lsof -i :3000
kill -9 <PID>

# Windows:
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

### Error: "Backend image not found"
**Solution:** Check if images/epack-backend.tar exists
```bash
ls -lh images/
```

### Reset to initial state:
```bash
# Stop containers
./scripts/stop.sh --volumes  # Also delete data

# Delete .env
rm .env

# Run setup again
./scripts/setup_prod.sh

# Start again
./scripts/start.sh
```

---

## Docker Desktop Verification

After starting, open **Docker Desktop**:

**Containers tab should show:**
- Project: **epack** ✅
- Containers:
  - **epack-backend** (green, healthy)
  - **epack-frontend** (green, healthy)

**Images tab should show:**
- **epack-backend:latest** (1.1GB)
- **epack-frontend:latest** (207MB)

**Volumes tab should show:**
- epack_database
- epack_logs
- epack_sessions
- epack_cache
- ... (other volumes)

---

## FAQ

**Q: Do I need to install Python or Node.js?**
A: No. Everything is included in the Docker images.

**Q: Do I need internet to start?**
A: No. Images are in the tar files. Internet is only needed for Google OAuth (during login).

**Q: Can I run on Windows 11 Home?**
A: Yes, with Docker Desktop + WSL2.

**Q: Will data be lost when I stop containers?**
A: No. Data is stored at ~/docker/volumes/epack/ and is preserved.

**Q: Can I move the ePACK folder to another computer?**
A: Yes, but you also need to copy ~/docker/volumes/epack/ (data folder).

**Q: How do I backup data?**
A: Backup the ~/docker/volumes/epack/ folder
```bash
tar -czf epack-backup-$(date +%Y%m%d).tar.gz ~/docker/volumes/epack
```

---

## Support

- **Documentation**: /docs/user-friendly/
- **Health Check**: http://localhost:8080/health
