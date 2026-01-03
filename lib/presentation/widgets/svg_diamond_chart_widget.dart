import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../../config/app_theme.dart';

class SVGDiamondChartWidget extends StatelessWidget {
  final Map<String, dynamic> planets;
  final Map<String, dynamic> houses;
  final double ascendant;
  final bool showLabels;
  final double? size;

  const SVGDiamondChartWidget({
    super.key,
    required this.planets,
    required this.houses,
    required this.ascendant,
    this.showLabels = true,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final chartSize = size ?? math.min(constraints.maxWidth - 40, constraints.maxHeight - 40);
        return Container(
          padding: const EdgeInsets.all(20),
          child: CustomPaint(
            size: Size(chartSize, chartSize),
            painter: SVGDiamondChartPainter(
              planets: planets,
              houses: houses,
              ascendant: ascendant,
              showLabels: showLabels,
            ),
          ),
        );
      },
    );
  }
}

class SVGDiamondChartPainter extends CustomPainter {
  final Map<String, dynamic> planets;
  final Map<String, dynamic> houses;
  final double ascendant;
  final bool showLabels;

  SVGDiamondChartPainter({
    required this.planets,
    required this.houses,
    required this.ascendant,
    this.showLabels = true,
  });

  final Map<String, Color> planetColors = {
    'Sun': Colors.orange,
    'Moon': Colors.lightBlue,
    'Mercury': Colors.grey,
    'Venus': Colors.yellow,
    'Mars': Colors.red,
    'Jupiter': Colors.blue,
    'Saturn': Colors.purple,
    'Rahu': Colors.brown,
    'Ketu': Colors.deepOrange,
  };

  final Map<String, String> planetSymbols = {
    'Sun': '☉',
    'Moon': '☽',
    'Mercury': '☿',
    'Venus': '♀',
    'Mars': '♂',
    'Jupiter': '♃',
    'Saturn': '♄',
    'Rahu': '☊',
    'Ketu': '☋',
  };

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final chartSize = math.min(size.width, size.height) * 0.85;
    final halfSize = chartSize / 2;

    // Define rectangle corners (diamond chart structure)
    final A = Offset(center.dx - halfSize, center.dy - halfSize); // Top-left
    final B = Offset(center.dx + halfSize, center.dy - halfSize); // Top-right
    final C = Offset(center.dx + halfSize, center.dy + halfSize); // Bottom-right
    final D = Offset(center.dx - halfSize, center.dy + halfSize); // Bottom-left

    // Edge midpoints
    final E = Offset(center.dx, center.dy - halfSize); // Top
    final F = Offset(center.dx + halfSize, center.dy); // Right
    final G = Offset(center.dx, center.dy + halfSize); // Bottom
    final H = Offset(center.dx - halfSize, center.dy); // Left

    // Center
    final O = center;

    // Calculate intersections for house boundaries
    final M = _lineIntersection(E, F, A, C);
    final N = _lineIntersection(F, G, B, D);
    final P = _lineIntersection(G, H, A, C);
    final Q = _lineIntersection(E, H, B, D);

    // Draw outer rectangle
    final rectPaint = Paint()
      ..color = AppTheme.primaryNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final outerRect = Rect.fromPoints(A, C);
    canvas.drawRect(outerRect, rectPaint);

    // Draw diagonals
    final diagonalPaint = Paint()
      ..color = AppTheme.primaryNavy.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawLine(A, C, diagonalPaint);
    canvas.drawLine(B, D, diagonalPaint);

    // Draw inner rhombus
    final rhombusPaint = Paint()
      ..color = AppTheme.accentGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final rhombusPath = Path()
      ..moveTo(E.dx, E.dy)
      ..lineTo(F.dx, F.dy)
      ..lineTo(G.dx, G.dy)
      ..lineTo(H.dx, H.dy)
      ..close();
    canvas.drawPath(rhombusPath, rhombusPaint);

    // Draw house boundaries
    final houseLinePaint = Paint()
      ..color = AppTheme.accentGold.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw all 12 houses
    final housePolygons = _getHousePolygons(A, B, C, D, E, F, G, H, O, M, N, P, Q);
    for (final polygon in housePolygons) {
      _drawPolygon(canvas, polygon, houseLinePaint);
    }

    // Draw house numbers
    if (showLabels) {
      final houseCenters = _getHouseCenters(A, B, C, D, E, F, G, H, O, M, N, P, Q);
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
      );

      for (int i = 0; i < 12; i++) {
        final houseNum = i + 1;
        final houseCenter = houseCenters[i];

        textPainter.text = TextSpan(
          text: '$houseNum',
          style: TextStyle(
            color: AppTheme.primaryNavy,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            houseCenter.dx - textPainter.width / 2,
            houseCenter.dy - textPainter.height / 2,
          ),
        );
      }
    }

    // Group planets by house
    final Map<int, List<Map<String, dynamic>>> planetsByHouse = {};
    planets.forEach((planetName, planetData) {
      if (planetData is Map<String, dynamic>) {
        final house = planetData['house'] as int? ?? 1;
        if (!planetsByHouse.containsKey(house)) {
          planetsByHouse[house] = [];
        }
        planetsByHouse[house]!.add({
          'name': planetName,
          'data': planetData,
        });
      }
    });

    // Draw planets
    final houseCenters = _getHouseCenters(A, B, C, D, E, F, G, H, O, M, N, P, Q);
    planetsByHouse.forEach((houseNum, planetList) {
      final housePolygon = housePolygons[houseNum - 1];
      final houseCenter = houseCenters[houseNum - 1];

      for (int i = 0; i < planetList.length; i++) {
        final planet = planetList[i];
        final planetName = planet['name'] as String;
        final planetData = planet['data'] as Map<String, dynamic>;
        final degreesInHouse = (planetData['degrees_in_house'] as num?)?.toDouble() ?? 0.0;
        final relativePos = (degreesInHouse / 30.0).clamp(0.0, 1.0);

        // Calculate precise planet position
        final planetPos = _getPrecisePlanetPosition(
          houseCenter,
          housePolygon,
          relativePos,
          planetList.length,
          i,
        );

        // Draw planet circle with gradient
        final planetColor = planetColors[planetName] ?? Colors.grey;
        final planetPaint = Paint()
          ..color = planetColor
          ..style = PaintingStyle.fill;

        canvas.drawCircle(planetPos, 16, planetPaint);

        // Draw planet border
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawCircle(planetPos, 16, borderPaint);

        // Draw planet symbol
        final symbol = planetSymbols[planetName] ?? planetName[0];
        final symbolPainter = TextPainter(
          text: TextSpan(
            text: symbol,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        symbolPainter.layout();
        symbolPainter.paint(
          canvas,
          Offset(
            planetPos.dx - symbolPainter.width / 2,
            planetPos.dy - symbolPainter.height / 2,
          ),
        );

        // Draw degrees label
        if (showLabels) {
          final degreesText = '${degreesInHouse.toStringAsFixed(1)}°';
          final degreesPainter = TextPainter(
            text: TextSpan(
              text: degreesText,
              style: TextStyle(
                color: AppTheme.primaryNavy,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          degreesPainter.layout();
          degreesPainter.paint(
            canvas,
            Offset(
              planetPos.dx - degreesPainter.width / 2,
              planetPos.dy + 20,
            ),
          );
        }
      }
    });

    // Draw center point
    final centerPaint = Paint()
      ..color = AppTheme.accentGold
      ..style = PaintingStyle.fill;
    canvas.drawCircle(O, 6, centerPaint);
  }

  Offset _lineIntersection(Offset p1, Offset p2, Offset p3, Offset p4) {
    final x1 = p1.dx;
    final y1 = p1.dy;
    final x2 = p2.dx;
    final y2 = p2.dy;
    final x3 = p3.dx;
    final y3 = p3.dy;
    final x4 = p4.dx;
    final y4 = p4.dy;

    final denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if (denom.abs() < 0.001) {
      return Offset((x1 + x3) / 2, (y1 + y3) / 2);
    }

    final t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom;
    final x = x1 + t * (x2 - x1);
    final y = y1 + t * (y2 - y1);

    return Offset(x, y);
  }

  void _drawPolygon(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.isEmpty) return;
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  List<List<Offset>> _getHousePolygons(
    Offset A, Offset B, Offset C, Offset D,
    Offset E, Offset F, Offset G, Offset H,
    Offset O, Offset M, Offset N, Offset P, Offset Q,
  ) {
    return [
      [E, M, O, Q], // House 1
      [A, E, Q], // House 2
      [A, Q, H], // House 3
      [H, Q, O, P], // House 4
      [H, P, D], // House 5
      [D, P, G], // House 6
      [G, P, O, N], // House 7
      [G, N, C], // House 8
      [C, N, F], // House 9
      [F, N, O, M], // House 10
      [F, M, B], // House 11
      [B, M, E], // House 12
    ];
  }

  List<Offset> _getHouseCenters(
    Offset A, Offset B, Offset C, Offset D,
    Offset E, Offset F, Offset G, Offset H,
    Offset O, Offset M, Offset N, Offset P, Offset Q,
  ) {
    final polygons = _getHousePolygons(A, B, C, D, E, F, G, H, O, M, N, P, Q);
    return polygons.map((poly) => _polygonCenter(poly)).toList();
  }

  Offset _polygonCenter(List<Offset> points) {
    if (points.isEmpty) return Offset.zero;
    double sumX = 0, sumY = 0;
    for (final point in points) {
      sumX += point.dx;
      sumY += point.dy;
    }
    return Offset(sumX / points.length, sumY / points.length);
  }

  Offset _getPrecisePlanetPosition(
    Offset houseCenter,
    List<Offset> housePolygon,
    double relativePos,
    int totalPlanets,
    int planetIndex,
  ) {
    if (housePolygon.isEmpty) return houseCenter;

    // Calculate angle for multiple planets in same house
    final angleStep = 2 * math.pi / math.max(totalPlanets, 1);
    final baseAngle = angleStep * planetIndex;

    // Find polygon bounds
    double minX = housePolygon[0].dx;
    double maxX = housePolygon[0].dx;
    double minY = housePolygon[0].dy;
    double maxY = housePolygon[0].dy;

    for (final point in housePolygon) {
      minX = math.min(minX, point.dx);
      maxX = math.max(maxX, point.dx);
      minY = math.min(minY, point.dy);
      maxY = math.max(maxY, point.dy);
    }

    // Calculate radius based on relative position
    final maxRadius = math.min(
      (maxX - minX) / 2,
      (maxY - minY) / 2,
    ) * 0.5; // Keep planets well within house

    final radius = maxRadius * (0.3 + relativePos * 0.4);

    // Position planet with angle offset for multiple planets
    final planetX = houseCenter.dx + radius * math.cos(baseAngle);
    final planetY = houseCenter.dy + radius * math.sin(baseAngle);

    final planetPos = Offset(planetX, planetY);

    // Ensure planet is inside polygon
    if (!_isPointInPolygon(planetPos, housePolygon)) {
      return Offset(
        (planetPos.dx + houseCenter.dx) / 2,
        (planetPos.dy + houseCenter.dy) / 2,
      );
    }

    return planetPos;
  }

  bool _isPointInPolygon(Offset point, List<Offset> polygon) {
    if (polygon.length < 3) return false;

    bool inside = false;
    int j = polygon.length - 1;

    for (int i = 0; i < polygon.length; i++) {
      final xi = polygon[i].dx;
      final yi = polygon[i].dy;
      final xj = polygon[j].dx;
      final yj = polygon[j].dy;

      final intersect = ((yi > point.dy) != (yj > point.dy)) &&
          (point.dx < (xj - xi) * (point.dy - yi) / (yj - yi) + xi);

      if (intersect) inside = !inside;
      j = i;
    }

    return inside;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

