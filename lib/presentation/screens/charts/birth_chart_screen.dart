import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_theme.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../services/computation_service.dart';
import '../../../services/pdf_report_service.dart';
import '../../../services/location_service.dart';
import '../../widgets/diamond_chart_widget.dart';

class BirthChartScreen extends ConsumerStatefulWidget {
  const BirthChartScreen({super.key});

  @override
  ConsumerState<BirthChartScreen> createState() => _BirthChartScreenState();
}

class _BirthChartScreenState extends ConsumerState<BirthChartScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  Map<String, dynamic>? _chartData;
  Map<String, dynamic>? _dashaData;
  
  // Location search
  List<PlacePrediction> _placePredictions = [];
  bool _isSearchingLocation = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    
    // TODO: REMOVE THIS - Default values for testing only
    // Setting default birth data: 31/10/1987, 6:35 AM, Amroha (28.9052, 78.4673)
    _nameController.text = 'Test User';
    _selectedDate = DateTime(1987, 10, 31);
    _dateController.text = '31/10/1987';
    _selectedTime = const TimeOfDay(hour: 6, minute: 35);
    _timeController.text = '06:35';
    _latitudeController.text = '28.9052';
    _longitudeController.text = '78.4673';
    _locationController.text = 'Amroha';
    // END TODO
    
    // Load stored dasha data if available
    _loadStoredDashaData();
    
    // Add listener for location search
    _locationController.addListener(_onLocationChanged);
  }
  
  Future<void> _loadStoredDashaData() async {
    final storedDasha = LocalStorageService.get('dasha_data');
    if (storedDasha != null && storedDasha is Map<String, dynamic>) {
      setState(() {
        _dashaData = storedDasha;
      });
    }
  }
  
  void _onLocationChanged() async {
    final query = _locationController.text.trim();
    if (query.length < 3) {
      _hideOverlay();
      return;
    }
    
    try {
      setState(() => _isSearchingLocation = true);
      final predictions = await LocationService.searchPlaces(query);
      setState(() {
        _placePredictions = predictions;
        _isSearchingLocation = false;
      });
      
      if (predictions.isNotEmpty) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    } catch (e) {
      setState(() => _isSearchingLocation = false);
      _hideOverlay();
    }
  }
  
  void _showOverlay() {
    _hideOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }
  
  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
  
  OverlayEntry _createOverlayEntry() {
    RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size.zero;
    
    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _placePredictions.length,
                itemBuilder: (context, index) {
                  final prediction = _placePredictions[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(prediction.mainText ?? prediction.description),
                    subtitle: prediction.secondaryText != null
                        ? Text(prediction.secondaryText!)
                        : null,
                    onTap: () => _selectPlace(prediction),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _selectPlace(PlacePrediction prediction) async {
    _hideOverlay();
    setState(() {
      _locationController.text = prediction.description;
      _placePredictions = [];
    });
    
    try {
      final details = await LocationService.getPlaceDetails(prediction.placeId);
      if (details != null) {
        setState(() {
          _latitudeController.text = details.latitude.toStringAsFixed(6);
          _longitudeController.text = details.longitude.toStringAsFixed(6);
          _locationController.text = details.formattedAddress;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location details: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _hideOverlay();
    _nameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _locationController.removeListener(_onLocationChanged);
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 6, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _generateChart() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _chartData = null;
      // Keep _dashaData until new one is ready for better UX
    });

    try {
      final lat = double.parse(_latitudeController.text);
      final lon = double.parse(_longitudeController.text);
      
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      print('[BirthChartScreen] Starting chart generation...');
      print('[BirthChartScreen] Parameters: name=${_nameController.text}, date=$dateTime, lat=$lat, lon=$lon');

      // Generate birth chart
      final chartResult = await ComputationService().generateBirthChart(
        name: _nameController.text,
        date: dateTime,
        latitude: lat,
        longitude: lon,
      );

      // Check if fallback was used
      if (chartResult.containsKey('_fallback_reason')) {
        final reason = chartResult['_fallback_reason'];
        final errorDetails = chartResult['_error_details'];
        print('[BirthChartScreen] ⚠️  WARNING: Chart generation used fallback data');
        print('[BirthChartScreen] Fallback reason: $reason');
        print('[BirthChartScreen] Error details: $errorDetails');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ Using sample data. Backend unavailable: $reason'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        print('[BirthChartScreen] ✅ Chart generated successfully from backend');
      }

      // Generate dasha data
      print('[BirthChartScreen] Generating dasha data...');
      final dashaResult = await ComputationService().generateDasha(
        date: dateTime,
        latitude: lat,
        longitude: lon,
      );

      print('[BirthChartScreen] Chart result keys: ${chartResult.keys.toList()}');
      print('[BirthChartScreen] Chart has planets: ${chartResult.containsKey('planets')}');
      if (chartResult.containsKey('planets')) {
        print('[BirthChartScreen] Planets: ${chartResult['planets'].keys.toList()}');
      }

      setState(() {
        _chartData = chartResult;
        _dashaData = dashaResult;
        _isLoading = false;
      });

      // Store birth data for divisional charts
      await LocalStorageService.save('birth_data', {
        'date': '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
        'time': '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00',
        'latitude': lat,
        'longitude': lon,
        'name': _nameController.text,
      });
      
      // Store computed birth chart data for varga charts (if computation was successful)
      if (chartResult.containsKey('planets')) {
        await LocalStorageService.save('birth_chart_data', chartResult);
      }
      
      // Store dasha data for persistence
      if (dashaResult.isNotEmpty) {
        await LocalStorageService.save('dasha_data', dashaResult);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generatePdfReport() async {
    if (_chartData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please generate a birth chart first'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Generating PDF report...')),
        );
      }

      // Generate PDF
      final pdfData = await PdfReportService().generateBirthChartReport(
        name: _nameController.text.isNotEmpty ? _nameController.text : 'User',
        birthDate: _selectedDate ?? DateTime.now(),
        birthTime: _timeController.text.isNotEmpty ? _timeController.text : '12:00:00',
        birthPlace: _locationController.text.isNotEmpty ? _locationController.text : 'Unknown',
        latitude: double.tryParse(_latitudeController.text) ?? 0,
        longitude: double.tryParse(_longitudeController.text) ?? 0,
        chartData: _chartData!,
        dashaData: _dashaData,
      );

      final fileName = 'kundli_${_nameController.text.replaceAll(' ', '_').isEmpty ? 'user' : _nameController.text.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      // Share/Download PDF
      await PdfReportService().sharePdf(pdfData, fileName);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF report generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Birth Chart'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        actions: [
          if (_chartData != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _chartData = null;
                  _dashaData = null;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _chartData == null ? _buildForm() : _buildChartView(),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Birth Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            _selectDate();
                          },
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth',
                            prefixIcon: Icon(Icons.calendar_today_rounded),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (_selectedDate == null) return 'Required';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _timeController,
                          readOnly: true,
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            _selectTime();
                          },
                          decoration: const InputDecoration(
                            labelText: 'Time of Birth',
                            prefixIcon: Icon(Icons.access_time_rounded),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (_selectedTime == null) return 'Required';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Birth Place',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Search Location',
                        prefixIcon: const Icon(Icons.search_rounded),
                        border: const OutlineInputBorder(),
                        helperText: 'Search for city or enter coordinates below',
                        suffixIcon: _isSearchingLocation
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _locationController.clear();
                                  _hideOverlay();
                                },
                              ),
                      ),
                      onTap: () {
                        if (_placePredictions.isNotEmpty) {
                          _showOverlay();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latitudeController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                            prefixIcon: Icon(Icons.north_rounded),
                            border: OutlineInputBorder(),
                            hintText: 'e.g., 28.9052',
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Required';
                            final lat = double.tryParse(value!);
                            if (lat == null || lat < -90 || lat > 90) {
                              return 'Invalid (-90 to 90)';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _longitudeController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            prefixIcon: Icon(Icons.east_rounded),
                            border: OutlineInputBorder(),
                            hintText: 'e.g., 78.4673',
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Required';
                            final lon = double.tryParse(value!);
                            if (lon == null || lon < -180 || lon > 180) {
                              return 'Invalid (-180 to 180)';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _generateChart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                foregroundColor: AppTheme.primaryNavy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Generate Chart',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartView() {
    final planets = _chartData!['planets'] as Map<String, dynamic>? ?? {};
    final houses = _chartData!['houses'] as Map<String, dynamic>? ?? {};
    final ascendant = (_chartData!['ascendant'] as num?)?.toDouble() ?? 0.0;
    final ascSign = _chartData!['ascendant_sign'] as String? ?? '';
    final ayanamsha = _chartData!['ayanamsha_name'] as String? ?? 'Lahiri';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Chart Info
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lagna: $ascSign',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$ayanamsha Ayanamsha',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryNavy,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_chartData!['moon_nakshatra'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Moon Nakshatra: ${_chartData!['moon_nakshatra']} (${_chartData!['moon_nakshatra_lord']})',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Diamond Chart - compact size similar to varga charts
        Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 280,
              height: 280,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: DiamondChartWidget(
                planets: planets,
                houses: houses,
                ascendant: ascendant,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Planet Positions
        _buildPlanetTable(planets),
        const SizedBox(height: 16),

        // Dasha Table
        if (_dashaData != null) _buildDashaSection(),
        const SizedBox(height: 16),

        // Action Buttons Row 1
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/varga-charts'),
                icon: const Icon(Icons.grid_view_rounded),
                label: const Text('Varga Charts'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/predictions/dasha'),
                icon: const Icon(Icons.timeline_rounded),
                label: const Text('Full Dasha'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  foregroundColor: AppTheme.primaryNavy,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Download Report Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _generatePdfReport,
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download Complete Report (PDF)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanetTable(Map<String, dynamic> planets) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Planet Positions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 12),
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
                rows: planets.entries.map((e) {
                  final data = e.value as Map<String, dynamic>;
                  final isRetro = data['retrograde'] == true;
                  return DataRow(cells: [
                    DataCell(Text(
                      isRetro ? '${e.key} (R)' : e.key,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isRetro ? Colors.red : null,
                      ),
                    )),
                    DataCell(Text(data['sign'] ?? '')),
                    DataCell(Text('${(data['degrees_in_sign'] as num?)?.toStringAsFixed(1) ?? '0'}°')),
                    DataCell(Text('H${data['house'] ?? 1}')),
                    DataCell(Text(data['nakshatra'] ?? '')),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashaSection() {
    return DashaTableWidget(dashaData: _dashaData!);
  }
}

/// Dasha Table Widget with drill-down capability
class DashaTableWidget extends StatefulWidget {
  final Map<String, dynamic> dashaData;

  const DashaTableWidget({super.key, required this.dashaData});

  @override
  State<DashaTableWidget> createState() => _DashaTableWidgetState();
}

class _DashaTableWidgetState extends State<DashaTableWidget> {
  // Dasha level: 0=Mahadasha, 1=Antardasha, 2=Pratyantardasha, 3=Sookshma
  int _currentLevel = 0;
  Map<String, dynamic>? _selectedMahadasha;
  Map<String, dynamic>? _selectedAntardasha;
  Map<String, dynamic>? _selectedPratyantardasha;

  final List<String> _levelNames = ['Mahadasha', 'Antardasha', 'Pratyantardasha', 'Sookshma'];
  
  // Planet colors
  final Map<String, Color> _planetColors = {
    'Ketu': const Color(0xFF8B4513),
    'Venus': const Color(0xFFFF69B4),
    'Sun': const Color(0xFFFF8C00),
    'Moon': const Color(0xFF87CEEB),
    'Mars': const Color(0xFFDC143C),
    'Rahu': const Color(0xFF696969),
    'Jupiter': const Color(0xFFFFD700),
    'Saturn': const Color(0xFF4B0082),
    'Mercury': const Color(0xFF228B22),
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button and title
            Row(
              children: [
                if (_currentLevel > 0)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _goBack,
                    color: AppTheme.primaryNavy,
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vimshottari ${_levelNames[_currentLevel]}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      if (_currentLevel > 0)
                        Text(
                          _getBreadcrumb(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                if (_currentLevel > 0)
                  TextButton(
                    onPressed: _goToMahadasha,
                    child: const Text('Go to Mahadasha'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Current level info
            if (_currentLevel > 0) _buildCurrentPeriodInfo(),
            
            const Divider(),
            
            // Dasha list (always 9 rows)
            _buildDashaList(),
          ],
        ),
      ),
    );
  }

  String _getBreadcrumb() {
    final parts = <String>[];
    if (_selectedMahadasha != null) {
      parts.add(_selectedMahadasha!['lord'] as String);
    }
    if (_selectedAntardasha != null && _currentLevel >= 2) {
      parts.add(_selectedAntardasha!['lord'] as String);
    }
    if (_selectedPratyantardasha != null && _currentLevel >= 3) {
      parts.add(_selectedPratyantardasha!['lord'] as String);
    }
    return parts.join(' → ');
  }

  Widget _buildCurrentPeriodInfo() {
    String lordName = '';
    String startDate = '';
    String endDate = '';
    
    switch (_currentLevel) {
      case 1:
        lordName = _selectedMahadasha!['lord'] as String;
        startDate = _selectedMahadasha!['start_date'] as String;
        endDate = _selectedMahadasha!['end_date'] as String;
        break;
      case 2:
        lordName = _selectedAntardasha!['lord'] as String;
        startDate = _selectedAntardasha!['start_date'] as String;
        endDate = _selectedAntardasha!['end_date'] as String;
        break;
      case 3:
        lordName = _selectedPratyantardasha!['lord'] as String;
        startDate = _selectedPratyantardasha!['start_date'] as String;
        endDate = _selectedPratyantardasha!['end_date'] as String;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: (_planetColors[lordName] ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (_planetColors[lordName] ?? Colors.grey).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _planetColors[lordName] ?? Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                lordName.substring(0, 2),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$lordName ${_levelNames[_currentLevel - 1]}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$startDate to $endDate',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashaList() {
    List<Map<String, dynamic>> periods = [];
    
    switch (_currentLevel) {
      case 0:
        // Mahadasha level
        periods = _getMahadashaList();
        break;
      case 1:
        // Antardasha level
        periods = _getAntardashaList();
        break;
      case 2:
        // Pratyantardasha level
        periods = _getPratyantardashaList();
        break;
      case 3:
        // Sookshma level
        periods = _getSookshmaList();
        break;
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: periods.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final period = periods[index];
        final lord = period['lord'] as String;
        final startDate = period['start_date'] as String? ?? '';
        final endDate = period['end_date'] as String? ?? '';
        final isCurrent = _isCurrentPeriod(period);
        
        return ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (_planetColors[lord] ?? Colors.grey).withOpacity(isCurrent ? 1 : 0.7),
              shape: BoxShape.circle,
              border: isCurrent ? Border.all(color: AppTheme.accentGold, width: 2) : null,
            ),
            child: Center(
              child: Text(
                lord.substring(0, 2),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              Text(
                lord,
                style: TextStyle(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent ? AppTheme.primaryNavy : null,
                ),
              ),
              if (isCurrent)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Current',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.primaryNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Text(
            '$startDate → $endDate',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          trailing: _currentLevel < 3
              ? Icon(Icons.chevron_right, color: Colors.grey[400])
              : null,
          onTap: _currentLevel < 3 ? () => _drillDown(period) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getMahadashaList() {
    final mahadashas = widget.dashaData['mahadashas'] as List<dynamic>? ?? [];
    return mahadashas.take(9).map((m) => m as Map<String, dynamic>).toList();
  }

  List<Map<String, dynamic>> _getAntardashaList() {
    if (_selectedMahadasha == null) return [];
    
    // Generate Antardasha periods for selected Mahadasha
    final mahaLord = _selectedMahadasha!['lord'] as String;
    final startJd = _selectedMahadasha!['start_jd'] as num? ?? 0;
    final years = _selectedMahadasha!['years'] as num? ?? 0;
    
    return _generateSubPeriods(mahaLord, startJd.toDouble(), years.toDouble() * 365.25, 120);
  }

  List<Map<String, dynamic>> _getPratyantardashaList() {
    if (_selectedAntardasha == null) return [];
    
    final antLord = _selectedAntardasha!['lord'] as String;
    final startJd = _selectedAntardasha!['start_jd'] as num? ?? 0;
    final days = _selectedAntardasha!['days'] as num? ?? 0;
    
    return _generateSubPeriods(antLord, startJd.toDouble(), days.toDouble(), 120);
  }

  List<Map<String, dynamic>> _getSookshmaList() {
    if (_selectedPratyantardasha == null) return [];
    
    final pratLord = _selectedPratyantardasha!['lord'] as String;
    final startJd = _selectedPratyantardasha!['start_jd'] as num? ?? 0;
    final days = _selectedPratyantardasha!['days'] as num? ?? 0;
    
    return _generateSubPeriods(pratLord, startJd.toDouble(), days.toDouble(), 120);
  }

  List<Map<String, dynamic>> _generateSubPeriods(String startLord, double startJd, double totalDays, double divisor) {
    final dashaSequence = ['Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury'];
    final dashaPeriods = {'Ketu': 7, 'Venus': 20, 'Sun': 6, 'Moon': 10, 'Mars': 7, 'Rahu': 18, 'Jupiter': 16, 'Saturn': 19, 'Mercury': 17};
    
    final startIndex = dashaSequence.indexOf(startLord);
    final periods = <Map<String, dynamic>>[];
    var currentJd = startJd;
    
    for (int i = 0; i < 9; i++) {
      final lord = dashaSequence[(startIndex + i) % 9];
      final subDays = totalDays * dashaPeriods[lord]! / divisor;
      final endJd = currentJd + subDays;
      
      periods.add({
        'lord': lord,
        'start_date': _jdToDateString(currentJd),
        'end_date': _jdToDateString(endJd),
        'start_jd': currentJd,
        'end_jd': endJd,
        'days': subDays,
      });
      
      currentJd = endJd;
    }
    
    return periods;
  }

  String _jdToDateString(double jd) {
    // Simplified JD to date conversion
    final z = (jd + 0.5).floor();
    final f = jd + 0.5 - z;
    int a;
    if (z < 2299161) {
      a = z;
    } else {
      final alpha = ((z - 1867216.25) / 36524.25).floor();
      a = z + 1 + alpha - (alpha / 4).floor();
    }
    final b = a + 1524;
    final c = ((b - 122.1) / 365.25).floor();
    final d = (365.25 * c).floor();
    final e = ((b - d) / 30.6001).floor();
    
    final day = b - d - (30.6001 * e).floor();
    final month = e < 14 ? e - 1 : e - 13;
    final year = month > 2 ? c - 4716 : c - 4715;
    
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  bool _isCurrentPeriod(Map<String, dynamic> period) {
    final currentData = widget.dashaData['current'] as Map<String, dynamic>?;
    if (currentData == null) return false;
    
    switch (_currentLevel) {
      case 0:
        final currentMaha = currentData['mahadasha'] as Map<String, dynamic>?;
        return currentMaha != null && currentMaha['lord'] == period['lord'];
      case 1:
        final currentAntar = currentData['antardasha'] as Map<String, dynamic>?;
        return currentAntar != null && currentAntar['lord'] == period['lord'];
      case 2:
        final currentPrat = currentData['pratyantardasha'] as Map<String, dynamic>?;
        return currentPrat != null && currentPrat['lord'] == period['lord'];
      case 3:
        final currentSookshma = currentData['sookshma'] as Map<String, dynamic>?;
        return currentSookshma != null && currentSookshma['lord'] == period['lord'];
    }
    return false;
  }

  void _drillDown(Map<String, dynamic> period) {
    setState(() {
      switch (_currentLevel) {
        case 0:
          _selectedMahadasha = period;
          _currentLevel = 1;
          break;
        case 1:
          _selectedAntardasha = period;
          _currentLevel = 2;
          break;
        case 2:
          _selectedPratyantardasha = period;
          _currentLevel = 3;
          break;
      }
    });
  }

  void _goBack() {
    setState(() {
      if (_currentLevel > 0) {
        _currentLevel--;
        if (_currentLevel < 3) _selectedPratyantardasha = null;
        if (_currentLevel < 2) _selectedAntardasha = null;
        if (_currentLevel < 1) _selectedMahadasha = null;
      }
    });
  }

  void _goToMahadasha() {
    setState(() {
      _currentLevel = 0;
      _selectedMahadasha = null;
      _selectedAntardasha = null;
      _selectedPratyantardasha = null;
    });
  }
}
