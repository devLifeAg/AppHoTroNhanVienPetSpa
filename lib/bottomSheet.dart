import 'package:app_ho_tro_nhan_vien_pet_spa/consts.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/util/myHelper.dart';
import 'package:flutter/material.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/model/NhanVien.dart';

class Bottomsheet extends StatefulWidget {
  final String tenContext; // Thêm cờ để kiểm tra
  final Nhanvien nv;
  final Function(DateTime, DateTime) onSearch; // Thêm callback
  const Bottomsheet(
      {super.key,
      required this.tenContext,
      required this.nv,
      required this.onSearch});
  @override
  _BottomsheetState createState() => _BottomsheetState();
}

class _BottomsheetState extends State<Bottomsheet> {
  final Myhelper helper = Myhelper();
  String selectedButton = "Tháng";
  int selectedMonth = DateTime.now().month - 1;
  late int selectedYear; // Khai báo biến nhưng chưa gán giá trị

  final List<String> months =
      List.generate(12, (index) => "Tháng ${index + 1}");
  final List<String> years = List.generate(
    DateTime.now().year - 2020 + 1, // Số lượng phần tử
    (index) =>
        (2020 + index).toString(), // Tạo danh sách từ 2020 đến năm hiện tại
  );

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    selectedYear = years.length - 1; // Gán giá trị sau khi `years` đã khởi tạo
  }

  void callBackDate() {
    DateTime ngaybd =
        DateTime(int.parse(years[selectedYear]), selectedMonth + 1, 1);
    DateTime ngaykt =
        DateTime(int.parse(years[selectedYear]), selectedMonth + 2, 0);
    widget.onSearch(ngaybd, ngaykt);
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra nếu Bottomsheet được gọi từ ManageHoaHong
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (widget.tenContext == "QLHH") ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSelectableButton("Tháng"),
                _buildSelectableButton("Ngày"),
              ],
            ),

            const SizedBox(
              height: 16,
            ),
            // Hiển thị giao diện theo loại đã chọn
            selectedButton == "Tháng"
                ? _buildMonthYearSelection()
                : _buildDateSelection(),

            const SizedBox(height: 16), // Khoảng cách

            // Nút Tìm kiếm
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: dark_purple,
                foregroundColor: white,
                elevation: 4, // Độ nổi
                minimumSize: Size(100, 50),
              ),
              onPressed: () {
                if (selectedButton == "Tháng") {
                  callBackDate();
                } else {
                  if (startDate == null || endDate == null) {
                    helper.showToast("không được bỏ trống!", false);
                    return;
                  } else {
                    if (startDate!.isAfter(endDate!)) {
                      helper.showToast(
                          "Ngày bắt đầu phải nhỏ hơn ngày kết thúc!", false);
                      return;
                    }
                    // Gọi callback để cập nhật dữ liệu
                    widget.onSearch(startDate!, endDate!);
                  }
                }
                Navigator.pop(context);
              },
              child: Text("Tìm kiếm"),
            ),
          ] else ...[
            _buildMonthYearSelection(),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: dark_purple,
                foregroundColor: white,
                elevation: 4, // Độ nổi
                minimumSize: Size(100, 50),
              ),
              onPressed: () {
                callBackDate();
                Navigator.pop(context);
              },
              child: const Text("Tìm kiếm"),
            )
          ]
        ],
      ),
    );
  }

  /// Widget tạo button với hiệu ứng gạch chân
  Widget _buildSelectableButton(String text) {
    bool isSelected =
        selectedButton == text; // Kiểm tra button nào đang được chọn

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedYear = 0;
          startDate = null;
          endDate = null;
          selectedButton = text; // Cập nhật trạng thái khi nhấn vào
        });
      },
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue : Colors.black,
            ),
          ),
          const SizedBox(height: 4), // Khoảng cách giữa text và gạch chân
          Container(
            width: 120, // Độ dài của gạch chân
            height: 4, // Độ dày của gạch chân
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue
                  : Colors.transparent, // Gạch chân nếu được chọn
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  /// Giao diện chọn tháng
  Widget _buildMonthSelection() {
    return SizedBox(
      height: 150, // Điều chỉnh kích thước phù hợp
      child: ListWheelScrollView.useDelegate(
        itemExtent: 50,
        perspective: 0.002,
        diameterRatio: 2,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(
            initialItem: selectedMonth), // Gán vị trí mặc định
        onSelectedItemChanged: (index) {
          setState(() {
            selectedMonth = index;
          });
        },
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final isSelected = index == selectedMonth;
            return Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: isSelected ? 22 : 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? dark_purple : Colors.grey,
                ),
                child: Text(months[index]),
              ),
            );
          },
          childCount: months.length,
        ),
      ),
    );
  }

  /// Giao diện chọn tháng
  Widget _buildYearSelection() {
    return SizedBox(
      height: 150, // Điều chỉnh kích thước phù hợp
      child: ListWheelScrollView.useDelegate(
        itemExtent: 50,
        perspective: 0.002,
        diameterRatio: 2,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(initialItem: selectedYear),
        onSelectedItemChanged: (index) {
          setState(() {
            selectedYear = index;
          });
        },
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final isSelected = index == selectedYear;
            return Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: isSelected ? 22 : 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? dark_purple : Colors.grey,
                ),
                child: Text(years[index]),
              ),
            );
          },
          childCount: years.length,
        ),
      ),
    );
  }

  /// Giao diện chọn ngày bắt đầu - kết thúc
  Widget _buildDateSelection() {
    return Column(
      children: [
        helper.buildDatePicker(context, "Chọn ngày bắt đầu", startDate, (date) {
          setState(() {
            startDate = date;
          });
        }),
        const SizedBox(height: 10),
        helper.buildDatePicker(context, "Chọn ngày kết thúc", endDate, (date) {
          setState(() {
            endDate = date;
          });
        }),
      ],
    );
  }

  Widget _buildMonthYearSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            const Text(
              "Tháng",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              height: 150, // Provide a height constraint
              width: 100,
              child: _buildMonthSelection(),
            ),
          ],
        ),
        Column(
          children: [
            const Text(
              "Năm",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              height: 150, // Provide a height constraint
              width: 100,
              child: _buildYearSelection(),
            ),
          ],
        ),
      ],
    );
  }
}
