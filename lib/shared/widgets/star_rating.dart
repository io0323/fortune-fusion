import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.max = 5,
    this.size = 20,
  });

  final double rating;
  final int max;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (i) {
        final value = rating - i;
        final IconData icon;
        if (value >= 1) {
          icon = Icons.star_rounded;
        } else if (value >= 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }
        return Icon(icon, size: size, color: AppColors.primary);
      }),
    );
  }
}
