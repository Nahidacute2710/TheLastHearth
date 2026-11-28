# Changelog — THE LAST HEARTH

Ghi các thay đổi theo mốc phát triển. Mới nhất ở trên. Định dạng dựa trên [Keep a Changelog](https://keepachangelog.com/).

## [Chưa phát hành] — CP-D: Lưu/tải và menu

### Thêm
- D1: `SaveManager` (JSON, file tạm, `.bak` cho file hỏng), `ItemDB`, `to_dict()/from_dict()` của `GameState`, `Inventory.to_array()/load_array()`, tự lưu ở quán + test.

### Sửa
- D1: bếp không nấu khi kho hết chỗ cho món ("Kho đã đầy"), món không bao giờ bị mất.

## [Chưa phát hành] — CP-C: Túi đồ, nấu ăn, khách

### Thêm
- C5: `CustomerData` + Lữ Khách (mỗi ngày 1 lần, trả vàng), HUD ngày và vàng + test.
- C4: `RecipeData`, `RecipeIngredient`, `mushroom_stew` (món + công thức), bếp nấu trong quán có thanh tiến trình, `EventBus.toast_requested` + test.
- C3: `InventoryPanel` (Tab/I, Esc đóng) hiện túi và kho, tạm dừng thế giới khi mở; sửa TECH-006 + test.
- C2: `cave_mushroom.tres` + icon placeholder, `LootEntry` và `EnemyData.loot`, scene `Pickup`, 4 nấm mọc sẵn trong mỏ, HUD đếm nấm, phím debug Shift+F1..F4 + test.
- C1: `ItemStack`, `Inventory`; túi và kho trong `GameState`, cất túi khi về quán, luật chết (giữ vật phẩm quest), bộ đếm ngày, thông báo `Toast`; giá treo cuốc đọc `GameState` + test.

## [Chưa phát hành] — CP-B: Combat

### Thêm
- B4: `PlayerData` + `innkeeper.tres`, máu player, i-frames khi bị đánh, né (Space), chết → tỉnh dậy ở quán, HUD ô máu, phím debug F4/F9/F10/F11 + test.
- B3: `EnemyData`, Thợ Mỏ Rỗng (lấy đà, đòn, bị đánh, chết), 10 con trong mỏ, `EventBus.enemy_died` + test.
- B2: `ItemData`, `WeaponData`, `rusty_pickaxe.tres`, giá treo vũ khí, đòn vung theo hướng chuột, hit-stop + test.
- B1: `HealthComponent`, `HitboxComponent`, `HurtboxComponent` + test.
- Test headless: `tests/run_all.gd`, `tests/test_case.gd` và 6 test chuyển từ CP-A.

## [Chưa phát hành] — CP-A: Tương tác và chuyển cảnh

### Thêm
- `docs/DECISION_LOG.md`; kế hoạch checkpoint trong `DEVELOPMENT_ROADMAP.md`.
- A4: Mỏ Bỏ Hoang graybox 4 phòng (2×2), tileset mỏ placeholder, cột đá.
- A3: `SceneRouter` có fade, script `Level` dùng chung, `main.gd` khởi động quán, Mỏ Bỏ Hoang bản 1 phòng có thang về quán, phím debug F1–F3.
- A2: component `Interactable` + `Interactor`, `InteractionPrompt` trên `UILayer`, scene `level_door.tscn`, nắp hầm placeholder trong quán.
- A1: `localization/translations.csv` (keys, en, vi), đăng ký bản dịch trong `project.godot` (`[internationalization]`).

## [Chưa phát hành] — Mốc 1.2: Player di chuyển trong phòng quán (2026-11-27)

### Thêm
- `scenes/characters/player.tscn` + `player.gd`: `CharacterBody2D` 8 hướng, gia tốc/ma sát `@export`, collider tròn ở chân, `Camera2D` (không smoothing).
- `scenes/tavern/tavern_main_hall.tscn` + `.gd`: phòng graybox 48×30 tile, `Floor` và `Walls` (`TileMapLayer`), `Entities` y-sort, truyền giới hạn camera (pixel) xuống player.
- `scenes/tavern/tavern_obstacle_placeholder.tscn`: chướng ngại `StaticBody2D`, dùng 3 lần.
- Placeholder: `chr_innkeeper_placeholder.png`, `tls_tavern_placeholder.png`, `env_obstacle_placeholder.png`; TileSet `resources/tilesets/tavern_placeholder_tileset.tres`.

### Thay đổi
- `scenes/main/main.tscn`: instance tạm phòng quán trong `LevelRoot` (đến mốc 1.4).

## [Chưa phát hành] — Mốc 1.1: Cấu hình project (2026-11-27)

### Thêm
- Input Map: `movement_up/down/left/right` (W/S/A/D, physical key), `interact` (E), `attack` (chuột trái), `dodge` (Space), `inventory` (Tab, I), `pause` (Escape).
- Tên 2D physics layer: 1 `World`, 2 `Player`, 3 `Enemy`, 4 `PlayerHurtbox`, 5 `EnemyHurtbox`, 6 `Interactable`.
- 4 autoload rỗng: `EventBus`, `GameState`, `SaveManager`, `SceneRouter`.
- `scenes/main/main.tscn` (`Main` → `LevelRoot`, `UILayer`) làm main scene.
- `CHANGELOG.md`.
- File `.gd.uid` do Godot 4.7 sinh cho mỗi script (được commit, không ignore).

### Thay đổi
- `display/window/stretch/scale_mode = "integer"` (TECH-003).
- `debug/gdscript/warnings/untyped_declaration = 1` (Warn).
- Gộp `.gitignore` về gốc repo, xóa `the-last-hearth/.gitignore` (TECH-002); bỏ ignore `export_presets.cfg` (TECH-001).

## Bảo trì

- `chore: normalize line endings`: thêm `.gitattributes` ở gốc repo (TECH-007).

## [0.0] — Giai đoạn 0: Khởi tạo nền tảng (2026-11-27)

- Cấu trúc thư mục, bộ tài liệu trong `the-last-hearth/docs/`, `CLAUDE.md`.
- Commit `docs: finalize phase 0 project foundation`.
