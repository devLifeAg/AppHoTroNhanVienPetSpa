class Ngaynghi {
  int nn_id, nv_id;
  DateTime ngay_off;

  Ngaynghi({required this.nn_id, required this.ngay_off, required this.nv_id});

    factory Ngaynghi.fromJson(Map<String, dynamic> json) {
    return Ngaynghi(
        nn_id: json["nn_id"],
        ngay_off: DateTime.parse(json["ngay_off"]),
        nv_id: json["nv_id"]
    );
  }
}