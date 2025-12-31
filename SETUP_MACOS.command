#!/bin/bash

# Tự động di chuyển vào thư mục chứa file script này
cd "$(dirname "$0")"

# Cấp quyền thực thi cho các file sh nếu chưa có
chmod +x *.sh

# Chạy script cài đặt chính
./setup_prod.sh

# Giữ terminal mở để user xem kết quả
echo ""
echo "-------------------------------------------"
echo "Quá trình chạy hoàn tất. Bạn có thể đóng cửa sổ này."
read -p "Bấm phím bất kỳ để thoát..." -n1 -s
