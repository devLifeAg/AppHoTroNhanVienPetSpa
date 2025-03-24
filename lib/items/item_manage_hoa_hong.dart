import 'package:flutter/material.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/model/ThongTinHoaHong.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/consts.dart';
import 'package:app_ho_tro_nhan_vien_pet_spa/util/myHelper.dart';

class ItemHoaHong extends StatelessWidget {
  const ItemHoaHong(
      {super.key,
      required this.hh,
      required this.listdichvucon,
      required this.index});
  final int index;
  final Thongtinhoahong hh;
  final Map<String, String> listdichvucon;

  @override
  Widget build(BuildContext context) {
    final Myhelper helper = Myhelper();
    return Container(
      // height: 118,
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: light_purple.withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
            BoxShadow(
              color: dark_purple, // Bóng mờ
              // blurRadius: 1, // Độ mờ của bóng
              offset: Offset(4, 4), // Độ dịch chuyển của bóng (X,Y)
            ),
          ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(8, 6, 8, 6),
            decoration: BoxDecoration(
              color: dark_purple.withOpacity(0.45),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8), // Bo góc trên bên trái
                topRight: Radius.circular(8), // Bo góc trên bên phải
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "${index + 1}. ${hh.tt_ten} ",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Image.asset(
                      hh.IconItem(),
                      width: 18,
                      height: 18,
                    ),
                  ],
                ),
                Text(
                  "${helper.formatCurrency(hh.hoa_hong)}đ",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ), // Căn phải
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dịch vụ: ${listdichvucon[hh.dichvucon.toString()]}",
                    style: TextStyle(color: Colors.white)),
                Text("Làm lúc: ${helper.formatNgayGio(hh.ngaygio)}",
                    style: TextStyle(color: Colors.white)),
                // Row(
                //   children: [
                //     SizedBox(
                //       width: 140,
                //       child:
                //     ),
                //     Expanded(
                //       child:
                //     )
                //   ],
                // ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Cân nặng: ${hh.tt_weight}kg",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Expanded(
                      child: Text(
                          "Tổng thu: ${helper.formatCurrency(hh.tt_total)}đ",
                          style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
