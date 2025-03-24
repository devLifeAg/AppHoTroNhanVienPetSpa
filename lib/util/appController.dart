import 'package:app_ho_tro_nhan_vien_pet_spa/model/TangCa.dart';
import 'package:intl/intl.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/model/NgayNghi.dart';
import 'dart:convert';
import 'package:app_ho_tro_nhan_vien_pet_spa/util/myHelper.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/consts.dart';
import 'package:http/http.dart' as http;

class Appcontroller {
  final Myhelper helper = Myhelper();

  Future<Map<String, dynamic>> fetchAllThongTinHoaHong(
      String id, DateTime ngaybd, DateTime ngaykt) async {
    try {
      String startDate =
          Uri.encodeComponent(DateFormat("yyyy-MM-dd 00:00:00").format(ngaybd));
      String endDate =
          Uri.encodeComponent(DateFormat("yyyy-MM-dd 23:59:59").format(ngaykt));

      final url =
          "${myUrl}thongtinhoahong?id=$id&ngaybd=$startDate&ngaykt=$endDate";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        return {
          "listhoahong": result["listhoahong"],
          "listdichvucon": result["listdichvucon"],
        };
      } else {
        helper.showToast("Lỗi kết nối server", false);
        return {
          "listhoahong": [],
          "listdichvucon": {},
        };
      }
    } catch (e) {
      helper.showToast("Lỗi: ${e.toString()}", false);
      return {
        "listhoahong": [],
        "listdichvucon": {},
      };
    }
  }

  Future<List<Ngaynghi>> fetchNgayNghi(DateTime ngaybd, DateTime ngaykt, String nvId) async {
    String startDate =
          Uri.encodeComponent(DateFormat("yyyy-MM-dd 00:00:00").format(ngaybd));
      String endDate =
          Uri.encodeComponent(DateFormat("yyyy-MM-dd 23:59:59").format(ngaykt));
    final String apiUrl =
        "${myUrl}getngaynghi?ngaybd=$startDate&ngaykt=$endDate&id=$nvId";
    try {
      final response = await http.get(Uri.parse(apiUrl));

      final result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Iterable data = result['listngaynghi'];
        return data.map((item) => Ngaynghi.fromJson(item)).toList();
      } else {
        String error = result["error"] != null ? ", ${result["error"]}" : "";
        helper.showToast(result["message"] + error, false);
        return [];
      }
    } catch (e) {
      helper.showToast("Lỗi kết nối server", false);
      return [];
    }
  }

  Future<List<Tangca>> fetchTangCa(DateTime ngaybd, DateTime ngaykt, String nvId) async {
    String startDate =
          Uri.encodeComponent(DateFormat("yyyy-MM-dd 00:00:00").format(ngaybd));
      String endDate =
          Uri.encodeComponent(DateFormat("yyyy-MM-dd 23:59:59").format(ngaykt));
    final String apiUrl =
        "${myUrl}gettangca?ngaybd=$startDate&ngaykt=$endDate&id=$nvId";
    try {
      final response = await http.get(Uri.parse(apiUrl));

      final result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Iterable data = result['listtangca'];
        // print("error: ${result["error"]}");
        return data.map((item) => Tangca.fromJson(item)).toList();
        
      } else {
        // print("error: ${result["error"]}");
        String error = result["error"] != null ? ", ${result["error"]}" : "";
        helper.showToast(result["message"] + error, false);
        return [];
      }
    } catch (e) {
      helper.showToast("Lỗi kết nối server", false);
      return [];
    }
  }

  
}
