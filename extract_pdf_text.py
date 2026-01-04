#!/usr/bin/env python3
"""
Extract text from PDF files for varga chart calculations
Note: PDFs are scanned, so OCR errors may exist. Manual review recommended.
"""

try:
    import pypdf
    HAS_PYPDF = True
except ImportError:
    try:
        import PyPDF2
        HAS_PYPDF = True
        pypdf = PyPDF2
    except ImportError:
        HAS_PYPDF = False

def extract_pdf_text(pdf_path):
    """Extract text from PDF file"""
    if not HAS_PYPDF:
        print("ERROR: pypdf or PyPDF2 not installed")
        print("Please install: pip install pypdf")
        print("Or: pip install PyPDF2")
        return None
    
    try:
        text = ""
        with open(pdf_path, 'rb') as file:
            pdf_reader = pypdf.PdfReader(file)
            num_pages = len(pdf_reader.pages)
            print(f"  Found {num_pages} pages")
            
            for i, page in enumerate(pdf_reader.pages, 1):
                page_text = page.extract_text()
                text += f"\n--- PAGE {i} ---\n"
                text += page_text + "\n"
                print(f"  Extracted page {i}/{num_pages}")
        
        return text
    except Exception as e:
        print(f"Error reading {pdf_path}: {e}")
        return None

if __name__ == "__main__":
    import sys
    import os
    
    pdfs = ["chartcalculation.pdf", "astrocalculation 2.pdf"]
    
    print("="*80)
    print("Varga Chart PDF Text Extraction")
    print("="*80)
    print("NOTE: PDFs are scanned - OCR errors may exist!")
    print("Please review extracted text carefully and validate formulas.\n")
    
    for pdf in pdfs:
        if not os.path.exists(pdf):
            print(f"\nWARNING: {pdf} not found. Skipping...")
            continue
            
        print(f"\n{'='*80}")
        print(f"Extracting text from: {pdf}")
        print('='*80)
        text = extract_pdf_text(pdf)
        if text:
            # Save to text file
            output_file = pdf.replace('.pdf', '.txt')
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(text)
            print(f"\n✓ Saved to: {output_file}")
            print(f"  Total characters: {len(text)}")
            print(f"\nFirst 2000 characters preview:\n{'-'*80}")
            print(text[:2000])
            print(f"\n{'='*80}")
            print("Next steps:")
            print("1. Review the extracted text files")
            print("2. Find varga calculation formulas and lookup tables")
            print("3. Update assets/varga_calculation_formulas.json")
            print("4. Update calculation code in all_varga_charts_screen.dart")
        else:
            print(f"✗ Failed to extract text from {pdf}")
    
    print("\n" + "="*80)
    print("Extraction complete!")
    print("="*80)

