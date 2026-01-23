#!/usr/bin/env python3
"""
Optimize India locations JSON by removing unnecessary fields and compressing.
"""

import json
import sys

def optimize_locations(input_file, output_file):
    """Optimize locations JSON file"""
    
    print(f"Loading {input_file}...")
    with open(input_file, 'r', encoding='utf-8') as f:
        locations = json.load(f)
    
    print(f"Loaded {len(locations)} locations")
    
    # Optimize: Keep only essential fields
    optimized = []
    for loc in locations:
        opt = {
            'n': loc['name'],  # name
            'a': loc['asciiname'],  # asciiname
            'lat': round(loc['latitude'], 5),  # latitude (5 decimal places = ~1m precision)
            'lon': round(loc['longitude'], 5),  # longitude
            's': loc['state'] if loc['state'] else '',  # state
            'd': loc['district'] if loc['district'] else '',  # district
            'p': loc['population'],  # population
            't': loc['search_terms'][:5] if len(loc['search_terms']) > 5 else loc['search_terms'],  # top 5 search terms
        }
        optimized.append(opt)
    
    print(f"Writing optimized data to {output_file}...")
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(optimized, f, ensure_ascii=False, separators=(',', ':'))  # Compact JSON
    
    original_size = len(json.dumps(locations, ensure_ascii=False))
    optimized_size = len(json.dumps(optimized, ensure_ascii=False, separators=(',', ':')))
    
    print(f"✅ Optimized:")
    print(f"   Original: {original_size / 1024 / 1024:.2f} MB")
    print(f"   Optimized: {optimized_size / 1024 / 1024:.2f} MB")
    print(f"   Reduction: {(1 - optimized_size / original_size) * 100:.1f}%")

if __name__ == '__main__':
    input_file = 'assets/locations/india_locations.json'
    output_file = 'assets/locations/india_locations_optimized.json'
    
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
    if len(sys.argv) > 2:
        output_file = sys.argv[2]
    
    optimize_locations(input_file, output_file)

