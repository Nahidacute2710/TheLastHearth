# THE LAST HEARTH — Cân bằng kinh tế

> Phiên bản: 0.1 · Cập nhật: 2026-11-28 · Phạm vi: VS-E1 (Ngọn Lửa Gốc)
> Mọi con số ở đây là 🧪 (giá trị thử, chỉnh sau khi chơi thử).
> Số liệu lấy từ file dữ liệu thật; bảng nhịp do `scripts/debug/economy_sim.gd` tính.

---

## 1. Nguồn thu và chi

| Mục | Giá trị 🧪 | File |
|---|---|---|
| Lữ Khách trả cho 1 Súp Nấm | **30 vàng** (trước VS-E1: 15) | `data/customers/weary_traveler.tres` |
| Công thức Súp Nấm | 2 Nấm Hang → 1 bát, 1,5 s | `data/recipes/mushroom_stew.tres` |
| Nấm mọc sẵn trong mỏ | 4 | `scenes/dungeon/abandoned_mine.tscn` |
| Thợ Mỏ Rỗng | 10 con, 50% rơi 1 Nấm Hang | `data/enemies/hollow_miner.tres` |
| Vỉa than mỗi chuyến | 2–3 vỉa (4 chỗ có thể có, mỗi phòng 1) | `abandoned_mine.gd` (`min_veins`, `max_veins`) |
| Than Hồng mỗi vỉa | 2–3, vỡ sau 3 cú Cuốc Chim | `scenes/dungeon/ore_vein.tscn` |
| Số khách mỗi ngày | 1, cấp lửa 3 trở lên: 2 | `data/hearth/hearth_levels.tres` |

## 2. Các cấp Ngọn Lửa Gốc

| Cấp | Giá | Mở khóa | Tổng vàng / than đã tiêu |
|---|---|---|---|
| 1 | (bắt đầu) | Ngọn lửa le lói | 0 / 0 |
| 2 | 30 vàng + 5 Than Hồng | Bếp nấu 2 bát một lần (4 nấm ra 2 bát), thời gian nấu × 0,6 | 30 / 5 |
| 3 | 80 + 10 | Thêm một Lữ Khách mỗi ngày (bàn thứ hai) | 110 / 15 |
| 4 | 150 + 18 | +1 máu tối đa vĩnh viễn (cộng dồn với Súp Nấm) | 260 / 33 |
| 5 | 250 + 28 | Né lướt xa hơn: tốc độ lướt × 1,45, cùng thời gian, cùng i-frame (khoảng 40 px thành 57 px) | 510 / 61 |

Giá cấp giữ nguyên như chủ dự án đặt. Chỉ chỉnh **giá Súp từ 15 lên 30 vàng** để khớp nhịp (xem mục 4).

## 3. Mô hình mô phỏng

Mô phỏng theo **giá trị trung bình**, không phải một ván ngẫu nhiên:

- Ngày 1 bắt đầu ở quán, không có gì. Mỗi ngày sau là sau một chuyến xuống mỏ.
- Mỗi chuyến mang về: `(4 nấm mọc sẵn + 10 quái × tỉ lệ giết × 0,5) × (1 − tỉ lệ chết)` nấm và `2,5 vỉa × tỉ lệ đập vỉa × 2,5 than × (1 − tỉ lệ chết)` than. Chết thì mất cả túi.
- Ở quán: nấu hết nấm thành súp, phục vụ đủ số khách, ăn 1 bát nếu còn dư, nhóm lửa ngay khi đủ cả vàng và than.

| Cách chơi | Tỉ lệ giết quái | Tỉ lệ đập vỉa | Tỉ lệ chết | Nấm / chuyến | Than / chuyến |
|---|---|---|---|---|---|
| Bình thường (normal) | 60% | 100% | 10% | 6,3 | 5,6 |
| Chậm (slow) | 40% | 80% | 25% | 4,5 | 3,75 |
| Giỏi (skilled) | 90% | 100% | 0% | 8,5 | 6,25 |

## 4. Nhịp dự kiến (ngày đạt từng cấp)

| Cách chơi | Cấp 2 | Cấp 3 | Cấp 4 | Cấp 5 | Bị giới hạn bởi |
|---|---|---|---|---|---|
| **Mục tiêu** | 2–3 | khoảng 5 | khoảng 8 | khoảng 12 | |
| Bình thường | **2** | **5** | **8** | **12** | vàng (than vừa đủ ở cấp 5) |
| Chậm | 3 | 5 | 10 | 18 | than |
| Giỏi | 2 | 5 | 8 | 12 | vàng (khách mỗi ngày là trần thu nhập) |

Bảng ngày của cách chơi bình thường:

| Ngày | Thu trong ngày | Vàng còn | Than còn | Cấp |
|---|---|---|---|---|
| 1 | 0 | 0 | 0 | 1 |
| 2 | 30 | 0 | 0,6 | **2** |
| 3 | 30 | 30 | 6,2 | 2 |
| 4 | 30 | 60 | 11,9 | 2 |
| 5 | 30 | 10 | 7,5 | **3** |
| 6 | 60 | 70 | 13,1 | 3 |
| 7 | 60 | 130 | 18,8 | 3 |
| 8 | 60 | 40 | 6,4 | **4** |
| 9 | 60 | 100 | 12,0 | 4 |
| 10 | 60 | 160 | 17,6 | 4 |
| 11 | 60 | 220 | 23,2 | 4 |
| 12 | 60 | 30 | 0,9 | **5** |

**Vì sao giá Súp lên 30:** với 15 vàng, thu nhập là 15 vàng/ngày đến cấp 3 nên cấp 3 rơi vào khoảng ngày 9 (mục tiêu 5). Ở 30 vàng, cả 4 cấp khớp mục tiêu mà không phải đổi giá nâng cấp.

**Nhận xét:**
- Thu nhập bị chặn bởi số khách, nên chơi giỏi không lên cấp nhanh hơn chơi bình thường. Chơi giỏi chỉ có dư nấm và than. Muốn thưởng cho người chơi giỏi thì sau này cần chỗ bán thêm (VS-E2: thêm món, thêm loại khách).
- Người chơi chậm bị chặn bởi than từ cấp 4. Nếu chơi thử thấy cấp 4–5 quá lâu thì giảm giá than cấp 4–5 trước, không tăng số vỉa.
- Cấp 2 ở ngày 2 cần mang về ít nhất 5 than ngay chuyến đầu (đập đủ 2 vỉa trở lên). Đập thiếu thì cấp 2 rơi vào ngày 3, vẫn trong mục tiêu.

## 5. Kiểm tra tự động

- `tests/test_economy.gd`: chạy mô phỏng trên dữ liệu thật. Cách chơi bình thường phải đạt cấp 2 ở ngày 2–3, cấp 3 ở ngày 4–6, cấp 4 ở ngày 7–9, cấp 5 ở ngày 11–13. Đổi giá hay số rơi mà lệch nhịp thì test báo đỏ.
- In bảng đầy đủ (PowerShell):
  `& "D:\Godot_v4.7.2\Godot_v4.7.2-stable_win64_console.exe" --headless --path "D:\Godot_v4.7.2\TheLastHearth\the-last-hearth" -s res://tests/economy_report.gd`

## 6. Lịch sử thay đổi

| Ngày | Phiên bản | Nội dung |
|---|---|---|
| 2026-11-28 | 0.1 | Bản đầu (VS-E1): 5 cấp lửa, Than Hồng, giá Súp 30, mô phỏng 3 cách chơi |
