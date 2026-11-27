# Changelog — THE LAST HEARTH

Ghi các thay đổi theo mốc phát triển. Mới nhất ở trên. Định dạng dựa trên [Keep a Changelog](https://keepachangelog.com/).

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

## [0.0] — Giai đoạn 0: Khởi tạo nền tảng (2026-11-27)

- Cấu trúc thư mục, bộ tài liệu trong `the-last-hearth/docs/`, `CLAUDE.md`.
- Commit `docs: finalize phase 0 project foundation`.
