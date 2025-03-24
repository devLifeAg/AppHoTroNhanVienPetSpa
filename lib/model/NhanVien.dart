class Nhanvien {
  int nv_id;
  String username;
  String name;
  String chucvu;

  Nhanvien(
      {required this.nv_id,
      required this.username,
      required this.name,
      required this.chucvu});

  factory Nhanvien.fromJson(Map<String, dynamic> json) {
    return Nhanvien(
        nv_id: json["nv_id"],
        username: json["nv_username"],
        name: json["nv_name"],
        chucvu: json["nv_chucvu"]);
  }

  // Chuyển đổi từ Object sang JSON
  Map<String, dynamic> toJson() {
    return {
      'nv_id': nv_id,
      'nv_username': username,
      'nv_name': name,
      'nv_chucvu': chucvu,
    };
  }
}
