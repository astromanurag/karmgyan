import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';
import '../../widgets/diamond_chart_widget.dart';

class ChartDemoScreen extends StatefulWidget {
  const ChartDemoScreen({super.key});

  @override
  State<ChartDemoScreen> createState() => _ChartDemoScreenState();
}

class _ChartDemoScreenState extends State<ChartDemoScreen> {
  Map<String, dynamic>? _chartData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSampleChart();
  }

  Future<void> _loadSampleChart() async {
    // Always use hardcoded sample data for reliable demo
    // This ensures all fields are correctly structured
    setState(() {
      _chartData = _getHardcodedSampleData();
      _isLoading = false;
    });
  }

  Map<String, dynamic> _getHardcodedSampleData() {
    // Sample data for DOB: 31/10/1987, 6:35 AM, 28.9052°N, 78.4673°E
    // Ascendant: Libra (using Lahiri Ayanamsha)
    // This chart has Venus, Mars, Ketu all in House 12 to test multiple planets
    return {
      'name': 'Sample User',
      'date': '1987-10-31',
      'time': '06:35:00',
      'latitude': 28.9052,
      'longitude': 78.4673,
      'ascendant': 186.5,
      'ascendant_sign': 'Libra',
      'ascendant_degrees': 6.5,
      'ayanamsha_name': 'Lahiri',
      'moon_nakshatra': 'Purva Phalguni',
      'moon_nakshatra_lord': 'Venus',
      'planets': {
        'Sun': {
          'longitude': 194.2,
          'sign': 'Libra',
          'sign_index': 6,
          'degrees_in_sign': 14.2,
          'house': 1,
          'degrees_in_house': 14.2,
          'nakshatra': 'Swati',
          'retrograde': false,
        },
        'Moon': {
          'longitude': 192.8,
          'sign': 'Libra',
          'sign_index': 6,
          'degrees_in_sign': 12.8,
          'house': 1,
          'degrees_in_house': 12.8,
          'nakshatra': 'Swati',
          'retrograde': false,
        },
        'Mercury': {
          'longitude': 188.5,
          'sign': 'Libra',
          'sign_index': 6,
          'degrees_in_sign': 8.5,
          'house': 1,
          'degrees_in_house': 8.5,
          'nakshatra': 'Chitra',
          'retrograde': false,
        },
        'Venus': {
          'longitude': 168.3,
          'sign': 'Virgo',
          'sign_index': 5,
          'degrees_in_sign': 18.3,
          'house': 12,
          'degrees_in_house': 18.3,
          'nakshatra': 'Hasta',
          'retrograde': false,
        },
        'Mars': {
          'longitude': 165.8,
          'sign': 'Virgo',
          'sign_index': 5,
          'degrees_in_sign': 15.8,
          'house': 12,
          'degrees_in_house': 15.8,
          'nakshatra': 'Hasta',
          'retrograde': false,
        },
        'Jupiter': {
          'longitude': 19.7,
          'sign': 'Aries',
          'sign_index': 0,
          'degrees_in_sign': 19.7,
          'house': 7,
          'degrees_in_house': 19.7,
          'nakshatra': 'Bharani',
          'retrograde': false,
        },
        'Saturn': {
          'longitude': 262.4,
          'sign': 'Sagittarius',
          'sign_index': 8,
          'degrees_in_sign': 22.4,
          'house': 3,
          'degrees_in_house': 22.4,
          'nakshatra': 'Purva Ashadha',
          'retrograde': true,
        },
        'Rahu': {
          'longitude': 175.2,
          'sign': 'Virgo',
          'sign_index': 5,
          'degrees_in_sign': 25.2,
          'house': 12,
          'degrees_in_house': 25.2,
          'nakshatra': 'Chitra',
          'retrograde': true,
        },
        'Ketu': {
          'longitude': 355.2,
          'sign': 'Pisces',
          'sign_index': 11,
          'degrees_in_sign': 25.2,
          'house': 6,
          'degrees_in_house': 25.2,
          'nakshatra': 'Revati',
          'retrograde': true,
        },
      },
      'houses': {
        'Ascendant': 186.5,
        'Ascendant_Sign': 'Libra',
        'House_1': 180.0,
        'House_1_Sign': 'Libra',
        'House_2': 210.0,
        'House_2_Sign': 'Scorpio',
        'House_3': 240.0,
        'House_3_Sign': 'Sagittarius',
        'House_4': 270.0,
        'House_4_Sign': 'Capricorn',
        'House_5': 300.0,
        'House_5_Sign': 'Aquarius',
        'House_6': 330.0,
        'House_6_Sign': 'Pisces',
        'House_7': 0.0,
        'House_7_Sign': 'Aries',
        'House_8': 30.0,
        'House_8_Sign': 'Taurus',
        'House_9': 60.0,
        'House_9_Sign': 'Gemini',
        'House_10': 90.0,
        'House_10_Sign': 'Cancer',
        'House_11': 120.0,
        'House_11_Sign': 'Leo',
        'House_12': 150.0,
        'House_12_Sign': 'Virgo',
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chart Demo - Sample Data'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadSampleChart();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _chartData == null
              ? const Center(
                  child: Text('Failed to load chart data'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Chart Info Card
                      _buildInfoCard(),
                      const SizedBox(height: 24),
                      // Birth Chart
                      _buildBirthChart(),
                      const SizedBox(height: 24),
                      // Planet Positions Table
                      _buildPlanetTable(),
                      const SizedBox(height: 24),
                      // House Positions Table
                      _buildHouseTable(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard() {
    final ascSign = _chartData!['ascendant_sign'] ?? 'N/A';
    final moonNak = _chartData!['moon_nakshatra'] ?? 'N/A';
    final moonNakLord = _chartData!['moon_nakshatra_lord'] ?? '';
    final ayanamsha = _chartData!['ayanamsha_name'] ?? 'Lahiri';
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.stars_rounded, color: AppTheme.accentGold),
                    const SizedBox(width: 12),
                    Text(
                      'North Indian Chart',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                          ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$ayanamsha Ayanamsha',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Date of Birth', _chartData!['date'] ?? 'N/A'),
            _buildInfoRow('Time of Birth', _chartData!['time'] ?? 'N/A'),
            _buildInfoRow(
              'Coordinates',
              '${_chartData!['latitude']}°N, ${_chartData!['longitude']}°E',
            ),
            const Divider(height: 16),
            _buildInfoRow('Lagna (Ascendant)', ascSign),
            _buildInfoRow('Moon Nakshatra', '$moonNak ($moonNakLord)'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthChart() {
    final planets = _chartData!['planets'] as Map<String, dynamic>? ?? {};
    final houses = _chartData!['houses'] as Map<String, dynamic>? ?? {};
    final ascendant = (_chartData!['ascendant'] as num?)?.toDouble() ?? 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Birth Chart (D1 - Rashi)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(minHeight: 450, maxHeight: 550),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.accentGold.withOpacity(0.3),
                  width: 2,
                ),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: DiamondChartWidget(
                  planets: planets,
                  houses: houses,
                  ascendant: ascendant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanetTable() {
    final planets = _chartData!['planets'] as Map<String, dynamic>? ?? {};

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Planet Positions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  AppTheme.primaryNavy.withOpacity(0.1),
                ),
                columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text('Planet')),
                  DataColumn(label: Text('Sign')),
                  DataColumn(label: Text('Deg°')),
                  DataColumn(label: Text('House')),
                  DataColumn(label: Text('Nakshatra')),
                ],
                rows: planets.entries.map((entry) {
                  final planet = entry.key;
                  final data = entry.value as Map<String, dynamic>;
                  final isRetro = data['retrograde'] == true;
                  final degrees = (data['degrees_in_sign'] as num?)?.toDouble() ?? 0;
                  return DataRow(cells: [
                    DataCell(Text(
                      isRetro ? '$planet (R)' : planet,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isRetro ? Colors.red : null,
                      ),
                    )),
                    DataCell(Text(data['sign'] ?? 'N/A')),
                    DataCell(Text('${degrees.toStringAsFixed(1)}°')),
                    DataCell(Text('H${data['house'] ?? 1}')),
                    DataCell(Text(data['nakshatra'] ?? 'N/A')),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHouseTable() {
    final houses = _chartData!['houses'] as Map<String, dynamic>? ?? {};

    // Extract only house data (not other fields)
    final houseData = <Map<String, String>>[];
    for (int i = 1; i <= 12; i++) {
      final sign = houses['House_${i}_Sign'] as String? ?? '';
      houseData.add({
        'house': 'House $i',
        'sign': sign,
      });
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'House Signs',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: houseData.length,
              itemBuilder: (context, index) {
                final house = houseData[index];
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: index == 0
                        ? AppTheme.accentGold.withOpacity(0.2)
                        : AppTheme.primaryNavy.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: index == 0
                          ? AppTheme.accentGold
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'H${index + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        house['sign'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}

