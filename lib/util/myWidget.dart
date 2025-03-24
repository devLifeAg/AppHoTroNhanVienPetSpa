import 'package:flutter/material.dart';

class Mywidget {
  Widget Loading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Căn giữa theo chiều dọc
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16), // Khoảng cách giữa vòng tròn và chữ
          Text(
            "Đang tải...",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
