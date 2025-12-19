# ePACK - Hướng Dẫn Cài Đặt Cho Người Mới Bắt Đầu

> 📌 **Dành cho người chưa biết gì về kỹ thuật** - Hướng dẫn này sẽ đưa bạn qua từng bước một cách chi tiết.

---

## 🤖 Bước 0: Cài Đặt ChatGPT Atlas (Khuyến Nghị Cao)

> [!TIP]
> **ChatGPT Atlas** là trợ lý AI có thể đọc và hiểu tài liệu hướng dẫn. Cài đặt trước để có người hỗ trợ bạn 24/7!

### Tại sao nên cài ChatGPT Atlas?

- ✅ Có thể hỏi bất kỳ câu hỏi nào về ePACK
- ✅ Hướng dẫn cài đặt từng bước theo ngữ cảnh của bạn
- ✅ Giải đáp lỗi và troubleshooting ngay lập tức
- ✅ Hoạt động như một chuyên gia kỹ thuật cá nhân

### Yêu cầu hệ thống cho ChatGPT Atlas:

| Thành phần | Yêu cầu |
|------------|---------|
| **macOS** | macOS 12 (Monterey) trở lên, chip Apple Silicon (M1/M2/M3/M4) |
| **Windows** | Sắp ra mắt (coming soon) |
| **Tài khoản** | Cần có tài khoản ChatGPT (miễn phí hoặc trả phí) |

> [!NOTE]
> Hiện tại ChatGPT Atlas chỉ hỗ trợ **macOS với Apple Silicon**. Nếu bạn dùng Windows hoặc Mac Intel, bạn có thể sử dụng ChatGPT web tại https://chat.openai.com thay thế.

### Cách cài đặt ChatGPT Atlas (macOS):

1. **Tải trình duyệt:**
   - Mở trình duyệt bất kỳ (Safari, Chrome...)
   - Truy cập: **https://chatgpt.com/atlas**
   - Click **"Download for macOS"**
   - File `.dmg` sẽ được tải về

2. **Cài đặt:**
   - Mở file `.dmg` vừa tải từ thư mục Downloads
   - Kéo biểu tượng **Atlas** vào thư mục **Applications**
   - Đóng cửa sổ và eject disk image

3. **Khởi động và đăng nhập:**
   - Mở Atlas từ Applications hoặc tìm kiếm Spotlight
   - Chấp nhận các yêu cầu bảo mật của macOS nếu có
   - Đăng nhập bằng tài khoản ChatGPT của bạn
   - (Tùy chọn) Import bookmarks từ Chrome/Safari nếu muốn

> [!IMPORTANT]
> **Sau khi cài xong ChatGPT Atlas**, bạn có thể insert file `INSTALLATION.md` này vào chat và yêu cầu:
> 
> *"Hướng dẫn tôi cài đặt ePACK từng bước theo file này"*
> 
> ChatGPT Atlas sẽ đọc hiểu và hướng dẫn bạn chi tiết!

---

## 🐳 Bước 1: Cài Đặt Docker Desktop

> [!CAUTION]
> **Docker Desktop là BẮT BUỘC** - ePACK chạy hoàn toàn trên Docker. Không cài Docker = Không chạy được ePACK.

### Yêu Cầu Hệ Thống Tối Thiểu

| Thành phần | Yêu cầu tối thiểu | Khuyến nghị |
|------------|-------------------|-------------|
| **RAM** | 8 GB | 16 GB |
| **Ổ cứng trống** | 20 GB | 50 GB |
| **CPU** | 2 cores | 4 cores |
| **Hệ điều hành** | Xem bên dưới | - |

### Hệ Điều Hành Được Hỗ Trợ

| OS | Phiên bản tối thiểu | Ghi chú |
|----|---------------------|---------|
| 🍎 **macOS** | macOS 11 (Big Sur) trở lên | Intel hoặc Apple Silicon |
| 🪟 **Windows** | Windows 10/11 (64-bit) | Cần bật WSL2 |
| 🐧 **Linux** | Ubuntu 20.04+ | Hoặc các distro tương đương |

### Cách Cài Docker Desktop

#### 🍎 macOS:

1. Truy cập: https://www.docker.com/products/docker-desktop/
2. Click **"Download for Mac"**
   - Chọn **Apple Chip** nếu dùng Mac M1/M2/M3
   - Chọn **Intel Chip** nếu dùng Mac cũ hơn
3. Mở file `.dmg` đã tải
4. Kéo biểu tượng **Docker** vào thư mục **Applications**
5. Mở Docker Desktop từ Applications
6. Đợi Docker khởi động (biểu tượng cá voi ở thanh menu chuyển sang xanh)

#### 🪟 Windows:

1. Truy cập: https://www.docker.com/products/docker-desktop/
2. Click **"Download for Windows"**
3. Chạy file `.exe` đã tải
4. **Quan trọng**: Đảm bảo chọn **"Use WSL 2 instead of Hyper-V"**
5. Làm theo hướng dẫn cài đặt
6. Restart máy tính khi được yêu cầu
7. Mở Docker Desktop và đợi khởi động

> [!WARNING]
> **Windows cần bật WSL2:**
> - Nếu chưa có WSL2, Docker Desktop sẽ hướng dẫn bạn cài
> - Hoặc mở PowerShell (Run as Administrator) và chạy: `wsl --install`

#### 🐧 Linux (Ubuntu):

```bash
# Cập nhật packages
sudo apt-get update

# Cài đặt packages cần thiết
sudo apt-get install ca-certificates curl gnupg

# Tải và cài Docker Desktop
# Xem chi tiết tại: https://docs.docker.com/desktop/install/linux-install/
```

### Kiểm Tra Docker Đã Hoạt Động

Sau khi cài xong, mở Terminal (macOS/Linux) hoặc Command Prompt (Windows) và chạy:

```bash
docker --version
```

**Kết quả mong đợi:**
```
Docker version 24.x.x, build xxxxxxx
```

> [!NOTE]
> Nếu thấy lỗi "docker command not found", hãy mở Docker Desktop và đợi nó khởi động hoàn toàn.

---

## � Khuyến Cáo: Dùng ChatGPT Atlas Để Hỗ Trợ Cài Đặt

> [!TIP]
> **Cách hiệu quả nhất để cài đặt ePACK:**

### Bước thực hiện:

1. **Mở ChatGPT Atlas** (extension đã cài ở Bước 0)

2. **Upload file hướng dẫn:**
   - Click vào biểu tượng 📎 (attach file) trong ChatGPT
   - Chọn file `INSTALLATION.md` này
   - Hoặc copy toàn bộ nội dung file và paste vào chat

3. **Yêu cầu hướng dẫn:**
   ```
   Tôi muốn cài đặt ePACK. Hãy hướng dẫn tôi từng bước 
   theo file hướng dẫn này. Máy tôi dùng [macOS/Windows].
   ```

4. **Làm theo hướng dẫn của ChatGPT Atlas:**
   - AI sẽ hỏi bạn các câu hỏi để hiểu tình huống
   - Hướng dẫn từng bước phù hợp với máy của bạn
   - Giải đáp ngay khi gặp lỗi

### Lợi ích:

| Tự cài đặt | Dùng ChatGPT Atlas |
|------------|-------------------|
| Đọc tài liệu dài | AI tóm tắt bước cần làm |
| Gặp lỗi không biết xử lý | AI giải thích và đưa ra giải pháp |
| Phải Google nhiều | Hỏi trực tiếp, câu trả lời ngay |
| Mất 30-60 phút | Tiết kiệm 50% thời gian |

---

## 📦 Bước 2: Giải Nén Package ePACK

1. Tải file **ePACK.zip** (được cung cấp)

2. Giải nén vào thư mục:
   - **macOS/Linux:** `~/ePACK` hoặc `/opt/epack`
   - **Windows:** `C:\ePACK`

3. Sau khi giải nén, cấu trúc thư mục:
   ```
   ePACK/
   ├── images/
   │   ├── epack-backend.tar       (1.1GB)
   │   └── epack-frontend.tar      (207MB)
   ├── scripts/
   │   ├── setup_prod.sh           ⭐ Chạy đầu tiên (macOS/Linux)
   │   ├── setup_prod.bat          ⭐ Chạy đầu tiên (Windows)
   │   ├── start.sh / start.bat
   │   └── stop.sh / stop.bat
   ├── docker-compose.yml
   └── README.md
   ```

---

## ⚙️ Bước 3: Chạy Setup (Chỉ 1 Lần Duy Nhất)

> [!IMPORTANT]
> Script setup chỉ cần chạy **MỘT LẦN** khi cài đặt lần đầu.

### 🍎 macOS/Linux:

**Cách 1 - Click chuột:**
1. Click chuột phải vào file `setup_prod.sh` trong thư mục `scripts/`
2. Chọn **"Open With"** → **"Other..."**
3. Chọn **"All Applications"** (ở dưới cùng)
4. Tìm và chọn **Terminal** → Click **Open**

**Cách 2 - Terminal:**
```bash
cd ~/ePACK
./scripts/setup_prod.sh
```

### 🪟 Windows:

1. Double-click vào file `setup_prod.bat` trong thư mục `scripts/`
2. Nếu có cảnh báo SmartScreen:
   - Click **"More info"**
   - Click **"Run anyway"**

**Kết quả mong đợi:**
```
=== ePACK Production Setup ===
Creating .env from template...
Generating security keys...
Securing .env file...
=== Setup Complete! ===
```

---

## 🚀 Bước 4: Khởi Động ePACK

### 🍎 macOS/Linux:
```bash
./scripts/start.sh
```

### 🪟 Windows:
Double-click vào `start.bat`

**Đợi khoảng 2-3 phút** (lần đầu load images)

**Kết quả mong đợi:**
```
🚀 ePACK Docker - Starting Application Stack

📦 Loading backend image from tar...
✅ Backend image loaded
📦 Loading frontend image from tar...
✅ Frontend image loaded

🚀 Starting ePACK Application...
✅ ePACK stack started successfully

🌐 Access URLs:
   Frontend:  http://localhost:3000
   Backend:   http://localhost:8080

🎉 ePACK is ready!
```

---

## 🌐 Bước 5: Truy Cập Ứng Dụng

Mở trình duyệt và truy cập: **http://localhost:3000**

Bạn sẽ thấy trang đăng nhập/đăng ký của ePACK.

---

## 🛑 Dừng và Khởi Động Lại

### Dừng ePACK:
- **macOS/Linux:** `./scripts/stop.sh`
- **Windows:** Double-click `stop.bat`

### Khởi động lại:
- **macOS/Linux:** `./scripts/start.sh`
- **Windows:** Double-click `start.bat`

> [!NOTE]
> **KHÔNG CẦN** chạy lại `setup_prod.sh/bat` khi khởi động lại. Setup chỉ chạy 1 lần duy nhất.

---

## ❓ FAQ - Câu Hỏi Thường Gặp

**Q: Có cần cài Python hay Node.js không?**
A: Không. Tất cả đã có trong Docker images.

**Q: Có cần internet để chạy không?**
A: Không cần (chỉ cần internet khi đăng nhập Google OAuth).

**Q: Data có mất khi tắt containers không?**
A: Không. Data được lưu an toàn tại `~/docker/volumes/epack/`

**Q: Gặp lỗi "Docker is not running"?**
A: Mở Docker Desktop và đợi nó khởi động hoàn toàn.

**Q: Gặp lỗi "Port 3000 already in use"?**
A: Đóng ứng dụng khác đang dùng port 3000, hoặc hỏi ChatGPT Atlas cách xử lý.

---

## 🆘 Cần Hỗ Trợ?

1. **Dùng ChatGPT Atlas** - Insert file này và yêu cầu hỗ trợ
2. **Xem User Guide** - `/docs/user-friendly/`
3. **Health Check** - http://localhost:8080/health
