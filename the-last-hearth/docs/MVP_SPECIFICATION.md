# THE LAST HEARTH — Đặc tả MVP

> Phiên bản: 0.4 · Cập nhật: 2026-11-27
> Quy ước nhãn: **✅ ĐÃ CHỐT** = chủ dự án đã xác nhận · **ĐỀ XUẤT** = gợi ý, chưa duyệt · **🧪 CẦN THỬ NGHIỆM** = chốt qua playtest/mockup · **❓** = câu hỏi mở.
> MVP = Giai đoạn 1 trong DEVELOPMENT_ROADMAP.md.

---

## 1. Mục tiêu

Chứng minh rằng **vòng lõi vui và hai nửa game nối với nhau được**, với lượng nội dung nhỏ nhất có thể.

```
Quản lý quán → Chuẩn bị → Đi dungeon → Chiến đấu → Thu thập tài nguyên → Trở về quán
      ▲                                                                       │
      └───────────── nấu món từ tài nguyên, bán cho khách, nhận tiền ◀────────┘
```

**MVP không phải là bản demo đẹp.** Asset tạm (hình khối, màu đơn sắc) là chấp nhận được và phải được đặt tên `_placeholder`.

## 2. Nội dung MVP

> ✅ = đã chốt (2026-11-27): nhân vật chính cố định, Thợ Mỏ Rỗng, Cuốc Chim, Nấm Hang, Súp Nấm. Các mục không có ✅ vẫn là ĐỀ XUẤT.
> Mọi con số cân bằng (máu, sát thương, số nguyên liệu, tỉ lệ rơi, số quái mỗi phòng) đã được chơi thử đạt ngày 2026-11-28; giá trị thực tế nằm trong các file `.tres` và `docs/DECISION_LOG.md`.

| Thành phần | Số lượng | Đề xuất cụ thể |
|---|---|---|
| Nhân vật chính | 1 | ✅ **Chủ quán** (`innkeeper`): nhân vật cố định, không có tạo nhân vật |
| Phòng quán trọ | 1 | **Sảnh chính**: lò sưởi (Ngọn Lửa Gốc, trang trí), 1 bếp, 1 bàn khách, 1 cửa hầm dẫn xuống dungeon |
| Khu vực dungeon | 1 | **Mỏ Bỏ Hoang** (`abandoned_mine`): 3 đến 4 phòng nối liền, thiết kế tay, có lối ra về quán |
| Quái vật | 1 | ✅ **Thợ Mỏ Rỗng** (`hollow_miner`): đi chậm, đuổi khi thấy player, đánh cận chiến có lấy đà |
| Vũ khí | 1 | ✅ **Cuốc Chim** (`rusty_pickaxe`): cận chiến, vung theo hướng chuột ✅ |
| Tài nguyên | 1 | ✅ **Nấm Hang** (`cave_mushroom`): rơi từ quái và mọc ở góc dungeon |
| Khách hàng NPC | 1 | **Lữ Khách** (`weary_traveler`): đến mỗi ngày, gọi 1 món |
| Công thức | 1 | ✅ **Súp Nấm** (`mushroom_stew`) = 2 Nấm Hang (đã chơi thử 2026-11-28) |

## 3. Kịch bản chơi mẫu (người chơi trải nghiệm thế nào)

1. **Bắt đầu ở quán.** Lữ Khách ngồi ở bàn, bong bóng thoại: "Có gì ấm bụng không?". Inventory trống, 0 vàng.
2. Player tương tác với bếp → hiện thông báo "Cần 3 Nấm Hang". → Người chơi hiểu mình phải đi lấy.
3. **Chuẩn bị:** Player nhặt Cuốc Chim ở giá treo cạnh cửa hầm (chỉ ở lần đầu).
4. **Đi dungeon:** Tương tác với cửa hầm → fade → xuất hiện ở Mỏ Bỏ Hoang.
5. **Chiến đấu:** Gặp 2 đến 3 Thợ Mỏ Rỗng mỗi phòng. Đánh chết → rơi Nấm Hang.
6. **Thu thập:** Nhặt nấm; HUD cập nhật số lượng.
7. **Trở về:** Đến lối ra → về quán. Game **tự lưu**.
   - Nếu bị đánh gục (✅ ĐÃ CHỐT): về quán, mất nấm, loot, tiền nhặt trong chuyến và đồ tiêu hao mang theo; giữ Cuốc Chim đang trang bị (bảng đầy đủ ở GDD mục 6).
8. **Quản lý quán:** Nấu Súp Nấm → mang cho Lữ Khách → nhận vàng. Ngày tăng thêm 1.
9. Thoát game, mở lại → "Tiếp tục" → mọi thứ còn nguyên.

**Liên kết Quán → Dungeon trong MVP (✅ đã làm ở D3, 2026-11-28):** Player cũng có thể **tự ăn** Súp Nấm trước khi xuống hầm để được +2 máu tối đa trong chuyến đó. Điều này tạo lựa chọn thật sự đầu tiên: *bán lấy tiền hay ăn để đi sâu hơn?*

## 4. Hệ thống trong MVP & tiêu chí chấp nhận

| Hệ thống | Tiêu chí chấp nhận (phải kiểm chứng được) |
|---|---|
| **Di chuyển** | Đi 8 hướng bằng WASD; tốc độ chéo không nhanh hơn tốc độ thẳng; va chạm tường không bị kẹt |
| **Chiến đấu** | Vung vũ khí có cooldown; quái nhận sát thương, bị đẩy lùi, nháy trắng; player có máu, i-frames, chết thì về quán theo bảng mất/giữ ở GDD mục 6 |
| **Tương tác** | Đứng gần đối tượng hiện prompt; bấm E kích hoạt; nhiều đối tượng thì chọn cái gần nhất |
| **Inventory** | Thêm/bớt vật phẩm đúng số lượng; xếp chồng theo `max_stack`; dữ liệu giữ nguyên khi chuyển cảnh; UI cập nhật theo signal |
| **Nấu ăn** | Chỉ nấu được khi đủ nguyên liệu; trừ đúng nguyên liệu; ra đúng món |
| **Khách hàng** | Khách nhận đúng món thì trả tiền; tiền hiện trên HUD |
| **Lưu & tải** | Lưu: ngày, vàng, inventory, đã nhặt vũ khí chưa. Tải lại đúng 100%. File save hỏng hoặc thiếu không làm crash game. File có `save_version`; ghi file tạm rồi mới thay thế file chính |
| **Localization** | Mọi chuỗi hiển thị dùng khóa dịch trong `localization/translations.csv`, không có chuỗi UI viết cứng trong script. Bắt buộc có cột `en`; cột `vi` chưa bắt buộc ở MVP |
| **Chuyển cảnh** | Quán ↔ Dungeon có fade, không rò rỉ node cũ |
| **Né** | Space lướt ngắn theo hướng di chuyển (đứng yên thì theo hướng chuột), có i-frames và cooldown |
| **Tạm dừng** | Esc dừng game (`get_tree().paused`); menu Tiếp tục / Về menu chính |

## 5. Ngoài phạm vi MVP (KHÔNG làm)

nhiều vũ khí · boss · sinh dungeon ngẫu nhiên · nhân viên · nâng cấp quán · cửa hàng · chế tạo trang bị · hệ thống nhiệm vụ · hội thoại nhiều nhánh · Ngọn Lửa Gốc có cơ chế · âm thanh/nhạc final · menu cài đặt (chỉ có menu tạm dừng tối thiểu: Tiếp tục / Về menu chính) · dịch đầy đủ và menu chọn ngôn ngữ (kiến trúc localization **có** trong MVP) · tạo nhân vật · tay cầm · Steam.

Nếu trong lúc làm MVP phát sinh ý tưởng, ghi vào mục "Ý tưởng chờ" bên dưới, **không** làm ngay.

## 6. Kế hoạch file dự kiến cho MVP

> Chỉ là kế hoạch. Chưa tạo file nào trong số này.

```
scripts/core/        event_bus.gd · game_state.gd · scene_router.gd
scripts/save/        save_manager.gd
scripts/components/  health_component.gd · hitbox_component.gd · hurtbox_component.gd · interactable.gd
scripts/data/        item_data.gd · weapon_data.gd · recipe_data.gd · enemy_data.gd · customer_data.gd · item_stack.gd
scripts/inventory/   inventory.gd
scenes/main/         main.tscn (scene khởi động + menu "Tiếp tục / Chơi mới")
scenes/characters/   player.tscn + player.gd · weary_traveler.tscn + .gd
scenes/enemies/      hollow_miner.tscn + .gd
scenes/tavern/       tavern_main_hall.tscn
scenes/dungeon/      abandoned_mine.tscn
scenes/interactions/ cooking_station.tscn · dungeon_door.tscn · pickup.tscn
scenes/ui/           hud.tscn · inventory_panel.tscn · interaction_prompt.tscn
data/items/          cave_mushroom.tres · mushroom_stew.tres · rusty_pickaxe.tres
data/recipes/        mushroom_stew.tres
data/enemies/        hollow_miner.tres
data/characters/     weary_traveler.tres
localization/        translations.csv (cột keys, en, vi)
tests/               test_inventory.gd · test_save_roundtrip.gd (nếu cài GUT)
```

## 7. Ý tưởng chờ (Parking Lot)

- (trống)

## 8. Lịch sử thay đổi

| Ngày | Phiên bản | Nội dung |
|---|---|---|
| 2026-11-27 | 0.1 | Bản khởi tạo |
| 2026-11-27 | 0.4 | Né và menu tạm dừng vào MVP; đòn theo hướng chuột; buff Súp Nấm ở D3 nếu kịp |
| 2026-11-27 | 0.3 | Cập nhật luật chết theo bảng mất/giữ |
| 2026-11-27 | 0.2 | Đánh dấu nội dung MVP đã chốt; luật chết mới thay cho mất 50%; thêm tiêu chí Localization; cập nhật ngoài phạm vi |
