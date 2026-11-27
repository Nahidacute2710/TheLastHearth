# THE LAST HEARTH — Lộ trình phát triển

> Phiên bản: 0.2 · Cập nhật: 2026-11-27
> Quy ước nhãn: **✅ ĐÃ CHỐT** = chủ dự án đã xác nhận · **ĐỀ XUẤT** = gợi ý, chưa duyệt · **🧪 CẦN THỬ NGHIỆM** = chốt qua playtest/mockup · **❓** = câu hỏi mở.
> Chưa gắn mốc thời gian cụ thể. Ước lượng thời gian phụ thuộc vào quy mô nhân sự ❓ (cần chủ dự án cung cấp).

---

## Nguyên tắc

- Mỗi giai đoạn có **tiêu chí hoàn thành** rõ ràng. Chưa đạt thì không chuyển giai đoạn.
- Cuối mỗi giai đoạn: báo cáo, chủ dự án xác nhận, cập nhật tài liệu, gắn tag Git.
- Ưu tiên làm cho *vui* trước, làm cho *đẹp* sau.

---

## Giai đoạn 0 — Khởi tạo nền tảng ✅ HOÀN THÀNH (2026-11-27)

**Mục tiêu:** Có cấu trúc dự án, tài liệu và quy chuẩn làm việc.

- [x] Kiểm tra project Godot và Git
- [x] Tạo cấu trúc thư mục
- [x] Viết bộ tài liệu thiết kế và kỹ thuật
- [x] Tạo `CLAUDE.md`
- [x] Thiết kế phạm vi MVP
- [x] Chủ dự án duyệt tài liệu và chốt quyết định Phase 0 (2026-11-27)
- [x] Cập nhật tài liệu theo quyết định đã chốt, kiểm tra tính nhất quán
- [x] Commit (`docs: finalize phase 0 project foundation`, 2026-11-27)
- [ ] Push lên GitHub, gắn tag `v0.0-init` (chờ chủ dự án yêu cầu)

**Tiêu chí hoàn thành:** Chủ dự án xác nhận tài liệu, project mở được trong editor mà không có lỗi.

> Các câu hỏi còn mở ở GDD mục 9 không chặn Giai đoạn 1; sẽ chốt dần qua playtest MVP.

---

## Giai đoạn 1 — MVP Prototype

**Mục tiêu:** Một vòng gameplay hoàn chỉnh, chơi được, dùng asset tạm. Chi tiết ở [MVP_SPECIFICATION.md](MVP_SPECIFICATION.md).

Chia thành các mốc nhỏ (mỗi mốc được duyệt riêng):

| Mốc | Nội dung | Kiểm chứng |
|---|---|---|
| 1.1 | Cấu hình project: input map (8 action), collision layers (6 layer), 4 autoload rỗng, `main.tscn` làm scene chính, integer scaling (TECH-003). ✅ **Hoàn thành 2026-11-27** (headless và editor đã kiểm tra) | Chạy F5 ra màn hình trống không lỗi |
| 1.2 | Player di chuyển trong phòng quán (graybox). ✅ **Hoàn thành 2026-11-27** (headless và editor đã kiểm tra, không rung hình) | Đi lại, va chạm tường |
| 1.3 | Hệ thống tương tác (`Interactable` + prompt); tạo `translations.csv` và khóa dịch đầu tiên | Đứng gần bếp/cửa hiện chữ "E" |
| 1.4 | Chuyển cảnh Quán ↔ Dungeon | Đi qua cửa sang dungeon và quay về |
| 1.5 | Chiến đấu: vũ khí + 1 loại quái + máu + chết | Đánh chết quái, quái đánh được player |
| 1.6 | Rơi đồ + inventory cơ bản | Quái rơi tài nguyên, nhặt vào túi |
| 1.7 | Nấu ăn + khách hàng NPC | Nấu món từ tài nguyên, phục vụ khách, nhận tiền |
| 1.8 | Lưu/tải | Thoát game, mở lại, dữ liệu còn nguyên |
| 1.9 | Hoàn thiện vòng chơi + playtest nội bộ | Một người mới chơi hết vòng không cần hướng dẫn miệng |

### Checkpoint (✅ duyệt 2026-11-27)

Từ mốc 1.3, công việc chia thành checkpoint. Mỗi checkpoint kết thúc ở một trạng thái chơi thử được; mỗi mốc nhỏ là 1 commit, không chờ duyệt giữa các mốc. Chủ dự án chơi thử và duyệt ở cuối mỗi checkpoint. Quyết định nhỏ tự chốt ghi ở `docs/DECISION_LOG.md`.

| Checkpoint | Mốc roadmap | Mốc nhỏ | Chơi thử được |
|---|---|---|---|
| CP-A | 1.3, 1.4 | A1 localization · A2 `Interactable` + prompt · A3 `SceneRouter` + fade · A4 Mỏ Bỏ Hoang graybox + cửa hầm | Quán → xuống mỏ → về quán |
| CP-B | 1.5 | B1 component máu/hitbox/hurtbox · B2 Cuốc Chim + đòn vung theo chuột · B3 Thợ Mỏ Rỗng · B4 máu player, i-frames, **né**, chết → tỉnh dậy ở quán | Đánh quái, né, bị đánh gục |
| CP-C | 1.6, 1.7 | C1 inventory + luật chết · C2 Nấm Hang · C3 túi đồ (TECH-006) · C4 bếp + Súp Nấm · C5 Lữ Khách, vàng, ngày | Nhặt nấm, nấu, bán |
| CP-D | 1.8, 1.9 | D1 save JSON · D2 menu chính, tự lưu, **menu tạm dừng** · D3 toàn vòng, cân thông số, buff Súp Nấm nếu kịp | Thoát và mở lại vẫn còn dữ liệu |

**Tiêu chí hoàn thành:** Vòng Quán → Chuẩn bị → Dungeon → Chiến đấu → Thu thập → Về quán chạy được trọn vẹn, có lưu/tải, không crash.

---

## Giai đoạn 2 — Vertical Slice

**Mục tiêu:** Một lát cắt nhỏ nhưng đạt chất lượng gần như bản phát hành, dùng để quảng bá và gọi vốn/tìm publisher.

- Art final cho quán (1 tầng) và 1 khu dungeon
- 3 đến 4 loại quái, 1 boss
- 2 đến 3 vũ khí, nâng cấp hệ thống né (né cơ bản đã có từ MVP)
- 5 đến 8 công thức, 3 đến 4 loại khách
- Cơ chế Ngọn Lửa Gốc phiên bản đầu
- Hội thoại cơ bản, 1 mạch nhiệm vụ ngắn
- Âm thanh và nhạc nền đầu tiên
- Sinh phòng dungeon ngẫu nhiên từ các phòng mẫu
- Menu chính, cài đặt (âm lượng, đổi phím), dịch đầy đủ EN/VI và chọn ngôn ngữ (kiến trúc localization đã có từ MVP)

**Tiêu chí hoàn thành:** 20 đến 30 phút gameplay mà người chơi ngoài đội muốn chơi tiếp.

---

## Giai đoạn 3 — Alpha (Nội dung đầy đủ về mặt tính năng)

- Tất cả hệ thống cốt lõi có mặt: nhân viên, nâng cấp quán, nhiệm vụ, kinh tế đầy đủ
- Tất cả khu vực dungeon có bản graybox
- Cốt truyện chính viết xong
- **Mở trang Steam (Coming Soon)** để bắt đầu thu wishlist
- Tích hợp Steamworks (achievement, cloud save) bằng GodotSteam ❓

**Tiêu chí hoàn thành:** Chơi được từ đầu đến cuối game (dù chưa đẹp, chưa cân bằng).

---

## Giai đoạn 4 — Beta (Nội dung hoàn thiện)

- Toàn bộ art, âm thanh final
- Cân bằng game, playtest diện rộng
- Tối ưu hiệu năng, hỗ trợ tay cầm, Steam Deck
- **Demo công khai** (cân nhắc tham gia Steam Next Fest)

**Tiêu chí hoàn thành:** Không còn bug mức Critical/High; đạt mục tiêu hiệu năng.

---

## Giai đoạn 5 — Phát hành

- Release Candidate, kiểm tra build Steam
- Trailer, press kit, chiến dịch ra mắt
- Ra mắt (Early Access hoặc 1.0 ❓)

## Giai đoạn 6 — Hậu phát hành

- Sửa lỗi theo phản hồi
- Cập nhật nội dung, có thể có DLC
- Hỗ trợ cộng đồng

---

## Quy ước Git theo giai đoạn

- Tag cuối mỗi giai đoạn: `v0.0-init`, `v0.1-mvp`, `v0.2-vslice`, `v0.5-alpha`, `v0.9-beta`, `v1.0`.

## Lịch sử thay đổi

| Ngày | Phiên bản | Nội dung |
|---|---|---|
| 2026-11-27 | 0.1 | Bản khởi tạo |
| 2026-11-27 | 0.3 | Chia Giai đoạn 1 thành 4 checkpoint |
| 2026-11-27 | 0.2 | Giai đoạn 0 hoàn thành; chi tiết mốc 1.1; localization theo mốc |
