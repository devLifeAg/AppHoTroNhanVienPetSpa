import 'package:app_ho_tro_nhan_vien_pet_spa/consts.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/model/DichVu.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/model/DichVuCon.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/util/myWidget.dart';
import 'package:flutter/material.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/navBar.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/model/ThongTinHoaHong.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/util/myHelper.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/model/NhanVien.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Addedithoahong extends StatefulWidget {
  final Nhanvien nv;
  final Thongtinhoahong? hh;
  final String tieude;
  final DateTime? dt;

  const Addedithoahong(
      {super.key, this.hh, required this.tieude, required this.nv, this.dt});

  @override
  State<StatefulWidget> createState() => _addEditHoaHongState();
}

class _addEditHoaHongState extends State<Addedithoahong> {
  final TextEditingController tenController = TextEditingController();
  final TextEditingController tongTienController = TextEditingController();
  final TextEditingController canNangController = TextEditingController();
  final Myhelper helper = Myhelper();
  final Mywidget mywidget = Mywidget();
  bool selectedPet = true; // Mặc định chọn "Chó"
  int idSelectedService = -1;
  int idSelectedDVC = -1;
  DateTime? selectedDateTime;
  double hoahong = 0.0;
  bool isAddEdit = false;
  List<Dichvu> _listDV = [];
  List<Dichvucon> _listDVCon = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData(); // Gọi một hàm xử lý đồng bộ
  }

  void _initData() async {
    await _loadDichVuChaCon(); // Đợi danh sách được tải xong
    _loadHoaHong(); // Gọi sau khi dữ liệu đã sẵn sàng
    setState(() {
      selectedDateTime = widget.dt ?? DateTime.now();
      isLoading = false; // Dữ liệu đã tải xong
    });
  }

  void _loadHoaHong() {
    if (widget.hh != null) {
      // Tìm dịch vụ con có `dvc_id` khớp với `widget.hh!.dichvucon`
      Dichvucon? dvcon = _listDVCon.firstWhere(
        (dvc) => dvc.dvc_id == widget.hh!.dichvucon,
      );
      setState(() {
        tenController.text = widget.hh!.tt_ten;
        tongTienController.text = helper.formatCurrency(widget.hh!.tt_total);
        canNangController.text = widget.hh!.tt_weight.toString();
        selectedPet = widget.hh!.cho_meo == 1 ? true : false;
        idSelectedService = dvcon.dv_id;
        idSelectedDVC = widget.hh!.dichvucon;
        selectedDateTime = widget.hh!.ngaygio;
        hoahong = widget.hh!.hoa_hong;
      });
    }
  }

  Future<int> themThongTinHoaHong() async {
    try {
      var response = await http.post(
        Uri.parse("${myUrl}addTTHH"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "tt_tenboss": tenController.text.trim(),
          "cho_meo": selectedPet,
          "tt_weight": double.parse(canNangController.text),
          "tt_total": double.parse(
              helper.removeFormatCurrency(tongTienController.text)),
          "dvc_id": idSelectedDVC,
          "ngaygio": helper.formatToSaveDateTime(selectedDateTime!, true),
          "hoa_hong": hoahong,
          "nv_id": widget.nv.nv_id
        }),
      );

      final result = jsonDecode(response.body);
      if (response.statusCode == 201) {
        helper.showToast(result["message"], true);
        return result["tt_id"];
      } else {
        helper.showToast("${result["message"]}, ${result["error"]}", false);
        return -1;
      }
    } catch (e) {
      helper.showToast("Lỗi kết nối server", false);
      return -1;
    }
  }

  Future<int> suaThongTinHoaHong() async {
    try {
      var response = await http.put(
        Uri.parse("${myUrl}updateTTHH"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "tt_id": widget.hh!.tt_id,
          "tt_tenboss": tenController.text.trim(),
          "cho_meo": selectedPet,
          "tt_weight": double.parse(canNangController.text),
          "tt_total": double.parse(
              helper.removeFormatCurrency(tongTienController.text)),
          "dvc_id": idSelectedDVC,
          "ngaygio": helper.formatToSaveDateTime(selectedDateTime!, true),
          "hoa_hong": hoahong,
        }),
      );

      final result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        helper.showToast(result["message"], true);
        return result["tt_id"];
      } else {
        helper.showToast("${result["message"]}, ${result["error"]}", false);
        return -1;
      }
    } catch (e) {
      helper.showToast("Lỗi kết nối server", false);
      return -1;
    }
  }

  Future<void> _loadDichVuChaCon() async {
    final data = await _fetchAllDichVuChaCon();
    setState(() {
      if (data["dichvucha"] != null && data["dichvucon"] != null) {
        _listDV = (data["dichvucha"] as List)
            .map((dv) => Dichvu.fromJson(dv))
            .toList();
        _listDVCon = (data["dichvucon"] as List)
            .map((dvc) => Dichvucon.fromJson(dvc))
            .toList();
      }
    });
  }

  Future<Map<String, dynamic>> _fetchAllDichVuChaCon() async {
    try {
      final url = "${myUrl}getdichvuchacon";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        return {
          "dichvucha": result["dichvucha"],
          "dichvucon": result["dichvucon"],
        };
      } else {
        helper.showToast("Lỗi kết nối server", false);
        return {
          "listhoahong": [],
          "listdichvucon": [],
        };
      }
    } catch (e) {
      helper.showToast("Lỗi: ${e.toString()}", false);
      return {
        "listhoahong": [],
        "listdichvucon": [],
      };
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime, // Mặc định là ngày hiện tại
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(selectedDateTime!), // Mặc định giờ hiện tại
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _formatAndCalculateCommission() {
    String input =
        helper.removeFormatCurrency(tongTienController.text); // Xóa dấu phẩy cũ
    double total = double.tryParse(input) ?? 0.0;

    // Tìm dịch vụ đang chọn
    double commissionRate = 0.0;
    if (idSelectedDVC != -1) {
      Dichvucon? dvcon = _listDVCon.firstWhere(
        (dvc) => dvc.dvc_id == idSelectedDVC,
      );
      commissionRate = dvcon.tiLeHoaHong;
    }

    // Tính tiền hoa hồng
    setState(() {
      hoahong = total * commissionRate;
      tongTienController.text =
          helper.formatCurrency(total); // Format lại số tiền
      tongTienController.selection = TextSelection.fromPosition(
        TextPosition(
            offset: tongTienController.text.length), // Giữ con trỏ ở cuối
      );
    });
  }

  bool validateInput() {
    if (tenController.text.trim().isEmpty) {
      helper.showToast("tên boss bị trống", false);
      return false;
    } else if (tenController.text.trim().length < 2 ||
        tenController.text.trim().length > 18) {
      helper.showToast("tên boss phải từ 2 - 18 kí tự", false);
      return false;
    } else if (tongTienController.text.isEmpty ||
        double.parse(helper.removeFormatCurrency(tongTienController.text)) <
            30000) {
      helper.showToast("tổng tiền không được rỗng hoặc dưới 30,000đ", false);
      return false;
    } else if (canNangController.text.isEmpty ||
        double.parse(canNangController.text) == 0.0) {
      helper.showToast("cân nặng không được rỗng", false);
      return false;
    } else if (idSelectedDVC == -1) {
      helper.showToast("chưa chọn dịch vụ làm", false);
      return false;
    } else if (selectedDateTime!.isAfter(DateTime.now())) {
      helper.showToast("bạn không được đi trước tương lai", false);
      return false;
    }
    return true;
  }

  Future<void> xuLyThemSua() async {
    if (!validateInput()) {
      return;
    }

    setState(() {
      isAddEdit = true;
    });

    int id;
    if (widget.hh == null) {
      id = await themThongTinHoaHong();
    } else {
      id = await suaThongTinHoaHong();
    }

    setState(() {
      isAddEdit = false;
    });

    if (id != -1) {
      Navigator.pop(context, {
        "Id": id,
        "startDate": selectedDateTime,
        "endDate": selectedDateTime,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
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
              widget.tieude,
              style: const TextStyle(color: white, fontWeight: FontWeight.bold),
            ),
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextField(
                          // controller: manvController,
                          decoration: const InputDecoration(
                            labelText: "Tên Boss",
                            border: OutlineInputBorder(), // Thêm viền
                          ),
                          controller: tenController,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Row(
                                    children: [
                                      Radio<bool>(
                                        value: true,
                                        groupValue: selectedPet,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedPet = value!;
                                            idSelectedService = -1;
                                            idSelectedDVC = -1;
                                            _formatAndCalculateCommission();
                                          });
                                        },
                                      ),
                                      Image.asset(
                                        iconDog,
                                        width: 18,
                                        height: 18,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      width: 10), // Khoảng cách giữa 2 lựa chọn
                                  Row(
                                    children: [
                                      Radio<bool>(
                                        value: false,
                                        groupValue: selectedPet,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedPet = value!;
                                            idSelectedService = -1;
                                            idSelectedDVC = -1;
                                            _formatAndCalculateCommission();
                                          });
                                        },
                                      ),
                                      Image.asset(
                                        iconCat,
                                        width: 18,
                                        height: 18,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                // controller: manvController,
                                decoration: const InputDecoration(
                                  labelText: "Tổng tiền",
                                  border: OutlineInputBorder(), // Thêm viền
                                  suffixText: "đ",
                                ),
                                onChanged: (value) {
                                  _formatAndCalculateCommission();
                                },
                                controller: tongTienController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: TextField(
                                // controller: manvController,
                                decoration: const InputDecoration(
                                  labelText: "Cân nặng",
                                  border: OutlineInputBorder(), // Thêm viền
                                  suffixText: "kg",
                                ),
                                onChanged: (value) {
                                  canNangController.text =
                                      helper.filterCanNangInput(value);
                                  canNangController.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(
                                        offset: canNangController
                                            .text.length), // Giữ con trỏ ở cuối
                                  );
                                },
                                controller: canNangController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                decoration: const InputDecoration(
                                  labelText: "Loại dịch vụ",
                                  border: OutlineInputBorder(),
                                ),
                                value: idSelectedService == -1
                                    ? null
                                    : idSelectedService,
                                items: _listDV
                                    .where((dv) => selectedPet
                                        ? dv.forDog == 1
                                        : dv.forCat == 1) // Lọc theo loại pet
                                    .map((Dichvu dv) {
                                  return DropdownMenuItem<int>(
                                    // Đảm bảo chỉ chứa int
                                    value: dv.dv_id,
                                    child: Text(
                                      dv.tenDichVu,
                                      style: TextStyle(
                                        color: idSelectedService == dv.dv_id
                                            ? Colors.blue
                                            : Colors.black, // Màu khi được chọn
                                        fontWeight:
                                            idSelectedService == dv.dv_id
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    ), // Hiển thị tên dịch vụ
                                  );
                                }).toList(),
                                onChanged: (int? value) {
                                  setState(() {
                                    idSelectedService =
                                        _listDV[value! - 1].dv_id;
                                    idSelectedDVC = -1;
                                    _formatAndCalculateCommission();
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: "Dịch vụ làm",
                            border: OutlineInputBorder(),
                          ),
                          value: idSelectedDVC == -1
                              ? null
                              : idSelectedDVC, // Tránh lỗi null
                          items: _listDVCon
                              .where((dvc) =>
                                  (selectedPet
                                      ? dvc.forDog == 1
                                      : dvc.forCat == 1) &&
                                  dvc.dv_id ==
                                      idSelectedService) // Lọc theo loại pet
                              .map((Dichvucon dvc) {
                            return DropdownMenuItem<int>(
                              // Đảm bảo chỉ chứa int
                              value: dvc.dvc_id,
                              child: Text(
                                dvc.tendichvucon,
                                style: TextStyle(
                                  color: idSelectedDVC == dvc.dvc_id
                                      ? Colors.blue
                                      : Colors.black, // Màu khi được chọn
                                  fontWeight: idSelectedDVC == dvc.dvc_id
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ), // Hiển thị tên dịch vụ
                            );
                          }).toList(),
                          onChanged: (int? value) {
                            setState(() {
                              idSelectedDVC = _listDVCon[value! - 1].dvc_id;
                              _formatAndCalculateCommission();
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextField(
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Chọn ngày giờ",
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_month),
                          ),
                          controller: TextEditingController(
                            text: helper.formatDateTime(selectedDateTime!),
                          ),
                          onTap: () => _selectDateTime(context),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              "Tỉ lệ: ${idSelectedDVC == -1 ? 0 : helper.formatTiLeHoaHong(_listDVCon[idSelectedDVC - 1].tiLeHoaHong)}%",
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: dark_purple,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Hoa hồng: ${helper.formatCurrency(hoahong)}đ",
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: dark_purple),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: white,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Hủy")),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: white,
                              ),
                              onPressed: isAddEdit
                                  ? null
                                  : () async {
                                      xuLyThemSua();
                                    },
                              child: const Text("Lưu"))
                        ],
                      )
                    ],
                  ),
                ),
        ));
  }
}
