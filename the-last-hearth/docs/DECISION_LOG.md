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
| 2026-11-27 | Test | Bộ test tự viết trong `tests/`, mỗi test khởi động `Main` mới; `SceneRouter.start()` reset trạng thái để chạy lại được | Không dùng addon theo yêu cầu | Claude |
| 2026-11-27 | B1 | i-frames thực hiện bằng cách tắt `monitorable` của hurtbox trong thời gian bất tử; gọi lại thì lấy thời lượng dài hơn | Một cơ chế chung cho bị đánh và né như yêu cầu | Claude |
| 2026-11-27 | B1 | Hướng knockback = từ thân người đánh tới hurtbox | Đơn giản, đọc được | Claude |
| 2026-11-27 | B2 | Chủ dự án chốt cảm giác combat: quái không gây sát thương khi chạm thân; chỉ đòn có lấy đà gây sát thương, lấy đà phải nhìn thấy rõ; hit-stop ~50 ms; không rung màn hình; vệt vung theo hướng chuột; hitbox chỉ bật vài frame, mỗi cú trúng một quái tối đa 1 lần | Quyết định của chủ dự án | Chủ dự án |
| 2026-11-27 | B2 | Cuốc Chim: sát thương 1, cooldown 0,35 s, knockback 160 px/s, hitbox bật 0,1 s, vệt vung 0,15 s, tốc độ đi khi đang vung ×0,4, hit-stop 0,05 s 🧪 | Giá trị khởi đầu, nằm trong `data/items/rusty_pickaxe.tres` | Claude |
| 2026-11-27 | B2 | Hitbox của cuốc: hình tròn bán kính 11 px, cách tâm thân 14 px theo hướng chuột 🧪 | Tầm với ngắn, hợp vũ khí cận chiến | Claude |
| 2026-11-27 | B2 | Hit-stop làm bằng cách tắt `process_mode` của `%Entities` trong level, timer bỏ qua time scale | Không dùng `Engine.time_scale`, nên fade và UI không bị ảnh hưởng | Claude |
| 2026-11-27 | B2 | Giá treo vũ khí đặt cạnh nắp hầm; lấy được đúng 1 lần (trang bị nằm ở `GameState`); xuống mỏ không cần có cuốc | Theo kịch bản MVP; không chặn người chơi | Claude |
| 2026-11-27 | B3 | Thợ Mỏ Rỗng: 3 máu, tốc độ 38 px/s, phát hiện 120 px, bỏ đuổi khi xa hơn 200 px, tầm đánh 22 px, lấy đà 0,6 s, hitbox 0,12 s, nghỉ sau đòn 0,6 s, sát thương 1, knockback 140 px/s, choáng khi bị đánh 0,25 s 🧪 | Giá trị khởi đầu trong `data/enemies/hollow_miner.tres` | Claude |
| 2026-11-27 | B3 | Hướng đòn của quái khóa lúc bắt đầu lấy đà 🧪 | Người chơi đọc được hướng và có thể né sang bên | Claude |
| 2026-11-27 | B3 | Đánh trúng quái đang lấy đà thì ngắt đòn của nó 🧪 | Thưởng cho người chơi đánh trước; đổi được nếu thấy quá dễ | Claude |
| 2026-11-27 | B3 | Lấy đà: quái nháy đỏ cam mỗi 0,1 s; trúng đòn: nháy trắng 0,08 s; chết: mờ trong 0,3 s 🧪 | Báo hiệu rõ, chỉ dùng `modulate`, chưa cần shader | Claude |
| 2026-11-27 | B3 | Quái phát hiện player theo khoảng cách, chưa xét tầm nhìn xuyên tường | Đủ cho MVP; tránh pathfinding phức tạp | Claude |
| 2026-11-27 | B4 | Chỉ số player chuyển từ `@export` trong `player.gd` sang Resource `PlayerData` (`data/characters/innkeeper.tres`) | Theo yêu cầu đặt thông số trong Resource; một chỗ để chỉnh | Claude |
| 2026-11-27 | B4 | Player: 5 máu, bất tử sau khi bị đánh 0,8 s (nhấp nháy), mất điều khiển khi bị đẩy lùi 0,15 s, chết → chờ 0,6 s rồi fade về quán 🧪 | Giá trị khởi đầu | Claude |
| 2026-11-27 | B4 | Né: tốc độ 220 px/s trong 0,18 s (khoảng 40 px), bất tử 0,22 s, cooldown 0,6 s; đang né thì mờ 50% 🧪 | Giá trị khởi đầu; i-frames dài hơn cú lướt một chút cho dễ né đúng lúc | Claude |
| 2026-11-27 | B4 | Đang né, đang bị đẩy lùi hoặc đã chết thì không vung cuốc được; đang vung vẫn né được | Né là lối thoát an toàn; không ngắt được thì cảm giác bị kẹt | Claude |
| 2026-11-27 | B4 | Hồi sinh = level quán mới có Player mới, nên máu đầy mỗi lần vào level; vũ khí đã trang bị giữ nguyên (nằm ở `GameState`) | Đúng luật chết đã chốt; luật mất đồ áp dụng ở CP-C | Claude |
| 2026-11-27 | B4 | HUD máu: các ô vuông đỏ góc trên trái, không có chữ (không cần khóa dịch), nghe `EventBus.player_health_changed` | UI tạm | Claude |
| 2026-11-27 | B4 | Phím debug thêm (chỉ bản debug): F4 hồi đầy máu, F9 tự sát, F10 sinh 1 Thợ Mỏ Rỗng cạnh player, F11 bật/tắt bất tử. Không dùng F5–F8 vì trùng phím editor | Theo yêu cầu chủ dự án | Claude |
| 2026-11-27 | CP-C | Chủ dự án chốt: túi chỉ chứa đồ trong chuyến; về quán an toàn thì tài nguyên trong túi tự vào kho quán (`GameState.stash`) kèm thông báo; chết mất cả túi trừ vật phẩm quest, giữ trang bị đang mặc; nấu lấy nguyên liệu từ kho, món đã nấu nằm trong kho đến khi giao; panel Tab/I hiện túi và kho; Súp Nấm = 2 Nấm Hang, nấu 1–2 s; Lữ Khách mỗi ngày 1 lần, đứng chờ nếu chưa có món; HUD hiện ngày và vàng; giá treo cuốc đọc trạng thái từ `GameState` | Quyết định của chủ dự án | Chủ dự án |
| 2026-11-27 | C1 | Túi 12 ô, kho 30 ô 🧪; mỗi ô một chồng tối đa `ItemData.max_stack`; túi đầy thì phần dư trả lại (nhặt không được) | Giá trị khởi đầu | Claude |
| 2026-11-27 | C1 | `GameState` nghe `EventBus.level_changed`: đi từ mỏ vào quán thì cất túi vào kho rồi tăng ngày; nghe `EventBus.player_died` để xóa túi ngay lúc chết, nên khi về quán sau khi chết không còn gì để cất | Một chỗ duy nhất áp dụng luật; không phụ thuộc cửa nào được dùng | Claude |
| 2026-11-27 | C1 | Kho đầy thì đồ không vừa ở lại trong túi (không mất) | Tránh mất đồ âm thầm | Claude |
| 2026-11-27 | C1 | Giá treo vũ khí trống khi `GameState.owns_item_id(id)` đúng (đang trang bị, trong túi hoặc trong kho) | Sửa theo yêu cầu: không hiện lại cuốc sau khi chết hay đi lại | Claude |
| 2026-11-27 | C1 | Thông báo: dòng chữ cỡ 8 ở giữa phía dưới màn hình, mỗi loại đồ một dòng, hiện 2 s rồi mờ 0,4 s, tối đa 4 dòng 🧪 | UI tạm | Claude |
| 2026-11-27 | C1 | Vàng chưa nhặt được trong mỏ nên luật "mất vàng nhặt trong chuyến" chưa có gì để áp dụng; `gold` của quán không bao giờ mất khi chết | Đúng bảng mất/giữ | Claude |
| 2026-11-27 | Kế hoạch | Kiểm tra headless bằng bản Godot 4.7.2 Linux chính thức trên bản sao project ở cloud | Không động vào máy chủ dự án | Chủ dự án |
