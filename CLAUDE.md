# CLAUDE.md — THE LAST HEARTH

Hướng dẫn cho Claude Code. **Đọc toàn bộ file này trước mỗi nhiệm vụ phát triển.**

## 1. Tổng quan

THE LAST HEARTH là game indie thương mại cho PC/Steam: Dark Fantasy · Tavern Management · Action Roguelite · Dungeon Crawler. 2D pixel art, top-down, single-player. Người chơi vận hành quán trọ cuối cùng trong vùng đất bị nguyền và xuống dungeon tìm tài nguyên cho quán. Hai nửa game phải phụ thuộc nhau thật sự.

Tài liệu gốc nằm ở `the-last-hearth/docs/`:
- `GAME_DESIGN_DOCUMENT.md`: tầm nhìn, cốt truyện, vòng chơi
- `GAMEPLAY_SYSTEMS.md`: chi tiết từng hệ thống và liên kết
- `TECHNICAL_ARCHITECTURE.md`: kiến trúc, autoload, data, save, layers, input
- `MVP_SPECIFICATION.md`: phạm vi và tiêu chí chấp nhận của MVP
- `ART_BIBLE.md` · `ASSET_GUIDELINES.md`: chuẩn đồ họa và asset
- `DEVELOPMENT_ROADMAP.md`: giai đoạn phát triển
- `BUG_TRACKER.md`: lỗi và nợ kỹ thuật

## 2. Ngôn ngữ giao tiếp

- Trao đổi, giải thích, lập kế hoạch, báo cáo và tài liệu: **tiếng Việt**.
- Tên biến, hàm, class, file, signal, commit message: **tiếng Anh**.
- Comment trong code: tiếng Anh, ngắn gọn; chỉ comment khi giải thích *vì sao*, không giải thích *cái gì*.

## 3. Công nghệ

- **Godot 4.7.2 stable**, renderer **GL Compatibility**, ngôn ngữ **GDScript**
- Editor/CLI: `D:/Godot_v4.7.2/Godot_v4.7.2-stable_win64.exe`
- Bản console (dùng cho headless): `D:/Godot_v4.7.2/Godot_v4.7.2-stable_win64_console.exe`
- Viewport 640×360, texture filter Nearest, stretch `canvas_items`
- Git + GitHub: `origin` = `github.com/Nahidacute2710/TheLastHearth`, nhánh chính `main`
- Chưa cài addon nào. Không có MCP nào được kết nối với Godot. **Không giả định** có công cụ nào chưa được xác nhận.

## 4. Cấu trúc repo

```
TheLastHearth/                 ← gốc repo Git (file này ở đây)
├── CLAUDE.md
├── .gitignore
└── the-last-hearth/           ← PROJECT GODOT (res://), chứa project.godot
    ├── assets/  characters enemies environments tilesets items ui effects audio/{music,sfx} fonts
    ├── scenes/  main tavern dungeon characters enemies ui interactions
    ├── scripts/ core components data player combat enemies tavern inventory crafting quests dialogue economy save
    ├── data/    characters enemies items recipes quests dialogues   (.tres instances)
    ├── resources/ shaders/ localization/ tests/
    └── docs/    (có .gdignore)
```

- Mọi đường dẫn `res://` tính từ `the-last-hearth/`.
- Script riêng của một scene đặt **cạnh** file `.tscn`. Script tái sử dụng đặt trong `scripts/`.
- Class Resource (định nghĩa) ở `scripts/data/`; instance `.tres` ở `data/`.
- Thư mục rỗng có `.gitkeep`. Có thể xóa `.gitkeep` khi thư mục đã có file thật.

## 5. Quy tắc GDScript

- **Static typing bắt buộc:** `var speed: float = 80.0`, `func take_damage(amount: int) -> void:`. Dùng `:=` khi kiểu đã rõ ràng.
- Theo [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html): tab để thụt lề; `snake_case` cho biến/hàm/file; `PascalCase` cho `class_name` và node; `CONSTANT_CASE` cho hằng số; signal ở thì quá khứ (`died`, `item_added`).
- Thứ tự trong file: `class_name` → `extends` → doc comment → signals → enums → constants → `@export` → biến public → biến `_private` → `@onready` → `_init/_ready/_process` → hàm public → hàm `_private`.
- Thành viên private bắt đầu bằng `_`.
- Dùng `@export` cho mọi thông số cần chỉnh; không hard-code số cân bằng game, đặt chúng trong Resource ở `data/`.
- Tham chiếu node con bằng `@onready var x: Node = $X` hoặc `%UniqueName`. **Không** dùng `get_node("/root/...")` hay đường dẫn dài qua nhiều cấp.
- Một script một trách nhiệm. Script dài hơn khoảng 300 dòng là dấu hiệu cần tách.
- Dùng `TileMapLayer`, không dùng `TileMap` (deprecated).
- Không dùng `await` trong `_process`/`_physics_process`.
- Xử lý lỗi rõ ràng: `push_error()` / `push_warning()` khi dữ liệu sai, không âm thầm bỏ qua.
- **Không viết cứng văn bản hiển thị** cho người chơi trong script: dùng khóa dịch (`tr()`), file `localization/translations.csv`. Xem `TECHNICAL_ARCHITECTURE.md` mục 5.1.

## 6. Quy tắc kiến trúc

Các quy tắc dưới đây đã được chủ dự án chốt (2026-11-27).

- **Call down, signal up.** Cha gọi con; con phát signal. Hệ thống ngang hàng giao tiếp qua `EventBus`.
- **Composition:** hành vi dùng chung là component node (`HealthComponent`, `HitboxComponent`, `HurtboxComponent`, `Interactable`).
- **Autoload chỉ gồm:** `EventBus`, `GameState`, `SaveManager`, `SceneRouter`. Thêm autoload mới phải giải thích lý do và được duyệt.
- `EventBus` chỉ khai báo signal, không có logic.
- Chỉ số và dữ liệu định nghĩa game dùng Resource `.tres` ở `data/`, tham chiếu bằng `id: StringName` cố định; save chỉ lưu `id`.
- Save dùng **JSON** trong `user://saves/`, có `save_version`. **Không** load `.tres`/`.res` từ `user://` (nguy cơ thực thi code). Ghi vào file tạm trước rồi mới thay thế file save chính.
- Logic thuần (inventory, recipe, save serialize) không phụ thuộc vào node, để test được.
- Mỗi scene thực thể phải chạy được độc lập (F6).
- Localization tiếng Anh + tiếng Việt thiết kế ngay từ kiến trúc dữ liệu (Resource lưu khóa dịch, không lưu chuỗi).
- Collision layers và input actions theo bảng trong `TECHNICAL_ARCHITECTURE.md` mục 7 và 8 (đã chốt 2026-11-27).

## 7. Quy tắc asset

- Tên file `snake_case`, chỉ ASCII, có tiền tố theo loại (`chr_`, `enm_`, `tls_`, `itm_`, `ui_`, `vfx_`, `sfx_`, `mus_`). Chi tiết xem `ASSET_GUIDELINES.md`.
- **Không tạo asset giả rồi tuyên bố là hoàn thiện.** Asset tạm phải có hậu tố `_placeholder`, và báo cáo phải nói rõ đó là placeholder.
- Không thêm asset bên thứ ba khi chưa ghi nguồn và giấy phép vào `assets/CREDITS.md`. Chỉ dùng giấy phép cho phép thương mại.
- File nguồn art (`.aseprite`, `.psd`, `.kra`) lưu **ngoài** `res://` (ngoài thư mục `the-last-hearth/`).
- Commit cả file `.import`. Không commit `.godot/`.
- Git LFS: chưa dùng. Điều kiện xem xét lại ở `ASSET_GUIDELINES.md` mục 7.
- Đổi tên/di chuyển asset hoặc scene nên làm trong Godot Editor. Nếu Claude phải di chuyển file bằng terminal thì phải cảnh báo người dùng và kiểm tra lại tham chiếu/UID.

## 8. Quy trình kiểm thử

Chạy từ thư mục `the-last-hearth/`:

```bash
# Import + parse toàn bộ project, phát hiện lỗi script (không mở cửa sổ)
"D:/Godot_v4.7.2/Godot_v4.7.2-stable_win64_console.exe" --headless --path . --import

# Chạy project headless vài frame rồi thoát (khi đã có main scene)
"D:/Godot_v4.7.2/Godot_v4.7.2-stable_win64_console.exe" --headless --path . --quit-after 120
```

```bash
# Chạy toàn bộ test headless (không dùng addon). Mã thoát khác 0 khi có test fail
"D:/Godot_v4.7.2/Godot_v4.7.2-stable_win64_console.exe" --headless --path . -s res://tests/run_all.gd
```

PowerShell (từ `the-last-hearth/`): `& "D:\Godot_v4.7.2\Godot_v4.7.2-stable_win64_console.exe" --headless --path . -s res://tests/run_all.gd`

- **Sau MỖI mốc:** chạy `--import`, `--quit-after 120` và `run_all.gd`; đọc output tìm `ERROR` / `SCRIPT ERROR` / `Parse Error` / `WARNING` / `FAIL`.
- Mỗi mốc mới phải thêm test cho phần logic kiểm tra được.
- **Quy tắc từ BUG-001 (chủ dự án chốt 2026-11-28):** mọi test làm thay đổi trạng thái game (ngày, vàng, túi, kho, máu, buff, vũ khí, save/load, chơi mới...) phải kiểm tra **cả HUD/UI hiển thị đúng**, không chỉ kiểm tra dữ liệu trong bộ nhớ. Lý do: BUG-001 có dữ liệu và file save đúng nhưng HUD sai, test chỉ kiểm tra dữ liệu nên không bắt được.
- `run_all.gd` đánh trượt test có `ERROR` / `SCRIPT ERROR` (TECH-009). Lỗi cố ý trong test phải tránh hoặc dùng API không in lỗi.
- Test không được đụng save thật: `test_case.gd` đặt `SaveManager.save_dir` về `user://test_saves/`.
- Test viết ở `tests/test_<đối tượng>.gd`, kế thừa `res://tests/test_case.gd`, mỗi hàm test tên `test_*`. Trong test, truy cập autoload qua `tree.root.get_node("SceneRouter")` (hàm `router()`), không dùng tên autoload trực tiếp.
- Unit test: bộ chạy tự viết `tests/run_all.gd` (không addon). GUT chưa cài; cài phải được duyệt.
- Những gì không kiểm chứng được qua headless (cảm giác điều khiển, hiển thị, animation) phải ghi rõ trong báo cáo là **"cần kiểm tra thủ công trong editor"**.
- **Không bao giờ tuyên bố đã test thành công nếu chưa thực sự chạy.** Báo cáo trung thực cả output lỗi.

## 9. Quy tắc Git

- Chỉ commit/push khi người dùng yêu cầu.
- Commit nhỏ, một mục đích. Message tiếng Anh theo Conventional Commits:
  `feat(combat): add hurtbox component` · `fix(save): handle missing save file` · `docs: update GDD` · `chore: ...` · `refactor: ...` · `test: ...`
- Tính năng lớn làm trên nhánh `feature/<tên>`, merge vào `main` khi đã kiểm thử.
- Tag cuối mỗi giai đoạn theo `DEVELOPMENT_ROADMAP.md`.
- Không force push, không rewrite lịch sử `main`, không commit secret hay file trong `.godot/`.

## 10. KHÔNG được tự ý làm (phải hỏi trước)

- Sửa `project.godot` (renderer, stretch mode, viewport, autoload, input map, layers) mà không giải thích và được duyệt
- Xóa hoặc đổi tên file/thư mục hiện có
- Thay đổi cấu trúc thư mục ở mục 4
- Cài addon/plugin, thêm dependency
- Thêm tính năng ngoài phạm vi giai đoạn hiện tại (xem mục 12)
- Thay đổi quyết định thiết kế đã chốt trong GDD
- Đổi định dạng save hoặc tăng `save_version` mà không có migration
- Sửa `.gitignore`, `.gitattributes`

Trước mọi thay đổi lớn (nhiều file, kiến trúc mới): **trình bày kế hoạch và chờ xác nhận.**

**Quy trình checkpoint (từ 2026-11-27):** làm lần lượt các mốc trong checkpoint, mỗi mốc 1 commit, không chờ duyệt giữa các mốc. Sau mỗi mốc: kiểm tra tĩnh + headless, cập nhật tài liệu, ghi quyết định nhỏ vào `docs/DECISION_LOG.md`, push (chỉ fast-forward). Được tự quyết tên node, cấu trúc scene, thông số khởi đầu (🧪), placeholder, UI tạm; được sửa `project.godot` khi thuộc checkpoint nhưng phải ghi trong báo cáo. Được thêm phím debug chỉ hoạt động khi `OS.is_debug_build()`.

**Chỉ dừng giữa checkpoint khi:** (1) cần đổi kiến trúc đã chốt hoặc làm khác GDD/MVP_SPECIFICATION; (2) cần addon/dependency; (3) cần xóa file không phải placeholder hoặc viết lại hệ thống đã có; (4) headless lỗi mà sửa 2 lần không được; (5) quyết định thiết kế ảnh hưởng cảm giác chơi mà tài liệu chưa nói tới.

**Cuối checkpoint báo cáo:** commit (hash + message), trích DECISION_LOG, lệnh headless PowerShell (có `&` ở đầu), một danh sách chơi thử ≤ 10 bước, rủi ro và thông số 🧪. Rồi dừng chờ kết quả.

## 11. Cập nhật tài liệu

- Code thay đổi kiến trúc → cập nhật `TECHNICAL_ARCHITECTURE.md`.
- Thêm/sửa hệ thống gameplay → cập nhật `GAMEPLAY_SYSTEMS.md` (và GDD nếu ảnh hưởng tầm nhìn).
- Hoàn thành mốc → tick checklist trong `DEVELOPMENT_ROADMAP.md` và thêm mục vào `CHANGELOG.md`.
- Quyết định nhỏ tự chốt → `the-last-hearth/docs/DECISION_LOG.md` (ngày, mốc, quyết định, lý do).
- Phát hiện lỗi chưa sửa ngay → ghi vào `BUG_TRACKER.md`.
- Mỗi tài liệu có bảng "Lịch sử thay đổi" ở cuối: thêm dòng khi sửa nội dung đáng kể.
- Nhãn trạng thái: **✅ ĐÃ CHỐT** · **ĐỀ XUẤT** · **🧪 CẦN THỬ NGHIỆM** · **❓** câu hỏi mở.
- Mục đánh dấu ❓ là chưa chốt; chỉ bỏ dấu ❓ hoặc gắn ✅ khi chủ dự án xác nhận.
- Cập nhật mục 12 của file này khi chuyển giai đoạn.

## 12. Giai đoạn hiện tại

**Giai đoạn 0 — Khởi tạo nền tảng: ✅ HOÀN THÀNH** (2026-11-27), commit `docs: finalize phase 0 project foundation`.

**Giai đoạn 1 — MVP, mốc 1.1 (cấu hình project): ✅ HOÀN THÀNH** (2026-11-27, headless và editor đã kiểm tra). Đã có: 9 input action, 6 collision layer, 4 autoload rỗng, `scenes/main/main.tscn` làm main scene, integer scaling, cảnh báo `untyped_declaration` = Warn. Chưa có gameplay.

**Mốc 1.2 (player di chuyển trong phòng quán graybox): ✅ HOÀN THÀNH** (2026-11-27, không rung hình nên chưa cần `snap_2d_transforms_to_pixel`).

**CP-A (mốc 1.3 + 1.4): ✅ HOÀN THÀNH** (2026-11-27).

**CP-B (mốc 1.5): ✅ HOÀN THÀNH** (B1–B4: component combat, Cuốc Chim, Thợ Mỏ Rỗng, máu player, né, chết → về quán; đã chơi thử 2026-11-28).

**CP-C (mốc 1.6 + 1.7): ✅ HOÀN THÀNH** (C1–C5: túi và kho quán, luật chết, Nấm Hang, panel túi đồ, bếp và Súp Nấm, Lữ Khách, vàng và ngày; đã chơi thử 2026-11-28).

**CP-D (mốc 1.8 + 1.9): ✅ HOÀN THÀNH** (2026-11-28): D1 save JSON, D2 menu chính và menu tạm dừng (đã chơi thử), D3 buff Súp Nấm, lưu khi tắt bằng nút X, test trọn vòng (có test, chờ chơi thử).

**Giai đoạn 1 — MVP: ✅ HOÀN THÀNH** (2026-11-28). Nhìn lại ở `the-last-hearth/docs/PHASE1_RETROSPECTIVE.md`.

**Giai đoạn 2 — Vertical Slice: đang làm.** Phạm vi, thứ tự checkpoint và quyết định đã duyệt 2026-11-28 (`the-last-hearth/docs/VERTICAL_SLICE_PLAN.md` mục 9). **VS-A ✅ HOÀN THÀNH** (2026-11-28, VSA1–VSA6, chờ chơi thử): Galmuri11/Galmuri9 + theme chung, `user://settings.cfg`, menu cài đặt, bus âm thanh + SFX tạm, physics interpolation. **Tiếp theo: lập kế hoạch VS-E1, chờ chủ dự án.** Nhân vật chính: `the-last-hearth/docs/STORY_BIBLE.md`. API key (PixelLab...) chỉ ở biến môi trường, không bao giờ commit.

**Ghi chú kiến trúc VS-A:** cài đặt (ngôn ngữ, âm lượng, phím, toàn màn hình) nằm trong `GameSettings` (`scripts/save/game_settings.gd`), do `SaveManager` đọc/ghi ở `user://settings.cfg`, tách khỏi save ván chơi. Âm thanh: node `Audio` (`AudioDirector`) trong `Main`, phát theo id qua `EventBus.sfx_requested`; id → file ở `data/audio/sfx_library.tres`. Mọi UI lấy font/màu từ `resources/ui/main_theme.tres` (gán qua `gui/theme/custom`), dùng `theme_type_variation` thay vì LabelSettings. Test cố ý gây ERROR của engine phải khai báo `allowed_errors`. Dịch chuyển tức thời phải gọi `reset_physics_interpolation()`.

**Kiểm tra headless phía Claude:** dùng bản Godot 4.7.2 Linux chính thức trên bản sao repo ở cloud (chủ dự án cho phép 2026-11-27).

Lịch sử thay đổi theo mốc ghi ở `CHANGELOG.md` (gốc repo).
