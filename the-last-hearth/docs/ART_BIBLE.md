# THE LAST HEARTH — Art Bible

> Phiên bản: 0.2 · Cập nhật: 2026-11-27
> Trạng thái: **ĐỀ XUẤT · 🧪 CẦN THỬ NGHIỆM**. Palette, tile 16×16 px và kích thước sprite cần được kiểm chứng bằng mockup trước khi khóa. Chủ dự án đã xác nhận (2026-11-27): đây **chưa** phải quyết định cuối cùng.

---

## 1. Tầm nhìn thị giác

**"Ấm bên trong, lạnh bên ngoài."**

Toàn bộ ngôn ngữ thị giác xoay quanh sự tương phản giữa **ánh lửa** (cam, hổ phách, vàng, đỏ gạch) và **Tro Lặng** (xám tro, xanh lạnh, tím nhạt, gần như mất màu). Người chơi phải *cảm thấy* được an toàn khi bước vào quán, và *cảm thấy* được sự ngột ngạt khi xuống mỏ.

Từ khóa: tro bụi · ánh nến · gỗ cũ · đá ẩm · im lặng · hơi ấm.

Tránh: màu neon bão hòa, gore quá mức, phong cách chibi dễ thương, gradient mượt kiểu vector.

## 2. Thông số kỹ thuật

| Thông số | Giá trị | Ghi chú |
|---|---|---|
| Độ phân giải nội bộ | 640 × 360 | Đã thiết lập trong `project.godot` |
| Kích thước tile | **16 × 16 px** | Hiển thị 40 × 22,5 tile trên màn hình |
| Nhân vật người | khung **16 × 24 px** (vẽ trong canvas 32 × 32) | Canvas rộng hơn để chứa vũ khí và hiệu ứng |
| Quái thường | 16 × 16 đến 32 × 32 px | |
| Boss | 48 × 48 đến 96 × 96 px | |
| Icon vật phẩm | 16 × 16 px | Có viền tối 1 px để đọc được trên mọi nền |
| Pixel density | **1 pixel nghệ thuật = 1 pixel game.** Không phóng to sprite trong scene | Mọi asset phải vẽ đúng kích thước |
| Texture filter | Nearest | Đã đặt mặc định |
| Góc nhìn | Top-down 3/4 | Thấy mặt trước và đỉnh đầu nhân vật; tường thấy mặt trước |

**Quy tắc vàng:** Không bao giờ scale sprite bằng số lẻ (1.5×, 0.8×). Nếu cần to hơn thì vẽ lại.

## 3. Palette (ĐỀ XUẤT ❓)

Palette giới hạn **32 màu**, chia thành 4 nhóm. File palette chính thức sẽ lưu ở `assets/palette/the_last_hearth.gpl` khi được duyệt.

### 3.1 Hearth — ánh lửa (dùng trong quán, lửa, vật phẩm quý)

| Vai trò | Hex |
|---|---|
| Lửa sáng nhất | `#FFE9A8` |
| Vàng lửa | `#F7B54A` |
| Cam ấm | `#E07B2E` |
| Đỏ than | `#A9432A` |
| Nâu gỗ sáng | `#8A5A3B` |
| Nâu gỗ tối | `#5A3626` |
| Bóng ấm | `#33201A` |

### 3.2 Hush — tro lạnh (dùng trong dungeon, vùng bị nguyền)

| Vai trò | Hex |
|---|---|
| Tro sáng | `#C9C6C0` |
| Tro | `#8E8C8A` |
| Xám xanh | `#5F6670` |
| Đá lạnh | `#3E4452` |
| Tím bóng | `#2E2838` |
| Đen tro | `#16141C` |

### 3.3 Accent — điểm nhấn gameplay

| Vai trò | Hex |
|---|---|
| Máu / nguy hiểm | `#C23B3B` |
| Hồi máu / sự sống | `#6FA35A` |
| Ma thuật Tro Lặng | `#8FB8D9` |
| Tương tác được (viền highlight) | `#FFF4D6` |

### 3.4 Quy tắc dùng màu

- Màu đen tuyệt đối `#000000` **không dùng** cho bóng. Bóng dùng `#16141C` hoặc `#33201A`.
- Mỗi sprite dùng tối đa khoảng 8 đến 12 màu.
- Thứ quan trọng với gameplay (kẻ địch, vật phẩm, đòn đánh) phải có độ tương phản sáng/tối rõ rệt so với nền. Kiểm tra bằng cách chuyển ảnh sang grayscale.

## 4. Ánh sáng

- **Quán:** `CanvasModulate` hơi ấm và tối nhẹ; mỗi nguồn lửa (lò sưởi, nến, đèn) có `PointLight2D` màu cam với texture gradient tròn mềm. Ngọn Lửa Gốc là nguồn sáng lớn nhất, có nhấp nháy nhẹ.
- **Dungeon:** `CanvasModulate` tối và lạnh (xám xanh). Player mang nguồn sáng nhỏ bán kính hạn chế. Tầm nhìn là một phần của độ khó.
- Renderer GL Compatibility hỗ trợ đầy đủ ánh sáng 2D cơ bản. Shadow 2D (`LightOccluder2D`) dùng có chọn lọc vì tốn hiệu năng.
- Không vẽ bóng đổ động cứng vào sprite. Chỉ vẽ ambient occlusion nhẹ ở chân nhân vật.

## 5. Animation

| Hành động | Số frame đề xuất | FPS |
|---|---|---|
| Idle | 4 | 6 |
| Đi bộ | 6 | 10 |
| Tấn công | 4 đến 6 | 12 đến 15 |
| Bị đánh | 2 | 12 |
| Chết | 6 đến 8 | 10 |

- 4 hướng (lên, xuống, trái, phải). Trái là phải lật ngang, trừ khi thiết kế bất đối xứng.
- Tấn công cần frame "anticipation" (lấy đà) rõ ràng để người chơi đọc được đòn của quái.
- Hit feedback: nháy trắng 1 đến 2 frame bằng shader, rung camera nhẹ, hitstop ngắn (0,05 đến 0,08 giây).

## 6. UI

- Font pixel bitmap, hỗ trợ đầy đủ **tiếng Việt có dấu** (bắt buộc kiểm tra trước khi chọn font).
- Khung UI phong cách gỗ và sắt rèn, tông Hearth.
- Kích thước chữ tối thiểu 8 px cao ở độ phân giải nội bộ.
- Không đặt chữ lên nền có độ tương phản thấp.

## 7. Môi trường

- **Quán trọ:** gỗ, đá ấm, vải, đồ gốm. Nhiều chi tiết nhỏ (cốc, bánh mì, rèm) tạo cảm giác có người sống.
- **Dungeon (mỏ bị nguyền):** đá ẩm, giàn gỗ mục, đường ray gỉ, tro phủ trên mặt đất, tinh thể Tro Lặng phát sáng xanh nhạt.
- Tileset theo chuẩn autotile/terrain của Godot 4 (`TileSet` terrain sets) để vẽ map nhanh.

## 8. Quy trình duyệt asset

1. Phác thảo (sketch) → gửi duyệt hình khối và độ đọc.
2. Bản màu theo palette → kiểm tra grayscale và kiểm tra trong game ở kích thước 1×.
3. Animation → kiểm tra trong game với tốc độ thật.
4. Đạt mới được đổi trạng thái thành *final* (xem ASSET_GUIDELINES.md).

**Asset tạm (placeholder)** phải đặt tên có hậu tố `_placeholder` và không bao giờ được xem là hoàn thiện.

## 9. Tài liệu tham khảo cảm hứng

Chỉ tham khảo không khí và kỹ thuật, không sao chép thiết kế:
- Không khí ánh lửa trong bóng tối của các tranh sơn dầu tenebrism.
- Pixel art top-down chi tiết cao của dòng game indie hiện đại.

(Bảng moodboard cụ thể sẽ được bổ sung khi có art director.)

## 10. Lịch sử thay đổi

| Ngày | Phiên bản | Nội dung |
|---|---|---|
| 2026-11-27 | 0.1 | Bản khởi tạo |
| 2026-11-27 | 0.2 | Ghi rõ palette và tile 16×16 là 🧪 cần thử nghiệm |
