import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../config/app_theme.dart';

/// North Indian Diamond Chart using normalized coordinate system [0,1] × [0,1]
/// Based on mathematically defined house polygons for precise placement

// Type alias for normalized points
typedef Point = List<double>; // [x, y] where 0 <= x, y <= 1

/// House polygons in normalized coordinates [0,1] × [0,1]
/// House 1 at top center, going anti-clockwise
/// Using padding of 0.02 from edges for better visual appearance
const double _pad = 0.02;
const Map<int, List<Point>> HOUSE_POLYGONS = {
  // House 1: Top center diamond (Lagna)
  1: [[0.50, _pad], [0.75, 0.25], [0.50, 0.50], [0.25, 0.25]],
  
  // House 2: Top-left corner triangle
  2: [[_pad, _pad], [0.50, _pad], [0.25, 0.25]],
  
  // House 3: Left-top triangle
  3: [[_pad, _pad], [0.25, 0.25], [_pad, 0.50]],
  
  // House 4: Left center diamond
  4: [[_pad, 0.50], [0.25, 0.25], [0.50, 0.50], [0.25, 0.75]],
  
  // House 5: Left-bottom triangle
  5: [[_pad, 0.50], [0.25, 0.75], [_pad, 1.0 - _pad]],
  
  // House 6: Bottom-left corner triangle
  6: [[_pad, 1.0 - _pad], [0.25, 0.75], [0.50, 1.0 - _pad]],
  
  // House 7: Bottom center diamond
  7: [[0.25, 0.75], [0.50, 0.50], [0.75, 0.75], [0.50, 1.0 - _pad]],
  
  // House 8: Bottom-right corner triangle
  8: [[0.50, 1.0 - _pad], [0.75, 0.75], [1.0 - _pad, 1.0 - _pad]],
  
  // House 9: Right-bottom triangle
  9: [[0.75, 0.75], [1.0 - _pad, 0.50], [1.0 - _pad, 1.0 - _pad]],
  
  // House 10: Right center diamond
  10: [[0.50, 0.50], [0.75, 0.25], [1.0 - _pad, 0.50], [0.75, 0.75]],
  
  // House 11: Right-top triangle
  11: [[0.75, 0.25], [1.0 - _pad, _pad], [1.0 - _pad, 0.50]],
  
  // House 12: Top-right corner triangle
  12: [[0.50, _pad], [1.0 - _pad, _pad], [0.75, 0.25]],
};

/// Compute centroid of a polygon
Offset _computeCentroid(List<Point> points) {
  double sumX = 0, sumY = 0;
  for (final p in points) {
    sumX += p[0];
    sumY += p[1];
  }
  return Offset(sumX / points.length, sumY / points.length);
}

/// Pre-computed house centers in normalized coordinates
final Map<int, Offset> HOUSE_CENTERS = Map.fromEntries(
  HOUSE_POLYGONS.entries.map((e) => MapEntry(e.key, _computeCentroid(e.value))),
);

/// Offsets for text placement (in normalized coordinates)
const double RASHI_OFFSET_Y = -0.055;  // Rashi number above center
const double PLANET_BASE_OFFSET_Y = 0.015;  // Planets below center
const double PLANET_SPACING = 0.04;  // Vertical spacing between planets

class DiamondChartWidget extends StatelessWidget {
  final Map<String, dynamic> planets;
  final Map<String, dynamic> houses;
  final double ascendant;

  const DiamondChartWidget({
    super.key,
    required this.planets,
    required this.houses,
    required this.ascendant,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        return CustomPaint(
          size: Size(size, size),
          painter: NorthIndianChartPainter(
            planets: planets,
            houses: houses,
            ascendant: ascendant,
          ),
        );
      },
    );
  }
}

class NorthIndianChartPainter extends CustomPainter {
  final Map<String, dynamic> planets;
  final Map<String, dynamic> houses;
  final double ascendant;

  NorthIndianChartPainter({
    required this.planets,
    required this.houses,
    required this.ascendant,
  });

  final Map<String, Color> planetColors = {
    'Sun': const Color(0xFFFF8C00),
    'Moon': const Color(0xFF4169E1),
    'Mercury': const Color(0xFF228B22),
    'Venus': const Color(0xFFFF1493),
    'Mars': const Color(0xFFDC143C),
    'Jupiter': const Color(0xFFDAA520),
    'Saturn': const Color(0xFF4B0082),
    'Rahu': const Color(0xFF2F4F4F),
    'Ketu': const Color(0xFF8B4513),
  };

  final Map<String, String> planetAbbrev = {
    'Sun': 'Su', 'Moon': 'Mo', 'Mercury': 'Me', 'Venus': 'Ve',
    'Mars': 'Ma', 'Jupiter': 'Ju', 'Saturn': 'Sa', 'Rahu': 'Ra', 'Ketu': 'Ke',
  };

  final List<String> rashiNames = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width; // Chart size in pixels
    
    // Helper to convert normalized [0,1] to pixels
    double toPx(double v) => v * s;
    Offset toPixelOffset(Offset normalized) => Offset(toPx(normalized.dx), toPx(normalized.dy));

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, s, s),
      Paint()..color = Colors.white..style = PaintingStyle.fill,
    );

    // Draw house polygons
    final linePaint = Paint()
      ..color = AppTheme.primaryNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = const Color(0xFFFDF9E5)
      ..style = PaintingStyle.fill;

    for (final entry in HOUSE_POLYGONS.entries) {
      final points = entry.value;
      final path = Path();
      path.moveTo(toPx(points[0][0]), toPx(points[0][1]));
      for (int i = 1; i < points.length; i++) {
        path.lineTo(toPx(points[i][0]), toPx(points[i][1]));
      }
      path.close();
      
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, linePaint);
    }

    // Get ascendant sign index
    final ascSignIndex = _getAscSignIndex();
    
    // Group planets by house
    final planetsByHouse = _groupPlanetsByHouse();

    // Draw rashi numbers for all 12 houses
    _drawRashiNumbers(canvas, ascSignIndex, s);

    // Draw planets in each house
    _drawPlanets(canvas, planetsByHouse, s);
  }

  int _getAscSignIndex() {
    final ascSign = houses['Ascendant_Sign'] as String?;
    if (ascSign != null) {
      final idx = rashiNames.indexOf(ascSign);
      if (idx >= 0) return idx;
    }
    return (ascendant ~/ 30) % 12;
  }

  Map<int, List<MapEntry<String, dynamic>>> _groupPlanetsByHouse() {
    final result = <int, List<MapEntry<String, dynamic>>>{};
    planets.forEach((name, data) {
      if (data is Map<String, dynamic>) {
        final house = data['house'] as int? ?? 1;
        result.putIfAbsent(house, () => []);
        result[house]!.add(MapEntry(name, data));
      }
    });
    return result;
  }

  void _drawRashiNumbers(Canvas canvas, int ascSignIndex, double size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final fontSize = size * 0.05;

    for (int houseNum = 1; houseNum <= 12; houseNum++) {
      final center = HOUSE_CENTERS[houseNum]!;
      final rashiIndex = (ascSignIndex + houseNum - 1) % 12;
      final rashiNum = rashiIndex + 1; // 1-12
      final isLagna = houseNum == 1;

      // Position: center + rashi offset
      final x = center.dx * size;
      final y = (center.dy + RASHI_OFFSET_Y) * size;

      textPainter.text = TextSpan(
        text: '$rashiNum',
        style: TextStyle(
          color: isLagna ? AppTheme.accentGold : AppTheme.primaryNavy.withOpacity(0.75),
          fontSize: fontSize,
          fontWeight: isLagna ? FontWeight.bold : FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  void _drawPlanets(Canvas canvas, Map<int, List<MapEntry<String, dynamic>>> planetsByHouse, double size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final entry in planetsByHouse.entries) {
      final houseNum = entry.key;
      final planetList = entry.value;
      
      if (houseNum < 1 || houseNum > 12) continue;
      
      final center = HOUSE_CENTERS[houseNum]!;
      final count = planetList.length;

      for (int idx = 0; idx < count; idx++) {
        final planetEntry = planetList[idx];
        final planetName = planetEntry.key;
        final planetData = planetEntry.value as Map<String, dynamic>;

        // Calculate vertical position: stack planets around center
        final offsetIndex = idx - (count - 1) / 2;
        final xNorm = center.dx;
        final yNorm = center.dy + PLANET_BASE_OFFSET_Y + offsetIndex * PLANET_SPACING;
        
        final x = xNorm * size;
        final y = yNorm * size;

        // Planet info
        final color = planetColors[planetName] ?? Colors.grey;
        final abbrev = planetAbbrev[planetName] ?? planetName.substring(0, 2);
        final degree = (planetData['degrees_in_sign'] as num?)?.toDouble() ?? 0.0;
        final isRetro = planetData['retrograde'] == true ||
                       (planetData['speed'] != null && (planetData['speed'] as num) < 0);

        // Create label: "Su 14.2°" or "Sa(R) 22.4°"
        final retroMark = isRetro ? '(R)' : '';
        final label = '$abbrev$retroMark ${degree.toStringAsFixed(1)}°';

        // Calculate font size based on planet count
        double fontSize = size * 0.034;
        if (count > 3) fontSize = size * 0.028;
        if (count > 5) fontSize = size * 0.022;

        // Draw planet background pill
        textPainter.text = TextSpan(
          text: label,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        );
        textPainter.layout();

        // Background pill
        final pillRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, y),
            width: textPainter.width + size * 0.02,
            height: textPainter.height + size * 0.01,
          ),
          Radius.circular(size * 0.01),
        );
        
        canvas.drawRRect(
          pillRect,
          Paint()..color = color.withOpacity(0.12)..style = PaintingStyle.fill,
        );
        
        canvas.drawRRect(
          pillRect,
          Paint()..color = color.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 0.8,
        );

        // Draw planet text
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
