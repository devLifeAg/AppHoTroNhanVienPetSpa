import 'package:app_ho_tro_nhan_vien_pet_spa/consts.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/util/appController.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/util/myWidget.dart';
import 'package:flutter/material.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/navBar.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/bottomSheet.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/util/myHelper.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/model/NhanVien.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Xemluong extends StatefulWidget {
  final Nhanvien nv;
  const Xemluong({super.key, required this.nv});

  @override
  State<StatefulWidget> createState() => _XemLuongState();
}

class _XemLuongState extends State<Xemluong> {
  final Myhelper helper = Myhelper();
  final Appcontroller myController = Appcontroller();
  final Mywidget mywidget = Mywidget();
  int month = 0;
  int year = 0;
  bool isLoading = true;
  int soNgayNghi = 0;
  int soGioTangCa = 0;
  int soLuongDvLam = 0;
  double tongHoaHong = 0.0;
  int soNgayTrongThang = 0;
  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    DateTime now = DateTime.now();
    month = now.month;
    year = now.year;
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    await _loadBangLuong(firstDayOfMonth, lastDayOfMonth);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadBangLuong(DateTime ngaybd, DateTime ngaykt) async {
    String id = widget.nv.nv_id.toString();
    await fetchBangLuong(ngaybd, ngaykt, id);
    setState(() {
      month = ngaybd.month;
      year = ngaybd.year;
      soNgayTrongThang = helper.getSoNgayTrongThang(month, year);
    });
  }

  Future<void> fetchBangLuong(
      DateTime ngaybd, DateTime ngaykt, String nvId) async {
    String startDate =
        Uri.encodeComponent(DateFormat("yyyy-MM-dd 00:00:00").format(ngaybd));
    String endDate =
        Uri.encodeComponent(DateFormat("yyyy-MM-dd 23:59:59").format(ngaykt));
    final String apiUrl =
        "${myUrl}getbangluong?ngaybd=$startDate&ngaykt=$endDate&id=$nvId";
    try {
      final response = await http.get(Uri.parse(apiUrl));

      final result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = result['bangluong']; // Chắc chắn nó là Map

        setState(() {
          soNgayNghi = data['soNgayNghi']; // Truy cập giá trị đúng
          soGioTangCa = data['soGioTangCa'];
          soLuongDvLam = data['soLuongDvLam'];
          tongHoaHong = data['tongHoaHong'].toDouble();
        });
      }
    } catch (e) {
      helper.showToast("Lỗi kết nối server", false);
    }
  }

  void _reloadData(DateTime startDate, DateTime endDate) async {
    _loadBangLuong(startDate, endDate);
    setState(() {
      isLoading = false;
    });
  }

  int soNgayCongThem() {
    if (soNgayTrongThang == 30) {
      return 2 - soNgayNGhiTinhLuong();
    } else if (soNgayTrongThang == 31) {
      return 3 - soNgayNGhiTinhLuong();
    } else if (soNgayTrongThang == 29) {
      return 1 - soNgayNGhiTinhLuong();
    }
    return 0;
  }

  double luongCung() {
    int ngayCongThucTe = soNgayCong() - soNgayNGhiTinhLuong();
    return 5000000 * ngayCongThucTe / 28;
  }

  int soNgayCong() {
    return soNgayTrongThang - soNgayNGhiKhongTinhLuong();
  }

  int soNgayNGhiTinhLuong() {
    if (soNgayTrongThang == 30) {
      if (soNgayNghi < 2) {
        return soNgayNghi;
      }
      return 2;
    } else if (soNgayTrongThang == 31) {
      if (soNgayNghi < 3) {
        return soNgayNghi;
      }
      return 3;
    } else if (soNgayTrongThang == 29) {
      if (soNgayNghi < 1) {
        return soNgayNghi;
      }
      return 1;
    }
    return 0;
  }

  int soNgayNGhiKhongTinhLuong() {
    return soNgayNghi - soNgayNGhiTinhLuong();
  }

  double tienPhuCap() {
    return (soNgayCong() - soNgayNGhiTinhLuong()) * 25000;
  }

  double tienTangCa() {
    return soGioTangCa * 25000;
  }

  double luongDot1() {
    return luongCung() + tienPhuCap() + tienTangCa();
  }

  double tongLuong() {
    return luongDot1() + tongHoaHong;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Navbar(
        nv: widget.nv,
      ),
      appBar: AppBar(
        centerTitle: true, // Căn giữa tiêu đề
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Lương",
          style: TextStyle(color: white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white), // Nút dấu +
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Bottomsheet(
                      tenContext: "XL",
                      nv: widget.nv,
                      onSearch: (startDate, endDate) {
                        _reloadData(startDate, endDate);
                      }); // Gọi Widget đã tạo sẵn
                },
              );
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [dark_purple, light_purple]),
          ),
        ),
      ),
      body: isLoading
          ? mywidget.Loading()
          : soLuongDvLam > 0
              ? Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromARGB(255, 130, 55, 201),
                          Color.fromARGB(255, 77, 47, 129)
                        ]),
                    borderRadius: BorderRadius.circular(12), // Bo góc
                    boxShadow: [
                      BoxShadow(
                        color: dark_purple.withOpacity(0.8), // Bóng mờ
                        blurRadius: 8, // Độ mờ của bóng
                        offset: Offset(6, 6), // Độ dịch chuyển của bóng (X,Y)
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.all(
                      16), // Tạo khoảng cách với viền ngoài
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          alignment: Alignment.center,
                          child: Text(
                            "Bảng Lương Tháng $month/$year",
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: white),
                          )),
                      Center(
                        child: Image.asset(
                          mainImage,
                          width: 100,
                          height: 100,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              customText("Ngày off không lương:"),
                              customText("Ngày off có lương:"),
                              customText("Số ngày công:"),
                              customText("Số giờ tăng ca:"),
                              customText("Số dịch vụ đã làm:"),
                              const SizedBox(
                                height: 16,
                              ),
                              customText("Lương cứng:"),
                              customText("Phụ cấp:"),
                              customText("Tiền tăng ca:"),
                              customText("Hoa hồng:"),
                              const SizedBox(
                                height: 16,
                              ),
                              customText("Tổng lương:", 20, true),
                              customText("Lương đợt 1:"),
                              customText("Lương đợt 2:"),
                            ],
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              customValueText(soNgayNGhiKhongTinhLuong(), donvi: " ngày"),
                              customValueText(soNgayNGhiTinhLuong(), donvi: " ngày"),
                              customValueText(soNgayCong(), donvi: " ngày"),
                              customValueText(soGioTangCa, donvi: " giờ"),
                              customValueText(soLuongDvLam, donvi: " dịch vụ"),
                              const SizedBox(
                                height: 16,
                              ),
                              customValueText(luongCung()),
                              customValueText(tienPhuCap()),
                              customValueText(tienTangCa()),
                              customValueText(tongHoaHong),
                              SizedBox(
                                height: 16,
                              ),
                              customValueText(tongLuong(),
                                  size: 20, bold: true),
                              customValueText(luongDot1()),
                              customValueText(tongHoaHong),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                )
              : const Center(child: Text("Chưa có bảng lương!")),
    );
  }

  Widget customText(String noidung, [double size = 16, bool bold = false]) {
    return Text(noidung,
        style: TextStyle(
            fontSize: size,
            color: white,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal));
  }

  Widget customValueText(dynamic value,
      {double size = 16, bool bold = false, String donvi = "đ"}) {
    String kq =
        value is double ? helper.formatCurrency(value) : value.toString();
    return Text(kq + donvi,
        style: TextStyle(
            fontSize: size,
            color: white,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal));
  }
}
