# THE LAST HEARTH — Story Bible

> Phiên bản: 0.2 · Cập nhật: 2026-11-28
> Quy ước nhãn giống GDD: **✅ ĐÃ CHỐT** · **ĐỀ XUẤT** · **❓** câu hỏi mở.
> Bối cảnh chung (Vael, Tro Lặng, Ngọn Lửa Gốc, Kẻ Rỗng) ở `GAME_DESIGN_DOCUMENT.md` mục 4. File này ghi chi tiết nhân vật và cốt truyện, bổ sung dần trong Vertical Slice.

---

## 1. Nhân vật chính: Maren

✅ **Bản đầu, chủ dự án chốt 2026-11-28. Còn sửa được đến hết VS-F.**

| Mục | Nội dung |
|---|---|
| Tên | Maren |
| Giới tính | Nữ |
| Tuổi | Khoảng 30 |
| Nghề cũ | Người đưa thư trên các tuyến đường của Vael |
| Lý do đến quán | Nhận chìa khóa quán qua một lá thư của người chủ cũ, người đã biến mất |

- Id trong code vẫn là `innkeeper` (vai trò, không phải tên), nên đổi tên nhân vật không phải đổi code.
- Tên hiển thị khi cần sẽ đi qua khóa dịch (ví dụ `CHAR_MAREN_NAME`), chưa tạo ở thời điểm này.

## 2. Lá thư của người chủ cũ (BẢN NHÁP, VS-E1)

✏️ **Bản nháp 2026-11-28, Claude viết, chờ chủ dự án duyệt. Còn sửa được đến hết VS-F.**

Mỗi lần nhóm Ngọn Lửa Gốc lên cấp, Maren đọc thêm 1–2 câu của lá thư. Giọng trầm, bí ẩn, gợi về Tro Lặng và tầng hầm, không giải thích hết. Người viết không ký tên. Khóa dịch nằm trong `localization/translations.csv`, cấp nào mở đoạn nào ghi ở `data/hearth/hearth_levels.tres`. Panel lò sưởi cho đọc lại mọi đoạn đã mở.

| Cấp | Khóa dịch | Tiếng Việt | English |
|---|---|---|---|
| 2 | `LETTER_HEARTH_2` | Maren. Nếu lửa đã bén lại, nghĩa là quán vẫn còn nhận ra cô. Đừng để nó tắt, kể cả những đêm cô mệt nhất. | Maren. If the fire has caught again, then the inn still knows you. Do not let it go out, not even on the nights you are tired. |
| 3 | `LETTER_HEARTH_3` | Khách sẽ đến nhiều hơn. Không phải vì bát súp. Ở đâu còn lửa, ở đó người ta còn nhớ tên mình. | More travelers will come. Not for the stew. Wherever a fire still burns, people still remember their own names. |
| 4 | `LETTER_HEARTH_4` | Tôi đã đào quá sâu dưới tầng hầm. Dưới đó tro vẫn rơi dù chẳng có ngọn lửa nào cháy. Nếu sự im lặng bắt đầu nghe như tiếng người, hãy quay lên. | I dug too deep beneath the cellar. Down there the ash falls with no fire to make it. If the silence starts to sound like a voice, come back up. |
| 5 | `LETTER_HEARTH_5` | Tro Lặng không sợ lửa. Nó sợ thứ mà ngọn lửa này đang canh giữ. Hãy tha lỗi cho tôi vì đã để lại chiếc chìa khóa cho cô. | The Hush does not fear fire. It fears what this fire is keeping. Forgive me for leaving you the key. |

Ý đồ: đoạn 3 nối với GDD (người nhiễm Tro Lặng quên tên nhau); đoạn 4 gợi nguồn Tro Lặng ở dưới sâu (GDD mục 4, câu hỏi mở); đoạn 5 gợi "Ngọn Lửa Gốc kháng cự vì đang canh giữ một thứ", để ngỏ cho VS-F.

## 3. Câu hỏi mở (chốt dần đến VS-F)

- ❓ Duyệt bản nháp lá thư ở mục 2 (giọng văn, độ lộ bí ẩn, có ký tên hay không).
- ❓ Quan hệ giữa Maren và người chủ cũ (người quen, khách quen trên tuyến thư, hay người lạ?).
- ❓ Mạch nhiệm vụ ngắn của Vertical Slice (VS-F) gắn với Quản Đốc Rỗng thế nào.

## 4. Lịch sử thay đổi

| Ngày | Phiên bản | Nội dung |
|---|---|---|
| 2026-11-28 | 0.2 | Bản nháp lá thư người chủ cũ (4 đoạn, mở theo cấp Ngọn Lửa Gốc) |
| 2026-11-28 | 0.1 | Bản khởi tạo: nhân vật chính Maren (bản đầu) |
