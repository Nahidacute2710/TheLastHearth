# THE LAST HEARTH — Kiến trúc kỹ thuật

> Phiên bản: 0.3 · Cập nhật: 2026-11-27
> Quy ước nhãn: **✅ ĐÃ CHỐT** = chủ dự án đã xác nhận · **ĐỀ XUẤT** = gợi ý, chưa duyệt · **🧪 CẦN THỬ NGHIỆM** = chốt qua playtest/mockup · **❓** = câu hỏi mở.
> Engine: Godot 4.7.2 stable · Ngôn ngữ: GDScript (static typing)

---

## 1. Nguyên tắc kiến trúc

> ✅ **ĐÃ CHỐT toàn bộ mục này (2026-11-27).**

1. **Scene là đơn vị lắp ráp.** Mỗi thực thể (player, quái, NPC, rương, ...) là một scene riêng có thể mở và chạy độc lập để thử.
2. **Composition hơn inheritance.** Hành vi dùng chung được tách thành *component* (node con) như `HealthComponent`, `HurtboxComponent`. Không xây cây kế thừa sâu.
3. **Dữ liệu tách khỏi logic.** Chỉ số vật phẩm, quái, công thức nằm trong file `Resource` (`.tres`) ở `data/`. Dữ liệu được tham chiếu bằng **ID cố định** (mục 5). Code không hard-code con số cân bằng game.
4. **"Call down, signal up".** Node cha được gọi hàm của node con. Node con chỉ phát signal lên trên. Hai hệ thống ngang hàng giao tiếp qua `EventBus`.
5. **Chỉ 4 autoload:** `EventBus`, `GameState`, `SaveManager`, `SceneRouter` (mục 3). Thêm autoload mới phải giải thích lý do và được duyệt. Không biến autoload thành "God object".
6. **Trạng thái lưu được tách khỏi node.** Dữ liệu cần lưu nằm trong các object dữ liệu thuần (`RefCounted`/`Resource`), không nằm rải rác trong node của scene.
7. **Static typing bắt buộc** cho mọi script GDScript (biến, tham số, giá trị trả về).
8. **Không viết cứng văn bản hiển thị** trong script. Dùng khóa dịch (mục 5.1).

## 2. Cấu trúc thư mục

Project Godot nằm ở `the-last-hearth/` (tương ứng `res://`). Thư mục gốc của repo chứa `CLAUDE.md` và `.gitignore`.

File nguồn art (`.aseprite`, `.psd`, `.kra`, ...) **không** nằm trong `res://` (✅ ĐÃ CHỐT, xem ASSET_GUIDELINES.md mục 3).

```
res://
├── assets/        Tài nguyên thô: sprite, tileset, âm thanh, font (xem ASSET_GUIDELINES.md)
├── scenes/        File .tscn, chia theo miền
│   ├── main/          Scene khởi động, scene gốc điều phối
│   ├── tavern/        Bản đồ quán, quầy, bếp
│   ├── dungeon/       Bản đồ dungeon, phòng, lối ra
│   ├── characters/    Player, NPC
│   ├── enemies/       Quái vật
│   ├── ui/            HUD, menu, inventory UI
│   └── interactions/  Đồ vật tương tác được: rương, bếp, cửa, vật phẩm rơi
├── scripts/       File .gd không gắn chặt vào một scene cụ thể, hoặc script của scene cùng miền
│   ├── core/          Autoload và tiện ích nền tảng (EventBus, GameState, SceneRouter)
│   ├── components/    Component tái sử dụng (Health, Hitbox, Hurtbox, Interactable)
│   ├── data/          Định nghĩa class Resource (ItemData, RecipeData, EnemyData, ...)
│   ├── player/  combat/  enemies/  tavern/  inventory/
│   ├── crafting/  quests/  dialogue/  economy/  save/
├── data/          Instance dữ liệu (.tres) tạo từ class trong scripts/data/
├── resources/     Resource dùng chung không phải dữ liệu game: Theme UI, material, gradient
├── shaders/       File .gdshader
├── localization/  File dịch (.csv / .po)
├── tests/         Kiểm thử tự động
└── docs/          Tài liệu (có .gdignore để Godot không quét)
```

**Thay đổi so với cấu trúc tham khảo ban đầu, và lý do:**

- Bỏ `scripts/systems/`: tên này quá chung chung, dễ thành nơi đổ mọi thứ. Thay bằng các thư mục theo miền đã có sẵn.
- Thêm `scripts/components/`: chứa component dùng chung giữa player, quái, NPC.
- Thêm `scripts/data/`: tách rõ *định nghĩa class* dữ liệu (code) khỏi *instance* dữ liệu (`data/*.tres`).
- Thêm `assets/audio/music` và `assets/audio/sfx`: nhạc và hiệu ứng âm thanh có thiết lập import khác nhau (loop, nén).
- Thêm `docs/.gdignore`: Godot bỏ qua thư mục tài liệu, không quét và không import.

**Quy tắc đặt script:** Script chỉ phục vụ một scene thì đặt cạnh file `.tscn` đó trong `scenes/`, ví dụ `scenes/enemies/hollow_miner.tscn` + `hollow_miner.gd`. Script tái sử dụng hoặc logic thuần thì đặt trong `scripts/`.

## 3. Autoload (Singleton) — ✅ ĐÃ CHỐT: chỉ 4 autoload

| Tên | File | Trách nhiệm | Không được làm |
|---|---|---|---|
| `EventBus` | `scripts/core/event_bus.gd` | Chỉ khai báo signal toàn cục | Chứa logic hay trạng thái |
| `GameState` | `scripts/core/game_state.gd` | Giữ dữ liệu phiên chơi: ngày, tiền, inventory, cờ tiến trình | Điều khiển node trong scene |
| `SaveManager` | `scripts/save/save_manager.gd` | Ghi/đọc file save, quản lý phiên bản save | Biết chi tiết của từng hệ thống |
| `SceneRouter` | `scripts/core/scene_router.gd` | Chuyển giữa Quán ↔ Dungeon, màn hình chuyển cảnh | Giữ dữ liệu gameplay |

Thứ tự load: `EventBus` → `GameState` → `SaveManager` → `SceneRouter`.

> Autoload **chưa được đăng ký** trong `project.godot`. Việc đăng ký sẽ làm ở mốc 1.1, và mỗi thay đổi `project.godot` đều phải giải thích lý do trước.
>
> Script autoload **không** khai báo `class_name` trùng tên autoload (Godot báo lỗi *"Class ... hides an autoload singleton"*). Autoload truy cập bằng tên toàn cục, ví dụ `EventBus.enemy_died`.

## 4. Luồng giao tiếp giữa các hệ thống

```
                    ┌────────────┐
       emit ──────▶ │  EventBus  │ ──────▶ connect
                    └────────────┘
   Player ─┐                               ┌─ HUD
   Enemy  ─┼─ (signal toàn cục: enemy_died, ├─ QuestTracker
   Stove  ─┘   item_collected, day_ended…)  └─ AudioManager (sau MVP)

   Scene nội bộ:  Parent ──gọi hàm──▶ Child
                  Parent ◀──signal──── Child

   Dữ liệu:  data/*.tres ──đọc──▶ Hệ thống ──ghi trạng thái──▶ GameState ──serialize──▶ SaveManager
```

**Khi nào dùng cái gì:**

| Tình huống | Cách làm |
|---|---|
| Player nhận sát thương từ quái trong cùng scene | `Hitbox` chạm `Hurtbox` → `HealthComponent.take_damage()` |
| Quái chết, HUD và nhiệm vụ cần biết | Quái emit `EventBus.enemy_died(enemy_data)` |
| Player nhặt vật phẩm | Gọi `GameState.inventory.add_item(item, qty)`; inventory emit signal `changed` |
| Chuyển từ quán xuống dungeon | `SceneRouter.go_to(SceneRouter.DUNGEON)` |
| Tìm node khác scene | **Không** dùng đường dẫn tuyệt đối `/root/...`. Dùng signal, group hoặc truyền tham chiếu |

## 5. Mô hình dữ liệu (Resource)

> ✅ **ĐÃ CHỐT:** chỉ số và dữ liệu định nghĩa game dùng Resource `.tres`, tham chiếu bằng `id: StringName` cố định. Danh sách trường trong bảng là dự kiến.

Class định nghĩa trong `scripts/data/`, có `class_name`, extends `Resource`:

| Class | Trường chính (dự kiến) | Instance ở |
|---|---|---|
| `ItemData` | `id: StringName`, `name_key: StringName` (khóa dịch), `icon: Texture2D`, `max_stack: int`, `sell_price: int` | `data/items/` |
| `WeaponData` (extends `ItemData`) | `damage: int`, `attack_cooldown: float`, `knockback: float` | `data/items/` |
| `RecipeData` | `id`, `inputs: Array[ItemStack]`, `output: ItemData`, `cook_time: float` | `data/recipes/` |
| `EnemyData` | `id`, `max_health`, `move_speed`, `contact_damage`, `loot_table` | `data/enemies/` |
| `CustomerData` | `id`, `name_key`, `wanted_items: Array[ItemData]`, `patience: float` | `data/characters/` |

Mọi dữ liệu được tham chiếu bằng **`id` dạng `StringName` cố định** (ví dụ `&"cave_mushroom"`). File save chỉ lưu `id`, không lưu đường dẫn file. Nhờ vậy có thể đổi tên/di chuyển file `.tres` mà không làm hỏng save.

Tra cứu từ `id` sang Resource qua một `DataRegistry` (dự kiến nằm ở `scripts/core/`, quét `data/` khi khởi động). Ở MVP có thể chỉ cần một dictionary `preload` đơn giản.

### 5.1 Localization — ✅ ĐÃ CHỐT: tiếng Anh + tiếng Việt

- Mọi chuỗi hiển thị cho người chơi dùng **khóa dịch** dạng `CONSTANT_CASE`, ví dụ `UI_PROMPT_COOK`, `ITEM_CAVE_MUSHROOM_NAME`. Code gọi `tr(key)`. Với `Label`/`Button`, gán khóa vào `text` và Godot tự dịch (auto translate).
- Resource dữ liệu lưu **khóa** (`name_key`, `description_key`), không lưu chuỗi đã dịch.
- File dịch: `localization/translations.csv`, UTF-8, cột `keys,en,vi`. Godot import CSV thành file `.translation`. Ngôn ngữ dự phòng: `en`.
- Đăng ký file dịch trong Project Settings → Localization (thay đổi `project.godot`) làm ở mốc có chuỗi UI đầu tiên (dự kiến 1.3), **không** làm ở 1.1.
- Font phải hiển thị đủ ký tự tiếng Việt (ASSET_GUIDELINES.md mục 4.3). Chuỗi tiếng Việt thường dài hơn tiếng Anh, nên UI không đặt chiều rộng cứng sát chữ.
- Chuỗi debug/log (`print`, `push_error`) không cần dịch.
- Chưa làm ở giai đoạn này: dịch toàn bộ nội dung, menu chọn ngôn ngữ (Vertical Slice).

## 6. Hệ thống lưu/tải

> ✅ **ĐÃ CHỐT:** JSON, có `save_version`, ghi file tạm trước rồi mới thay thế file save chính.

- **Định dạng:** JSON, ghi vào `user://saves/slot_<n>.json`.
- **Lý do không dùng `ResourceSaver`/`.tres` cho save:** file `.tres` có thể chứa script nhúng, và việc load một file save do người khác chia sẻ có thể thực thi code. JSON an toàn hơn, dễ đọc khi debug và dễ migrate.
- **Cấu trúc:**
  ```json
  {
    "save_version": 1,
    "game_version": "0.1.0",
    "timestamp": "2026-11-27T20:00:00",
    "game_state": { "day": 1, "gold": 0, "flags": {} },
    "inventory": [ { "id": "cave_mushroom", "qty": 3 } ]
  }
  ```
- Mỗi hệ thống cần lưu có cặp hàm `to_dict() -> Dictionary` và `from_dict(data: Dictionary) -> void`.
- `save_version` tăng mỗi khi cấu trúc thay đổi; `SaveManager` có hàm migrate từ phiên bản cũ.
- Ghi an toàn: ghi vào file tạm `.tmp` trước, xong mới đổi tên đè lên file cũ, để tránh hỏng save khi game crash giữa chừng. Hành vi đổi tên đè file trên Windows sẽ được kiểm thử ở mốc 1.8.

## 7. Physics: Collision Layers — ✅ ĐÃ CHỐT (2026-11-27)

`World` ở layer 1 vì node vật lý mới trong Godot mặc định nằm ở layer 1 và mask 1: tường và `TileMapLayer` mới tạo tự động là `World`. Tên layer đã đặt trong `project.godot` (`[layer_names]`).

| Layer | Tên | Node dùng | Mục đích |
|---|---|---|---|
| 1 | `World` | `StaticBody2D`, collision của `TileMapLayer` | Tường, vật cản tĩnh |
| 2 | `Player` | `CharacterBody2D` của player | Thân player |
| 3 | `Enemy` | `CharacterBody2D` của quái | Thân quái |
| 4 | `PlayerHurtbox` | `Area2D` hurtbox của player | Vùng player nhận sát thương |
| 5 | `EnemyHurtbox` | `Area2D` hurtbox của quái | Vùng quái nhận sát thương |
| 6 | `Interactable` | `Area2D` của component `Interactable` | Vùng tương tác: bếp, cửa, khách |
| 7–32 | (trống) | | Thêm layer mới phải được duyệt |

| Đối tượng | Layer | Mask | Ghi chú |
|---|---|---|---|
| Tường / tile | 1 | (trống) | |
| Thân player | 2 | 1 | Chỉ bị tường chặn |
| Thân quái | 3 | 1, 3 | Bị tường chặn; quái không chồng lên nhau |
| Hurtbox player | 4 | (trống) | Chỉ để được phát hiện |
| Hurtbox quái | 5 | (trống) | Chỉ để được phát hiện |
| Hitbox đòn của player | (trống) | 5 | Dò hurtbox quái |
| Hitbox đòn của quái | (trống) | 4 | Dò hurtbox player |
| Vùng tương tác | 6 | 2 | Dò thân player |

- Thân player và thân quái **không chặn nhau** (player mask không có 3, quái mask không có 2). Sát thương đi qua hitbox/hurtbox.
- Quy tắc: **hitbox dò hurtbox**. `HitboxComponent` (`Area2D`, `monitoring = true`) nhận `area_entered` từ hurtbox và gọi vào `HurtboxComponent` → `HealthComponent`.
- Đòn đánh của player không có mask 4 nên không tự đánh trúng mình; tương tự với quái.

## 8. Input Map — ✅ ĐÃ CHỐT (2026-11-27)

| Action | Phím | Ghi chú |
|---|---|---|
| `movement_up` / `movement_down` / `movement_left` / `movement_right` | W / S / A / D | Physical key: giữ đúng vị trí trên bàn phím AZERTY/QWERTZ |
| `interact` | E | |
| `attack` | Chuột trái | |
| `dodge` | Space | Khai báo ở 1.1; cơ chế né ở Vertical Slice |
| `inventory` | Tab, I | |
| `pause` | Escape | Khai báo ở 1.1; chưa có menu tạm dừng |

Đọc hướng di chuyển bằng `Input.get_vector(&"movement_left", &"movement_right", &"movement_up", &"movement_down")`. Code chỉ dùng tên action, không đọc phím trực tiếp. Tay cầm: thêm sau MVP.

**Rủi ro đã biết (chưa xử lý):** Tab trùng action mặc định `ui_focus_next`. Khi một `Control` đang có focus, Tab sẽ chuyển focus thay vì mở inventory. Phải xử lý khi làm UI inventory (mốc 1.6), ví dụ đặt `focus_mode` phù hợp hoặc xử lý `inventory` trong `_unhandled_input`/`_input` trước UI. Theo dõi ở BUG_TRACKER.md (TECH-006).

## 9. Cấu hình project hiện tại (đã kiểm tra)

| Thiết lập | Giá trị | Nhận xét |
|---|---|---|
| Viewport | 640×360 | Tốt cho pixel art, scale đúng tỉ lệ 2× lên 1280×720, 3× lên 1920×1080 |
| Window override | 1280×720 | Hợp lý khi phát triển |
| Stretch mode | `canvas_items` | Chạy được; xem đề xuất bên dưới |
| Default texture filter | Nearest (0) | Đúng cho pixel art |
| Renderer | GL Compatibility | Phù hợp game 2D, chạy được trên máy yếu |
| `rendering_device/driver.windows` | d3d12 | Chỉ có tác dụng với renderer Forward+/Mobile; hiện không ảnh hưởng |
| 3D physics | Jolt | Không ảnh hưởng game 2D |

**Đề xuất TECH-003 — integer scaling (CHƯA áp dụng, dự kiến làm ở mốc 1.1 nếu được duyệt):**

```ini
[display]
window/stretch/mode="canvas_items"   ; giữ nguyên
window/stretch/aspect="keep"         ; giữ tỉ lệ 16:9, mặc định của Godot nên không cần ghi
window/stretch/scale_mode="integer"  ; MỚI: chỉ phóng to theo bội số nguyên
```

- Với `scale_mode = integer`, Godot làm tròn xuống hệ số phóng to gần nhất và thêm viền đen phần dư: 1280×720 → 2×, 1920×1080 → 3×, 2560×1440 → 4×, 3840×2160 → 6×. Màn 1366×768 → 2× (viền đen quanh 1280×720).
- Lý do: mỗi pixel nghệ thuật luôn hiện bằng đúng N×N pixel màn hình, không có pixel to nhỏ không đều.
- 🧪 Cần thử ở mốc 1.2 khi có chuyển động: `rendering/2d/snap/snap_2d_transforms_to_pixel` để tránh sprite rung khi camera di chuyển ở tọa độ lẻ.
- Cân nhắc `stretch/mode = "viewport"` nếu muốn mọi thứ, kể cả UI và chuyển động, khớp lưới pixel tuyệt đối. Đánh đổi là chữ UI và chuyển động camera kém mượt hơn. Nên thử cả hai ở MVP rồi mới chốt.
- Bật cảnh báo `untyped_declaration` ở mức Warning để ép static typing.

## 10. Kiểm thử

- **Kiểm tra headless** (không cần mở editor):
  ```
  "D:/Godot_v4.7.2/Godot_v4.7.2-stable_win64_console.exe" --headless --path . --import
  ```
  Lệnh này import toàn bộ project và báo lỗi parse script. Chạy từ thư mục `the-last-hearth/`.
- **Unit test:** dự kiến dùng addon GUT (Godot Unit Test) cho logic thuần như inventory, công thức, serialize save. Addon **chưa được cài**; sẽ đề xuất ở Giai đoạn 1.
- **Scene test:** mỗi scene thực thể phải chạy được độc lập bằng F6.

## 11. Hiệu năng (mục tiêu)

- 60 FPS ổn định trên máy tầm thấp (GPU tích hợp).
- Dùng `TileMapLayer` (không dùng node `TileMap` đã deprecated).
- Pool đối tượng cho đạn/hiệu ứng nếu số lượng lớn (chỉ làm khi đo thấy cần).

## 12. Lịch sử thay đổi

| Ngày | Phiên bản | Nội dung |
|---|---|---|
| 2026-11-27 | 0.1 | Bản khởi tạo |
| 2026-11-27 | 0.3 | Chốt collision layers (6 layer, hitbox dò hurtbox) và Input Map (9 action, thêm `pause`); ghi rủi ro Tab |
| 2026-11-27 | 0.2 | Chốt nguyên tắc kiến trúc, 4 autoload, Resource + ID, save JSON, static typing; thêm mục 5.1 Localization; đề xuất collision 6 layer, input `movement_*`, cấu hình TECH-003 |
