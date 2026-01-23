import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class CosmicBackground extends StatelessWidget {
  final Widget child;
  final String? imagePath;

  const CosmicBackground({
    super.key,
    required this.child,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryNavy,
            AppTheme.primaryBlue,
            AppTheme.primaryNavy.withOpacity(0.8),
          ],
        ),
        // TODO: Add background image when available
        // image: imagePath != null
        //     ? DecorationImage(
        //         image: AssetImage(imagePath!),
        //         fit: BoxFit.cover,
        //         opacity: 0.3,
        //       )
        //     : null,
      ),
      child: Stack(
        children: [
          // Animated stars effect (optional)
          _buildStars(),
          // Content
          child,
        ],
      ),
    );
  }

  Widget _buildStars() {
    return CustomPaint(
      painter: StarsPainter(),
      child: Container(),
    );
  }
}

class StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw random stars
    final random = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < 50; i++) {
      final x = (random + i * 137) % size.width.toInt();
      final y = (random + i * 199) % size.height.toInt();
      final radius = (random + i * 73) % 3 + 1.0;
      
      canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

