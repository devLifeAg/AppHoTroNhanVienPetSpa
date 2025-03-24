class Dichvucon {
  int dvc_id;
  String tendichvucon;
  int forDog;
  int forCat;
  double tiLeHoaHong;
  int dv_id;

  Dichvucon(
      {required this.dvc_id,
      required this.tendichvucon,
      required this.forDog,
      required this.forCat,
      required this.tiLeHoaHong,
      required this.dv_id});

  factory Dichvucon.fromJson(Map<String, dynamic> json) {
    return Dichvucon(
        dvc_id: json["dvc_id"],
        tendichvucon: json["tendichvucon"],
        forDog: json["forDog"],
        forCat: json["forCat"],
        tiLeHoaHong: json["tilehh"],
        dv_id: json["dv_id"]);
  }
}