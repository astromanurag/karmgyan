#!/usr/bin/env python3
"""
Process GeoNames India location data (IN.txt) into a compact JSON format for Flutter app.
Filters for cities, towns, and populated places.
"""

import json
import sys
import os
from pathlib import Path

def process_geonames_file(input_file, output_file):
    """Process GeoNames file and create compact JSON for app"""
    
    locations = []
    feature_classes_to_include = {
        'P',  # Populated place
        'A',  # Administrative boundary
    }
    
    feature_codes_to_include = {
        'PPL',   # Populated place
        'PPLA',  # Seat of a first-order administrative division
        'PPLA2', # Seat of a second-order administrative division
        'PPLA3', # Seat of a third-order administrative division
        'PPLA4', # Seat of a fourth-order administrative division
        'PPLC',  # Capital of a political entity
        'PPLG',  # Seat of government of a political entity
        'ADM1',  # First-order administrative division
        'ADM2',  # Second-order administrative division
        'ADM3',  # Third-order administrative division
    }
    
    print(f"Processing {input_file}...")
    
    with open(input_file, 'r', encoding='utf-8') as f:
        line_count = 0
        for line in f:
            line_count += 1
            if line_count % 10000 == 0:
                print(f"  Processed {line_count} lines, found {len(locations)} locations...")
            
            parts = line.strip().split('\t')
            if len(parts) < 19:
                continue
            
            try:
                geonameid = parts[0]
                name = parts[1]
                asciiname = parts[2]
                alternatenames = parts[3] if len(parts) > 3 and parts[3] else ''
                latitude = float(parts[4]) if parts[4] else 0.0
                longitude = float(parts[5]) if parts[5] else 0.0
                feature_class = parts[6] if len(parts) > 6 else ''
                feature_code = parts[7] if len(parts) > 7 else ''
                country_code = parts[8] if len(parts) > 8 else ''
                admin1_code = parts[10] if len(parts) > 10 else ''  # State
                admin2_code = parts[11] if len(parts) > 11 else ''   # District
                population = int(parts[14]) if len(parts) > 14 and parts[14] else 0
                timezone = parts[17] if len(parts) > 17 else ''
                
                # Filter for India and relevant features
                if country_code != 'IN':
                    continue
                
                if feature_class not in feature_classes_to_include:
                    continue
                
                if feature_code not in feature_codes_to_include:
                    continue
                
                # Build search terms
                search_terms = [name.lower(), asciiname.lower()]
                if alternatenames:
                    search_terms.extend([alt.lower() for alt in alternatenames.split(',')])
                
                location = {
                    'id': geonameid,
                    'name': name,
                    'asciiname': asciiname,
                    'latitude': latitude,
                    'longitude': longitude,
                    'state': admin1_code,
                    'district': admin2_code,
                    'population': population,
                    'timezone': timezone,
                    'search_terms': list(set(search_terms)),  # Remove duplicates
                }
                
                locations.append(location)
                
            except (ValueError, IndexError) as e:
                # Skip malformed lines
                continue
    
    print(f"\nTotal locations found: {len(locations)}")
    
    # Sort by population (descending) to prioritize cities
    locations.sort(key=lambda x: x['population'], reverse=True)
    
    # Write to JSON file
    print(f"Writing to {output_file}...")
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(locations, f, ensure_ascii=False, indent=2)
    
    print(f"✅ Successfully created {output_file} with {len(locations)} locations")
    print(f"   File size: {os.path.getsize(output_file) / 1024 / 1024:.2f} MB")
    
    return len(locations)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python process_india_locations.py <path_to_IN.txt> [output_file]")
        print("Example: python process_india_locations.py /Users/manurag03/Downloads/IN.txt")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else 'assets/locations/india_locations.json'
    
    # Create output directory if it doesn't exist
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    if not os.path.exists(input_file):
        print(f"Error: Input file not found: {input_file}")
        sys.exit(1)
    
    process_geonames_file(input_file, output_file)

