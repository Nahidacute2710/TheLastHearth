# THE LAST HEARTH — Kế hoạch Vertical Slice (Giai đoạn 2)

> Phiên bản: 0.2 · Cập nhật: 2026-11-28
> Trạng thái: **✅ ĐÃ DUYỆT (2026-11-28)** cho phạm vi, thứ tự checkpoint và các quyết định ở mục 9. Kế hoạch chi tiết từng checkpoint được lập và duyệt riêng trước khi làm. **VS-A (mục 10) ✅ hoàn thành 2026-11-28, chờ chơi thử.** Tiếp theo: lập kế hoạch VS-E1.
> Nguồn phạm vi: `DEVELOPMENT_ROADMAP.md` Giai đoạn 2 và `GAME_DESIGN_DOCUMENT.md`.

---

## 1. Mục tiêu

Một lát cắt nhỏ nhưng gần chất lượng phát hành, đủ để quảng bá và tìm publisher.
**Tiêu chí hoàn thành (theo roadmap):** 20–30 phút gameplay mà người chơi ngoài đội muốn chơi tiếp.

## 2. Phạm vi

| Nhóm | Phạm vi | Ghi chú |
|---|---|---|
| Art | Art final cho quán (1 tầng) và 1 khu dungeon; player có animation | Nguồn chính PixelLab, chỉnh tay (mục 4) |
| Quái | 3–4 loại quái + boss Quản Đốc Rỗng | Thợ Mỏ Rỗng giữ lại |
| Vũ khí | 2–3 vũ khí, nâng cấp né | Mỗi vũ khí một nhịp đánh khác |
| Dungeon | Ghép ngẫu nhiên từ phòng mẫu thiết kế tay; pathfinding; tầm nhìn | Phòng đầu và phòng boss cố định |
| Quán | Ngọn Lửa Gốc v1 + nâng cấp (chỗ tiêu vàng); 5–8 công thức; 3–4 loại khách | E1 và E2 tách riêng |
| Câu chuyện | Hội thoại cơ bản, 1 mạch nhiệm vụ ngắn | Nhân vật chính Maren (`STORY_BIBLE.md`) |
| Âm thanh | SFX, nhạc nền quán, mỏ, boss | Thư viện CC0 hoặc có giấy phép thương mại rõ ràng |
| UI | Pixel font hỗ trợ tiếng Việt, menu cài đặt (âm lượng, đổi phím, ngôn ngữ), dịch đầy đủ EN/VI | |
| Ngoài phạm vi | Tay cầm (để sau Vertical Slice), giới hạn số ngày | Mọi input vẫn đi qua action |

## 3. Thứ tự checkpoint (✅ ĐÃ DUYỆT)

| Thứ tự | CP | Nội dung | Chơi thử được |
|---|---|---|---|
| 1 | VS-A | Nền trình bày: pixel font, theme UI, menu cài đặt, bus âm thanh + SFX tạm, physics interpolation (TECH-008) | Vòng MVP đọc rõ chữ, có tiếng, đổi được cài đặt |
| 2 | VS-E1 | Ngọn Lửa Gốc v1 + nâng cấp quán bằng vàng + tài nguyên (4–5 cấp, đề xuất khi lập kế hoạch) | Vàng có chỗ tiêu, quán thay đổi theo cấp |
| 3 | VS-B | Mockup 1 màn hình được duyệt, rồi art thật cho player (đi, đánh, né, bị đánh, chết) và quán 1 tầng | Vòng chơi với art thật ở quán |
| 4 | VS-C | Dungeon ghép phòng mẫu, pathfinding, tầm nhìn, art mỏ, 2–3 quái mới | Mỗi chuyến một bố cục, quái không xuyên tường |
| 5 | VS-D | 2–3 vũ khí, nâng cấp né, boss Quản Đốc Rỗng | Đánh boss 2 pha |
| 6 | VS-E2 + VS-F | 5–8 công thức, 3–4 loại khách; hội thoại, mạch nhiệm vụ, nhạc, dịch đầy đủ, cân bằng, playtest 20–30 phút | Đạt tiêu chí hoàn thành |

## 4. Art (✅ ĐÃ CHỐT)

- **PixelLab qua MCP** là nguồn chính; chưa dùng Retro Diffusion.
- Mọi asset được chỉnh tay theo `ART_BIBLE.md`. Làm mockup 1 màn hình và được duyệt trước khi làm hàng loạt.
- Ghi prompt và nguồn từng asset (quy trình ở `ASSET_GUIDELINES.md` mục 5.1).
- API key chỉ ở biến môi trường; không commit, không ghi vào file cấu hình có trong git.
- **Hiện trạng 2026-11-28:** chưa có connector PixelLab trong phiên làm việc của Claude. Cần chủ dự án thêm connector trước VS-B (chưa cần cho VS-A và VS-E1).
- Steam yêu cầu khai báo nội dung tạo bằng AI trên trang cửa hàng.

## 5. Âm thanh (✅ ĐÃ CHỐT)

- SFX và nhạc từ thư viện CC0 hoặc có giấy phép thương mại rõ ràng; ghi giấy phép **từng file** trong `assets/CREDITS.md`.
- SFX cần có: vung cuốc, trúng đòn, quái lấy đà (quan trọng cho đọc đòn), né, nhặt đồ, nấu, nhận vàng, UI. Nhạc: quán, mỏ, boss.
- Kỹ thuật: bus Master / Music / SFX; âm lượng trong menu cài đặt.

## 6. Pixel font tiếng Việt

Yêu cầu: đủ chữ có dấu, kể cả dấu chồng (ầ, ẫ, ặ, ổ, ự); giấy phép cho nhúng vào game thương mại (SIL OFL 1.1 được chấp nhận). Ứng viên và màn hình thử ở mục 10.2.

## 7. Boss và chỗ tiêu vàng (✅ ĐÃ CHỐT)

- **Boss "Quản Đốc Rỗng" (Hollow Foreman):** 2 pha; 3 đòn đều có báo trước: đập đất, lao tới, gọi Thợ Mỏ Rỗng. Sang pha 2 khi máu dưới 50%.
- **Chỗ tiêu vàng:** nâng cấp quán gộp vào Ngọn Lửa Gốc. Dùng vàng + tài nguyên để "nhóm lửa" lên cấp; mỗi cấp mở một thứ. Danh sách 4–5 cấp sẽ đề xuất khi lập kế hoạch VS-E1.

## 8. Rủi ro

- Phạm vi lớn so với một người làm: giữ mỗi checkpoint chơi thử được; cắt bớt nội dung trước khi cắt chất lượng.
- Art tốn thời gian nhất; phụ thuộc connector PixelLab.
- Ghép phòng ngẫu nhiên dễ làm vỡ cân bằng: có test tự động mọi bố cục đi được từ lối vào tới phòng boss.
- Môi trường cloud của Claude không tải được từ các trang âm thanh (kenney.nl, opengameart.org, freesound.org bị chặn ngày 2026-11-28). Âm thanh thật có thể cần chủ dự án tải về hoặc mở quyền mạng.

## 9. Quyết định đã chốt (2026-11-28)

| # | Câu hỏi | Quyết định |
|---|---|---|
| 1 | Nguồn art | PixelLab qua MCP, chỉnh tay, mockup trước |
| 2 | Ngân sách | Không nêu; dùng PixelLab và thư viện miễn phí/CC0 |
| 3 | Âm thanh | Thư viện CC0 hoặc giấy phép thương mại rõ ràng |
| 4 | Thứ tự | VS-A → VS-E1 → VS-B → VS-C → VS-D → VS-E2 + VS-F |
| 5 | Dungeon | Ghép ngẫu nhiên phòng mẫu thiết kế tay; phòng đầu và boss cố định |
| 6 | Boss | Quản Đốc Rỗng, 2 pha, 3 đòn có báo trước |
| 7 | Chỗ tiêu vàng | Nâng cấp quán gộp vào Ngọn Lửa Gốc |
| 8 | Nhịp ngày | Như MVP |
| 9 | Giới hạn ngày | Không |
| 10 | Nhân vật chính | Maren (bản đầu, `STORY_BIBLE.md`) |
| 11 | TECH-008 | Bật ở VS-A, kiểm tra camera rung |
| 12 | Tag `v0.1-mvp` | Có, tại `3822f93` |
| 13 | Tay cầm | Sau Vertical Slice |

---

## 10. Kế hoạch VS-A — Nền trình bày (✅ ĐÃ DUYỆT, ĐÃ LÀM XONG 2026-11-28)

**Mục tiêu:** toàn bộ vòng MVP đọc rõ chữ bằng pixel font tiếng Việt, có theme UI chung, có tiếng, có menu cài đặt, chuyển động mượt trên màn hình tần số cao. Không thêm gameplay.

### 10.1 Các mốc

| Mốc | Nội dung | Commit dự kiến | Test |
|---|---|---|---|
| VSA0 ✅ | Màn hình thử font (`scenes/debug/font_preview.tscn`), font ứng viên trong `assets/fonts/candidates/`, `assets/CREDITS.md` | `feat(ui): font preview screen with candidate fonts` | Mọi ứng viên có đủ ký tự trong `translations.csv`; màn hình đổi font và ngôn ngữ đúng |
| VSA1 ✅ `361f7d2` | Font được chọn thành `assets/fonts/fnt_<tên>.ttf` (tắt antialiasing, hinting, subpixel); xóa ứng viên không chọn; theme chung `resources/ui/main_theme.tres` (font, cỡ, khoảng dòng đủ cho dấu chồng, màu nền/viền panel, nút); gán theme cho mọi UI | `feat(ui): pixel font and shared ui theme` | Mọi Label/Button dùng font của theme; đủ ký tự; không chữ nào tràn khỏi khung ở cả EN và VI |
| VSA2 ✅ `5175bd8` | Cài đặt lưu riêng ở `user://settings.cfg` (ConfigFile): ngôn ngữ, âm lượng 3 bus, phím đã đổi. Ngôn ngữ chuyển từ save ván chơi sang đây (save cũ vẫn đọc được, lấy ngôn ngữ cũ một lần) | `feat(settings): settings file separate from game save` | Lưu/đọc, file hỏng thì dùng mặc định, migrate ngôn ngữ từ save cũ, Chơi mới không reset cài đặt |
| VSA3 ✅ `fb23092` | Menu cài đặt mở từ menu chính và menu tạm dừng: ngôn ngữ, 3 thanh âm lượng, đổi phím cho các action gameplay (di chuyển 4 hướng, tương tác, đánh, né, túi đồ), nút "Khôi phục mặc định". Esc đóng menu cài đặt trước | `feat(ui): settings menu with volume, language, key rebinding` | Đổi phím có tác dụng ngay và sau khi mở lại; không gán trùng phím (báo lỗi); Esc đúng thứ tự; HUD và chữ cập nhật khi đổi ngôn ngữ |
| VSA4 ✅ `38b0226` | Bus âm thanh Master / Music / SFX (`default_bus_layout.tres`); node `Audio` trong `Main` nghe signal từ EventBus và phát SFX; SFX tạm cho vung cuốc, trúng đòn, quái lấy đà, né, nhặt đồ, nấu xong, nhận vàng, bấm nút UI | `feat(audio): audio buses and placeholder sfx` | Mỗi signal phát đúng âm; âm lượng 0 thì tắt; không lỗi khi thiếu file |
| VSA5 ✅ `b63dac9` | TECH-008: bật `physics/common/physics_interpolation`; gọi `reset_physics_interpolation()` khi đặt vị trí tức thời (spawn, vào level, hồi sinh) | `feat(core): enable physics interpolation` | Setting bật; player/quái đặt vị trí tức thời không bị "trượt" từ vị trí cũ |
| VSA6 ✅ | Rà toàn bộ: docs, CHANGELOG, test, danh sách chơi thử | `docs: complete vs-a` | Toàn bộ test |

### 10.2 Pixel font ứng viên (đã kiểm tra 2026-11-28)

Độ phủ được kiểm tra bằng script trên bảng mã của font: toàn bộ 134 chữ có dấu tiếng Việt (hoa và thường, kể cả đ/Đ) cùng mọi ký tự trong `translations.csv`.

| Font | Cỡ gốc | Phủ tiếng Việt | Giấy phép | Nguồn tải | Nhận xét |
|---|---|---|---|---|---|
| **Galmuri11** (Lee Minseo) | 12 px | Đủ 134/134 | SIL OFL 1.1 | npm `galmuri@2.40.3` (https://www.npmjs.com/package/galmuri), dự án https://github.com/quiple/galmuri | Dễ đọc nhất, dấu chồng tách rõ; hợp với chữ hội thoại và menu |
| **Galmuri9** (cùng họ) | 10 px | Đủ 134/134 | SIL OFL 1.1 | Như trên | Gọn hơn, hợp HUD; dấu chồng vẫn rõ ở 10 px |
| **Tiny5** (Gissio, The Tiny5 Project Authors) | 8 px | Đủ 134/134 | SIL OFL 1.1 | Google Fonts (https://fonts.google.com/specimen/Tiny5), file từ https://github.com/google/fonts/tree/main/ofl/tiny5 | Nhỏ nhất, đậm chất pixel; dấu chồng cao, cần khoảng dòng rộng; chữ thường khó đọc hơn khi đứng lâu |
| **VT323** (Peter Hull) | 16 px trở lên | Đủ 134/134 | SIL OFL 1.1 | Google Fonts (https://fonts.google.com/specimen/VT323), file từ https://github.com/google/fonts/tree/main/ofl/vt323 | Kiểu màn hình terminal cũ, hẹp và cao. **Lỗi khi hiển thị trong Godot ở 16 px:** chữ hoa Ơ, Ư mất móc ("CỬA" đọc thành "CỦA", "ƯỚT" thành "UỚT"). Không đề xuất |

Đã loại vì thiếu chữ tiếng Việt (thiếu ơ, ư hoặc các chữ có dấu nặng/hỏi): Pixelify Sans, Silkscreen, Press Start 2P, Jersey 10, Micro 5, Bytesized, Doto, Sixtyfour, DotGothic16, Galmuri14. Handjet đủ chữ nhưng là font biến thể nét co giãn, không bám lưới pixel nên không đề xuất.

Galmuri11 và Galmuri9 được cắt bớt (subset) chỉ còn chữ Latin, tiếng Việt và dấu câu (bản gốc 5 MB vì có cả chữ Hàn); OFL cho phép sửa đổi và font không khai báo Reserved Font Name.

**Phát hiện khi chụp màn hình trong Godot:** dấu trên chữ hoa (Ầ, Ổ, Ữ) cao hơn phần ascent của font, nên khung chữ phải có khoảng dòng và lề trên rộng hơn 3–4 px, nếu không dấu bị cắt khi nằm sát mép khung cuộn hoặc chạm dòng trên. Theme ở VSA1 sẽ tính phần này.

**Gợi ý của Claude:** Galmuri11 cho chữ chính, Galmuri9 cho HUD (cùng họ nên đồng bộ). Chủ dự án chọn bằng mắt ở màn hình thử.

### 10.3 Cách xem màn hình thử font

- Trong editor: mở `scenes/debug/font_preview.tscn`, bấm **F6**.
- Hoặc PowerShell:
  `& "D:\Godot_v4.7.2\Godot_v4.7.2-stable_win64.exe" --path "D:\Godot_v4.7.2\TheLastHearth\the-last-hearth" res://scenes/debug/font_preview.tscn`
- Phím: **← / →** đổi font, **Enter** đổi EN/VI, **↑ / ↓** cuộn, **Esc** thoát. Chữ được vẽ ở đúng độ phân giải game 640×360, phóng nguyên lần như khi chơi.

### 10.4 Danh sách chơi thử cuối VS-A (bản dự kiến; bản cuối ở báo cáo VS-A)

1. Menu chính, HUD, túi đồ, menu tạm dừng: mọi chữ dùng pixel font mới, dấu tiếng Việt không bị cắt hay đè dòng trên.
2. Menu cài đặt: đổi ngôn ngữ, toàn bộ chữ đổi ngay (kể cả HUD đang mở).
3. Kéo âm lượng SFX về 0 rồi vung cuốc: không có tiếng; kéo lên: có tiếng. Tương tự cho Master.
4. Đổi phím né sang phím khác, chơi thử, thoát game, mở lại: phím mới vẫn còn. Thử gán trùng phím: bị báo lỗi. "Khôi phục mặc định" đưa về như cũ.
5. Chơi trên màn hình 120/144 Hz (nếu có): đi lại và quay camera không rung; xuống mỏ, chết, tỉnh dậy: không thấy nhân vật "trượt" qua màn hình.
6. Chơi mới: cài đặt (ngôn ngữ, âm lượng, phím) vẫn giữ nguyên.

### 10.5 Câu hỏi cần chốt cho VS-A (✅ đã chốt 2026-11-28, xem DECISION_LOG mục VS-A)

1. Chọn font (hoặc 2 font: chữ chính và HUD) từ màn hình thử.
2. Cài đặt lưu riêng `user://settings.cfg` và chuyển ngôn ngữ ra khỏi save ván chơi: đồng ý không?
3. Không thêm autoload mới: âm thanh là node con của `Main`, cài đặt do `SaveManager` đọc/ghi. Nếu muốn tách `Settings` thành autoload thứ 5 thì là thay đổi kiến trúc, cần duyệt.
4. SFX tạm: Claude tự sinh bằng script (đánh dấu `_placeholder`, không vấn đề giấy phép), vì cloud không tải được từ các trang âm thanh. Âm thanh thật từ thư viện CC0 để sau (VS-B hoặc khi chủ dự án cung cấp file). Đồng ý không?
5. Theme UI được gán toàn project qua `gui/theme/custom` trong `project.godot` (sửa cấu hình Godot): đồng ý không?
6. Có thêm tùy chọn toàn màn hình / cửa sổ vào menu cài đặt không? (Chưa có trong yêu cầu, mặc định là không làm.)

## 11. Lịch sử thay đổi

| Ngày | Phiên bản | Nội dung |
|---|---|---|
| 2026-11-28 | 0.3 | VS-A hoàn thành (VSA1–VSA6), ghi commit từng mốc |
| 2026-11-28 | 0.2 | Chủ dự án duyệt: ghi quyết định mục 9, thứ tự mới (tách VS-E1/E2), kế hoạch VS-A và font ứng viên |
| 2026-11-28 | 0.1 | Bản đề xuất |
