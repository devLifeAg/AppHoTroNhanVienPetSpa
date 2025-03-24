class Tangca {
  int tc_id;
  DateTime ngay;
  int sogio, nv_id;

  Tangca({required this.tc_id, required this.ngay, required this.sogio, required this.nv_id});

    factory Tangca.fromJson(Map<String, dynamic> json) {
    return Tangca(
        tc_id: json["tc_id"],
        ngay: DateTime.parse(json["ngay"]),
        sogio: json["sogio"],
        nv_id: json["nv_id"]);
  }
}