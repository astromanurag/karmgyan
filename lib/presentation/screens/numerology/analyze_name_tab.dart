import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../config/app_theme.dart';
import '../../../services/numerology_service.dart';

class AnalyzeNameTab extends ConsumerStatefulWidget {
  final Map<String, dynamic>? sampleData;
  
  const AnalyzeNameTab({super.key, this.sampleData});

  @override
  ConsumerState<AnalyzeNameTab> createState() => _AnalyzeNameTabState();
}

class _AnalyzeNameTabState extends ConsumerState<AnalyzeNameTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedSystem = 'pythagorean';
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    // Use sample data if provided
    if (widget.sampleData != null) {
      _nameController.text = widget.sampleData!['name'] ?? '';
      _selectedDate = widget.sampleData!['birthDate'] as DateTime?;
      _selectedSystem = widget.sampleData!['system'] ?? 'pythagorean';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryNavy,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _analyzeName() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final result = await NumerologyService().analyzeName(
        name: _nameController.text.trim(),
        birthDate: _selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
            : null,
        system: _selectedSystem,
      );

      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Card
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Enter Your Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'Enter your full birth name',
                        prefixIcon: const Icon(Icons.person, color: AppTheme.accentGold),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Birth Date (Optional)
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Birth Date (Optional)',
                          hintText: 'Tap to select',
                          prefixIcon: const Icon(Icons.calendar_today, color: AppTheme.accentGold),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _selectedDate != null
                              ? DateFormat('dd MMM yyyy').format(_selectedDate!)
                              : 'Not selected',
                          style: TextStyle(
                            color: _selectedDate != null
                                ? AppTheme.textPrimary
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // System Selection
                    DropdownButtonFormField<String>(
                      value: _selectedSystem,
                      decoration: InputDecoration(
                        labelText: 'Numerology System',
                        prefixIcon: const Icon(Icons.settings, color: AppTheme.accentGold),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'pythagorean',
                          child: Text('Pythagorean (Western)'),
                        ),
                        DropdownMenuItem(
                          value: 'chaldean',
                          child: Text('Chaldean (Ancient)'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedSystem = value!;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Analyze Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _analyzeName,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGold,
                        foregroundColor: AppTheme.primaryNavy,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryNavy,
                                ),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calculate),
                                SizedBox(width: 8),
                                Text(
                                  'Analyze Name',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Results
            if (_result != null) ...[
              const SizedBox(height: 20),
              _buildResults(_result!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResults(Map<String, dynamic> result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Destiny Number
        if (result['destiny_number'] != null)
          _buildNumberCard(
            'Destiny Number',
            'Your life purpose and natural talents',
            result['destiny_number'],
          ),
        
        const SizedBox(height: 16),
        
        // Soul Urge Number
        if (result['soul_urge_number'] != null)
          _buildNumberCard(
            'Soul Urge Number',
            'Your inner desires and heart\'s wishes',
            result['soul_urge_number'],
          ),
        
        const SizedBox(height: 16),
        
        // Personality Number
        if (result['personality_number'] != null)
          _buildNumberCard(
            'Personality Number',
            'How others perceive you',
            result['personality_number'],
          ),
        
        const SizedBox(height: 16),
        
        // Life Path Number (if birth date provided)
        if (result['life_path_number'] != null)
          _buildNumberCard(
            'Life Path Number',
            'Your core journey and life lessons',
            result['life_path_number'],
          ),
        
        const SizedBox(height: 16),
        
        // Compatibility (if both life path and destiny exist)
        if (result['life_path_destiny_compatibility'] != null)
          _buildCompatibilityCard(result['life_path_destiny_compatibility']),
      ],
    );
  }

  Widget _buildNumberCard(
    String title,
    String subtitle,
    Map<String, dynamic> numberData,
  ) {
    final number = numberData['number'] as int;
    final meaning = numberData['meaning'] as Map<String, dynamic>?;
    
    if (meaning == null) return const SizedBox.shrink();

    final localMeaning = NumerologyService().getNumberMeaning(number);
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Color(localMeaning['color'] as int).withOpacity(0.1),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(localMeaning['color'] as int),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(localMeaning['color'] as int).withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      number.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Title
            Text(
              meaning['title'] as String? ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentGold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Personality
            Text(
              meaning['personality'] as String? ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Keywords
            if (meaning['keywords'] != null)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (meaning['keywords'] as List)
                    .map((keyword) => Chip(
                          label: Text(
                            keyword,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Color(localMeaning['color'] as int).withOpacity(0.2),
                          side: BorderSide.none,
                        ))
                    .toList(),
              ),
            
            const SizedBox(height: 16),
            
            // Strengths
            if (meaning['strengths'] != null) ...[
              const Text(
                '💪 Strengths',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              ...(meaning['strengths'] as List).map((strength) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(strength, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  )),
            ],
            
            const SizedBox(height: 16),
            
            // Weaknesses
            if (meaning['weaknesses'] != null) ...[
              const Text(
                '⚠️ Challenges',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              ...(meaning['weaknesses'] as List).map((weakness) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(weakness, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  )),
            ],
            
            const SizedBox(height: 16),
            
            // Career Paths
            if (meaning['career'] != null) ...[
              const Text(
                '💼 Career Paths',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (meaning['career'] as List)
                    .map((career) => Chip(
                          label: Text(career, style: const TextStyle(fontSize: 12)),
                          backgroundColor: AppTheme.accentGold.withOpacity(0.2),
                          side: BorderSide.none,
                        ))
                    .toList(),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Lucky Colors
            if (meaning['lucky_colors'] != null) ...[
              const Text(
                '🎨 Lucky Colors',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (meaning['lucky_colors'] as List)
                    .map((color) => Chip(
                          label: Text(color, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.purple.withOpacity(0.1),
                          side: BorderSide.none,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilityCard(Map<String, dynamic> compatibility) {
    final score = compatibility['score'] as int;
    final compatibilityLevel = compatibility['compatibility'] as String;
    final description = compatibility['description'] as String;
    
    Color scoreColor;
    if (score >= 70) {
      scoreColor = Colors.green;
    } else if (score >= 50) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              scoreColor.withOpacity(0.1),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💫 Life Path & Destiny Compatibility',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 16),
            
            // Compatibility Score
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: scoreColor, width: 8),
                    ),
                    child: Center(
                      child: Text(
                        '$score%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: scoreColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      compatibilityLevel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

