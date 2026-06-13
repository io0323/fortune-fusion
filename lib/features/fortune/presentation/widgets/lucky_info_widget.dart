import 'package:flutter/material.dart';

class LuckyInfoWidget extends StatelessWidget {
  const LuckyInfoWidget({
    super.key,
    required this.color,
    required this.number,
    required this.direction,
  });

  final String color;
  final int number;
  final String direction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ラッキーカラー: $color'),
        Text('ラッキーナンバー: $number'),
        Text('吉方位: $direction'),
      ],
    );
  }
}
