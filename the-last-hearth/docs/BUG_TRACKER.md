# THE LAST HEARTH — Bug Tracker

> Theo dõi lỗi và vấn đề kỹ thuật. Khi dự án lớn hơn, nên chuyển sang GitHub Issues và giữ file này làm bản tóm tắt.

---

## Quy ước

**ID:** `BUG-<số 3 chữ số>` cho lỗi, `TECH-<số>` cho nợ kỹ thuật/vấn đề cấu hình.

**Mức độ (Severity):**

| Mức | Định nghĩa |
|---|---|
| Critical | Crash, mất save, không thể tiếp tục chơi |
| High | Tính năng chính hỏng, có cách tránh nhưng khó |
| Medium | Lỗi rõ ràng nhưng không cản trở tiến trình |
| Low | Lỗi hiển thị, chính tả, chi tiết nhỏ |

**Trạng thái:** `Open` → `In Progress` → `Fixed` (chờ kiểm tra) → `Verified` (đã kiểm tra lại) · hoặc `Won't Fix` / `Duplicate`.

**Quy tắc:**
- Mỗi lỗi phải có bước tái hiện. Không tái hiện được thì ghi rõ "không tái hiện được" và tần suất xảy ra.
- Chỉ chuyển sang `Verified` sau khi đã thực sự chạy lại và xác nhận.
- Ghi commit hash đã sửa lỗi.

---

## Đang mở

| ID | Tiêu đề | Mức | Trạng thái | Phát hiện | Ghi chú |
|---|---|---|---|---|---|
| TECH-001 | `export_presets.cfg` bị liệt kê trong `.gitignore` ở gốc repo | Low | Open (đã có quyết định) | 2026-11-27 | **Quyết định 2026-11-27:** cho phép commit nếu file không chứa thông tin nhạy cảm hay dữ liệu cá nhân. **Kiểm tra 2026-11-27:** file chưa tồn tại (chưa có preset). Chưa sửa `.gitignore`. Xem chi tiết bên dưới. |
| TECH-002 | Có hai file `.gitignore` (gốc repo và `the-last-hearth/`) với nội dung chồng lấn | Low | Open (đã có đề xuất) | 2026-11-27 | Không gây lỗi. Đã kiểm tra nội dung, đề xuất hợp nhất bên dưới. Chờ duyệt. |
| TECH-003 | Chưa đặt `stretch/scale_mode = integer` | Low | Open (đã có cấu hình đề xuất) | 2026-11-27 | Cấu hình dự kiến ở TECHNICAL_ARCHITECTURE.md mục 9. Triển khai ở mốc 1.1 nếu được duyệt. |
| TECH-005 | Git LFS chưa được thiết lập | Low | Open (hoãn có chủ đích) | 2026-11-27 | **Quyết định 2026-11-27:** chưa thiết lập. Điều kiện xem xét lại ở ASSET_GUIDELINES.md mục 7 (file > 50 MB, tổng nhị phân > ~500 MB, hoặc bắt đầu commit file nguồn lớn). |

## Đã đóng

| ID | Tiêu đề | Mức | Trạng thái | Sửa ở commit | Ghi chú |
|---|---|---|---|---|---|
| TECH-004 | Chưa có Main Scene | Low | Won't Fix (không phải lỗi) | — | Trạng thái bình thường ở Phase 0. Đã chuyển thành công việc của mốc MVP 1.1 (DEVELOPMENT_ROADMAP.md). |

### Chi tiết TECH-001: `export_presets.cfg`

- Từ Godot 4, mật khẩu keystore và khóa mã hóa export nằm ở `.godot/export_credentials.cfg` (đã bị ignore cùng `.godot/`). `export_presets.cfg` chỉ còn cấu hình build, nên thường **nên** commit để mọi máy build giống nhau.
- File có thể chứa đường dẫn tuyệt đối (ví dụ `export_path` có tên người dùng Windows) hoặc thông tin publisher. Phải đọc nội dung trước khi commit.
- **Việc cần làm khi tạo preset export đầu tiên:** đọc file → nếu sạch, bỏ dòng `export_presets.cfg` khỏi `.gitignore` gốc (thay đổi `.gitignore` cần được duyệt) → commit.

### Chi tiết TECH-002: hai file `.gitignore`

| File | Nội dung hiện tại | Đang được Git theo dõi |
|---|---|---|
| `.gitignore` (gốc repo) | `.godot/` · `.import/` · `export.cfg` · `export_presets.cfg` · `*.tmp` · `.DS_Store` | Có |
| `the-last-hearth/.gitignore` (Godot tự tạo) | `.godot/` · `/android/` | Có |

Phân tích:
- `.godot/` trong file gốc không có `/` ở đầu nên đã khớp `the-last-hearth/.godot/`. Dòng `.godot/` ở file con là trùng lặp.
- `/android/` ở file con neo vào `the-last-hearth/android/` (thư mục build template Android). Khi gộp lên gốc phải viết `/the-last-hearth/android/`.
- `.import/` là thư mục cache của Godot 3, không dùng ở Godot 4. Vô hại, có thể bỏ.
- `export.cfg` không phải file chuẩn của Godot 4. Vô hại.

Đề xuất hợp nhất thành một `.gitignore` ở gốc repo (chờ duyệt):

```gitignore
# Godot 4
.godot/
/the-last-hearth/android/

# Export: export_presets.cfg sẽ được commit sau khi kiểm tra (TECH-001)
export_presets.cfg
export.cfg

# OS / tạm
*.tmp
.DS_Store
Thumbs.db
```

Sau đó xóa `the-last-hearth/.gitignore` (thao tác xóa file, cần được duyệt). Phương án thay thế không cần xóa: giữ nguyên cả hai file, vì hiện không gây lỗi.

---

## Mẫu báo lỗi chi tiết

Copy mẫu này khi lỗi cần mô tả dài:

```markdown
### BUG-XXX: <Tiêu đề ngắn>
- **Mức độ:** Critical / High / Medium / Low
- **Trạng thái:** Open
- **Phiên bản / commit:**
- **Phát hiện ngày:**
- **Bước tái hiện:**
  1.
  2.
- **Kết quả mong đợi:**
- **Kết quả thực tế:**
- **Log / ảnh chụp:**
- **Nguyên nhân (nếu đã xác định):**
- **Cách sửa:**
```

---

## Lịch sử thay đổi

| Ngày | Nội dung |
|---|---|
| 2026-11-27 | Bản khởi tạo: TECH-001 đến TECH-004 |
| 2026-11-27 | Chốt quyết định TECH-001; phân tích và đề xuất TECH-002, TECH-003; đóng TECH-004; thêm TECH-005 (Git LFS) |
