# ePACK - Hướng Dẫn Cài Đặt

## Yêu Cầu Hệ Thống

- Docker Desktop (latest version)
- macOS 11+, Windows 10/11, or Ubuntu 20.04+
- 8GB RAM minimum
- 20GB free disk space

---

## Cấu Trúc Package

```
ePACK/
├── images/
│   ├── epack-backend.tar       (1.1GB)
│   └── epack-frontend.tar      (207MB)
├── scripts/
│   ├── setup_prod.sh           ⭐ CHẠY ĐẦU TIÊN
│   ├── start.sh                ⭐ CHẠY SAU setup
│   ├── stop.sh
│   ├── update.sh
│   └── ...
├── docker-compose.yml
├── .env.docker.example
└── README.md
```

---

## Bước 1: Giải Nén Package

Giải nén ePACK.zip vào thư mục mong muốn:
- macOS/Linux: ~/ePACK hoặc /opt/epack
- Windows: C:\ePACK

---

## Bước 2: Mở Terminal / Command Prompt

### 🍎 macOS:
**Chạy file .sh bằng Terminal:**
1. Click chuột phải vào file `setup_prod.sh` (hoặc `start.sh`)
2. Chọn **"Open With"** → **"Other..."**
3. Trong cửa sổ mở ra, chọn **"All Applications"** (ở dưới cùng)
4. Tìm và chọn **Terminal** → Click **Open**

> 💡 **Tip:** Sau lần đầu, Terminal sẽ xuất hiện trong menu "Open With"

### 🪟 Windows:
**Chạy file .bat:**
1. Double-click vào file `setup_prod.bat` (hoặc `start.bat`)
2. Nếu có cảnh báo SmartScreen, chọn **"More info"** → **"Run anyway"**

> 💡 **Tip:** Hoặc click chuột phải → **"Run as administrator"** nếu cần quyền admin

---

## Bước 3: Chạy Setup (1 lần duy nhất)

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

**Script sẽ tự động:**
- ✅ Tạo file .env từ template
- ✅ Generate SECRET_KEY (64 chars)
- ✅ Generate ENCRYPTION_KEY (44 chars)
- ✅ Cấu hình data directory: ~/docker/volumes/epack

**Kết quả mong đợi:**
```
Working directory: /path/to/ePACK
=== ePACK Production Setup ===
Creating .env from template...
Generating security keys...
Securing .env file...
=== Setup Complete! ===
```

---

## Bước 4: Khởi Động ePACK

### macOS/Linux:
```bash
./scripts/start.sh
```

### Windows:
```batch
.\scripts\start.bat
```

**Script sẽ:**
- ✅ Load images từ tar files (lần đầu ~2-3 phút)
- ✅ Tạo Docker network: epack-network
- ✅ Start containers: epack-backend, epack-frontend
- ✅ Health check
- ✅ Tạo runtime folders tại ~/docker/volumes/epack/

**Kết quả mong đợi:**
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

## Bước 5: Truy Cập Ứng Dụng

Mở browser: **http://localhost:3000**

Lần đầu sẽ thấy trang signup/authentication.

---

## Bước 6: Dừng ePACK (Khi Cần)

### macOS/Linux:
```bash
./scripts/stop.sh
```

### Windows:
```batch
.\scripts\stop.bat
```

**Data sẽ được giữ lại** tại ~/docker/volumes/epack/

---

## Bước 7: Khởi Động Lại

Sau khi stop, chỉ cần chạy lại:

```bash
./scripts/start.sh
```

**KHÔNG CẦN** chạy lại setup_prod.sh!

---

## Các Lệnh Hữu Ích

### Xem logs:
```bash
./scripts/logs.sh           # Tất cả logs
./scripts/logs.sh backend   # Chỉ backend
./scripts/logs.sh frontend  # Chỉ frontend
```

### Kiểm tra trạng thái:
```bash
./scripts/status.sh
```

### Update/Restart:
```bash
./scripts/update.sh
```

---

## Thư Mục Data

Sau khi start lần đầu, data được lưu tại:

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

## Xử Lý Sự Cố

### Lỗi: "Docker is not running"
**Giải pháp:** Mở Docker Desktop và đợi khởi động

### Lỗi: "Port 3000 already in use"
**Giải pháp:** Dừng ứng dụng đang dùng port 3000
```bash
# macOS/Linux:
lsof -i :3000
kill -9 <PID>

# Windows:
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

### Lỗi: "Backend image not found"
**Giải pháp:** Kiểm tra file images/epack-backend.tar có tồn tại
```bash
ls -lh images/
```

### Reset về trạng thái ban đầu:
```bash
# Stop containers
./scripts/stop.sh --volumes  # Xóa cả data

# Xóa .env
rm .env

# Chạy lại setup
./scripts/setup_prod.sh

# Start lại
./scripts/start.sh
```

---

## Docker Desktop Verification

Sau khi start, mở **Docker Desktop**:

**Containers tab phải thấy:**
- Project: **epack** ✅
- Containers:
  - **epack-backend** (green, healthy)
  - **epack-frontend** (green, healthy)

**Images tab phải thấy:**
- **epack-backend:latest** (1.1GB)
- **epack-frontend:latest** (207MB)

**Volumes tab phải thấy:**
- epack_database
- epack_logs
- epack_sessions
- epack_cache
- ... (các volumes khác)

---

## FAQ

**Q: Có cần cài Python hay Node.js không?**
A: Không. Tất cả đã có trong Docker images.

**Q: Có cần internet để start không?**
A: Không. Images đã có trong tar files. Chỉ cần internet cho Google OAuth (lúc login).

**Q: Có thể chạy trên Windows 11 Home không?**
A: Có, với Docker Desktop + WSL2.

**Q: Data có mất khi stop containers không?**
A: Không. Data lưu tại ~/docker/volumes/epack/ và được preserve.

**Q: Có thể di chuyển folder ePACK sang máy khác không?**
A: Có, nhưng cần copy cả folder ~/docker/volumes/epack/ (data).

**Q: Làm sao backup data?**
A: Backup folder ~/docker/volumes/epack/
```bash
tar -czf epack-backup-$(date +%Y%m%d).tar.gz ~/docker/volumes/epack
```

---

## Hỗ Trợ

- **Documentation**: /docs/user-friendly/
- **Health Check**: http://localhost:8080/health
