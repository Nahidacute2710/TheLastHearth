# THE LAST HEARTH — Hệ thống Gameplay

> Phiên bản: 0.4 · Cập nhật: 2026-11-27
> Quy ước nhãn: **✅ ĐÃ CHỐT** = chủ dự án đã xác nhận · **ĐỀ XUẤT** = gợi ý, chưa duyệt · **🧪 CẦN THỬ NGHIỆM** = chốt qua playtest/mockup · **❓** = câu hỏi mở.
> Mỗi hệ thống ghi rõ: mục đích · đầu vào · đầu ra · liên kết · phạm vi MVP.

---

## 1. Bản đồ liên kết hệ thống

```
                          ┌───────────────┐
                          │  NGỌN LỬA GỐC │ (sau MVP)
                          └──────┬────────┘
                       mở khóa độ sâu / sức chứa quán
          ┌──────────────────────┼──────────────────────┐
          ▼                      │                      ▼
  ┌──────────────┐               │              ┌──────────────┐
  │   DUNGEON    │               │              │     QUÁN     │
  │ ┌──────────┐ │  tài nguyên   │              │ ┌──────────┐ │
  │ │ Chiến đấu│─┼──────────────▶│ INVENTORY ◀──┼─│ Nấu ăn   │ │
  │ └──────────┘ │               │      │       │ └────┬─────┘ │
  │ ┌──────────┐ │               │      │       │      ▼       │
  │ │ Rơi đồ   │─┼───────────────┘      │       │ ┌──────────┐ │
  │ └──────────┘ │                      │       │ │ Khách    │ │
  └──────▲───────┘                      │       │ └────┬─────┘ │
         │       buff món ăn / vũ khí    │       │      ▼ tiền  │
         └──────────────────────────────┴───────┼─ KINH TẾ     │
                                                └──────────────┘
                  NHIỆM VỤ & HỘI THOẠI bao trùm cả hai phía
```

---

## 2. Hệ thống nền tảng

### 2.1 Di chuyển (Movement)
- **Mục đích:** Điều khiển nhân vật mượt, chính xác.
- **Chi tiết:** `CharacterBody2D`, 8 hướng, có gia tốc và giảm tốc ngắn để có cảm giác "nặng" vừa phải. Tốc độ lấy từ biến export, không hard-code.
- **Thông số khởi đầu (🧪 CẦN THỬ NGHIỆM, `@export` trong `player.gd`):** `max_speed` 80 px/s (khoảng 5 tile/giây), `acceleration` 800 px/s² (đạt tốc độ tối đa sau khoảng 0,1 giây), `friction` 1000 px/s² (dừng sau khoảng 0,08 giây). Hướng đọc bằng `Input.get_vector()` nên đi chéo không nhanh hơn đi thẳng. Camera trong Player, `position_smoothing` tắt ở 1.2.
- **Liên kết:** Chiến đấu (đứng khựng khi tấn công), Tương tác.
- **MVP:** ✅ Đi bộ 8 hướng (mốc 1.2). ❌ Cơ chế né/lăn (Vertical Slice). Action `dodge` được khai báo sẵn trong Input Map từ mốc 1.1 nhưng chưa gắn cơ chế.

### 2.2 Tương tác (Interaction)
- **Mục đích:** Một cách thống nhất để player tương tác với mọi đối tượng.
- **Chi tiết:** Đối tượng có component `Interactable` (Area2D, layer 6 `interactable`, mask 2) dò thân player và có `prompt_text`, signal `interacted(actor)`. Khi nhiều đối tượng cùng báo player trong vùng, player chọn đối tượng gần nhất. (Bố trí layer ✅ ĐÃ CHỐT, xem TECHNICAL_ARCHITECTURE.md mục 7.) Hiện prompt "[E] Nấu ăn".
- **Liên kết:** Nấu ăn, Khách hàng, Cửa chuyển cảnh, Rương, NPC hội thoại.
- **MVP:** ✅

### 2.3 Inventory
- **Mục đích:** Lưu vật phẩm player mang theo.
- **Chi tiết:** Class `Inventory` (`RefCounted`) giữ danh sách `ItemStack {item: ItemData, quantity: int}`. API: `add_item`, `remove_item`, `has_item`, `get_quantity`, signal `changed`. Logic tách khỏi UI. Inventory thuộc `GameState`, nên tồn tại xuyên suốt khi chuyển cảnh.
- **MVP:** ✅ Danh sách đơn giản, số ô giới hạn, UI hiển thị dạng lưới. ❌ Kéo thả, kho chứa, phân loại.
- **Hệ quả của luật chết (✅ ĐÃ CHỐT, bảng ở GDD mục 6):** khi chết, mất mọi thứ player đang mang trong chuyến (loot, tài nguyên, tiền nhặt được, đồ tiêu hao, trang bị chưa mặc); giữ trang bị đang mặc và vật phẩm cốt truyện/quest. Vì vậy inventory phải phân biệt được: *đồ cất ở quán*, *đồ đang mang theo*, *slot trang bị đang mặc*, và cờ *vật phẩm quest* trên `ItemData`.
- **Cách làm (ĐỀ XUẤT, chốt ở mốc 1.6; chưa code):** khi chết, xóa toàn bộ inventory mang theo trừ vật phẩm có cờ quest; slot trang bị đang mặc không bị ảnh hưởng; tiền nhặt trong chuyến tính riêng (`run_gold`) và chỉ cộng vào `gold` khi về quán.

### 2.4 Lưu/Tải
- **Chi tiết:** Xem TECHNICAL_ARCHITECTURE.md mục 6.
- **MVP:** ✅ 1 slot, tự lưu khi trở về quán, tải khi bấm "Tiếp tục".

### 2.5 Chuyển cảnh & Thời gian
- **Chi tiết:** `SceneRouter` đổi scene giữa Quán và Dungeon, có fade đen. Bộ đếm ngày nằm trong `GameState`.
- **MVP:** ✅ Chuyển cảnh + fade. Ngày tăng khi đi ngủ hoặc khi về từ dungeon (❓ chốt ở MVP). ❌ Đồng hồ trong ngày.

---

## 3. Hệ thống Dungeon

### 3.1 Chiến đấu (Combat)
- **Mục đích:** Hành động cận chiến ngắn, đọc được, có phản hồi mạnh.
- **Chi tiết:**
  - `HitboxComponent` (Area2D gây sát thương) và `HurtboxComponent` (Area2D nhận sát thương) → `HealthComponent` (máu, signal `died`, `health_changed`).
  - Đòn đánh theo hướng chuột hoặc hướng di chuyển ❓.
  - Có cooldown, knockback, i-frames ngắn sau khi bị đánh.
  - Phản hồi: nháy trắng, hitstop, rung camera.
- **Đầu vào:** `WeaponData`. **Đầu ra:** Signal chết → rơi đồ, nhiệm vụ.
- **MVP:** ✅ 1 vũ khí cận chiến, đánh 1 hướng. ❌ Combo, kỹ năng, vũ khí tầm xa.
- **Khi player chết (✅ ĐÃ CHỐT):** về quán, áp dụng bảng mất/giữ ở GDD mục 6. Không thêm hình phạt khác khi chưa được duyệt.
- **Chỉ số** (máu, sát thương, cooldown, knockback, i-frames): 🧪 CẦN THỬ NGHIỆM, đặt trong Resource `.tres`.

### 3.2 Quái vật (Enemy AI)
- **Chi tiết:** State machine đơn giản: `Idle → Chase → Attack → Hurt → Dead`. Chỉ số lấy từ `EnemyData`.
- **MVP:** ✅ 1 loại quái cận chiến, đuổi theo khi thấy player, tấn công khi lại gần. ❌ Pathfinding phức tạp (MVP dùng di chuyển thẳng hoặc `NavigationAgent2D` cơ bản).

### 3.3 Rơi đồ (Loot)
- **Chi tiết:** `EnemyData.loot_table` gồm các cặp `{item, chance, min_qty, max_qty}`. Khi chết, sinh `Pickup` trên mặt đất; player chạm vào thì nhặt.
- **MVP:** ✅ 1 loại tài nguyên, tỉ lệ rơi cố định.

### 3.4 Sinh dungeon
- **Chi tiết dài hạn:** Ghép các phòng thiết kế sẵn (room templates) theo graph, có phòng chiến đấu, phòng thưởng, phòng boss.
- **MVP:** ❌ Chỉ 1 khu vực thiết kế tay.

### 3.5 Boss
- **MVP:** ❌ (Vertical Slice).

---

## 4. Hệ thống Quán trọ

### 4.1 Nấu ăn (Cooking)
- **Mục đích:** Biến tài nguyên dungeon thành giá trị (tiền + buff).
- **Chi tiết:** Tương tác với bếp → chọn công thức có đủ nguyên liệu → trừ nguyên liệu → sau `cook_time` nhận món. Dữ liệu từ `RecipeData`.
- **MVP:** ✅ 1 công thức, 1 bếp, nấu xong ngay hoặc chờ vài giây.

### 4.2 Khách hàng (Customers)
- **Chi tiết:** Khách đến, ngồi vào chỗ, yêu cầu món. Player mang món đến (tương tác) → nhận tiền. Khách có độ kiên nhẫn; hết kiên nhẫn thì bỏ đi.
- **MVP:** ✅ 1 khách, xuất hiện cố định mỗi ngày, yêu cầu 1 món. ❌ Kiên nhẫn, danh tiếng, nhiều khách.

### 4.3 Kinh tế (Economy)
- **Chi tiết:** Tiền (`gold`) trong `GameState`. Nguồn thu: phục vụ khách, bán vật phẩm. Chi: mua nguyên liệu, nâng cấp, trang bị.
- **MVP:** ✅ Chỉ thu tiền từ khách, hiển thị trên HUD. ❌ Cửa hàng, nâng cấp.

### 4.4 Chế tạo (Crafting)
- **Chi tiết:** Tương tự nấu ăn nhưng ra trang bị/vật phẩm. Dùng chung khung `RecipeData` với trường `station_type` để phân biệt bếp/lò rèn.
- **MVP:** ❌

### 4.5 Nhân viên (Staff)
- **Chi tiết:** Thuê NPC tự động phục vụ/nấu ăn, có chỉ số, có lương. Vận hành quán khi player ở dungeon, tạo thu nhập thụ động.
- **MVP:** ❌

### 4.6 Nâng cấp cơ sở vật chất
- **Chi tiết:** Tiêu tiền + vật liệu dungeon để mở phòng, thêm bàn, nâng bếp.
- **MVP:** ❌

---

## 5. Hệ thống xuyên suốt

### 5.1 Ngọn Lửa Gốc (Hearth Flame) — hệ thống bản sắc
- **Vai trò (✅ ĐÃ CHỐT):** cơ chế quan trọng gắn với sự tồn tại và phát triển của quán.
- **Chi tiết (ĐỀ XUẤT ❓):** Xem GDD mục 5.2. Cấp lửa quyết định giới hạn độ sâu dungeon và sức chứa quán.
- **MVP:** ❌ (nhưng kiến trúc `GameState` phải chừa chỗ cho nó).

### 5.2 Nhiệm vụ (Quests)
- **Chi tiết:** `QuestData` với các mục tiêu (giết X, thu thập Y, mang Z cho NPC). Theo dõi qua signal `EventBus`.
- **MVP:** ❌ (Yêu cầu món của khách đóng vai trò "nhiệm vụ" đơn giản nhất.)

### 5.3 Hội thoại (Dialogue)
- **Chi tiết:** Dữ liệu hội thoại ở `data/dialogues/`. Cân nhắc addon Dialogue Manager ❓ hoặc tự viết hệ thống đơn giản.
- **MVP:** ❌ Chỉ hộp thoại 1 dòng khi tương tác với khách.

### 5.4 Buff từ món ăn
- **Chi tiết:** Ăn món trước khi xuống dungeon → buff tạm thời trong chuyến đi (ví dụ +máu tối đa).
- **MVP:** ❓ 🧪 Nên có nếu kịp, vì đây là liên kết "Quán → Dungeon" rõ ràng nhất. Đề xuất: món duy nhất của MVP vừa bán được cho khách, vừa có thể ăn để +máu.

### 5.5 Ngôn ngữ (Localization)
- **✅ ĐÃ CHỐT:** hỗ trợ tiếng Anh và tiếng Việt. Mọi văn bản hiển thị (UI, tên vật phẩm, thoại) dùng khóa dịch, không viết cứng trong script. Kiến trúc ở TECHNICAL_ARCHITECTURE.md mục 5.1.
- **MVP:** ✅ Dùng khóa dịch cho mọi chuỗi hiển thị. ❌ Dịch đầy đủ, menu chọn ngôn ngữ.

---

## 6. Lịch sử thay đổi

| Ngày | Phiên bản | Nội dung |
|---|---|---|
| 2026-11-27 | 0.1 | Bản khởi tạo |
| 2026-11-27 | 0.4 | Thông số di chuyển khởi đầu của mốc 1.2 |
| 2026-11-27 | 0.3 | Luật chết chi tiết; tương tác theo layer 6 `interactable` dò player |
| 2026-11-27 | 0.2 | Luật chết đã chốt và hệ quả cho inventory; vai trò Ngọn Lửa Gốc; action `dodge`; thêm mục 5.5 Localization |
