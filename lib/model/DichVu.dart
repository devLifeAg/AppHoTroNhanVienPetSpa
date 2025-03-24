class Dichvu {
  int dv_id;
  String tenDichVu;
  int forDog;
  int forCat;

  Dichvu(
      {required this.dv_id,
      required this.tenDichVu,
      required this.forDog,
      required this.forCat});

  factory Dichvu.fromJson(Map<String, dynamic> json) {
    return Dichvu(
        dv_id: json["dv_id"],
        tenDichVu: json["tendichvu"],
        forDog: json["forDog"],
        forCat: json["forCat"]
    );
  }
  String getTenDichVu() {
    return tenDichVu;
  }
}
