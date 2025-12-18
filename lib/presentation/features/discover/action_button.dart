import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onSuperLike;

  const ActionButtons({
    super.key,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onSuperLike,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final size = (availableWidth / 5.0).clamp(52.0, 64.0);
        final iconSize = (size / 2.3).clamp(20.0, 30.0);
        final heartIconSize = (size / 2.15).clamp(22.0, 32.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: FontAwesomeIcons.xmark,
              color: Colors.white,
              backgroundColor: Colors.grey.withOpacity(0.3),
              buttonSize: size,
              size: iconSize,
              onPressed: onSwipeLeft,
            ),
            _buildActionButton(
              icon: FontAwesomeIcons.solidHeart,
              color: Colors.white,
              backgroundColor: const Color(0xFFFE3C72),
              buttonSize: size,
              size: heartIconSize,
              onPressed: onSwipeRight,
            ),
            _buildActionButton(
              icon: FontAwesomeIcons.solidStar,
              color: Colors.white,
              backgroundColor: Colors.blueAccent,
              buttonSize: size,
              size: iconSize,
              onPressed: onSuperLike,
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required double buttonSize,
    double size = 24,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: IconButton(
        icon: FaIcon(icon, size: size, color: color),
        onPressed: onPressed,
      ),
    );
  }
}
