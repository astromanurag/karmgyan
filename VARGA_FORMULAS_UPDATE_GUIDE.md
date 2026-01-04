# Varga Formulas Update Guide

## Overview
Varga chart calculation formulas are stored in `assets/varga_calculation_formulas.json`. This file should be updated with formulas extracted from `chartcalculation.pdf` and `astrocalculation 2.pdf`.

## Current Status
- ✅ D9 (Navamsa) - Working correctly
- ❌ D16 (Shodasamsa) - Showing Taurus instead of Scorpio (6 signs off)
- ❌ D20 (Vimsamsa) - Showing Cancer instead of Capricorn (6 signs off)
- ⚠️ Other charts - Need validation with PDFs

## Steps to Update Formulas

### 1. Extract PDF Text
```bash
# Install PDF library
pip install pypdf

# Run extraction script
python3 extract_pdf_text.py
```

This will create:
- `chartcalculation.txt`
- `astrocalculation 2.txt`

**Note:** PDFs are scanned, so OCR errors may exist. Manual review is recommended.

### 2. Review Extracted Text
Look for:
- Calculation formulas for each varga chart
- Lookup tables showing sign mappings
- Specific sequences or offsets for D16, D20, etc.

### 3. Update JSON File
Edit `assets/varga_calculation_formulas.json`:

#### For Formulas:
```json
"D16": {
  "formula": "Extracted formula from PDF",
  "notes": "Any special notes or warnings"
}
```

#### For Lookup Tables:
If PDFs contain lookup tables, add them:
```json
"lookup_tables": {
  "D16_table": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 0, 1, 2, 3],
  "D20_table": [...]
}
```

### 4. Update Code
After updating the JSON, update the calculation logic in:
- `lib/presentation/screens/charts/all_varga_charts_screen.dart`
- Use `VargaCalculationService` to load formulas if needed

## Varga Charts Included (Shodasamsa Vargas)
- D1 (Rashi)
- D2 (Hora)
- D3 (Drekkana)
- D4 (Chaturthamsa)
- D7 (Saptamsa)
- D9 (Navamsa) ✅
- D10 (Dasamsa)
- D12 (Dwadasamsa)
- D16 (Shodasamsa) ❌
- D20 (Vimsamsa) ❌
- D24 (Chaturvimsamsa)
- D27 (Saptavimsamsa)
- D30 (Trimsamsa)
- D40 (Khavedamsa)
- D45 (Akshavedamsa)
- D60 (Shashtiamsa)

**Removed:** D5, D6, D8, D11 (not needed)

## Priority
1. **D16** - Fix Scorpio/Taurus issue
2. **D20** - Fix Capricorn/Cancer issue
3. Validate other charts with PDFs

