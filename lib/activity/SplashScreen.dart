import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/activity/ManageHoaHong.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/activity/loginActivity.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/util/myHelper.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/consts.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/activity/ManageNgayNghi.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/activity/ManageTangCa.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/activity/XemLuong.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/activity/PhanTichTaiChinh.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/model/NhanVien.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Myhelper helper = Myhelper();
  late final Map<int, Widget Function(Nhanvien)> _pages;

  @override
  void initState() {
    super.initState();
    _pages = {
      0: (nv) => Managehoahong(nv: nv),
      1: (nv) => Managengaynghi(nv: nv),
      2: (nv) => Managetangca(nv: nv),
      3: (nv) => Xemluong(nv: nv),
      4: (nv) => Phantichtaichinh(nv: nv),
    };
    _autoLogin();
  }

  Future<void> _autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString("username");
    String? savedPassword = prefs.getString("password");

    if (savedUsername != null && savedPassword != null) {
      var nv = await helper.getNhanVien();
      if (nv != null) {
        int selectedIndex =
            prefs.getInt('selectedIndex') ?? 0; // Lấy giá trị đã lưu
        _navigateToPage(_pages[selectedIndex]!(nv));
        return;
      }
    }
    _navigateToPage(const LoginPage());
  }

  void _navigateToPage(Widget page) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [dark_purple, light_purple]),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hiệu ứng tải
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 20),

          Text(
            "Đang kiểm tra...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ));
  }
}
