import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../../services/numerology_service.dart';

class SuggestNamesTab extends ConsumerStatefulWidget {
  const SuggestNamesTab({super.key});

  @override
  ConsumerState<SuggestNamesTab> createState() => _SuggestNamesTabState();
}

class _SuggestNamesTabState extends ConsumerState<SuggestNamesTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _targetNumber = 8;
  String _selectedSystem = 'pythagorean';
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  bool _suggestByNumber = false; // Toggle between base name and number-only suggestions
  String _selectedLanguage = 'en';
  String? _selectedReligion;
  String? _selectedGender; // 'male', 'female', or null for both
  Set<String> _displayedNames = {}; // Track displayed names for duplicate prevention

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _suggestNames() async {
    if (!_suggestByNumber && !_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = null;
      _displayedNames = {}; // Reset displayed names for new search
    });

    try {
      Map<String, dynamic> result;
      
      if (_suggestByNumber) {
        // Suggest names by number only
        result = await NumerologyService().suggestNamesByNumber(
          targetNumber: _targetNumber,
          system: _selectedSystem,
          language: _selectedLanguage,
          religion: _selectedReligion,
          gender: _selectedGender,
          excludeNames: _displayedNames.toList(),
        );
        // Add base_name and target_number for compatibility with display
        result['base_name'] = 'Names matching number $_targetNumber';
        result['target_number'] = _targetNumber;
      } else {
        // Suggest name variations from base name
        result = await NumerologyService().suggestNames(
          name: _nameController.text.trim(),
          targetNumber: _targetNumber,
          system: _selectedSystem,
        );
      }

      // Track displayed names
      final suggestions = result['suggestions'] as List?;
      if (suggestions != null) {
        for (var suggestion in suggestions) {
          final name = suggestion['name'] as String?;
          if (name != null) {
            _displayedNames.add(name.toLowerCase());
          }
        }
      }

      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      
      print('❌ Error in _suggestNames: $e');
      print('Result was: $_result');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _generateMore() async {
    if (!_suggestByNumber || _result == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch more unique names
      final result = await NumerologyService().suggestNamesByNumber(
        targetNumber: _targetNumber,
        system: _selectedSystem,
        language: _selectedLanguage,
        religion: _selectedReligion,
        gender: _selectedGender,
        excludeNames: _displayedNames.toList(),
      );

      final newSuggestions = result['suggestions'] as List?;
      if (newSuggestions != null && newSuggestions.isNotEmpty) {
        // Track new names
        for (var suggestion in newSuggestions) {
          final name = suggestion['name'] as String?;
          if (name != null) {
            _displayedNames.add(name.toLowerCase());
          }
        }

        // Merge with existing suggestions
        final existingSuggestions = _result!['suggestions'] as List? ?? [];
        final mergedSuggestions = [...existingSuggestions, ...newSuggestions];

        setState(() {
          _result = {
            ..._result!,
            'suggestions': mergedSuggestions,
          };
          _isLoading = false;
        });
      } else {
        // No more unique names available
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No more unique names available'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
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
                      'Find Lucky Name Variations',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Get name suggestions to achieve your desired number',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Toggle between modes
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('From Base Name'),
                            selected: !_suggestByNumber,
                            onSelected: (selected) {
                              setState(() {
                                _suggestByNumber = false;
                              });
                            },
                            selectedColor: AppTheme.accentGold,
                            labelStyle: TextStyle(
                              color: !_suggestByNumber 
                                  ? AppTheme.primaryNavy 
                                  : Colors.grey[600],
                              fontWeight: !_suggestByNumber 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('By Number Only'),
                            selected: _suggestByNumber,
                            onSelected: (selected) {
                              setState(() {
                                _suggestByNumber = true;
                              });
                            },
                            selectedColor: AppTheme.accentGold,
                            labelStyle: TextStyle(
                              color: _suggestByNumber 
                                  ? AppTheme.primaryNavy 
                                  : Colors.grey[600],
                              fontWeight: _suggestByNumber 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Name Field (only show if not suggesting by number)
                    if (!_suggestByNumber)
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Base Name',
                          hintText: 'Enter name to modify',
                          prefixIcon: const Icon(Icons.edit, color: AppTheme.accentGold),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (!_suggestByNumber && (value == null || value.trim().isEmpty)) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                    
                    if (!_suggestByNumber) const SizedBox(height: 16),
                    
                    const SizedBox(height: 16),
                    
                    // Target Number Selector
                    const Text(
                      'Target Number',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildTargetNumberGrid(),
                    
                    const SizedBox(height: 16),
                    
                    // System Selection
                    DropdownButtonFormField<String>(
                      value: _selectedSystem,
                      decoration: InputDecoration(
                        labelText: 'System',
                        prefixIcon: const Icon(Icons.settings, color: AppTheme.accentGold),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'pythagorean',
                          child: Text('Pythagorean'),
                        ),
                        DropdownMenuItem(
                          value: 'chaldean',
                          child: Text('Chaldean'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedSystem = value!;
                        });
                      },
                    ),
                    
                    // Language and Religion Selection (only for "By Number Only" mode)
                    if (_suggestByNumber) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedLanguage,
                        decoration: InputDecoration(
                          labelText: 'Language',
                          prefixIcon: const Icon(Icons.language, color: AppTheme.accentGold),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'en', child: Text('English')),
                          DropdownMenuItem(value: 'hi', child: Text('Hindi (हिंदी)')),
                          DropdownMenuItem(value: 'fr', child: Text('French (Français)')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedLanguage = value!;
                            _selectedReligion = null; // Reset religion when language changes
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String?>(
                        value: _selectedReligion,
                        decoration: InputDecoration(
                          labelText: 'Religion (Optional)',
                          hintText: 'Select religion',
                          prefixIcon: const Icon(Icons.church, color: AppTheme.accentGold),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _getReligionOptions(_selectedLanguage),
                        onChanged: (value) {
                          setState(() {
                            _selectedReligion = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String?>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          labelText: 'Gender (Optional)',
                          hintText: 'Select gender',
                          prefixIcon: const Icon(Icons.person, color: AppTheme.accentGold),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Both')),
                          DropdownMenuItem(value: 'male', child: Text('Male')),
                          DropdownMenuItem(value: 'female', child: Text('Female')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                    
                    // Suggest Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _suggestNames,
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
                                Icon(Icons.auto_fix_high),
                                SizedBox(width: 8),
                                Text(
                                  'Generate Suggestions',
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
              _buildSuggestions(_result!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTargetNumberGrid() {
    // Standard numerology numbers: 1-9 (master numbers 11, 22, 33 are optional)
    // Most common usage is 1-9, master numbers are special cases
    final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]; // Standard numbers
    final masterNumbers = [11, 22, 33]; // Master numbers (optional, shown separately)
    
    return Column(
      children: [
        // Standard numbers 1-9
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: numbers.length,
          itemBuilder: (context, index) {
            final number = numbers[index];
            final isSelected = number == _targetNumber;
            final meaning = NumerologyService().getNumberMeaning(number);
            
            return InkWell(
              onTap: () {
                setState(() {
                  _targetNumber = number;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Color(meaning['color'] as int)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Color(meaning['color'] as int)
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    number.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        // Master numbers (optional, shown separately with info)
        const SizedBox(height: 12),
        const Text(
          'Master Numbers (Optional)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: masterNumbers.map((number) {
            final isSelected = number == _targetNumber;
            final meaning = NumerologyService().getNumberMeaning(number);
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _targetNumber = number;
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color(meaning['color'] as int)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Color(meaning['color'] as int)
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      number.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        const Text(
          'Note: Master numbers (11, 22, 33) are special and not reduced to single digits',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuggestions(Map<String, dynamic> result) {
    final baseName = result['base_name'] as String? ?? 'Suggestions';
    final targetNumber = result['target_number'] as int? ?? result['targetNumber'] as int? ?? _targetNumber;
    final suggestions = result['suggestions'] as List?;
    
    if (targetNumber == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Invalid result: target number not found'),
        ),
      );
    }
    
    final meaning = NumerologyService().getNumberMeaning(targetNumber);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Card(
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
                  Color(meaning['color'] as int).withOpacity(0.2),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  '🎯 Target Number',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Color(meaning['color'] as int),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(meaning['color'] as int).withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      targetNumber.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  meaning['title'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (meaning['keywords'] as List).join(' • '),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Suggestions List
        if (suggestions == null || suggestions.isEmpty)
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No suggestions found for "$baseName"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try a different name or target number',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...suggestions.map((suggestion) {
            final name = suggestion['name'] as String;
            final number = suggestion['number'] as int;
            final variationType = suggestion['variation_type'] as String;
            final isExactMatch = suggestion['exact_match'] as bool? ?? false;
            
            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(meaning['color'] as int),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    if (isExactMatch) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '✓ Match',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(
                  variationType,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.info_outline, color: AppTheme.accentGold),
                  onPressed: () {
                    // Could analyze this name in detail
                    _showNameDetails(name);
                  },
                ),
              ),
            );
          }).toList(),
        
        // Generate More Button (only for "By Number Only" mode)
        if (_suggestByNumber && (suggestions?.isNotEmpty ?? false)) ...[
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _generateMore,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
            ),
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.add_circle_outline),
            label: Text(
              _isLoading ? 'Generating...' : 'Generate More',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_displayedNames.length} unique names generated',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  List<DropdownMenuItem<String?>> _getReligionOptions(String language) {
    switch (language) {
      case 'en':
        return [
          const DropdownMenuItem(value: null, child: Text('Any')),
          const DropdownMenuItem(value: 'christian', child: Text('Christian')),
          const DropdownMenuItem(value: 'jewish', child: Text('Jewish')),
          const DropdownMenuItem(value: 'muslim', child: Text('Muslim')),
          const DropdownMenuItem(value: 'hindu', child: Text('Hindu')),
        ];
      case 'hi':
        return [
          const DropdownMenuItem(value: null, child: Text('कोई भी')),
          const DropdownMenuItem(value: 'hindu', child: Text('हिंदू')),
          const DropdownMenuItem(value: 'sikh', child: Text('सिख')),
        ];
      case 'fr':
        return [
          const DropdownMenuItem(value: null, child: Text('Tout')),
          const DropdownMenuItem(value: 'christian', child: Text('Chrétien')),
        ];
      default:
        return [const DropdownMenuItem(value: null, child: Text('Any'))];
    }
  }

  void _showNameDetails(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: const Text(
          'Would you like to analyze this name in detail?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Switch to analyze tab with this name
              _nameController.text = name;
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGold,
              foregroundColor: AppTheme.primaryNavy,
            ),
            child: const Text('Analyze'),
          ),
        ],
      ),
    );
  }
}

