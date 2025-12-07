import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double starSize;
  final Color? color;
  final bool allowInteraction;
  final ValueChanged<double>? onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.starSize = 24.0,
    this.color,
    this.allowInteraction = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        final isFilled = starValue <= rating;
        final isHalfFilled = starValue - 0.5 <= rating && rating < starValue;

        return GestureDetector(
          onTap: allowInteraction && onRatingChanged != null
              ? () => onRatingChanged!(starValue)
              : null,
          child: Icon(
            isFilled
                ? Icons.star
                : isHalfFilled
                    ? Icons.star_half
                    : Icons.star_border,
            size: starSize,
            color: color ?? Theme.of(context).colorScheme.tertiary,
          ),
        );
      }),
    );
  }
}

