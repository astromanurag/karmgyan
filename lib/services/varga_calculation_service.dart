import 'dart:convert';
import 'package:flutter/services.dart';
import '../config/app_config.dart';

/// Service to handle varga chart calculations with formulas from PDFs
/// Formulas are stored in assets/varga_calculation_formulas.json
class VargaCalculationService {
  static final VargaCalculationService _instance = VargaCalculationService._internal();
  factory VargaCalculationService() => _instance;
  VargaCalculationService._internal();

  Map<String, dynamic>? _formulas;

  /// Load formulas from JSON file
  Future<void> loadFormulas() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/varga_calculation_formulas.json');
      _formulas = json.decode(jsonString);
    } catch (e) {
      print('Error loading varga formulas: $e');
      _formulas = null;
    }
  }

  /// Get formula for a specific varga chart
  Map<String, dynamic>? getFormula(String vargaCode) {
    if (_formulas == null) return null;
    final vargaCharts = _formulas!['varga_charts'] as Map<String, dynamic>?;
    return vargaCharts?[vargaCode] as Map<String, dynamic>?;
  }

  /// Get lookup table for a specific varga chart
  List<int>? getLookupTable(String vargaCode) {
    if (_formulas == null) return null;
    final tables = _formulas!['lookup_tables'] as Map<String, dynamic>?;
    final tableKey = '${vargaCode}_table';
    final table = tables?[tableKey];
    if (table is List) {
      return table.cast<int>();
    }
    return null;
  }

  /// Calculate varga sign index using formula or lookup table
  int? calculateVargaSign({
    required String vargaCode,
    required int originalSignIndex,
    required int divisionNum,
    double? degreesInSign,
  }) {
    final formula = getFormula(vargaCode);
    if (formula == null) return null;

    // Check if lookup table exists
    final lookupTable = getLookupTable(vargaCode);
    if (lookupTable != null && divisionNum < lookupTable.length) {
      // Use lookup table: sign_index = (originalSignIndex + lookupTable[divisionNum]) % 12
      return (originalSignIndex + lookupTable[divisionNum]) % 12;
    }

    // Use formula-based calculation
    // Formulas are implemented in all_varga_charts_screen.dart
    // This service provides access to stored formulas for reference
    return null;
  }
}

