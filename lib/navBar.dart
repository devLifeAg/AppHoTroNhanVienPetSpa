import 'package:app_ho_tro_nhan_vien_pet_spa/activity/ManageHoaHong.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/activity/ManageNgayNghi.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/activity/ManageTangCa.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/activity/PhanTichTaiChinh.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/activity/XemLuong.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/activity/loginActivity.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/consts.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/model/NhanVien.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/util/myHelper.dart';

class Navbar extends StatefulWidget {
  final Nhanvien nv;
  const Navbar({super.key, required this.nv});
  @override
  State<StatefulWidget> createState() => _NavBarState();
}

class _NavBarState extends State<Navbar> with WidgetsBindingObserver {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSelectedIndex();
  }

    @override
  void dispose() {
    super.dispose();
  }

  void _loadSelectedIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedIndex = prefs.getInt('selectedIndex') ?? 0; // Lấy giá trị đã lưu
    });
  }

  void _saveSelectedIndex(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedIndex', index); // Lưu giá trị mới
  }

  void navigateTo(int index, Widget page) {
    if (selectedIndex == index) return; // Không điều hướng nếu đang ở trang đó

    setState(() {
      selectedIndex = index;
    });
    _saveSelectedIndex(index); // Lưu trạng thái khi chuyển trang

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then((_) {
      _loadSelectedIndex(); // Khi quay lại, load lại trạng thái
    });
  }

  @override
  Widget build(BuildContext context) {
    final Myhelper helper = Myhelper();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              widget.nv.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(widget.nv.chucvu),
            currentAccountPicture: Image.asset(mainImage),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [dark_purple, light_purple]),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: Text(
              "Hoa hồng",
              style: TextStyle(
                  fontWeight:
                      selectedIndex == 0 ? FontWeight.bold : FontWeight.normal),
            ),
            selected: selectedIndex ==
                0, // Kiểm tra nếu màn hình hiện tại là Hoa hồng
            selectedTileColor: Colors.purple.shade100, // Màu khi được chọn
            onTap: () => navigateTo(0, Managehoahong(nv: widget.nv)),
          ),
          ListTile(
            leading: const Icon(Icons.work_off),
            title: Text(
              "Ngày nghỉ",
              style: TextStyle(
                  fontWeight:
                      selectedIndex == 1 ? FontWeight.bold : FontWeight.normal),
            ),
            selected: selectedIndex == 1,
            selectedTileColor: Colors.purple.shade100,
            onTap: () => navigateTo(1, Managengaynghi(nv: widget.nv)),
          ),
          ListTile(
            leading: const Icon(Icons.more_time),
            title: Text(
              "Tăng ca",
              style: TextStyle(
                  fontWeight:
                      selectedIndex == 2 ? FontWeight.bold : FontWeight.normal),
            ),
            selected: selectedIndex == 2,
            selectedTileColor: Colors.purple.shade100,
            onTap: () => navigateTo(2, Managetangca(nv: widget.nv)),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: Text(
              "Lương",
              style: TextStyle(
                  fontWeight:
                      selectedIndex == 3 ? FontWeight.bold : FontWeight.normal),
            ),
            selected: selectedIndex == 3,
            selectedTileColor: Colors.purple.shade100,
            onTap: () => navigateTo(3, Xemluong(nv: widget.nv)),
          ),
          ListTile(
              leading: const Icon(Icons.equalizer),
              title: Text(
                "Phân tích thu nhập",
                style: TextStyle(
                    fontWeight: selectedIndex == 4
                        ? FontWeight.bold
                        : FontWeight.normal),
              ),
              selected: selectedIndex == 4,
              selectedTileColor: Colors.purple.shade100,
              onTap: () {
                navigateTo(4, Phantichtaichinh(nv: widget.nv));
              }),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Đăng xuất"),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove("username");
              await prefs.remove("password");
              await prefs.remove("nhanvien");
              await prefs.remove("selectedIndex");
              helper.showToast("đăng xuất thành công", true);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
