import 'package:app_ho_tro_nhan_vien_pet_spa/model/NgayNghi.dart';
import 'package:flutter/material.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/consts.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/util/myHelper.dart';

class ItemNgayNghi extends StatelessWidget {
  const ItemNgayNghi({super.key, required this.nn, required this.index, required this.isSelected});
  final int index;
  final Ngaynghi nn;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
  final Myhelper helper = Myhelper();
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.deepPurple[400] : light_purple,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
            BoxShadow(
              color: dark_purple.withOpacity(0.85), // Bóng mờ
              // blurRadius: 1, // Độ mờ của bóng
              offset: Offset(4, 4), // Độ dịch chuyển của bóng (X,Y)
            ),
          ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text("Ngày off ${index + 1}: ${helper.formatDate(nn.ngay_off)}",
        style: TextStyle(fontSize: 16, color: white, fontWeight: FontWeight.bold),),
        ),
    );
  }
}
