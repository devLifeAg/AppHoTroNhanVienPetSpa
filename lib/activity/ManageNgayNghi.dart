import 'package:app_ho_tro_nhan_vien_pet_spa/consts.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/items/item_manage_ngay_nghi.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/model/NgayNghi.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/util/appController.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/util/myWidget.dart';
import 'package:flutter/material.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/navBar.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/bottomSheet.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/util/myHelper.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/model/NhanVien.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Managengaynghi extends StatefulWidget {
  final Nhanvien nv;
  const Managengaynghi({super.key, required this.nv});

  @override
  State<StatefulWidget> createState() => _QuanLyNgayNghiState();
}

class _QuanLyNgayNghiState extends State<Managengaynghi> {
  final Myhelper helper = Myhelper();
  final Appcontroller myController = Appcontroller();
  final Mywidget mywidget = Mywidget();
  final ScrollController _scrollController = ScrollController();

  DateTime? ngayNghi;
  int selectedIndex = -1;
  List<Ngaynghi> _listNN = [];
  int ngayNghiId = -1;
  bool isLoading = true;
  int month = 0;
  int year = 0;

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
    await _loadTrangNgayNghi(firstDayOfMonth, lastDayOfMonth);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadTrangNgayNghi(DateTime ngaybd, DateTime ngaykt) async {
    String id = widget.nv.nv_id.toString();
    final data = await myController.fetchNgayNghi(ngaybd, ngaykt, id);
    setState(() {
      month = ngaybd.month;
      year = ngaybd.year;
      _listNN = data;
    });
  }

  void _reloadData(DateTime startDate, DateTime endDate) async {
    await _loadTrangNgayNghi(startDate, endDate);
    setState(() {
      selectedIndex = -1;
      ngayNghiId = -1;
      ngayNghi = null;
      isLoading = false;
    });
  }

  Future<int> themNgayNghi() async {
    try {
      var response = await http.post(
        Uri.parse("${myUrl}addngaynghi"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ngay_off": helper.formatToSaveDateTime(ngayNghi!),
          "nv_id": widget.nv.nv_id
        }),
      );

      final result = jsonDecode(response.body);
      if (response.statusCode == 201) {
        helper.showToast(result["message"], true);
        return result["nn_id"];
      } else {
        helper.showToast("${result["message"]}, ${result["error"]}", false);
        return -1;
      }
    } catch (e) {
      helper.showToast("Lỗi kết nối server", false);
      return -1;
    }
  }

  Future<int> capNhatNgayNghi() async {
    try {
      var response = await http.put(
        Uri.parse("${myUrl}updatengaynghi"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ngay_off": helper.formatToSaveDateTime(ngayNghi!),
          "nn_id": ngayNghiId
        }),
      );

      final result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        helper.showToast(result["message"], true);
        return ngayNghiId;
      } else {
        helper.showToast("${result["message"]}, ${result["error"]}", false);
        return -1;
      }
    } catch (e) {
      helper.showToast("Lỗi kết nối server", false);
      return -1;
    }
  }

  Future<bool> xoaNgayNghi(int nnId) async {
    try {
      final response = await http.delete(
        Uri.parse("${myUrl}deletengaynghi"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"nn_id": nnId}),
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
      return true;
    }
  }

  void xuLyThemNgayNghi() async {
    int kq;
    if(ngayNghi == null){
      helper.showToast("ngày nghỉ không được trống", false);
      return;
    }else if (ngayNghi!.isAfter(DateTime.now())) {
      helper.showToast("không được nghỉ trước tương lai", false);
      return;
    } else if (selectedIndex == -1) {
      kq = await themNgayNghi();
    } else {
      kq = await capNhatNgayNghi();
    }
    
    if (kq != -1) {
      setState(() {
        isLoading = true;
      });
      DateTime firstDayOfMonth = DateTime(ngayNghi!.year, ngayNghi!.month, 1);
      DateTime lastDayOfMonth =
          DateTime(ngayNghi!.year, ngayNghi!.month + 1, 0);
      _reloadData(firstDayOfMonth, lastDayOfMonth);
      await Future.delayed(Duration(milliseconds: 1500));
      int newIndex = _listNN.indexWhere((item) => item.nn_id == kq);
      if (newIndex >= 8) {
        double offset = newIndex * 42.0; //chiều cao item
        double maxScroll = _scrollController.position.maxScrollExtent;

        _scrollController.animateTo(
          offset > maxScroll ? maxScroll : offset,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
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
        title: Text(
          "Ngày Nghỉ $month/$year",
          style: const TextStyle(color: white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white), // Nút dấu +
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Bottomsheet(
                    tenContext: "QLNN",
                    nv: widget.nv,
                    onSearch: (startDate, endDate) {
                      _loadTrangNgayNghi(startDate, endDate);
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
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: helper.buildDatePicker(
                            context, "Chọn ngày nghỉ", ngayNghi, (date) {
                          setState(() {
                            ngayNghi = date;
                          });
                        }),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedIndex == -1
                                ? light_purple
                                : Colors.deepPurple[400],
                            foregroundColor: white,
                            fixedSize: Size.fromWidth(
                              90,
                            ),
                            elevation: 3, // Độ cao của shadow
                            shadowColor: dark_purple,
                          ),
                          onPressed: () {
                            xuLyThemNgayNghi();
                          },
                          child: Text(selectedIndex == -1 ? "Thêm" : "Lưu"))
                    ],
                  ),
                ),
                Expanded(
                  child: _listNN.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 10, 8),
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: _listNN.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                child: ItemNgayNghi(
                                  nn: _listNN[index],
                                  index: index,
                                  isSelected: selectedIndex == index,
                                ),
                                onTap: () {
                                  setState(() {
                                    if (selectedIndex == index) {
                                      // Nếu item đã được chọn, nhấn lại sẽ bỏ chọn
                                      selectedIndex = -1;
                                      ngayNghiId = -1;
                                      ngayNghi = null;
                                    } else {
                                      selectedIndex = index;
                                      ngayNghi = _listNN[index].ngay_off;
                                      ngayNghiId = _listNN[index].nn_id;
                                    }
                                  });
                                },
                                onLongPress: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Xóa Ngày Nghỉ"),
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
                                              bool kq = await xoaNgayNghi(
                                                  _listNN[index].nn_id);
                                              if (kq) {
                                                setState(() {
                                                  if (selectedIndex == index) {
                                                    selectedIndex = -1;
                                                    ngayNghiId = -1;
                                                    ngayNghi = null;
                                                  }
                                                  _listNN.removeAt(index);
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
                          ),
                        )
                      : const Center(
                          child: Text("Danh sách trống!"),
                        ),
                ),
              ],
            ),
    );
  }
}
