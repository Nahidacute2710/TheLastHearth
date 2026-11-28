# THE LAST HEARTH — Quy chuẩn Asset

> Phiên bản: 0.2 · Cập nhật: 2026-11-27
> Quy ước nhãn: **✅ ĐÃ CHỐT** = chủ dự án đã xác nhận · **ĐỀ XUẤT** = gợi ý, chưa duyệt · **🧪 CẦN THỬ NGHIỆM** = chốt qua playtest/mockup · **❓** = câu hỏi mở.
> Áp dụng cho mọi file trong `assets/`, `scenes/`, `scripts/`, `data/`.

---

## 1. Quy tắc đặt tên chung

- **Chữ thường, `snake_case`**, chỉ dùng `a-z`, `0-9`, `_`. Không dấu tiếng Việt, không khoảng trắng, không viết hoa.
  - Lý do: Windows không phân biệt hoa/thường nhưng bản export và Linux/Steam Deck thì có. Sai hoa/thường gây lỗi chỉ xuất hiện sau khi export.
- Tên mô tả nội dung, đi từ chung đến riêng: `<loại>_<tên>_<biến thể>_<hành động>`.
- Không dùng tên kiểu `new`, `final`, `final2`, `test`, `copy`.

## 2. Tiền tố theo loại

| Loại | Mẫu | Ví dụ |
|---|---|---|
| Sprite nhân vật | `chr_<tên>_<hành động>.png` | `chr_innkeeper_walk.png` |
| Sprite quái | `enm_<tên>_<hành động>.png` | `enm_hollow_miner_attack.png` |
| Tileset | `tls_<khu vực>.png` | `tls_tavern_floor.png` |
| Môi trường / đạo cụ | `env_<tên>.png` | `env_hearth_fireplace.png` |
| Icon vật phẩm | `itm_<id>.png` | `itm_cave_mushroom.png` |
| UI | `ui_<thành phần>.png` | `ui_panel_wood.png` |
| Hiệu ứng | `vfx_<tên>.png` | `vfx_hit_spark.png` |
| Nhạc | `mus_<khu vực>_<tâm trạng>.ogg` | `mus_tavern_evening.ogg` |
| Âm thanh | `sfx_<nguồn>_<hành động>.wav` | `sfx_sword_swing_01.wav` |
| Font | `fnt_<tên>.ttf` | `fnt_hearth_pixel.ttf` |
| Shader | `<tác dụng>.gdshader` | `hit_flash.gdshader` |
| Scene | `<tên>.tscn` | `player.tscn`, `tavern_main_room.tscn` |
| Script | `<tên>.gd` | `health_component.gd` |
| Dữ liệu | `<id>.tres` | `data/items/cave_mushroom.tres` |

**Biến thể** đánh số 2 chữ số: `_01`, `_02`. **Placeholder** thêm hậu tố `_placeholder`: `enm_hollow_miner_placeholder.png`.

## 3. Nơi lưu trữ

| Loại | Thư mục |
|---|---|
| Nhân vật chính, NPC | `assets/characters/<tên>/` |
| Quái | `assets/enemies/<tên>/` |
| Tileset | `assets/tilesets/` |
| Đạo cụ, phông nền | `assets/environments/<khu vực>/` |
| Icon vật phẩm | `assets/items/` |
| UI | `assets/ui/` |
| Hiệu ứng | `assets/effects/` |
| Nhạc / SFX | `assets/audio/music/` · `assets/audio/sfx/` |
| Font | `assets/fonts/` |

Khi một nhân vật/quái có từ 3 file trở lên thì tạo thư mục con riêng cho nó.

**File nguồn** (`.aseprite`, `.psd`, `.kra`, project âm thanh) **không** để trong `res://` (✅ ĐÃ CHỐT 2026-11-27), vì Godot sẽ cố import chúng và làm nặng project.
- Vị trí đề xuất: thư mục `source_art/` ở gốc repo, ngang hàng `the-last-hearth/` (ĐỀ XUẤT, chưa tạo).
- ❓ Có commit `source_art/` lên Git hay lưu riêng ngoài repo: quyết định khi có file nguồn đầu tiên. Git LFS chưa được thiết lập (mục 7).
- Không đặt file nguồn cạnh asset trong `res://`, kể cả trong thư mục `.gdignore`.

## 4. Định dạng & thiết lập import

### 4.1 Hình ảnh
- Định dạng: **PNG** (RGBA, không nén có mất dữ liệu).
- Spritesheet: các frame xếp hàng ngang, kích thước frame đồng nhất, không padding (hoặc padding đều nếu cần tránh bleeding).
- Import: filter **Nearest** (mặc định project), **Mipmaps: tắt**, Compress mode: **Lossless**.
- Không chỉnh texture filter riêng lẻ trên từng node trừ khi có lý do và ghi chú.

### 4.2 Âm thanh
- SFX: **WAV** 16-bit 44,1 kHz (ngắn, cần độ trễ thấp).
- Nhạc: **OGG Vorbis** (dài, cần nén). Bật **Loop** trong import cho nhạc nền.
- Chuẩn hóa âm lượng: SFX đỉnh khoảng −3 dBFS, nhạc khoảng −14 LUFS.

### 4.3 Font
- TTF/OTF hoặc bitmap font. **Bắt buộc** kiểm tra hiển thị đủ ký tự tiếng Việt (ă â đ ê ô ơ ư và 5 dấu thanh) trước khi đưa vào.
- Với pixel font: tắt antialiasing, tắt hinting, `subpixel_positioning` tắt.

## 5. Bản quyền & nguồn gốc (BẮT BUỘC cho game thương mại)

- Mọi asset không do đội tự làm phải được ghi vào `assets/CREDITS.md` (tạo khi có asset đầu tiên) với: tên file, tác giả, nguồn (URL), giấy phép, ngày tải.
- Chỉ dùng giấy phép cho phép **thương mại**: CC0, CC-BY (phải ghi công), SIL OFL 1.1 (chỉ cho font, kèm file giấy phép), hoặc giấy phép đã mua.
- Âm thanh và nhạc (✅ 2026-11-28): chỉ từ thư viện CC0 hoặc có giấy phép thương mại rõ ràng; ghi giấy phép **từng file** trong `CREDITS.md`.
- **Không** dùng asset có giấy phép NC (non-commercial), asset không rõ nguồn, hoặc asset lấy từ game khác.
- Asset tạo bằng AI: ghi rõ công cụ và cách tạo trong `CREDITS.md`. Steam yêu cầu khai báo nội dung AI khi phát hành.

### 5.1 Quy trình art bằng PixelLab (✅ ĐÃ CHỐT 2026-11-28)

- PixelLab qua MCP là nguồn art chính; chưa dùng Retro Diffusion.
- Mọi asset sinh ra đều được **chỉnh tay** cho đúng palette, kích thước và góc nhìn trong `ART_BIBLE.md` trước khi vào game.
- Làm **mockup 1 màn hình** (quán + nhân vật + HUD) và được duyệt trước khi làm hàng loạt.
- Ghi cho **từng asset** trong `CREDITS.md`: công cụ, prompt (nguyên văn), tham số chính, ngày tạo, các bước chỉnh tay.
- **API key** chỉ đặt trong biến môi trường. Không commit, không ghi vào bất kỳ file cấu hình nào có trong git (kể cả `.mcp.json`, `project.godot`, `.env` không có trong `.gitignore`).

## 6. Trạng thái asset

Theo dõi trong bảng ở `assets/ASSET_STATUS.md` (tạo khi có asset thật):

| Trạng thái | Ý nghĩa |
|---|---|
| `placeholder` | Hình tạm để code chạy được. Không bao giờ phát hành |
| `wip` | Đang vẽ |
| `review` | Chờ duyệt theo ART_BIBLE.md |
| `final` | Đã duyệt, dùng cho bản phát hành |

## 7. Quản lý trong Git

- **Có commit:** file asset, file `.import` đi kèm (chứa thiết lập import), `.tscn`, `.tres`, `.gd`, `.gdshader`.
- **Không commit:** thư mục `.godot/` (cache, đã nằm trong `.gitignore`).
- Đổi tên/di chuyển asset **phải làm trong Godot Editor** (FileSystem dock), không làm bằng Explorer, để Godot cập nhật tham chiếu và UID.
- **Git LFS: ✅ ĐÃ CHỐT chưa thiết lập.** Đánh giá lại khi xảy ra một trong các điều kiện: (1) có file đơn lẻ trên 50 MB (GitHub cảnh báo ở 50 MB, chặn ở 100 MB); (2) tổng dung lượng art/audio nhị phân vượt khoảng 500 MB; (3) bắt đầu commit file nguồn lớn (`.psd`, project âm thanh) hoặc file nhị phân sửa thường xuyên. Khi đó lập kế hoạch riêng, vì chuyển file đã có trong lịch sử sang LFS cần rewrite history. Theo dõi ở BUG_TRACKER.md (TECH-005).

## 8. Lịch sử thay đổi

| Ngày | Phiên bản | Nội dung |
|---|---|---|
| 2026-11-28 | 0.3 | Thêm OFL cho font, quy định giấy phép âm thanh, quy trình art PixelLab |
| 2026-11-27 | 0.1 | Bản khởi tạo |
| 2026-11-27 | 0.2 | Chốt file nguồn art ngoài `res://`; ghi nhận quyết định chưa dùng Git LFS và điều kiện xem xét lại |
