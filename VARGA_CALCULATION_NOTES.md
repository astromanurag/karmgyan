# Varga Chart Calculation Notes

## Current Issues
- **D16 (Shodasamsa)**: Expected Scorpio ascendant, getting Taurus (6 signs off)
- **D20 (Vimsamsa)**: Expected Capricorn ascendant, getting Cancer (6 signs off)

## Next Steps
1. Extract text from `chartcalculation.pdf` and `astrocalculation 2.pdf` using:
   ```bash
   pip install pypdf
   python3 extract_pdf_text.py
   ```

2. Review the extracted text files to find:
   - Specific calculation formulas for each varga chart
   - Lookup tables for sign mappings
   - Any special sequences or offsets

3. Update the calculation methods in `all_varga_charts_screen.dart` based on the PDF formulas

## Key Areas to Update
- D16 (Shodasamsa) calculation - lines ~361-363 and ~459-462
- D20 (Vimsamsa) calculation - lines ~364-366 and ~463-465
- Any other varga charts that don't match expected results

## Lookup Table Structure
If the PDFs contain lookup tables, we can create static maps like:
```dart
static const Map<int, int> d16SignMapping = {
  // division_num -> sign_offset
  0: 0, 1: 1, 2: 2, ... // Based on PDF table
};
```

