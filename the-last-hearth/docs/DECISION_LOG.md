# THE LAST HEARTH — Nhật ký quyết định

> Ghi các quyết định nhỏ được tự chốt trong lúc làm checkpoint (trong phạm vi tài liệu đã duyệt), và các quyết định chủ dự án đưa ra kèm theo.
> Quyết định lớn (kiến trúc, thiết kế) vẫn ghi ở tài liệu gốc; file này chỉ dẫn chiếu.
> 🧪 = thông số khởi đầu, cần cảm nhận khi chơi thử. Các thông số của CP-A, CP-B, CP-C đã được chủ dự án chơi thử đạt ngày 2026-11-28 và giữ nguyên giá trị.

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
| 2026-11-27 | A2 | Cửa hầm là nắp sàn 32×16 đặt trong `FloorProps` (vẽ dưới `Entities`), vùng tương tác tròn bán kính 16 px (đã chơi thử 2026-11-28) | Nắp sàn không được che player | Claude |
| 2026-11-27 | A2 | Prompt: Label cỡ chữ 8, viền tối, đặt cách đối tượng 28 px phía trên, font mặc định của Godot (đã chơi thử 2026-11-28) | UI tạm; pixel font chọn sau | Claude |
| 2026-11-27 | A3 | Script `Level` dùng chung cho các phòng (1 tầng kế thừa) | Gom phần lặp (camera, điểm xuất hiện); vẫn theo composition cho hành vi | Claude |
| 2026-11-27 | A3 | Mỗi level tự chứa Player; SceneRouter chỉ đặt vị trí theo `Marker2D` trong `%Spawns` | Đơn giản cho MVP; trạng thái player sau này nằm ở `GameState` | Claude |
| 2026-11-27 | A3 | Fade 0,25 giây mỗi chiều, màu `#16141C`; `LevelRoot` bị tắt xử lý trong lúc fade (đã chơi thử 2026-11-28) | Player không đi được khi màn hình đang tối | Claude |
| 2026-11-27 | A3 | Phím debug (chỉ bản debug): F1 đổi EN/VI, F2 xuống mỏ, F3 về quán | Chơi thử nhanh | Claude |
| 2026-11-27 | A4 | Mỏ: 4 phòng 24×21 tile xếp 2×2 (51×45 tile), lối đi 3 tile, đi theo vòng R1 → R2 → R4 → R3 (R3 không nối thẳng R1) (đã chơi thử 2026-11-28) | Đủ chỗ đặt 2–3 quái/phòng ở CP-B; buộc đi một vòng | Claude |
| 2026-11-27 | A4 | Lối ra về quán là chính cái thang ở lối vào (phòng 1) (đã chơi thử 2026-11-28) | Đi xa thì phải quay về, tạo rủi ro trên đường về; đổi được nếu chơi thấy dài | Claude |
| 2026-11-27 | A4 | Cột đá trong mỏ vẽ bằng tile tường (khác quán: chướng ngại quán là scene riêng) | Đá là địa hình, không cần y-sort với player | Claude |
| 2026-11-27 | Test | Bộ test tự viết trong `tests/`, mỗi test khởi động `Main` mới; `SceneRouter.start()` reset trạng thái để chạy lại được | Không dùng addon theo yêu cầu | Claude |
| 2026-11-27 | B1 | i-frames thực hiện bằng cách tắt `monitorable` của hurtbox trong thời gian bất tử; gọi lại thì lấy thời lượng dài hơn | Một cơ chế chung cho bị đánh và né như yêu cầu | Claude |
| 2026-11-27 | B1 | Hướng knockback = từ thân người đánh tới hurtbox | Đơn giản, đọc được | Claude |
| 2026-11-27 | B2 | Chủ dự án chốt cảm giác combat: quái không gây sát thương khi chạm thân; chỉ đòn có lấy đà gây sát thương, lấy đà phải nhìn thấy rõ; hit-stop ~50 ms; không rung màn hình; vệt vung theo hướng chuột; hitbox chỉ bật vài frame, mỗi cú trúng một quái tối đa 1 lần | Quyết định của chủ dự án | Chủ dự án |
| 2026-11-27 | B2 | Cuốc Chim: sát thương 1, cooldown 0,35 s, knockback 160 px/s, hitbox bật 0,1 s, vệt vung 0,15 s, tốc độ đi khi đang vung ×0,4, hit-stop 0,05 s (đã chơi thử 2026-11-28) | Giá trị khởi đầu, nằm trong `data/items/rusty_pickaxe.tres` | Claude |
| 2026-11-27 | B2 | Hitbox của cuốc: hình tròn bán kính 11 px, cách tâm thân 14 px theo hướng chuột (đã chơi thử 2026-11-28) | Tầm với ngắn, hợp vũ khí cận chiến | Claude |
| 2026-11-27 | B2 | Hit-stop làm bằng cách tắt `process_mode` của `%Entities` trong level, timer bỏ qua time scale | Không dùng `Engine.time_scale`, nên fade và UI không bị ảnh hưởng | Claude |
| 2026-11-27 | B2 | Giá treo vũ khí đặt cạnh nắp hầm; lấy được đúng 1 lần (trang bị nằm ở `GameState`); xuống mỏ không cần có cuốc | Theo kịch bản MVP; không chặn người chơi | Claude |
| 2026-11-27 | B3 | Thợ Mỏ Rỗng: 3 máu, tốc độ 38 px/s, phát hiện 120 px, bỏ đuổi khi xa hơn 200 px, tầm đánh 22 px, lấy đà 0,6 s, hitbox 0,12 s, nghỉ sau đòn 0,6 s, sát thương 1, knockback 140 px/s, choáng khi bị đánh 0,25 s (đã chơi thử 2026-11-28) | Giá trị khởi đầu trong `data/enemies/hollow_miner.tres` | Claude |
| 2026-11-27 | B3 | Hướng đòn của quái khóa lúc bắt đầu lấy đà (đã chơi thử 2026-11-28) | Người chơi đọc được hướng và có thể né sang bên | Claude |
| 2026-11-27 | B3 | Đánh trúng quái đang lấy đà thì ngắt đòn của nó (đã chơi thử 2026-11-28) | Thưởng cho người chơi đánh trước; đổi được nếu thấy quá dễ | Claude |
| 2026-11-27 | B3 | Lấy đà: quái nháy đỏ cam mỗi 0,1 s; trúng đòn: nháy trắng 0,08 s; chết: mờ trong 0,3 s (đã chơi thử 2026-11-28) | Báo hiệu rõ, chỉ dùng `modulate`, chưa cần shader | Claude |
| 2026-11-27 | B3 | Quái phát hiện player theo khoảng cách, chưa xét tầm nhìn xuyên tường | Đủ cho MVP; tránh pathfinding phức tạp | Claude |
| 2026-11-27 | B4 | Chỉ số player chuyển từ `@export` trong `player.gd` sang Resource `PlayerData` (`data/characters/innkeeper.tres`) | Theo yêu cầu đặt thông số trong Resource; một chỗ để chỉnh | Claude |
| 2026-11-27 | B4 | Player: 5 máu, bất tử sau khi bị đánh 0,8 s (nhấp nháy), mất điều khiển khi bị đẩy lùi 0,15 s, chết → chờ 0,6 s rồi fade về quán (đã chơi thử 2026-11-28) | Giá trị khởi đầu | Claude |
| 2026-11-27 | B4 | Né: tốc độ 220 px/s trong 0,18 s (khoảng 40 px), bất tử 0,22 s, cooldown 0,6 s; đang né thì mờ 50% (đã chơi thử 2026-11-28) | Giá trị khởi đầu; i-frames dài hơn cú lướt một chút cho dễ né đúng lúc | Claude |
| 2026-11-27 | B4 | Đang né, đang bị đẩy lùi hoặc đã chết thì không vung cuốc được; đang vung vẫn né được | Né là lối thoát an toàn; không ngắt được thì cảm giác bị kẹt | Claude |
| 2026-11-27 | B4 | Hồi sinh = level quán mới có Player mới, nên máu đầy mỗi lần vào level; vũ khí đã trang bị giữ nguyên (nằm ở `GameState`) | Đúng luật chết đã chốt; luật mất đồ áp dụng ở CP-C | Claude |
| 2026-11-27 | B4 | HUD máu: các ô vuông đỏ góc trên trái, không có chữ (không cần khóa dịch), nghe `EventBus.player_health_changed` | UI tạm | Claude |
| 2026-11-27 | B4 | Phím debug thêm (chỉ bản debug): F4 hồi đầy máu, F9 tự sát, F10 sinh 1 Thợ Mỏ Rỗng cạnh player, F11 bật/tắt bất tử. Không dùng F5–F8 vì trùng phím editor | Theo yêu cầu chủ dự án | Claude |
| 2026-11-27 | CP-C | Chủ dự án chốt: túi chỉ chứa đồ trong chuyến; về quán an toàn thì tài nguyên trong túi tự vào kho quán (`GameState.stash`) kèm thông báo; chết mất cả túi trừ vật phẩm quest, giữ trang bị đang mặc; nấu lấy nguyên liệu từ kho, món đã nấu nằm trong kho đến khi giao; panel Tab/I hiện túi và kho; Súp Nấm = 2 Nấm Hang, nấu 1–2 s; Lữ Khách mỗi ngày 1 lần, đứng chờ nếu chưa có món; HUD hiện ngày và vàng; giá treo cuốc đọc trạng thái từ `GameState` | Quyết định của chủ dự án | Chủ dự án |
| 2026-11-27 | C1 | Túi 12 ô, kho 30 ô (đã chơi thử 2026-11-28); mỗi ô một chồng tối đa `ItemData.max_stack`; túi đầy thì phần dư trả lại (nhặt không được) | Giá trị khởi đầu | Claude |
| 2026-11-27 | C1 | `GameState` nghe `EventBus.level_changed`: đi từ mỏ vào quán thì cất túi vào kho rồi tăng ngày; nghe `EventBus.player_died` để xóa túi ngay lúc chết, nên khi về quán sau khi chết không còn gì để cất | Một chỗ duy nhất áp dụng luật; không phụ thuộc cửa nào được dùng | Claude |
| 2026-11-27 | C1 | Kho đầy thì đồ không vừa ở lại trong túi (không mất) | Tránh mất đồ âm thầm | Claude |
| 2026-11-27 | C1 | Giá treo vũ khí trống khi `GameState.owns_item_id(id)` đúng (đang trang bị, trong túi hoặc trong kho) | Sửa theo yêu cầu: không hiện lại cuốc sau khi chết hay đi lại | Claude |
| 2026-11-27 | C1 | Thông báo: dòng chữ cỡ 8 ở giữa phía dưới màn hình, mỗi loại đồ một dòng, hiện 2 s rồi mờ 0,4 s, tối đa 4 dòng (đã chơi thử 2026-11-28) | UI tạm | Claude |
| 2026-11-27 | C1 | Vàng chưa nhặt được trong mỏ nên luật "mất vàng nhặt trong chuyến" chưa có gì để áp dụng; `gold` của quán không bao giờ mất khi chết | Đúng bảng mất/giữ | Claude |
| 2026-11-27 | C2 | Thợ Mỏ Rỗng rơi 1 Nấm Hang với tỉ lệ 50%; mỏ có 4 nấm mọc sẵn (1 mỗi phòng); chồng nấm tối đa 20; giá bán tham khảo 2 (đã chơi thử 2026-11-28) | Trung bình 1 chuyến có khoảng 9 nấm (5 từ quái + 4 mọc sẵn), đủ khoảng 4 bát; ít nhất 4 nấm (2 bát) dù không giết quái nào | Claude |
| 2026-11-27 | C2 | Bảng rơi đồ nằm trong `EnemyData.loot` (danh sách `LootEntry`); `Level` nghe `EventBus.enemy_died` và đặt `Pickup` vào `%Entities` | Data-driven; quái không cần biết gì về đồ rơi | Claude |
| 2026-11-27 | C2 | `Pickup` là Area2D layer 6 (Interactable), mask 2: chạm là nhặt, không cần bấm E; túi đầy thì phần dư nằm lại | Nhặt nhanh trong lúc đánh | Claude |
| 2026-11-27 | C2 | HUD: biểu tượng Nấm Hang và số nấm trong túi (`×3`) dưới thanh máu | UI tạm, không có chữ | Claude |
| 2026-11-27 | C2 | Phím debug thêm (chỉ bản debug): Shift+F1 +5 Nấm Hang vào túi, Shift+F2 +5 vào kho, Shift+F3 sang ngày mới, Shift+F4 +50 vàng | Theo yêu cầu; tránh F5–F8 | Claude |
| 2026-11-27 | C3 | Panel túi đồ: túi 6×2 ô, kho 10×3 ô, ô 20×20 px, giữa màn hình; chỉ xem, chưa kéo thả (đã chơi thử 2026-11-28) | UI tạm đúng phạm vi MVP | Claude |
| 2026-11-27 | C3 | Mở panel thì thế giới tạm dừng (`get_tree().paused`), panel chạy ở `PROCESS_MODE_ALWAYS`; Esc cũng đóng panel; không mở được khi đang chuyển cảnh (đã chơi thử 2026-11-28) | Mở túi giữa trận không bị đánh lén; đổi được nếu muốn xem túi trong lúc chạy | Claude |
| 2026-11-27 | C3 | TECH-006: panel đọc `inventory` trong `_input` (trước GUI) và đánh dấu đã xử lý, mọi ô đặt `FOCUS_NONE`; không sửa `ui_focus_next` trong `project.godot` | Tab không bao giờ tới phần chuyển focus; không đụng cấu hình | Claude |
| 2026-11-27 | C4 | Súp Nấm: 2 Nấm Hang → 1 Súp, nấu 1,5 s; chồng tối đa 10 (đã chơi thử 2026-11-28) | Theo khoảng 1–2 s đã chốt | Claude |
| 2026-11-27 | C4 | Bếp đặt cạnh lò sưởi (520, 100); bấm E nấu ngay công thức duy nhất, chưa có menu chọn món; thiếu nguyên liệu thì hiện thông báo "Cần 2 Nấm Hang trong kho" | MVP chỉ có 1 công thức | Claude |
| 2026-11-27 | C4 | Đang nấu thì bếp tắt tương tác; player đi lại tự do; rời quán giữa chừng thì món được nấu xong ngay (không mất nguyên liệu) | Tránh mất đồ vì chuyển cảnh | Claude |
| 2026-11-27 | C4 | Thanh tiến trình vẽ bằng `_draw` trên đầu bếp (24×3 px, màu cam) | Placeholder | Claude |
| 2026-11-27 | C4 | Thêm `EventBus.toast_requested(message)` cho thông báo chung; người gửi tự dịch bằng `tr()` | Một kênh thông báo cho mọi hệ thống | Claude |
| 2026-11-27 | C5 | Lữ Khách đứng cạnh bàn (430, 330), trả 15 vàng cho 1 Súp Nấm (đã chơi thử 2026-11-28); phục vụ xong thì biến mất đến ngày sau | Giá khởi đầu: 1 chuyến khoảng 4 bát nhưng khách chỉ mua 1 bát mỗi ngày | Claude |
| 2026-11-27 | C5 | Ngày phục vụ khách lưu ở `GameState.customer_served_day` (id → ngày), nên tải lại quán trong cùng ngày khách không quay lại | Dữ liệu sẽ được lưu ở CP-D | Claude |
| 2026-11-27 | C5 | HUD góc trên phải: "Ngày X" (trắng) và "X vàng" (vàng), khóa `HUD_DAY`, `HUD_GOLD`, cập nhật khi đổi ngôn ngữ | Theo yêu cầu | Claude |
| 2026-11-28 | CP-D | Chủ dự án chốt: lưu ngày, vàng, kho, vũ khí đang trang bị, ngôn ngữ; giá treo suy ra từ `GameState`; không lưu vị trí player; chỉ tự lưu ở quán (về từ mỏ, sau khi giao món); file hỏng, rỗng, thiếu trường hoặc `save_version` lạ thì không crash, báo một dòng trên menu, giữ file hỏng dưới tên `.bak`; menu chính Tiếp tục / Chơi mới / Thoát, Chơi mới đè save phải xác nhận; menu tạm dừng Esc; Esc khi túi đồ đang mở chỉ đóng túi; ô túi đồ hiện tên món khi rê chuột hoặc chọn; bếp kiểm tra kho còn chỗ trước khi nấu | Quyết định của chủ dự án | Chủ dự án |
| 2026-11-28 | D1 | Lưu thêm `customer_served_day` (khách nào đã được phục vụ ngày nào) | Không có thì tải lại cùng ngày Lữ Khách quay lại, mua thêm được vàng | Claude |
| 2026-11-28 | D1 | Túi không được lưu: chỉ lưu khi ở quán, lúc đó túi luôn trống | Đúng luật thoát giữa chuyến thì mất chuyến | Claude |
| 2026-11-28 | D1 | `ItemDB` (id → đường dẫn `.tres`) để đọc lại id trong file save; có test bắt buộc mọi file trong `data/items/` phải được đăng ký | Save chỉ chứa id, không chứa đường dẫn | Claude |
| 2026-11-28 | D1 | Kiểm tra toàn bộ file trước khi áp dụng: file sai thì không đổi gì trong `GameState`. Vũ khí có id lạ hoặc mục kho sai kiểu = file hỏng; mục kho có id lạ thì bỏ qua và ghi cảnh báo | Không bao giờ áp dụng nửa chừng | Claude |
| 2026-11-28 | D1 | Bếp: nếu kho không đủ chỗ cho món thì không nấu, hiện "Kho đã đầy". Nếu kho bị lấp đầy trong lúc đang nấu (chỉ xảy ra bằng phím debug), món vẫn được thêm vượt giới hạn ô để không bao giờ mất | Theo yêu cầu không mất món | Claude |
| 2026-11-28 | D1 | Test dùng thư mục `user://test_saves/`, không đụng tới save thật trong `user://saves/` | Chạy test trên máy chủ dự án không làm mất save | Claude |
| 2026-11-28 | D2 | Game mở vào menu chính (nền tối, không tải level phía sau). Chơi mới ghi save ngay (ngày 1), nên "Tiếp tục" xuất hiện từ lần mở sau | Nếu không, chọn Chơi mới rồi thoát sẽ vẫn còn save cũ | Claude |
| 2026-11-28 | D2 | Về menu chính từ quán thì lưu (giữ món vừa nấu sau lần tự lưu cuối); từ mỏ thì không lưu | Theo quyết định không lưu ở mỏ; ở quán thì không có lý do bỏ dữ liệu | Claude |
| 2026-11-28 | D2 | Menu tạm dừng đọc Esc trong `_unhandled_input`, túi đồ đọc trong `_input`, nên Esc đóng túi trước; túi không mở được khi đang tạm dừng hoặc đang ở menu | Đúng thứ tự đã chốt | Claude |
| 2026-11-28 | D2 | Tên món hiện ở một dòng dưới hai lưới khi rê chuột vào ô; bấm chuột trái chọn ô thì tên giữ lại khi rời chuột | Dễ thấy hơn tooltip mặc định | Claude |
| 2026-11-28 | D2 | Phím debug: Shift+F9 xóa file save | Theo yêu cầu; tránh F5–F8 | Claude |
| 2026-11-28 | D2 | Tên game giữ "The Last Hearth" ở cả hai ngôn ngữ (khóa `GAME_TITLE`) | Tên riêng; chủ dự án có thể đổi cột vi | Claude |
| 2026-11-28 | BUG-001 | `GameState.start_new_game()` là đường duy nhất để bắt đầu ván mới: xóa ngày, vàng, túi, kho, vũ khí, khách đã phục vụ, theo dõi level, rồi phát lại toàn bộ signal. Ngôn ngữ không bị reset. Chưa có buff nên chưa có gì để xóa; món đang nấu nằm trong level quán, được nấu xong khi quán bị gỡ, rồi bị xóa cùng kho | Theo yêu cầu sửa tận gốc | Chủ dự án |
| 2026-11-28 | BUG-001 | Về menu chính từ quán: gỡ level trước rồi mới lưu | Nồi đang nấu được nấu xong khi quán rời cây scene, nên món có trong save | Claude |
| 2026-11-28 | D3 | Chủ dự án chốt: Súp Nấm ăn ở quán cho +2 máu tối đa chuyến kế, HUD thêm 2 ô khác màu, mất khi về quán hoặc khi chết, mỗi chuyến ăn 1 lần, có lưu, Chơi mới reset; tắt bằng nút X thì lưu nếu ở quán; test trọn vòng; mọi test đổi trạng thái phải kiểm tra cả HUD/UI | Quyết định của chủ dự án | Chủ dự án |
| 2026-11-28 | D3 | Ăn qua panel túi đồ: chọn Súp trong ô kho → nút "Ăn (+2 máu tối đa chuyến tới)"; không ăn được thì nút mờ và ghi lý do (đã ăn / chỉ ăn ở quán). Không làm thêm đối tượng tương tác mới | Cách đơn giản nhất, dùng lại UI có sẵn | Claude |
| 2026-11-28 | D3 | Buff hiện ngay ở quán sau khi ăn (7 ô, 2 ô cuối màu vàng cam) và giữ suốt chuyến; xóa trong `GameState` khi về quán (cùng chỗ cất túi) hoặc khi chết | Người chơi thấy ngay mình đã ăn | Claude |
| 2026-11-28 | D3 | Ăn xong thì tự lưu (đang ở quán) | Đúng quy tắc chỉ lưu ở quán; tắt game ngay sau khi ăn không mất buff | Claude |
| 2026-11-28 | D3 | Trường `max_health_buff` trong save là tùy chọn (thiếu thì 0), nên không tăng `save_version` | Save cũ vẫn đọc được | Claude |
| 2026-11-28 | D3 | Nút X: `Main` tắt tự thoát (`set_auto_accept_quit(false)`), gỡ level (nồi đang nấu được tính) rồi lưu nếu ở quán, sau đó mới thoát. Ở mỏ và ở menu thì không ghi gì | Dùng chung hàm với "Về menu chính" | Claude |
| 2026-11-28 | D3 | Bộ chạy test đánh trượt mọi test có ERROR / SCRIPT ERROR (dùng `Logger` của Godot qua `OS.add_logger`) | Phát hiện khi viết test trọn vòng: SCRIPT ERROR dừng hàm test giữa chừng mà vẫn báo PASS | Claude |
| 2026-11-28 | VS | Giai đoạn 1 chính thức hoàn thành (chơi thử 6 bước D3 đạt); tag `v0.1-mvp` tại `3822f93` | Chơi thử đạt | Chủ dự án |
| 2026-11-28 | VS | Art: PixelLab qua MCP là nguồn chính, chỉnh tay theo ART_BIBLE; mockup 1 màn hình trước khi làm hàng loạt; ghi prompt/nguồn từng asset; API key chỉ ở biến môi trường, không commit; chưa dùng Retro Diffusion | Quyết định của chủ dự án | Chủ dự án |
| 2026-11-28 | VS | Âm thanh: SFX/nhạc từ thư viện CC0 hoặc có giấy phép thương mại rõ ràng, ghi giấy phép từng file | Quyết định của chủ dự án | Chủ dự án |
| 2026-11-28 | VS | Thứ tự: VS-A → VS-E1 (Ngọn Lửa Gốc v1 + nâng cấp) → VS-B (art) → VS-C → VS-D → VS-E2 (5–8 công thức, 3–4 loại khách) + VS-F | Chỗ tiêu vàng có sớm; art làm sau khi hệ thống ổn định | Chủ dự án |
| 2026-11-28 | VS | Dungeon: ghép ngẫu nhiên từ phòng mẫu thiết kế tay; phòng đầu và phòng boss cố định; có test mọi bố cục đi được | Quyết định của chủ dự án | Chủ dự án |
| 2026-11-28 | VS | Boss "Quản Đốc Rỗng" (Hollow Foreman): 2 pha, 3 đòn có báo trước (đập đất, lao tới, gọi Thợ Mỏ Rỗng); sang pha 2 khi dưới 50% máu | Quyết định của chủ dự án | Chủ dự án |
| 2026-11-28 | VS | Chỗ tiêu vàng: nâng cấp quán gộp vào Ngọn Lửa Gốc; vàng + tài nguyên để "nhóm lửa" lên cấp, mỗi cấp mở một thứ; danh sách 4–5 cấp đề xuất khi lập kế hoạch VS-E1 | Quyết định của chủ dự án | Chủ dự án |
| 2026-11-28 | VS | Nhịp ngày giữ như MVP (quán → mỏ → về là sang ngày mới); không giới hạn số ngày | Trả lời câu hỏi mở 2 và 3 của GDD | Chủ dự án |
| 2026-11-28 | VS | Nhân vật chính bản đầu: Maren (xem STORY_BIBLE.md), còn sửa được đến VS-F | Quyết định của chủ dự án | Chủ dự án |
| 2026-11-28 | VS | TECH-008: bật physics interpolation ở VS-A, có bước kiểm tra camera có rung không | Quyết định của chủ dự án | Chủ dự án |
| 2026-11-28 | VS | Tay cầm: để sau Vertical Slice; mọi input vẫn đi qua action | Quyết định của chủ dự án | Chủ dự án |
| 2026-11-28 | VS | Font: giấy phép SIL OFL 1.1 được chấp nhận cho font (nhúng vào game thương mại, ghi giấy phép kèm theo) | Chủ dự án nêu OFL làm ví dụ hợp lệ | Chủ dự án |
| 2026-11-27 | Kế hoạch | Kiểm tra headless bằng bản Godot 4.7.2 Linux chính thức trên bản sao project ở cloud | Không động vào máy chủ dự án | Chủ dự án |
