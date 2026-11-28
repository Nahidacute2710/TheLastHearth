# THE LAST HEARTH — Game Design Document

> Phiên bản: 0.4 · Cập nhật: 2026-11-28
> Trạng thái: **Định hướng đã duyệt (Phase 0)**. Mục nào không ghi ✅ thì vẫn là đề xuất.
> Quy ước nhãn: **✅ ĐÃ CHỐT** = chủ dự án đã xác nhận · **ĐỀ XUẤT** = gợi ý, chưa duyệt · **🧪 CẦN THỬ NGHIỆM** = chốt qua playtest/mockup · **❓** = câu hỏi mở.

---

## 1. Tóm tắt một câu

Bạn giữ ngọn lửa cuối cùng của một vùng đất bị nguyền rủa: ban ngày vận hành quán trọ để nuôi sống ngọn lửa, khi đi thám hiểm thì xuống dungeon để tìm những gì quán cần, và mỗi chuyến đi lại mạnh hơn nhờ quán.

## 2. Thông tin chung

| Mục | Nội dung |
|---|---|
| Tên | THE LAST HEARTH |
| Thể loại | Dark Fantasy · Tavern Management · Action Roguelite · Dungeon Crawler |
| Nền tảng | PC (Windows trước tiên), phát hành trên Steam |
| Engine | Godot 4.7 · GDScript |
| Đồ họa | 2D Pixel Art, góc nhìn top-down |
| Chế độ chơi | Single-player |
| Đối tượng | Người chơi thích quản lý (Stardew Valley, Moonlighter) và hành động roguelite (Hades, Enter the Gungeon) |
| Điều khiển | Bàn phím + chuột; tay cầm là mục tiêu sau MVP |
| Ngôn ngữ | ✅ Tiếng Anh + Tiếng Việt. Kiến trúc localization có từ đầu; dịch đầy đủ làm sau (xem TECHNICAL_ARCHITECTURE.md mục 5.1) |

## 3. Trụ cột thiết kế (Design Pillars)

Mỗi tính năng mới phải phục vụ ít nhất một trụ cột. Tính năng nào không phục vụ trụ cột nào thì loại.

1. **Ngọn lửa là sự sống** — Quán trọ không chỉ là một menu. Đây là nơi an toàn duy nhất, và việc giữ nó ấm áp là động lực cảm xúc của game.
2. **Hai nửa nuôi nhau** — Quản lý quán và phiêu lưu dungeon phải phụ thuộc nhau thật sự. Nếu người chơi bỏ hẳn một nửa mà vẫn tiến bộ tốt thì thiết kế đã sai.
3. **Bóng tối có trọng lượng** — Chiến đấu ngắn, gắt, có rủi ro thật. Chết thì mất những gì chưa kịp mang về quán (xem mục 6).
4. **Thế giới kể chuyện qua con người** — Cốt truyện đến từ khách trọ, nhân viên và những gì tìm thấy dưới lòng đất, không đến từ những đoạn văn dài.

## 4. Bối cảnh & cốt truyện

> ✅ **ĐÃ CHỐT làm định hướng chính thức ban đầu (2026-11-27):** tên vùng đất **Vael**, tên lời nguyền **Tro Lặng**, và **Ngọn Lửa Gốc** là cơ chế quan trọng gắn với sự tồn tại và phát triển của quán trọ.
> Các chi tiết còn lại (Kẻ Rỗng, tên tiếng Anh, nguồn gốc lời nguyền, người chủ cũ, bí ẩn trung tâm) vẫn là **ĐỀ XUẤT**.

### 4.1 Thế giới

Vùng **Vael** từng là một thung lũng trù phú, sống nhờ các mạch than và mạch quặng sâu dưới núi. Một đêm nọ, một làn tro xám không rõ nguồn gốc bắt đầu rơi. Dân gian gọi nó là **Tro Lặng (the Hush)**. Ở đâu Tro Lặng phủ dày thì lửa tắt, âm thanh tắt dần, và người ta quên dần tên của nhau. Những ai bị nhiễm quá lâu biến thành **Kẻ Rỗng (the Hollowed)** và lang thang trong các hầm mỏ bỏ hoang.

### 4.2 Quán trọ The Last Hearth

Ở rìa thung lũng có một quán trọ cổ. Lò sưởi trong quán là **Ngọn Lửa Gốc (the Hearth)**, và vì một lý do chưa ai hiểu, Tro Lặng không thể tiến lại gần nó. Người chơi thừa kế quán từ người chủ cũ, nay đã mất tích. Quán trở thành nơi trú chân cuối cùng của lữ khách, thợ săn và người tị nạn.

### 4.3 Nhân vật chính

✅ **ĐÃ CHỐT:** nhân vật chính là **nhân vật cố định**, có danh tính và cốt truyện riêng: người chủ quán mới. MVP **không** có hệ thống tạo nhân vật. Tùy chỉnh ngoại hình có thể xem xét ở giai đoạn sau. ✅ **Bản đầu (2026-11-28):** **Maren**, nữ, khoảng 30 tuổi, từng là người đưa thư trên các tuyến đường Vael; nhận chìa khóa quán qua lá thư của người chủ cũ đã biến mất. Chi tiết ở `STORY_BIBLE.md`, còn sửa được đến VS-F.

Đây không phải anh hùng được chọn mà là một người bình thường buộc phải cầm vũ khí, vì không ai khác sẽ xuống dưới đó.

### 4.4 Bí ẩn trung tâm

- Tro Lặng đến từ đâu? Từ thứ gì đó ở tầng sâu nhất của mỏ.
- Vì sao Ngọn Lửa Gốc kháng cự được nó?
- Người chủ cũ đã đi đâu?

Câu trả lời được hé lộ dần qua boss, vật phẩm cổ và câu chuyện của khách trọ. Chi tiết cốt truyện đầy đủ sẽ có ở tài liệu `STORY_BIBLE.md` (tạo 2026-11-28, bổ sung dần trong Vertical Slice).

### 4.5 Tông giọng

U tối nhưng không tuyệt vọng. Bên ngoài lạnh, xám và im lặng; bên trong quán ấm, ồn ào và có mùi đồ ăn. Sự tương phản này là bản sắc thị giác và cảm xúc của game.

## 5. Vòng gameplay

### 5.1 Vòng lõi (Core Loop)

```
 ┌──────────────┐     ┌─────────────┐     ┌──────────────┐
 │ QUẢN LÝ QUÁN │ ──▶ │  CHUẨN BỊ   │ ──▶ │  THÁM HIỂM   │
 │ phục vụ khách│     │ ăn món buff │     │ chiến đấu    │
 │ nấu ăn, bán  │     │ chọn trang  │     │ thu thập     │
 │ nâng cấp     │     │ bị, nhiệm vụ│     │ tài nguyên   │
 └──────▲───────┘     └─────────────┘     └──────┬───────┘
        │                                        │
        └──────────── TRỞ VỀ QUÁN ◀──────────────┘
              mang nguyên liệu, vật phẩm, câu chuyện
```

### 5.2 Liên kết giữa hai nửa (yêu cầu bắt buộc)

| Từ Dungeon → Quán | Từ Quán → Dungeon |
|---|---|
| Nguyên liệu nấu ăn (thịt quái, nấm hang, ...) | Món ăn cho buff trước chuyến đi (máu, sát thương, kháng Tro) |
| Vật liệu nâng cấp quán (gỗ mục, quặng, ...) | Tiền để mua/rèn vũ khí và trang bị |
| Vật phẩm hiếm để bán cho khách đặc biệt | Khách trọ giao nhiệm vụ: "tìm giúp tôi X ở tầng Y" |
| Manh mối cốt truyện mở khóa khách mới | Nhân viên được thuê giúp quán vận hành khi người chơi vắng mặt |
| Than tro (Ember) để giữ Ngọn Lửa Gốc | Cấp của Ngọn Lửa Gốc quyết định độ sâu tối đa có thể xuống |

**Cơ chế Ngọn Lửa Gốc:** ✅ vai trò đã chốt: đây là cơ chế quan trọng gắn với sự tồn tại và phát triển của quán. Cách vận hành dưới đây vẫn là ĐỀ XUẤT ❓: Lửa có "cấp độ". Muốn tăng cấp phải tiêu tài nguyên đặc biệt lấy từ dungeon. Cấp càng cao thì quán càng có nhiều chỗ, càng hút khách, và người chơi càng chịu được Tro Lặng lâu hơn khi ở dưới mỏ. Đây là sợi dây chính nối hai nửa game.

### 5.3 Nhịp một ngày trong game

✅ **ĐÃ CHỐT (2026-11-28):** giữ nhịp như MVP cho Vertical Slice: ở quán (nấu, phục vụ) → xuống mỏ → về quán (an toàn hay bị đánh gục) là sang ngày mới. **Không giới hạn số ngày.** Phần dưới là ý tưởng cũ, giữ để tham khảo.

1. **Sáng** — Chuẩn bị quán: nấu trước, sắp xếp, nhận nhiệm vụ.
2. **Chiều tối** — Mở cửa, phục vụ khách (giai đoạn quản lý chủ động).
3. **Đêm** — Đóng cửa, đi thám hiểm dungeon (một chuyến/đêm).
4. **Kết thúc** — Trở về hoặc bị đánh gục, game lưu, sang ngày mới.

Thứ tự: xem quyết định ở đầu mục.

### 5.4 Vòng meta (dài hạn)

- Nâng cấp quán (phòng mới, bếp, quầy rượu, phòng ngủ cho khách).
- Mở khóa công thức, vũ khí, khu vực dungeon mới.
- Tuyển nhân viên có kỹ năng riêng.
- Tiến triển cốt truyện qua từng tầng và boss.

## 6. Roguelite: luật chết & giữ lại

**✅ ĐÃ CHỐT (2026-11-27) — khi nhân vật bị đánh gục trong dungeon:**

| Mất | Giữ lại |
|---|---|
| Loot nhặt trong chuyến đó | Trang bị **đang mặc** |
| Tài nguyên nhặt trong chuyến đó | Vật phẩm cốt truyện / quest |
| Tiền nhặt trong chuyến đó | Mọi thứ đã cất ở quán (chưa mang xuống) |
| Đồ tiêu hao mang theo từ quán | |
| Trang bị mang theo nhưng **chưa mặc** | |

- Không có hình phạt nào khác khi chưa được chủ dự án duyệt.
- Về quán bằng lối ra nghĩa là đã mang về: giữ toàn bộ.

**ĐỀ XUẤT (chưa duyệt):**
- Khu vực dungeon được sinh từ các "phòng" thiết kế sẵn, ghép ngẫu nhiên (sau MVP).
- Vật phẩm dịch chuyển về quán giữa chuyến (sau MVP).
- Tiến trình meta (nâng cấp quán, công thức) không bao giờ mất.

## 7. Danh sách hệ thống

Mô tả chi tiết ở [GAMEPLAY_SYSTEMS.md](GAMEPLAY_SYSTEMS.md). Tóm tắt:

| Nhóm | Hệ thống |
|---|---|
| Nền tảng | Di chuyển, tương tác, inventory, lưu/tải, chuyển cảnh |
| Quán | Khách hàng, nấu ăn, chế tạo, nhân viên, nâng cấp, kinh tế |
| Dungeon | Chiến đấu, quái vật, rơi đồ, sinh phòng, boss |
| Xuyên suốt | Nhiệm vụ, hội thoại, Ngọn Lửa Gốc, thời gian/ngày |

## 8. Phạm vi MVP

Xem [MVP_SPECIFICATION.md](MVP_SPECIFICATION.md).

## 9. Câu hỏi mở cần chủ dự án quyết định

**Đã trả lời (2026-11-27):**
- Tên vùng đất, lời nguyền → **Vael**, **Tro Lặng** ✅
- Nhân vật chính → cố định, có danh tính riêng ✅
- Phạt khi chết → bảng ở mục 6 ✅
- Ngôn ngữ phát hành → tiếng Anh + tiếng Việt ✅

**Đã trả lời (2026-11-28):**
- Nhân vật chính → Maren (bản đầu, xem `STORY_BIBLE.md`) ✅
- Nhịp ngày → giữ như MVP (quán → mỏ → về là sang ngày mới) ✅
- Giới hạn số ngày → không giới hạn ✅

**Còn mở:** chưa có.

## 10. Lịch sử thay đổi

| Ngày | Phiên bản | Nội dung |
|---|---|---|
| 2026-11-28 | 0.4 | Chốt nhân vật chính (Maren, bản đầu), nhịp ngày, không giới hạn ngày; tài liệu cốt truyện đổi tên thành STORY_BIBLE.md |
| 2026-11-27 | 0.1 | Bản nháp khởi tạo |
| 2026-11-27 | 0.3 | Chốt bảng mất/giữ khi chết (thêm tiền, đồ tiêu hao, trang bị chưa mặc, vật phẩm quest) |
| 2026-11-27 | 0.2 | Chốt quyết định Phase 0: luật chết, nhân vật cố định, EN/VI, Vael/Tro Lặng/Ngọn Lửa Gốc; thêm quy ước nhãn |
