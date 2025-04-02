import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/model/NhanVien.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Myhelper {
  String formatNgayGio(DateTime dt) {
    String formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(dt);
    return formattedDate;
  }

  String formatToSaveDateTime(DateTime dt, [bool formatType = false]) {
    if (formatType) {
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
    }
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  String formatCurrency(double value) {
    final format =
        NumberFormat("#,###", "en_US"); // Luôn dùng `,` để phân cách hàng nghìn
    return format.format(value);
  }

  int getSoNgayTrongThang(int thang, int nam) {
    if (thang < 1 || thang > 12) return -1; // Tháng không hợp lệ

    List<int> ngayTrongThang = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    return (thang == 2 && (nam % 4 == 0 && nam % 100 != 0 || nam % 400 == 0))
        ? 29
        : ngayTrongThang[thang - 1];
  }

  String removeFormatCurrency(String chuoi) {
    String rawInput = chuoi;
    String input = rawInput.replaceAll(',', '');
    return input;
  }

  void showToast(String message, bool kieuthongbao) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: kieuthongbao ? Colors.green : Colors.red,
      textColor: Colors.white,
    );
  }

  String formatDateTime(DateTime dt) {
    String kq = "";
    kq = "${dt.day.toString().padLeft(2, '0')}/"
        "${dt.month.toString().padLeft(2, '0')}/"
        "${dt.year} "
        "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
    return kq;
  }

  String formatDate(DateTime dt) {
    String kq = "";
    kq = "${dt.day.toString().padLeft(2, '0')}/"
        "${dt.month.toString().padLeft(2, '0')}/"
        "${dt.year} ";
    return kq;
  }

  String filterCanNangInput(String value) {
    // Nếu trống, trả về rỗng
    if (value.isEmpty) return "";

    // Nếu chỉ có dấu ".", trả về "0."
    if (value == ".") return "";

    // Kiểm tra và chỉ giữ lại số thực hợp lệ
    final regex = RegExp(r'^\d*\.?\d*$'); // Chỉ chấp nhận số và một dấu `.`
    return regex.hasMatch(value) ? value : value.substring(0, value.length - 1);
  }

  /// Widget chọn ngày
  Widget buildDatePicker(BuildContext context, String label, DateTime? date,
      Function(DateTime) onDateSelected) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null ? formatDate(date) : label,
              style: TextStyle(
                  fontSize: 16,
                  color: date != null ? Colors.black : Colors.grey),
            ),
            Icon(Icons.calendar_month, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<Nhanvien?> getNhanVien() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nhanvienJson = prefs.getString('nhanvien');
    if (nhanvienJson != null) {
      return Nhanvien.fromJson(jsonDecode(nhanvienJson));
    }
    return null;
  }

  int formatTiLeHoaHong(double hh) {
    return (hh * 100).toInt();
  }
}
