# THE LAST HEARTH — Kiến trúc kỹ thuật

> Phiên bản: 0.5 · Cập nhật: 2026-11-27
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

**SceneRouter (đã làm ở A3):** `Main` gọi `SceneRouter.start(%LevelRoot, SceneRouter.TAVERN)` một lần. `go_to(level_id, spawn_id)` fade đen → tắt xử lý `LevelRoot` trong lúc chuyển → thay level → gọi `level.place_player(spawn_id)` → fade sáng → emit `EventBus.level_changed`. Overlay fade là `CanvasLayer` (layer 100) do SceneRouter tự tạo. Danh sách level nằm trong hằng `_LEVEL_PATHS`.

> ✅ Đã đăng ký trong `project.godot` (`[autoload]`, bật Global Variable) ở mốc 1.1. Mọi thay đổi `project.godot` về sau vẫn phải giải thích lý do trước.
>
> Script autoload **không** khai báo `class_name` trùng tên autoload (Godot báo lỗi *"Class ... hides an autoload singleton"*). Autoload truy cập bằng tên toàn cục, ví dụ `EventBus.enemy_died`.

## 4. Luồng giao tiếp giữa các hệ thống

```
                    ┌────────────┐
       emit ──────▶ │  EventBus  │ ──────▶ connect
                    └────────────┘
   Player ─┐                               ┌─ HUD
   Enemy  ─┼─ (signal toàn cục: enemy_died, ├─ QuestTracker
   Stove  ─┘   item_collected, day_ended…)  └─ Audio (AudioDirector trong Main, VS-A)

   Scene nội bộ:  Parent ──gọi hàm──▶ Child
                  Parent ◀──signal──── Child

   Dữ liệu:  data/*.tres ──đọc──▶ Hệ thống ──ghi trạng thái──▶ GameState ──serialize──▶ SaveManager
```

**Khi nào dùng cái gì:**

| Tình huống | Cách làm |
|---|---|
| Đối tượng tương tác báo có player ở gần | `Interactable` emit `EventBus.interactable_available(self)`; `Interactor` của player chọn cái gần nhất và emit `EventBus.interaction_focus_changed` cho UI prompt |
| Player nhận sát thương từ quái trong cùng scene | `Hitbox` chạm `Hurtbox` → `HealthComponent.take_damage()` |
| Quái chết, HUD và nhiệm vụ cần biết | Quái emit `EventBus.enemy_died(enemy_data)` |
| Player nhặt vật phẩm | Gọi `GameState.inventory.add_item(item, qty)`; inventory emit signal `changed` |
| Chuyển từ quán xuống dungeon | `SceneRouter.go_to(SceneRouter.DUNGEON, &"entrance")`. ✅ `Main` tồn tại suốt game; `SceneRouter` chỉ thay level trong `Main/LevelRoot` |
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
- ✅ Đã đăng ký ở mốc A1: `[internationalization] locale/translations` trỏ tới `translations.en.translation` và `translations.vi.translation`. Hai file này do Godot sinh khi import CSV và **được commit** cùng `translations.csv.import`.
- Ngôn ngữ khi chạy theo ngôn ngữ hệ điều hành; không có bản dịch thì dùng `en`. Bản debug có phím chuyển EN/VI (xem DECISION_LOG.md).
- Chuỗi có tham số dùng khóa định dạng, ví dụ `UI_PROMPT_FORMAT` = `[%s] %s` (phím, hành động).
- Font phải hiển thị đủ ký tự tiếng Việt (ASSET_GUIDELINES.md mục 4.3). Chuỗi tiếng Việt thường dài hơn tiếng Anh, nên UI không đặt chiều rộng cứng sát chữ.
- Chuỗi debug/log (`print`, `push_error`) không cần dịch.
- Chưa làm ở giai đoạn này: dịch toàn bộ nội dung, menu chọn ngôn ngữ (Vertical Slice).

## 6. Hệ thống lưu/tải

> ✅ **ĐÃ CHỐT:** JSON, có `save_version`, ghi file tạm trước rồi mới thay thế file save chính.

- **Định dạng:** JSON, ghi vào `user://saves/slot_<n>.json`.
- **Lý do không dùng `ResourceSaver`/`.tres` cho save:** file `.tres` có thể chứa script nhúng, và việc load một file save do người khác chia sẻ có thể thực thi code. JSON an toàn hơn, dễ đọc khi debug và dễ migrate.
- **Cấu trúc (đã làm ở D1, `scripts/save/save_manager.gd`):**
  ```json
  {
    "save_version": 1,
    "game_version": "0.1.0",
    "timestamp": "2026-11-28T10:00:00",
    "game_state": {
      "day": 2, "gold": 15, "equipped_weapon": "rusty_pickaxe",
      "stash": [ { "id": "cave_mushroom", "count": 3 } ],
      "customer_served_day": { "weary_traveler": 2 }
    }
  }
  ```
- Save cũ (trước VS-A) có trường `"settings": { "locale": ... }`: chỉ được đọc một lần để chuyển ngôn ngữ sang `settings.cfg`, file save không bị sửa.
- Chỉ tự lưu khi đang ở quán (`EventBus.autosave_requested`: về từ mỏ, sau khi giao món). Không lưu túi và vị trí player.
- File không đọc được (JSON sai, rỗng, thiếu trường, `save_version` khác) được đổi tên thành `slot_1.json.bak`; menu hiện một dòng lỗi (`SaveManager.last_error_key`).
- Mỗi hệ thống cần lưu có cặp hàm `to_dict() -> Dictionary` và `from_dict(data: Dictionary) -> void`.
- `save_version` tăng mỗi khi cấu trúc thay đổi; `SaveManager` có hàm migrate từ phiên bản cũ.
- Ghi an toàn: ghi vào file tạm `.tmp` trước, xong mới đổi tên đè lên file cũ, để tránh hỏng save khi game crash giữa chừng. Hành vi đổi tên đè file trên Windows: `DirAccess.rename_absolute` đè file đích; test headless chạy trên Linux, cần chủ dự án xác nhận trên Windows khi chơi thử.

## 6.1 Cài đặt người chơi (✅ VS-A, 2026-11-28)

- File riêng `user://settings.cfg` (ConfigFile), không nằm trong save ván chơi. Chơi mới không đổi cài đặt.
- Nội dung: ngôn ngữ, âm lượng 3 bus (Master/Music/SFX, tuyến tính 0..1, 0 = tắt), toàn màn hình, phím đã đổi của 8 action gameplay (`pause` cố định).
- Lớp dữ liệu `GameSettings` (`scripts/save/game_settings.gd`, RefCounted); `SaveManager` đọc/ghi và áp dụng (`load_settings`, `set_locale`, `set_volume`, `set_fullscreen`, `rebind_action`, `reset_key_bindings`). Không thêm autoload.
- File hỏng hoặc giá trị sai: dùng mặc định cho phần sai, không crash.
- Toàn màn hình dùng `Window.MODE_FULLSCREEN`; integer scaling giữ nguyên (1080p → 3×, 1366×768 → 2× có viền).

## 6.2 Âm thanh (✅ VS-A)

- Bus: Master → Music, SFX (`default_bus_layout.tres`).
- Node `Audio` (`AudioDirector`, `scenes/main/audio_director.gd`) trong `Main`, `PROCESS_MODE_ALWAYS`, 8 `AudioStreamPlayer` trên bus SFX.
- Hệ thống phát âm bằng `EventBus.sfx_requested.emit(&"<id>")`; mọi `BaseButton` tự phát `ui_click`.
- Bảng id → file: `SfxLibrary` (`data/audio/sfx_library.tres`). Thay âm thật chỉ cần đổi file trong bảng, không sửa code. Id lạ chỉ cảnh báo một lần.

## 6.3 Theme UI (✅ VS-A)

- `resources/ui/main_theme.tres` gán toàn project qua `gui/theme/custom`. Font chính `fnt_main.tres` (Galmuri11, 12 px), HUD `fnt_hud.tres` (Galmuri9, 10 px), `spacing_top` chừa chỗ dấu chữ hoa.
- UI dùng `theme_type_variation` (HudLabel, HudGoldLabel, TitleLabel, ErrorLabel, SlotCountLabel, CompactButton), không dùng LabelSettings hay `font_size` riêng.
- Chỉ dùng cỡ gốc của font (hoặc bội nguyên), không phóng lẻ.

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
| `dodge` | Space | Cơ chế né ở mốc B4 (MVP) |
| `inventory` | Tab, I | |
| `pause` | Escape | Menu tạm dừng tối thiểu ở mốc D2 |

Đọc hướng di chuyển bằng `Input.get_vector(&"movement_left", &"movement_right", &"movement_up", &"movement_down")`. Code chỉ dùng tên action, không đọc phím trực tiếp. Tay cầm: thêm sau MVP.

**Rủi ro đã biết (chưa xử lý):** Tab trùng action mặc định `ui_focus_next`. Khi một `Control` đang có focus, Tab sẽ chuyển focus thay vì mở inventory. Phải xử lý khi làm UI inventory (mốc 1.6), ví dụ đặt `focus_mode` phù hợp hoặc xử lý `inventory` trong `_unhandled_input`/`_input` trước UI. Theo dõi ở BUG_TRACKER.md (TECH-006).

## 9. Cấu hình project hiện tại (đã kiểm tra)

| Thiết lập | Giá trị | Nhận xét |
|---|---|---|
| Viewport | 640×360 | Tốt cho pixel art, scale đúng tỉ lệ 2× lên 1280×720, 3× lên 1920×1080 |
| Window override | 1280×720 | Hợp lý khi phát triển |
| Stretch mode | `canvas_items` | Giữ nguyên |
| Stretch aspect | mặc định `keep` | Giữ tỉ lệ 16:9 |
| Scale mode | `integer` | ✅ Áp dụng ở mốc 1.1 (TECH-003) |
| Cảnh báo `untyped_declaration` | 1 = Warn | ✅ Áp dụng ở mốc 1.1; xem lại cuối Giai đoạn 1 có nâng lên Error không |
| Main scene | `res://scenes/main/main.tscn` | ✅ Mốc 1.1 |
| Default texture filter | Nearest (0) | Đúng cho pixel art |
| Renderer | GL Compatibility | Phù hợp game 2D, chạy được trên máy yếu |
| `rendering_device/driver.windows` | d3d12 | Chỉ có tác dụng với renderer Forward+/Mobile; hiện không ảnh hưởng |
| 3D physics | Jolt | Không ảnh hưởng game 2D |

**TECH-003 — integer scaling (✅ đã áp dụng ở mốc 1.1).** Tên setting đã đối chiếu với tài liệu `ProjectSettings` của Godot 4.7.2:

```ini
[display]
window/stretch/mode="canvas_items"   ; giữ nguyên
window/stretch/aspect="keep"         ; giữ tỉ lệ 16:9, mặc định của Godot nên không cần ghi
window/stretch/scale_mode="integer"  ; MỚI: chỉ phóng to theo bội số nguyên
```

- Với `scale_mode = integer`, Godot làm tròn xuống hệ số phóng to gần nhất và thêm viền đen phần dư: 1280×720 → 2×, 1920×1080 → 3×, 2560×1440 → 4×, 3840×2160 → 6×. Màn 1366×768 → 2× (viền đen quanh 1280×720).
- Lý do: mỗi pixel nghệ thuật luôn hiện bằng đúng N×N pixel màn hình, không có pixel to nhỏ không đều.
- `rendering/2d/snap/snap_2d_transforms_to_pixel`: chưa bật. Đã thử ở mốc 1.2 và qua các lần chơi thử đến 2026-11-28, không thấy rung hình.
- Cân nhắc `stretch/mode = "viewport"` nếu muốn mọi thứ, kể cả UI và chuyển động, khớp lưới pixel tuyệt đối. Đánh đổi là chữ UI và chuyển động camera kém mượt hơn. Nên thử cả hai ở MVP rồi mới chốt.
- ✅ Đã bật cảnh báo `debug/gdscript/warnings/untyped_declaration = 1` (Warn).

## 9.1 Quy ước scene 2D (từ mốc 1.2)

- **Gốc tọa độ ở chân** cho mọi thực thể đứng trên sàn (player, quái, NPC, đồ vật). Sprite dùng `offset` để đáy hình nằm ở gốc. Nhờ vậy y-sort đúng.
- Thực thể nằm trong node `Entities` (`Node2D`, `y_sort_enabled = true`) của phòng. Tile sàn và tường nằm ở các `TileMapLayer` riêng, ngoài `Entities`.
- Va chạm của thực thể chỉ ở phần chân/đế (top-down 3/4): player dùng `CircleShape2D` bán kính 5 px, chướng ngại dùng hình chữ nhật ở đáy.
- Chướng ngại vật trong phòng là scene `StaticBody2D` riêng (layer 1, mask trống), không vẽ bằng tile, để y-sort cùng player.
- **Camera:** `Camera2D` nằm trong Player. Phòng (cha) gọi `player.set_camera_limits(rect)` với khung phòng **tính bằng pixel**. `TileMapLayer.get_used_rect()` trả về tọa độ tile, phải nhân `tile_set.tile_size` trước khi truyền.
- TileSet placeholder: `resources/tilesets/tavern_placeholder_tileset.tres`, tile 16×16, physics layer 0 = layer 1 `World`.
- **Level (từ A3):** mọi scene phòng chơi được gắn script kế thừa `Level` (`scripts/core/level.gd`). Một tầng kế thừa duy nhất, chỉ chứa phần chung: giới hạn camera và `place_player(spawn_id)`. Phòng phải có `%Floor`, `%Player`, `%Spawns` (các `Marker2D`, luôn có `default`). Level tự chứa instance Player của mình.
- Đồ vật nằm sát sàn (nắp hầm, thang) đặt trong `FloorProps`, vẽ dưới `Entities`.

## 10. Kiểm thử

- **Kiểm tra headless** (không cần mở editor):
  ```
  "D:/Godot_v4.7.2/Godot_v4.7.2-stable_win64_console.exe" --headless --path . --import
  ```
  Lệnh này import toàn bộ project và báo lỗi parse script. Chạy từ thư mục `the-last-hearth/`.
- **Test headless (từ CP-B):** `godot --headless --path . -s res://tests/run_all.gd`. Bộ chạy tự viết, không addon: tìm mọi `tests/test_*.gd`, chạy các hàm `test_*`, in PASS/FAIL, mã thoát 1 khi có lỗi. Base `tests/test_case.gd` có `check`, `check_eq`, `wait`, `start_main`, `tap`, `hold`. Test có thể khởi động `Main` thật và giả lập input. Addon GUT chưa cài.
- Bộ chạy đánh trượt test có `ERROR` của engine; test cố ý gây lỗi (ví dụ file cài đặt hỏng) khai báo chuỗi lỗi được phép trong `allowed_errors`.
- `physics/common/physics_interpolation` bật từ VSA5: dịch chuyển tức thời (spawn, vào level, hồi sinh) phải gọi `reset_physics_interpolation()`; camera player chạy ở chế độ physics.
- **Scene test:** mỗi scene thực thể phải chạy được độc lập bằng F6.

## 11. Hiệu năng (mục tiêu)

- 60 FPS ổn định trên máy tầm thấp (GPU tích hợp).
- Dùng `TileMapLayer` (không dùng node `TileMap` đã deprecated).
- Pool đối tượng cho đạn/hiệu ứng nếu số lượng lớn (chỉ làm khi đo thấy cần).

## 12. Lịch sử thay đổi

| Ngày | Phiên bản | Nội dung |
|---|---|---|
| 2026-11-28 | 0.6 | VS-A: mục 6.1 cài đặt, 6.2 âm thanh, 6.3 theme; bỏ `settings` khỏi save; `allowed_errors`, physics interpolation |
| 2026-11-27 | 0.1 | Bản khởi tạo |
| 2026-11-27 | 0.5 | Thêm mục 9.1 Quy ước scene 2D (mốc 1.2) |
| 2026-11-27 | 0.4 | Mốc 1.1: autoload đã đăng ký, integer scaling, cảnh báo untyped, main scene |
| 2026-11-27 | 0.3 | Chốt collision layers (6 layer, hitbox dò hurtbox) và Input Map (9 action, thêm `pause`); ghi rủi ro Tab |
| 2026-11-27 | 0.2 | Chốt nguyên tắc kiến trúc, 4 autoload, Resource + ID, save JSON, static typing; thêm mục 5.1 Localization; đề xuất collision 6 layer, input `movement_*`, cấu hình TECH-003 |
