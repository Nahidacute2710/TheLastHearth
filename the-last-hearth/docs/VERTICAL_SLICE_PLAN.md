# THE LAST HEARTH — Kế hoạch Vertical Slice (Giai đoạn 2)

> Ngày lập: 2026-11-28 · Trạng thái: **ĐỀ XUẤT, CHƯA LÀM, CHƯA DUYỆT.** Chưa có file code hay asset nào được tạo theo kế hoạch này.
> Nguồn phạm vi: `DEVELOPMENT_ROADMAP.md` Giai đoạn 2 và `GAME_DESIGN_DOCUMENT.md`.

---

## 1. Mục tiêu

Một lát cắt nhỏ nhưng gần chất lượng phát hành, đủ để quảng bá và tìm publisher.
**Tiêu chí hoàn thành (theo roadmap):** 20–30 phút gameplay mà người chơi ngoài đội muốn chơi tiếp.

## 2. Phạm vi đề xuất

| Nhóm | Phạm vi (từ roadmap) | Ghi chú |
|---|---|---|
| Art | Art final cho quán (1 tầng) và 1 khu dungeon; player có animation | Thay toàn bộ `_placeholder` của MVP |
| Quái | 3–4 loại quái + 1 boss | Thợ Mỏ Rỗng giữ lại, thêm 2–3 loại khác hành vi (đánh xa, lao tới, đi đàn) |
| Vũ khí | 2–3 vũ khí, nâng cấp né | Mỗi vũ khí một nhịp đánh khác |
| Dungeon | Sinh phòng ngẫu nhiên từ các phòng mẫu; pathfinding; tầm nhìn | Trả nợ kỹ thuật "quái xuyên tường" |
| Quán | 5–8 công thức, 3–4 loại khách, chỗ tiêu vàng | Vàng phải có ý nghĩa |
| Bản sắc | Ngọn Lửa Gốc phiên bản đầu | Trụ cột 1 của GDD |
| Câu chuyện | Hội thoại cơ bản, 1 mạch nhiệm vụ ngắn | Trụ cột 4 |
| Âm thanh | SFX đầu tiên, nhạc nền quán và mỏ | |
| UI | Pixel font hỗ trợ tiếng Việt, menu cài đặt (âm lượng, đổi phím, ngôn ngữ), dịch đầy đủ EN/VI | |

## 3. Chia checkpoint (mỗi checkpoint chơi thử được)

| CP | Nội dung | Chơi thử được |
|---|---|---|
| VS-A | Nền trình bày: pixel font tiếng Việt, theme UI chung, menu cài đặt (âm lượng, ngôn ngữ, đổi phím), bus âm thanh + SFX tạm, quyết định TECH-008 | Toàn bộ vòng MVP đọc rõ chữ, có tiếng đánh/nhặt/nấu, đổi được ngôn ngữ trong menu |
| VS-B | Quy trình art + art thật cho player (đi, đánh, né, bị đánh, chết) và quán 1 tầng | Vòng MVP với quán và nhân vật art thật |
| VS-C | Dungeon: phòng mẫu ghép ngẫu nhiên, pathfinding, tầm nhìn, art mỏ, 2–3 quái mới | Mỗi chuyến xuống mỏ một bố cục khác, quái không xuyên tường |
| VS-D | 2–3 vũ khí, nâng cấp né, 1 boss cuối khu | Đánh boss, chọn vũ khí trước khi xuống |
| VS-E | Quán: 5–8 công thức, 3–4 loại khách, chỗ tiêu vàng, Ngọn Lửa Gốc v1 | Kiếm vàng có mục đích, quán thay đổi theo tiến trình |
| VS-F | Hội thoại cơ bản, 1 mạch nhiệm vụ ngắn, nhạc nền, dịch đầy đủ, cân bằng, playtest 20–30 phút với người ngoài | Đạt tiêu chí hoàn thành |

Thứ tự VS-A trước vì font và âm thanh ảnh hưởng mọi màn hình; VS-B trước VS-C vì quy trình art cần chốt trước khi làm nhiều quái.

## 4. Art: công cụ và quy trình

- **Đã kiểm tra trong phiên này (2026-11-28):** **không có** connector/MCP PixelLab hay Retro Diffusion đang được kết nối. Connector đang có là Canva, không phù hợp để làm sprite pixel art cho game.
- **Nếu muốn dùng PixelLab hoặc Retro Diffusion:** anh/chị cần tự thêm connector (hoặc cấp API key qua biến môi trường, không ghi vào repo). Trước khi dùng phải kiểm tra:
  - Điều khoản dùng thương mại của asset sinh ra.
  - Steam yêu cầu khai báo nội dung tạo bằng AI trên trang cửa hàng.
  - Asset sinh ra vẫn phải qua chỉnh tay cho đúng palette và kích thước trong `ART_BIBLE.md`.
- **Phương án khác:** thuê họa sĩ pixel art hoặc mua asset pack có giấy phép thương mại (ghi nguồn vào `ASSET_GUIDELINES.md`).
- Dù chọn cách nào: làm một mockup 1 màn hình (quán + player + HUD) trước, chốt palette và tile 16×16 (đang là 🧪 trong `ART_BIBLE.md`), rồi mới làm hàng loạt.

## 5. Âm thanh

- SFX: vung cuốc, trúng đòn, quái lấy đà (rất quan trọng cho cảm giác đọc đòn), né, nhặt đồ, nấu, nhận vàng, UI.
- Nhạc: 1 bản quán (ấm), 1 bản mỏ (căng), 1 bản boss.
- Nguồn: thư viện có giấy phép thương mại, hoặc thuê. Ghi giấy phép từng file.
- Kỹ thuật: bus Master / Music / SFX, âm lượng trong menu cài đặt, lưu cài đặt riêng với save ván chơi.

## 6. Pixel font tiếng Việt

- Yêu cầu: đủ chữ có dấu tiếng Việt, kể cả dấu chồng (ầ, ẫ, ặ, ổ, ự...) ở cỡ 8–12 px; chiều cao dòng đủ cho dấu chồng không đè dòng trên; giấy phép cho phép dùng thương mại và nhúng vào game (ví dụ SIL OFL).
- Cách làm: chọn 2–3 font ứng viên, dựng một màn hình thử với toàn bộ chuỗi trong `translations.csv`, anh/chị chọn bằng mắt. Nếu không font nào đạt, phương án dự phòng là tự vẽ bitmap font (Godot hỗ trợ font từ ảnh).
- Chưa chọn font cụ thể nào; cần kiểm tra trực tiếp độ phủ dấu và giấy phép trước khi đề xuất.

## 7. Boss và chỗ tiêu vàng (ý tưởng để chốt)

- **Boss khu mỏ (ĐỀ XUẤT):** một quái lớn có 2–3 đòn lấy đà khác nhau, dùng đúng ngôn ngữ đọc đòn của Thợ Mỏ Rỗng; thắng thì mở khu tiếp theo hoặc một công thức mới.
- **Chỗ tiêu vàng (ĐỀ XUẤT, chọn 1–2):** nâng cấp quán (bếp nấu nhanh hơn, thêm bàn, thêm khách); cửa hàng mua vũ khí/nguyên liệu; "nhóm lửa" cho Ngọn Lửa Gốc. Gợi ý: nâng cấp quán, vì phục vụ cả trụ cột 1 và 2.

## 8. Rủi ro

- Phạm vi lớn so với một người làm: nên giữ mỗi checkpoint ở mức chơi thử được và cắt bớt nội dung trước khi cắt chất lượng.
- Art là phần tốn thời gian nhất và quyết định cảm giác "gần bản phát hành".
- Sinh phòng ngẫu nhiên dễ làm vỡ cân bằng: cần test tự động kiểm tra mọi bố cục đi được từ lối vào tới lối ra.

## 9. Quyết định cần chủ dự án chốt

1. Công cụ và nguồn art: PixelLab / Retro Diffusion (cần thêm connector và kiểm tra điều khoản), thuê họa sĩ, hay mua asset pack?
2. Ngân sách cho art, âm thanh, font.
3. Nguồn âm thanh và nhạc: thư viện hay thuê?
4. Có đồng ý thứ tự checkpoint VS-A → VS-F không?
5. Dungeon: ghép ngẫu nhiên từ phòng mẫu như roadmap, hay giữ thiết kế tay cho Vertical Slice?
6. Boss: ý tưởng ở mục 7 có đúng hướng không?
7. Chỗ tiêu vàng đầu tiên: nâng cấp quán, cửa hàng, hay Ngọn Lửa Gốc?
8. Nhịp một ngày (GDD 5.3): phục vụ trước rồi thám hiểm, hay ngược lại?
9. Có giới hạn số ngày (áp lực thời gian) không?
10. Tên, giới tính, tiểu sử nhân vật chính (cần cho hội thoại).
11. TECH-008: bật physics interpolation trong `project.godot` không?
12. Tạo tag `v0.1-mvp` cho commit kết thúc Giai đoạn 1 theo quy ước trong roadmap không?
13. Tay cầm: đưa vào Vertical Slice hay để sau?
