# THE LAST HEARTH — Nhìn lại Giai đoạn 1 (MVP)

> Ngày viết: 2026-11-28 · Phạm vi: từ mốc 1.1 (2026-11-27) đến D3 (2026-11-28).
> Trạng thái: **Giai đoạn 1 hoàn thành.** Chủ dự án đã chơi thử đạt CP-A, CP-B, CP-C, D1–D2 và bản sửa BUG-001. Buff Súp Nấm và lưu khi tắt bằng nút X (D3) đã có test, đang chờ chơi thử lần cuối.

---

## 1. Đã làm gì

Vòng chơi MVP chạy trọn vẹn với asset placeholder:

```
Menu chính → Quán: lấy Cuốc Chim → xuống Mỏ Bỏ Hoang → đánh Thợ Mỏ Rỗng, né, nhặt Nấm Hang
→ về quán (tự cất vào kho, sang ngày mới, tự lưu) → nấu Súp Nấm → ăn (+2 máu tối đa) hoặc bán cho Lữ Khách
→ lưu / thoát / Tiếp tục
```

| Checkpoint | Nội dung | Commit chính |
|---|---|---|
| 1.1, 1.2 | Cấu hình project (input, collision layer, autoload, integer scaling); player đi 8 hướng trong quán graybox | `41c0837`, `fcb2939` |
| CP-A | Localization (`translations.csv`), `Interactable` + prompt, `SceneRouter` có fade, Mỏ Bỏ Hoang 4 phòng | `e58cd50` → `764ddf5` |
| CP-B | Component máu/hitbox/hurtbox, Cuốc Chim theo hướng chuột + hit-stop, Thợ Mỏ Rỗng (lấy đà rõ ràng), máu player, i-frames, né, chết → tỉnh dậy ở quán | `68b648d` → `098cedc` |
| CP-C | Túi + kho quán, luật chết, Nấm Hang (rơi + mọc sẵn), panel túi đồ (sửa TECH-006), bếp + Súp Nấm, Lữ Khách, vàng và ngày | `934a31a` → `5707a75` |
| CP-D | Save JSON (file tạm, `.bak` cho file hỏng), menu chính, menu tạm dừng, sửa BUG-001, buff Súp Nấm, lưu khi tắt cửa sổ, test trọn vòng | `f27bb10` → `963f70e` |

**Số liệu:** 20 file test, **76 test headless** (chạy bằng `tests/run_all.gd`, không addon), 37 khóa dịch có đủ tiếng Anh và tiếng Việt, 4 autoload đúng như kiến trúc đã chốt.

## 2. Quyết định quan trọng

Toàn bộ quyết định có ngày và lý do ở `docs/DECISION_LOG.md`. Những quyết định định hình game:

- **Cảm giác chiến đấu:** quái không gây sát thương khi chạm thân; chỉ đòn có lấy đà (nháy đỏ cam 0,6 s) mới gây sát thương; hit-stop 50 ms không dùng `Engine.time_scale`; không rung màn hình; đòn theo hướng chuột.
- **Luật chết:** mất cả túi trừ vật phẩm quest, giữ trang bị đang mặc và mọi thứ trong kho quán. Về quán (an toàn hay chết) là sang ngày mới.
- **Túi và kho:** túi chỉ chứa đồ trong chuyến; về quán an toàn thì tự cất vào kho. Nấu ăn, ăn và bán đều lấy từ kho.
- **Lưu:** chỉ lưu khi ở quán; thoát giữa chuyến là mất chuyến. File hỏng không bao giờ làm crash game và luôn được giữ lại dưới tên `.bak`.
- **Kiến trúc:** `Main` tồn tại suốt game, `SceneRouter` chỉ thay level trong `LevelRoot`; dữ liệu trong Resource `.tres`; `GameState.start_new_game()` là đường duy nhất để bắt đầu ván mới.
- **Quy trình:** checkpoint chơi thử được, mỗi mốc một commit kèm test, Claude chạy headless bằng Godot 4.7.2 Linux trên bản sao repo ở cloud.

## 3. Lỗi đã gặp và bài học

### BUG-001: Chơi mới không reset vàng và ngày (High, Verified)

- **Triệu chứng:** sau khi về menu chính rồi Chơi mới, HUD vẫn hiện vàng và ngày của ván cũ.
- **Nguyên nhân:** file save và `GameState` trong bộ nhớ đều đúng. Hàm reset gán lại biến nhưng không phát signal, nên khung ngày/vàng (sống suốt game trong `Main`) không biết số đã đổi.
- **Vì sao test không bắt được:** test chỉ kiểm tra dữ liệu trong bộ nhớ và file save, không kiểm tra HUD.
- **Bài học, thành quy tắc trong CLAUDE.md:** mọi test làm đổi trạng thái phải kiểm tra cả HUD/UI. Mọi việc reset phải đi qua một hàm duy nhất và phát lại toàn bộ signal.

### TECH-009: test bị SCRIPT ERROR vẫn báo PASS (Medium, Fixed)

- Một lỗi script trong hàm test (coroutine) dừng hàm đó giữa chừng mà không ghi thất bại nào. Phát hiện khi viết test trọn vòng: lambda trong GDScript bắt biến cục bộ theo giá trị, nên cờ "đã giết quái" không bao giờ đổi, rồi test gọi vào node đã bị giải phóng.
- **Sửa:** bộ chạy test gắn một `Logger` và đánh trượt mọi test có `ERROR` / `SCRIPT ERROR`. Rà lại toàn bộ test cũ, không có lỗi ẩn nào khác.
- **Bài học:** một bộ test "xanh" chỉ có giá trị khi chính bộ chạy test cũng được kiểm tra; đã thử cố ý làm hỏng test để chắc rằng nó báo đỏ.

### Các lỗi nhỏ khác

| Lỗi | Bài học |
|---|---|
| Bếp có thể làm mất món nếu kho đầy (sửa ở D1: kiểm tra chỗ trước khi trừ nguyên liệu) | Kiểm tra điều kiện trước khi lấy tài nguyên của người chơi |
| Về menu khi đang nấu: save thiếu món, mất nguyên liệu (sửa cùng BUG-001) | Thứ tự "gỡ level rồi mới lưu" quan trọng khi level còn giữ trạng thái |
| `SceneRouter` giữ trạng thái giữa các lần chạy test | Autoload cần hàm reset rõ ràng |
| Đồng bộ về máy bằng bundle bị dừng giữa chừng vì thiếu quyền xóa file | Kiểm tra quyền trước khi chạy git trên thư mục được chia sẻ |

## 4. Nợ kỹ thuật và giới hạn còn lại

| Mục | Mức | Ghi chú |
|---|---|---|
| Quái phát hiện player xuyên tường, chưa có tầm nhìn | Medium | Cần raycast tầm nhìn |
| Chưa có pathfinding, quái có thể kẹt ở cột đá | Medium | `NavigationRegion2D` / `NavigationAgent2D` |
| Font mặc định của Godot cỡ 8, khó đọc | Medium | Cần pixel font có đủ dấu tiếng Việt |
| Toàn bộ art là placeholder tự sinh bằng script | — | Đúng phạm vi MVP |
| Chưa có âm thanh và nhạc | — | Đúng phạm vi MVP |
| Chưa có chỗ tiêu vàng | Medium | Vàng chỉ tăng, chưa có ý nghĩa |
| TECH-008: chưa bật physics interpolation (màn hình 120/144 Hz) | Low | Cần duyệt sửa `project.godot` |
| TECH-005: chưa dùng Git LFS | Low | Hoãn có chủ đích đến khi có asset lớn |
| Ghi đè file save bằng `rename` mới test trên Linux | Low | Chủ dự án đã chơi thử save/load trên Windows ở D2 đạt |
| Tắt game bằng nút X ngay giữa lúc chuyển cảnh chưa có test riêng | Low | Hiện coi như "không ở quán", không lưu |
| Toast cũ có thể còn hiện thoáng qua sau menu | Low | Bị nền menu che |
| Chưa hỗ trợ tay cầm, chưa có menu cài đặt (âm lượng, đổi phím, ngôn ngữ) | — | Ngoài phạm vi MVP |
| Một số thông số vẫn là `const` trong script (nháy, toast, kích thước ô) | Low | Chuyển sang Resource khi làm UI thật |

## 5. Điều nên giữ cho Giai đoạn 2

1. Checkpoint chơi thử được, ghi quyết định ngay khi chốt.
2. Test headless sau mỗi mốc, kiểm tra cả dữ liệu lẫn hiển thị.
3. Mọi chuỗi qua khóa dịch, có test bắt thiếu cột `vi`.
4. Một đường duy nhất cho mỗi thay đổi trạng thái lớn (ván mới, tải save, chết, về quán).
