#!/usr/bin/env python3
"""
Daily Horoscope Generation using Perplexity Pro API
Generates structured horoscope content for all 12 zodiac signs
"""

import sys
import json
import argparse
from datetime import datetime
import requests

# Zodiac signs
ZODIAC_SIGNS = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
]

def generate_horoscope_for_sign(zodiac_sign, date_str, perplexity_api_key):
    """Generate horoscope for a specific zodiac sign using Perplexity API"""
    
    prompt = f"""Generate a detailed daily horoscope for {zodiac_sign} on {date_str}. 
    
Provide a comprehensive astrological reading covering:
1. Love & Relationships - romantic prospects, relationship dynamics
2. Career & Finance - work opportunities, financial outlook
3. Health & Wellness - physical and mental well-being
4. Personal Growth - spiritual and personal development
5. Lucky Numbers - 3-5 numbers for the day
6. Lucky Colors - 2-3 colors
7. Overall Forecast - general energy and advice for the day

Format the response as a JSON object with these exact keys:
{{
  "love": "...",
  "career": "...",
  "health": "...",
  "personal_growth": "...",
  "lucky_numbers": [number1, number2, number3],
  "lucky_colors": ["color1", "color2"],
  "overall_forecast": "..."
}}

Keep each section concise (2-3 sentences) but meaningful. Be positive and encouraging while being realistic."""

    try:
        headers = {
            'Authorization': f'Bearer {perplexity_api_key}',
            'Content-Type': 'application/json',
        }
        
        data = {
            'model': 'llama-3.1-sonar-large-128k-online',
            'messages': [
                {
                    'role': 'system',
                    'content': 'You are an expert Vedic astrologer providing daily horoscope readings. Always respond with valid JSON only, no additional text.'
                },
                {
                    'role': 'user',
                    'content': prompt
                }
            ],
            'temperature': 0.7,
            'max_tokens': 1000,
        }
        
        response = requests.post(
            'https://api.perplexity.ai/chat/completions',
            headers=headers,
            json=data,
            timeout=30
        )
        
        if response.status_code != 200:
            raise Exception(f'Perplexity API error: {response.status_code} - {response.text}')
        
        result = response.json()
        content = result['choices'][0]['message']['content']
        
        # Try to parse JSON from response
        # Sometimes Perplexity wraps JSON in markdown code blocks
        content = content.strip()
        if content.startswith('```'):
            # Remove markdown code blocks
            lines = content.split('\n')
            content = '\n'.join(lines[1:-1]) if len(lines) > 2 else content
        
        # Parse JSON
        try:
            horoscope_data = json.loads(content)
        except json.JSONDecodeError:
            # If JSON parsing fails, create structured response from text
            horoscope_data = {
                'love': content[:200] if len(content) > 200 else content,
                'career': '',
                'health': '',
                'personal_growth': '',
                'lucky_numbers': [],
                'lucky_colors': [],
                'overall_forecast': content[-200:] if len(content) > 200 else content,
            }
        
        return horoscope_data
        
    except Exception as e:
        print(f'Error generating horoscope for {zodiac_sign}: {e}', file=sys.stderr)
        # Return default structure on error
        return {
            'love': f'Today brings opportunities for {zodiac_sign} in relationships.',
            'career': 'Focus on your goals and maintain a positive attitude.',
            'health': 'Take care of your physical and mental well-being.',
            'personal_growth': 'Reflect on your journey and embrace growth.',
            'lucky_numbers': [1, 7, 9],
            'lucky_colors': ['Blue', 'Gold'],
            'overall_forecast': f'A balanced day for {zodiac_sign} with opportunities for progress.',
        }

def generate_all_horoscopes(date_str, perplexity_api_key):
    """Generate horoscopes for all 12 zodiac signs"""
    results = {}
    
    for sign in ZODIAC_SIGNS:
        print(f'Generating horoscope for {sign}...', file=sys.stderr)
        results[sign] = generate_horoscope_for_sign(sign, date_str, perplexity_api_key)
    
    return results

def main():
    parser = argparse.ArgumentParser(description='Generate daily horoscopes using Perplexity API')
    parser.add_argument('--date', type=str, help='Date in YYYY-MM-DD format (default: today)')
    parser.add_argument('--api-key', type=str, required=True, help='Perplexity API key')
    parser.add_argument('--sign', type=str, help='Generate for specific zodiac sign only')
    
    args = parser.parse_args()
    
    date_str = args.date or datetime.now().strftime('%Y-%m-%d')
    api_key = args.api_key
    
    if args.sign:
        # Generate for single sign
        if args.sign not in ZODIAC_SIGNS:
            result = {'error': f'Invalid zodiac sign: {args.sign}'}
        else:
            horoscope = generate_horoscope_for_sign(args.sign, date_str, api_key)
            result = {
                'date': date_str,
                'zodiac_sign': args.sign,
                'content_json': horoscope,
            }
    else:
        # Generate for all signs
        horoscopes = generate_all_horoscopes(date_str, api_key)
        result = {
            'date': date_str,
            'horoscopes': horoscopes,
        }
    
    print(json.dumps(result, indent=2))

if __name__ == '__main__':
    main()

