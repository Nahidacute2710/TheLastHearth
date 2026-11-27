# THE LAST HEARTH — Nhật ký quyết định

> Ghi các quyết định nhỏ được tự chốt trong lúc làm checkpoint (trong phạm vi tài liệu đã duyệt), và các quyết định chủ dự án đưa ra kèm theo.
> Quyết định lớn (kiến trúc, thiết kế) vẫn ghi ở tài liệu gốc; file này chỉ dẫn chiếu.
> 🧪 = thông số khởi đầu, cần cảm nhận khi chơi thử.

| Ngày | Mốc | Quyết định | Lý do | Người chốt |
|---|---|---|---|---|
| 2026-11-27 | Kế hoạch | Chia Giai đoạn 1 còn lại thành CP-A → CP-D (xem DEVELOPMENT_ROADMAP.md) | Mỗi checkpoint chơi thử được | Chủ dự án |
| 2026-11-27 | Kế hoạch | Vung vũ khí theo hướng chuột | Điều khiển chính xác bằng chuột | Chủ dự án |
| 2026-11-27 | Kế hoạch | Chết: fade, tỉnh dậy ở quán với máu đầy | Vòng chơi liền mạch | Chủ dự án |
| 2026-11-27 | Kế hoạch | Mỗi lần từ dungeon về quán (an toàn hay chết) là sang ngày mới | Nhịp một chuyến một ngày | Chủ dự án |
| 2026-11-27 | Kế hoạch | Buff +2 máu Súp Nấm làm ở D3 nếu kịp, không thì Vertical Slice | Ưu tiên vòng chơi trọn vẹn | Chủ dự án |
| 2026-11-27 | Kế hoạch | `Main` tồn tại suốt game; `SceneRouter` chỉ thay level trong `LevelRoot` | UI và fade không bị hủy khi chuyển cảnh | Chủ dự án |
| 2026-11-27 | Kế hoạch | Thêm né (B4) và menu tạm dừng tối thiểu (D2) vào MVP | Bổ sung của chủ dự án | Chủ dự án |
| 2026-11-27 | A1 | Commit cả `translations.*.translation` do Godot sinh | Đường dẫn trong `project.godot` trỏ tới chúng; tránh lỗi thiếu file trước lần import đầu | Claude |
| 2026-11-27 | A1 | Ngôn ngữ theo hệ điều hành, dự phòng `en` | Mặc định của Godot, không cần setting thêm | Claude |
| 2026-11-27 | A1 | Prompt dùng khóa định dạng `UI_PROMPT_FORMAT` = `[%s] %s` | Thứ tự phím/hành động có thể đổi theo ngôn ngữ | Claude |
| 2026-11-27 | A2 | Interactable báo player qua EventBus; component `Interactor` (con của Player) chọn đối tượng gần nhất | Interactable dò thân player (mask 2) theo bảng layer đã chốt, nên player không có Area2D riêng để dò | Claude |
| 2026-11-27 | A2 | Một scene `level_door.tscn` dùng chung cho cửa hầm và lối ra mỏ (export `target_level`, `target_spawn`, `prompt_key`, `texture`) | Tránh lặp scene | Claude |
| 2026-11-27 | A2 | Cửa hầm là nắp sàn 32×16 đặt trong `FloorProps` (vẽ dưới `Entities`), vùng tương tác tròn bán kính 16 px 🧪 | Nắp sàn không được che player | Claude |
| 2026-11-27 | A2 | Prompt: Label cỡ chữ 8, viền tối, đặt cách đối tượng 28 px phía trên, font mặc định của Godot 🧪 | UI tạm; pixel font chọn sau | Claude |
| 2026-11-27 | A3 | Script `Level` dùng chung cho các phòng (1 tầng kế thừa) | Gom phần lặp (camera, điểm xuất hiện); vẫn theo composition cho hành vi | Claude |
| 2026-11-27 | A3 | Mỗi level tự chứa Player; SceneRouter chỉ đặt vị trí theo `Marker2D` trong `%Spawns` | Đơn giản cho MVP; trạng thái player sau này nằm ở `GameState` | Claude |
| 2026-11-27 | A3 | Fade 0,25 giây mỗi chiều, màu `#16141C`; `LevelRoot` bị tắt xử lý trong lúc fade 🧪 | Player không đi được khi màn hình đang tối | Claude |
| 2026-11-27 | A3 | Phím debug (chỉ bản debug): F1 đổi EN/VI, F2 xuống mỏ, F3 về quán | Chơi thử nhanh | Claude |
| 2026-11-27 | A4 | Mỏ: 4 phòng 24×21 tile xếp 2×2 (51×45 tile), lối đi 3 tile, đi theo vòng R1 → R2 → R4 → R3 (R3 không nối thẳng R1) 🧪 | Đủ chỗ đặt 2–3 quái/phòng ở CP-B; buộc đi một vòng | Claude |
| 2026-11-27 | A4 | Lối ra về quán là chính cái thang ở lối vào (phòng 1) 🧪 | Đi xa thì phải quay về, tạo rủi ro trên đường về; đổi được nếu chơi thấy dài | Claude |
| 2026-11-27 | A4 | Cột đá trong mỏ vẽ bằng tile tường (khác quán: chướng ngại quán là scene riêng) | Đá là địa hình, không cần y-sort với player | Claude |
| 2026-11-27 | Kế hoạch | Kiểm tra headless bằng bản Godot 4.7.2 Linux chính thức trên bản sao project ở cloud | Không động vào máy chủ dự án | Chủ dự án |
