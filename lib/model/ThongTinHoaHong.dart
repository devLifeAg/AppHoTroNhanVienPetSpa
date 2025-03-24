import 'package:app_ho_tro_nhan_vien_pet_spa/consts.dart';

class Thongtinhoahong {
  int tt_id, nv_id, dichvucon;
  int cho_meo;
  String tt_ten;
  double tt_weight, tt_total, hoa_hong;
  DateTime ngaygio;

  Thongtinhoahong(
      {required this.tt_id,
      required this.tt_ten,
      required this.cho_meo,
      required this.tt_weight,
      required this.tt_total,
      required this.dichvucon,
      required this.ngaygio,
      required this.hoa_hong,
      required this.nv_id});

factory Thongtinhoahong.fromJson(Map<String, dynamic> json) {
    return Thongtinhoahong(
        tt_id: json["tt_id"],
        tt_ten: json["tt_tenboss"],
        cho_meo: json["cho_meo"],
        tt_weight: json["tt_weight"].toDouble(),
        tt_total: json["tt_total"].toDouble(),
        dichvucon: json["dvc_id"],
        ngaygio: DateTime.parse(json["ngaygio"]),
        hoa_hong: json["hoa_hong"].toDouble(),
        nv_id: json["nv_id"],
        );
  }

  String IconItem() {
    String iconPath = "";
    iconPath = cho_meo==1 ? iconDog : iconCat;
    return iconPath;
  }

  @override
  String toString() {
    return "ID: $tt_id\n"
        "Tên: $tt_ten\n"
        "Là con: $cho_meo\n"
        "Cân nặng: $tt_weight kg\n"
        "Tổng tiền: $tt_total VND\n"
        "Dịch vụ: $dichvucon\n"
        "Hoa hồng: $hoa_hong\n"
        "Ngày giờ: $ngaygio";
  }
}
