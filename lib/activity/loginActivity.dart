import 'package:app_ho_tro_nhan_vien_pet_spa/consts.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/model/NhanVien.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_ho_tro_nhan_vien_pet_spa/util/myHelper.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/activity/ManageHoaHong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final TextEditingController userName = TextEditingController();
  final TextEditingController passWord = TextEditingController();
  final Myhelper helper = Myhelper();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [dark_purple, light_purple]),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(size.height * 0.030),
            child: Column(
              children: [
                Image.asset(mainImage),
                const Text(
                  "Xin Chào Bạn!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 34,
                    color: white,
                  ),
                ),
                SizedBox(height: size.height * 0.024),
                TextField(
                  style: const TextStyle(
                    color: inputColor,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    hintText: "Tên đăng nhập",
                    prefixIcon: Icon(Icons.person_outline),
                    fillColor: white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(37),
                    ),
                  ),
                  controller: userName,
                ),
                SizedBox(height: size.height * 0.020),
                TextField(
                  obscureText: true,
                  style: const TextStyle(
                    color: inputColor,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    hintText: "Mật khẩu",
                    prefixIcon: Icon(Icons.key),
                    fillColor: white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(37),
                    ),
                  ),
                  controller: passWord,
                ),
                SizedBox(height: size.height * 0.020),
                CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: size.height * 0.080,
                      decoration: BoxDecoration(
                        color: dark_purple,
                        borderRadius: BorderRadiusDirectional.circular(37),
                      ),
                      child: const Text(
                        "Đăng Nhập",
                        style: TextStyle(
                            color: white, fontWeight: FontWeight.w700),
                      ),
                    ),
                    onPressed: (){
                      // helper.showToast("${myUrl}", false);
                      // print("${myUrl}login");
                      _dangNhap();
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveNhanVien(Nhanvien nhanvien, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String nhanvienJson =
        jsonEncode(nhanvien.toJson()); // Chuyển đối tượng thành JSON
    await prefs.setString('nhanvien', nhanvienJson);
    await prefs.setString('username', nhanvien.username);
    await prefs.setString('password', password);
  }

  void _dangNhap() async {
    final nv = await _getNhanVien(userName.text, passWord.text);
    if (nv != null) {
      saveNhanVien(nv, passWord.text);
      helper.showToast("Đăng nhập thành công", true);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Managehoahong(nv: nv,)),
        );
      }
    }
  }

  Future<Nhanvien?> _getNhanVien(String username, String password) async {
    final response = await http.post(
      Uri.parse("${myUrl}login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result["success"]) {
        return Nhanvien.fromJson(result["nhanvien"]);
      } else {
        helper.showToast("Sai tài khoản hoặc mật khẩu", false);
        return null;
      }
    } else {
      helper.showToast("Lỗi kết nối server", false);
      return null;
    }
  }
}
