import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../consts.dart';
import '../util/appController.dart';
import '../util/myHelper.dart';
import '../util/myWidget.dart';
import '../navBar.dart';
import '../bottomSheet.dart';
import '../model/NhanVien.dart';
import '../model/TangCa.dart';
import '../items/item_manage_tang_ca.dart';

class Managetangca extends StatefulWidget {
  final Nhanvien nv;
  const Managetangca({super.key, required this.nv});

  @override
  State<StatefulWidget> createState() => _QuanLyTangCaState();
}

class _QuanLyTangCaState extends State<Managetangca> {
  final Myhelper helper = Myhelper();
  final Appcontroller myController = Appcontroller();
  final Mywidget mywidget = Mywidget();
  final TextEditingController soGioController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Tangca> _listTC = [];
  DateTime? ngayTangCa;
  int selectedIndex = -1;
  int tangCaId = -1;
  int month = 0;
  int year = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    DateTime now = DateTime.now();
    month = now.month;
    year = now.year;
    await _loadTrangTangCa(
        DateTime(now.year, now.month, 1), DateTime(now.year, now.month + 1, 0));
    setState(() => isLoading = false);
  }

  Future<void> _loadTrangTangCa(DateTime ngaybd, DateTime ngaykt) async {
    final data = await myController.fetchTangCa(
        ngaybd, ngaykt, widget.nv.nv_id.toString());
    setState(() {
      month = ngaybd.month;
      year = ngaybd.year;
      _listTC = data;
    });
  }

  void _reloadData(DateTime startDate, DateTime endDate) async {
    await _loadTrangTangCa(startDate, endDate);
    setState(() {
      selectedIndex = -1;
      tangCaId = -1;
      soGioController.text = "";
      ngayTangCa = null;
      isLoading = false;
    });
  }

  Future<int> themTangCa() async {
    try {
      var response = await http.post(
        Uri.parse("${myUrl}addtangca"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ngay": helper.formatToSaveDateTime(ngayTangCa!),
          "sogio": int.parse(soGioController.text),
          "nv_id": widget.nv.nv_id
        }),
      );

      final result = jsonDecode(response.body);
      if (response.statusCode == 201) {
        helper.showToast(result["message"], true);
        return result["tc_id"];
      } else {
        String error = result["error"] != null ? ", ${result["error"]}" : "";
        helper.showToast("${result["message"]}$error", false);
        return -1;
      }
    } catch (e) {
      helper.showToast("Lỗi kết nối server", false);
      return -1;
    }
  }

  Future<int> capNhatTangCa() async {
    try {
      var response = await http.put(
        Uri.parse("${myUrl}updatetangca"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ngay": helper.formatToSaveDateTime(ngayTangCa!),
          "sogio": int.parse(soGioController.text),
          "tc_id": tangCaId
        }),
      );

      final result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        helper.showToast(result["message"], true);
        return tangCaId;
      } else {
        String error = result["error"] != null ? ", ${result["error"]}" : "";
        helper.showToast("${result["message"]}$error", false);
        return -1;
      }
    } catch (e) {
      helper.showToast("Lỗi kết nối server", false);
      return -1;
    }
  }

  Future<bool> xoaTangCa(int tcId) async {
    try {
      final response = await http.delete(
        Uri.parse("${myUrl}deletetangca"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"tc_id": tcId}),
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

  void xuLyThemTangCa() async {
    int kq;
    if (ngayTangCa == null) {
      helper.showToast("không được bỏ trống ngày", false);
      return;
    } else if (ngayTangCa!.isAfter(DateTime.now())) {
      helper.showToast("không được tăng ca trước tương lai", false);
      return;
    } else if (soGioController.text.isEmpty ||
        int.parse(soGioController.text) == 0) {
      helper.showToast("giờ tăng ca không được trống hoặc bằng 0", false);
      return;
    } else if (selectedIndex == -1) {
      kq = await themTangCa();
    } else {
      kq = await capNhatTangCa();
    }

    if (kq != -1) {
      setState(() {
        isLoading = true;
      });
      DateTime firstDayOfMonth =
          DateTime(ngayTangCa!.year, ngayTangCa!.month, 1);
      DateTime lastDayOfMonth =
          DateTime(ngayTangCa!.year, ngayTangCa!.month + 1, 0);
      _reloadData(firstDayOfMonth, lastDayOfMonth);
      await Future.delayed(Duration(milliseconds: 1500));
      int newIndex = _listTC.indexWhere((item) => item.tc_id == kq);
      if (newIndex >= 6) {
        double offset = newIndex * 63.0; //chiều cao item
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
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          drawer: Navbar(
            nv: widget.nv,
          ),
          onDrawerChanged: (isOpened) {
            if (isOpened) {
              FocusScope.of(context).requestFocus(FocusNode());
              // Ép focus vào một FocusNode trống để tránh TextField bị focus lại
            }
          },
          appBar: AppBar(
            centerTitle: true, // Căn giữa tiêu đề
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              "Tăng Ca $month/$year",
              style: const TextStyle(color: white, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon:
                    const Icon(Icons.search, color: Colors.white), // Nút dấu +
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Bottomsheet(
                          tenContext: "QLTC",
                          nv: widget.nv,
                          onSearch: (startDate, endDate) {
                            _loadTrangTangCa(startDate, endDate);
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
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Expanded(
                            child: helper.buildDatePicker(
                                context, "Chọn ngày", ngayTangCa, (date) {
                              setState(() {
                                ngayTangCa = date;
                              });
                            }),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          SizedBox(
                            height: 50,
                            width: 70,
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: "Số giờ",
                                border: OutlineInputBorder(), // Thêm viền
                              ),
                              onChanged: (value) {
                                if (!RegExp(r'^[1-9]\d*$').hasMatch(value)) {
                                  soGioController.text = value.replaceAll(
                                      RegExp(r'[^0-9]'),
                                      ''); // Loại bỏ ký tự không phải số
                                  soGioController.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(
                                        offset: soGioController.text.length),
                                  );
                                }
                              },
                              controller: soGioController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedIndex == -1
                                    ? Colors.purple[700]
                                    : Colors.purple[900],
                                foregroundColor: white,
                                fixedSize: Size.fromWidth(90),
                                elevation: 3, // Độ cao của shadow
                                shadowColor: dark_purple,
                              ),
                              onPressed: () {
                                xuLyThemTangCa();
                              },
                              child: Text(selectedIndex == -1 ? "Thêm" : "Lưu"))
                        ],
                      ),
                    ),
                    Expanded(
                      child: _listTC.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(8),
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: _listTC.length,
                                clipBehavior: Clip
                                    .none, // Cho phép các phần tử render vượt ra ngoài
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 4),
                                      child: ItemTangCa(
                                        tc: _listTC[index],
                                        index: index,
                                        isSelected: selectedIndex == index,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        if (selectedIndex == index) {
                                          // Nếu item đã được chọn, nhấn lại sẽ bỏ chọn
                                          selectedIndex = -1;
                                          tangCaId = -1;
                                          soGioController.text = "";
                                          ngayTangCa = null;
                                        } else {
                                          selectedIndex = index;
                                          tangCaId = _listTC[index].tc_id;
                                          ngayTangCa = _listTC[index].ngay;
                                          soGioController.text =
                                              _listTC[index].sogio.toString();
                                        }
                                      });
                                    },
                                    onLongPress: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Xóa Thông Tin"),
                                            content: Text(
                                                "Bạn có chắc muốn xóa không?"),
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
                                                  bool kq = await xoaTangCa(
                                                      _listTC[index].tc_id);
                                                  if (kq) {
                                                    setState(() {
                                                      if (selectedIndex ==
                                                          index) {
                                                        selectedIndex = -1;
                                                        tangCaId = -1;
                                                        ngayTangCa = null;
                                                        soGioController.text =
                                                            "";
                                                      }
                                                      _listTC.removeAt(index);
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
                    )
                  ],
                ),
        ));
  }
}
