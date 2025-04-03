import 'package:app_ho_tro_nhan_vien_pet_spa/consts.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/util/myWidget.dart';
import 'package:flutter/material.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/navBar.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/bottomSheet.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/model/ThongTinHoaHong.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/items/item_manage_hoa_hong.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/activity/addEditHoaHong.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/util/myHelper.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/util/appController.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/model/NhanVien.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Managehoahong extends StatefulWidget {
  final Nhanvien nv;
  const Managehoahong({super.key, required this.nv});

  @override
  State<StatefulWidget> createState() => _QuanLyHoaHongState();
}

class _QuanLyHoaHongState extends State<Managehoahong> {
  final Myhelper helper = Myhelper();
  final Appcontroller myController = Appcontroller();
  final Mywidget mywidget = Mywidget();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = true;
  List<Thongtinhoahong> _listHH = [];
  Map<String, String> _listDVC = {};
  DateTime now = DateTime.now();
  String dateTo = "";

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    String startDate = DateFormat('dd/MM/yyyy').format(now);
    dateTo = "$startTime $startDate - $endTime $startDate";
    await _loadTrangThongTinHoaHong(now, now);
    setState(() {
      isLoading = false;
    });
  }

  void _reloadData(DateTime startDate, DateTime endDate) async {
    await _loadTrangThongTinHoaHong(startDate, endDate);
    dateTo =
        "$startTime ${helper.formatDate(startDate)} - $endTime ${helper.formatDate(endDate)}";
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadTrangThongTinHoaHong(
      DateTime ngaybd, DateTime ngaykt) async {
    String id = widget.nv.nv_id.toString();
    final data = await myController.fetchAllThongTinHoaHong(id, ngaybd, ngaykt);
    setState(() {
      _listHH = (data["listhoahong"] as List)
          .map((hh) => Thongtinhoahong.fromJson(hh))
          .toList();
      if (_listHH.isNotEmpty) {
        _listDVC = Map<String, String>.from(data["listdichvucon"]);
      }
    });
  }

  double tinhTongHoaHong() {
    return _listHH.fold(0, (sum, item) => sum + item.hoa_hong);
  }

  Future<bool?> deleteThongTin(int ttId) async {
    try {
      final response = await http.delete(
        Uri.parse("${myUrl}deleteTTHH"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"tt_id": ttId}),
      );

      final result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        helper.showToast(result["message"], true);
        return true;
      } else {
        helper.showToast(result["message"], false);
        return false;
      }
    } catch (e) {
      helper.showToast("Lỗi kết nối server", false);
      return false;
    }
  }

  void scrollToItem(int newId) async {
    await Future.delayed(Duration(milliseconds: 1500));
    int newIndex = _listHH.indexWhere((item) => item.tt_id == newId);
    if (newIndex >= 3) {
      double offset = newIndex * 118.0; //chiều cao item
      double maxScroll = _scrollController.position.maxScrollExtent;

      _scrollController.animateTo(
        offset > maxScroll ? maxScroll : offset,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
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
          "Quản Lý Hoa Hồng",
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
                    tenContext: "QLHH",
                    nv: widget.nv,
                    onSearch: (startDate, endDate) {
                      // Nhận ngày tìm kiếm
                      dateTo =
                          "$startTime ${helper.formatDate(startDate)} - $endTime ${helper.formatDate(endDate)}";
                      _loadTrangThongTinHoaHong(startDate, endDate);
                    },
                  ); // Gọi Widget đã tạo sẵn
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
          : Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
              child: Column(
                children: [
                  Text(
                    dateTo,
                    style: const TextStyle(color: inputColor, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Tổng hoa hồng: ${helper.formatCurrency(tinhTongHoaHong())}đ",
                    style: const TextStyle(
                        color: inputColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8), // Khoảng cách giữa text và list
                  Expanded(
                    // Sử dụng Expanded để ListView chiếm phần còn lại của màn hình
                    child: _listHH.isNotEmpty
                        ? ListView.builder(
                            controller:
                                _scrollController, // Gán ScrollController
                            itemCount: _listHH.length,
                            clipBehavior: Clip
                                .none, // Cho phép các phần tử render vượt ra ngoài
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                child: ItemHoaHong(
                                    hh: _listHH[index],
                                    listdichvucon: _listDVC,
                                    index: index),
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Addedithoahong(
                                        hh: _listHH[index],
                                        tieude: "Sửa Thông Tin",
                                        nv: widget.nv,
                                      ),
                                    ),
                                  );
                                  if (result != null) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    int newId = result["Id"];
                                    DateTime startDate = result["startDate"];
                                    DateTime endDate = result["endDate"];

                                    _reloadData(startDate, endDate);

                                    scrollToItem(newId);
                                  }
                                },
                                onLongPress: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Xóa Thông Tin"),
                                        content:
                                            Text("Bạn có chắc muốn xóa không?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Đóng hộp thoại
                                            },
                                            child: Text("Không"),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              bool? kq = await deleteThongTin(
                                                  _listHH[index].tt_id);
                                              if (kq!) {
                                                setState(() {
                                                  _listHH.removeAt(index);
                                                });
                                              }
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Có"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          )
                        : const Center(
                            child: Text("danh sách trống!"),
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Addedithoahong(
                hh: null,
                tieude: "Thêm Thông Tin",
                nv: widget.nv,
              ),
            ),
          );
          if (result != null) {
            setState(() {
              isLoading = true;
            });
            int newId = result["Id"];
            DateTime startDate = result["startDate"];
            DateTime endDate = result["endDate"];

            _reloadData(startDate, endDate);

            scrollToItem(newId);
          }
        },
        backgroundColor: dark_purple, // Màu nền nút
        child: const Icon(Icons.add, color: Colors.white), // Icon dấu +
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Đặt nút ở góc dưới bên phải
    );
  }
}
