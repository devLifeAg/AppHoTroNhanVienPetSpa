import 'package:app_ho_tro_nhan_vien_pet_spa/model/TangCa.dart';
import 'package:flutter/material.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/consts.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/util/myHelper.dart';

class ItemTangCa extends StatelessWidget {
  const ItemTangCa(
      {super.key,
      required this.tc,
      required this.index,
      required this.isSelected});
  final int index;
  final Tangca tc;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
  final Myhelper helper = Myhelper(); // Khởi tạo helper trong build để tránh giữ trạng thái không cần thiết
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.purple[900] : Colors.purple[700],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
            BoxShadow(
              color: dark_purple.withOpacity(0.6), // Bóng mờ
              // blurRadius: 1, // Độ mờ của bóng
              offset: Offset(4, 4), // Độ dịch chuyển của bóng (X,Y)
            ),
          ],
      ),
      child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ngày tăng ca ${index + 1}: ${helper.formatDate(tc.ngay)}",
                style: TextStyle(
                    fontSize: 16, color: white, fontWeight: FontWeight.bold),
              ),
              Text("Số giờ tăng ca: ${tc.sogio.toString()}", style: TextStyle(fontSize: 14, color: white),)
            ],
          )),
    );
  }
}
