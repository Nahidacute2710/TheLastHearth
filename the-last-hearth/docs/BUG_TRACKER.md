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
| BUG-001 | Chơi mới sau khi về menu chính: HUD vẫn hiện vàng và ngày của ván cũ | High | Fixed | 2026-11-28 | Tái hiện: chơi tới vàng > 0, ngày > 1 → Esc → Về menu chính → Chơi mới → xác nhận. **Nguyên nhân:** file save và `GameState` trong bộ nhớ đều đúng (ngày 1, 0 vàng); `reset_session()` gán lại biến nhưng không phát `day_changed`/`gold_changed`/`weapon_equipped`, nên `DayGoldDisplay` (sống suốt game trong `Main`) giữ số cũ. **Sửa:** một hàm duy nhất `GameState.start_new_game()` xóa toàn bộ phiên và phát lại mọi signal; `from_dict()` dùng chung phần xóa + phát. Kèm sửa: về menu từ quán khi đang nấu thì lưu sau khi bếp nấu xong (trước đây save thiếu món, mất nguyên liệu). Test `test_new_game_reset.gd`. |
| TECH-001 | `export_presets.cfg` bị liệt kê trong `.gitignore` ở gốc repo | Low | Fixed | 2026-11-27 | Đã bỏ ignore (mốc 1.1, chưa commit). File chưa tồn tại nên chưa có gì để kiểm tra; khi tạo preset đầu tiên phải mở file kiểm tra trước khi commit. |
| TECH-002 | Có hai file `.gitignore` (gốc repo và `the-last-hearth/`) với nội dung chồng lấn | Low | Fixed | 2026-11-27 | Đã gộp về `.gitignore` gốc và xóa file con (mốc 1.1, chưa commit). Đã chạy `git check-ignore`: `.godot/` và `android/` vẫn bị ignore. |
| TECH-003 | Chưa đặt `stretch/scale_mode = integer` | Low | Verified | 2026-11-27 | Đã đặt `window/stretch/scale_mode="integer"` (mốc 1.1). Chủ dự án đã kiểm tra trong editor 2026-11-27. |
| TECH-006 | Phím Tab của `inventory` trùng `ui_focus_next` | Low | Fixed | 2026-11-27 | Khi một `Control` có focus, Tab chuyển focus thay vì mở inventory. **Đã sửa ở C3:** `InventoryPanel` đọc action `inventory` trong `_input` và gọi `set_input_as_handled()`, các ô không nhận focus. Có test `test_tab_and_i_keys_toggle_and_tab_does_not_move_focus`. |
| TECH-008 | Chưa bật physics interpolation; chuyển động có thể kém mượt trên màn hình 120/144 Hz | Low | Open | 2026-11-27 | Physics chạy 60 tick/giây, màn hình tần số cao vẽ nhiều frame hơn nên vị trí có thể bị giật. Cách xử lý dự kiến: bật `physics/common/physics_interpolation` (sửa `project.godot`, cần duyệt). Chưa xử lý. |
| TECH-007 | Quy tắc đuôi dòng chưa thống nhất (CRLF/LF lẫn lộn) | Low | Fixed | 2026-11-27 | Đã thêm `.gitattributes` ở gốc repo (`* text=auto eol=lf`) và chạy `git add --renormalize .`: không file nào trong index phải đổi (index vốn đã là LF). Commit `chore: normalize line endings`. |
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

**Đã thực hiện ở mốc 1.1** (chủ dự án duyệt 2026-11-27). Bản gộp thực tế giữ `.import/` và `export.cfg` (vô hại), bỏ `export_presets.cfg` (TECH-001). Đề xuất ban đầu:

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

`the-last-hearth/.gitignore` đã được xóa sau khi xác nhận mọi quy tắc của nó đã có ở file gốc.

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
| 2026-11-27 | Thêm TECH-008 (physics interpolation) |
| 2026-11-27 | Sửa TECH-007 (`.gitattributes` gốc) |
| 2026-11-27 | Thêm TECH-007 (đuôi dòng CRLF/LF) |
| 2026-11-27 | Mốc 1.1: sửa TECH-001, TECH-002, TECH-003; thêm TECH-006 (Tab) |
| 2026-11-27 | Chốt quyết định TECH-001; phân tích và đề xuất TECH-002, TECH-003; đóng TECH-004; thêm TECH-005 (Git LFS) |
