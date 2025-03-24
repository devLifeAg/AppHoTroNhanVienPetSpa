import 'package:app_ho_tro_nhan_vien_pet_spa/consts.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/util/myHelper.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/util/myWidget.dart';
import 'package:flutter/material.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/navBar.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/model/NhanVien.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';

class Phantichtaichinh extends StatefulWidget {
  final Nhanvien nv;
  const Phantichtaichinh({super.key, required this.nv});
  @override
  State<StatefulWidget> createState() => _PhanTichTaiChinhState();
}

class _PhanTichTaiChinhState extends State<Phantichtaichinh> {
  final Myhelper helper = Myhelper();
  final Mywidget mywidget = Mywidget();
  final TextEditingController moneyController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  String selectedOption = "tháng";
  String? aiResponse;
  bool isLoading = false;

  void fetchAIResponse(String money, String time) async {
    setState(() {
      isLoading = true; // Hiển thị loading khi bắt đầu gọi API
    });
    final url = Uri.parse("${myUrl}phantich");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"money": money, "time": time}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        aiResponse = jsonResponse['choices'][0]['message']['content'];
      } else {
        helper.showToast("Lỗi: ${response.statusCode}", false);
        // throw Exception("Lỗi: ${response.statusCode}");
      }
    } catch (e) {
      helper.showToast("Lỗi khi gọi API: $e", false);
    }
    setState(() {
      isLoading = false; // Hiển thị loading khi bắt đầu gọi API
    });
  }

  Future<String> callAiPhanTichTaiChinh(String money, String time) async {
    final url = Uri.parse("${myUrl}phantich");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"money": money, "time": time}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['choices'][0]['message']['content'];
      } else {
        helper.showToast("Lỗi: ${response.statusCode}", false);
        return "";
        // throw Exception("Lỗi: ${response.statusCode}");
      }
    } catch (e) {
      helper.showToast("Lỗi khi gọi API: $e", false);
      return "";
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
              title: const Text(
                "AI Phân Tích Tài Chính",
                style: TextStyle(color: white, fontWeight: FontWeight.bold),
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
            body: SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      // controller: manvController,
                      decoration: const InputDecoration(
                        labelText: "Mức thu nhập muốn đạt",
                        border: OutlineInputBorder(), // Thêm viền
                        suffixText: "đ",
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (!RegExp(r'^[1-9]\d*$').hasMatch(value)) {
                            moneyController.text = value.replaceAll(
                                RegExp(r'[^0-9]'),
                                ''); // Loại bỏ ký tự không phải số
                            moneyController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: moneyController.text.length),
                            );
                          }
                          setState(() {
                            moneyController.text = helper.formatCurrency(
                                double.parse(moneyController
                                    .text)); // Format lại số tiền
                            moneyController.selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                  offset: moneyController
                                      .text.length), // Giữ con trỏ ở cuối
                            );
                          });
                        }
                      },
                      keyboardType: TextInputType.number,
                      controller: moneyController,
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextField(
                            // controller: manvController,
                            decoration: const InputDecoration(
                              labelText: "Thời gian",
                              border: OutlineInputBorder(), // Thêm viền,
                            ),
                            onChanged: (value) {
                              if (!RegExp(r'^[1-9]\d*$').hasMatch(value)) {
                                timeController.text = value.replaceAll(
                                    RegExp(r'[^0-9]'),
                                    ''); // Loại bỏ ký tự không phải số
                                timeController.selection =
                                    TextSelection.fromPosition(
                                  TextPosition(
                                      offset: timeController.text.length),
                                );
                              }
                            },
                            keyboardType: TextInputType.number,
                            controller: timeController,
                          ),
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: "tháng/năm",
                            border: OutlineInputBorder(),
                          ),
                          value: selectedOption == "" ? null : selectedOption,
                          items: ["tháng", "năm"].map((String option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(
                                option,
                                style: TextStyle(
                                  color: selectedOption == option
                                      ? Colors.blue
                                      : Colors.black,
                                  fontWeight: selectedOption == option
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedOption = value!;
                            });
                          },
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(8),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple[400],
                                foregroundColor: white,
                                elevation: 3, // Độ cao của shadow
                                shadowColor: dark_purple,
                                fixedSize: Size.fromWidth(
                                  116,
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      int money = int.parse(
                                          helper.removeFormatCurrency(
                                              moneyController.text));
                                      if (money < 6000000) {
                                        helper.showToast(
                                            "Số tiền không được rỗng và phải lớn hơn 6 triệu!",
                                            false);
                                        return;
                                      }
                                      if (timeController.text.isEmpty ||
                                          int.parse(timeController.text) < 1) {
                                        helper.showToast(
                                            "thời gian không được rỗng và phải lớn hơn 1!",
                                            false);
                                        return;
                                      }
                                      String time =
                                          "${timeController.text} $selectedOption";
                                      fetchAIResponse(money.toString(), time);
                                      FocusScope.of(context).unfocus();
                                    },
                              child: const Text("Phân tích")))
                    ],
                  ),
                  isLoading
                      ? mywidget.Loading()
                      : aiResponse == null
                          ? Container()
                          : aiResponse!.isEmpty
                              ? const Text("Có lỗi xảy ra vui lòng thử lại!")
                              : Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Container(
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color.fromARGB(255, 130, 55, 201),
                                              Color.fromARGB(255, 77, 47, 129)
                                            ]),
                                        borderRadius:
                                            BorderRadius.circular(12), // Bo góc
                                        boxShadow: [
                                          BoxShadow(
                                            color: dark_purple
                                                .withOpacity(0.8), // Bóng mờ
                                            blurRadius: 8, // Độ mờ của bóng
                                            offset: Offset(6,
                                                6), // Độ dịch chuyển của bóng (X,Y)
                                          ),
                                        ],
                                      ), // Tạo khoảng cách với viền ngoài
                                      child: Column(
                                        children: [
                                          Text(
                                            "AI trả lời:",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: white),
                                          ),
                                          MarkdownBody(
                                            data: aiResponse!,
                                            styleSheet: MarkdownStyleSheet(
                                              p: const TextStyle(
                                                  color: Colors
                                                      .white), // Đổi màu chữ thường sang trắng
                                              h1: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold),
                                              h2: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold),
                                              h3: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                              strong: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                              em: const TextStyle(
                                                  color: Colors.white,
                                                  fontStyle: FontStyle.italic),
                                              code: const TextStyle(
                                                  color: Colors.white,
                                                  backgroundColor: Colors.grey),
                                              listBullet: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          )
                                          // MarkdownLatexRenderer(content: aiResponse!)
                                        ],
                                      )))
                ],
              ),
            ))));
  }
}
