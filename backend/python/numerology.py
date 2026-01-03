#!/usr/bin/env python3
"""
Numerology Calculations and Analysis
Supports both Pythagorean and Chaldean systems
"""

import json
from datetime import datetime

# Pythagorean system (most common in Western numerology)
PYTHAGOREAN = {
    'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5, 'F': 6, 'G': 7, 'H': 8, 'I': 9,
    'J': 1, 'K': 2, 'L': 3, 'M': 4, 'N': 5, 'O': 6, 'P': 7, 'Q': 8, 'R': 9,
    'S': 1, 'T': 2, 'U': 3, 'V': 4, 'W': 5, 'X': 6, 'Y': 7, 'Z': 8
}

# Chaldean system (ancient system)
CHALDEAN = {
    'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5, 'F': 8, 'G': 3, 'H': 5, 'I': 1,
    'J': 1, 'K': 2, 'L': 3, 'M': 4, 'N': 5, 'O': 7, 'P': 8, 'Q': 1, 'R': 2,
    'S': 3, 'T': 4, 'U': 6, 'V': 6, 'W': 6, 'X': 5, 'Y': 1, 'Z': 7
}

VOWELS = set('AEIOU')

# Number meanings and characteristics
NUMBER_MEANINGS = {
    1: {
        "title": "The Leader",
        "keywords": ["Independence", "Leadership", "Ambition", "Originality"],
        "personality": "Natural leaders, independent, ambitious, and pioneering. They are assertive and have strong willpower.",
        "strengths": ["Leadership", "Innovation", "Courage", "Self-reliance"],
        "weaknesses": ["Dominating", "Impatient", "Arrogant", "Self-centered"],
        "career": ["Entrepreneur", "Manager", "Innovator", "Leader"],
        "lucky_colors": ["Red", "Orange", "Gold"],
        "compatible_numbers": [1, 3, 5, 9],
        "neutral_numbers": [2, 7],
        "incompatible_numbers": [4, 6, 8]
    },
    2: {
        "title": "The Peacemaker",
        "keywords": ["Harmony", "Cooperation", "Diplomacy", "Sensitivity"],
        "personality": "Diplomatic, sensitive, and cooperative. They seek harmony and balance in relationships.",
        "strengths": ["Cooperation", "Patience", "Intuition", "Diplomacy"],
        "weaknesses": ["Indecisive", "Over-sensitive", "Dependent", "Timid"],
        "career": ["Mediator", "Counselor", "Team player", "Artist"],
        "lucky_colors": ["White", "Cream", "Silver"],
        "compatible_numbers": [2, 4, 6, 8],
        "neutral_numbers": [1, 5],
        "incompatible_numbers": [3, 7, 9]
    },
    3: {
        "title": "The Creative",
        "keywords": ["Creativity", "Expression", "Joy", "Communication"],
        "personality": "Creative, expressive, and optimistic. They have a gift for communication and enjoy socializing.",
        "strengths": ["Creativity", "Communication", "Optimism", "Charm"],
        "weaknesses": ["Scattered", "Superficial", "Extravagant", "Moody"],
        "career": ["Artist", "Writer", "Entertainer", "Designer"],
        "lucky_colors": ["Yellow", "Purple", "Pink"],
        "compatible_numbers": [1, 3, 5, 9],
        "neutral_numbers": [2, 6],
        "incompatible_numbers": [4, 7, 8]
    },
    4: {
        "title": "The Builder",
        "keywords": ["Stability", "Hard work", "Discipline", "Organization"],
        "personality": "Practical, disciplined, and reliable. They build solid foundations and value stability.",
        "strengths": ["Reliability", "Organization", "Discipline", "Patience"],
        "weaknesses": ["Rigid", "Stubborn", "Conventional", "Overly serious"],
        "career": ["Engineer", "Accountant", "Manager", "Builder"],
        "lucky_colors": ["Blue", "Grey", "Brown"],
        "compatible_numbers": [2, 4, 6, 8],
        "neutral_numbers": [7],
        "incompatible_numbers": [1, 3, 5, 9]
    },
    5: {
        "title": "The Free Spirit",
        "keywords": ["Freedom", "Adventure", "Change", "Versatility"],
        "personality": "Adventurous, versatile, and freedom-loving. They thrive on change and new experiences.",
        "strengths": ["Adaptability", "Curiosity", "Energy", "Enthusiasm"],
        "weaknesses": ["Restless", "Irresponsible", "Impulsive", "Inconsistent"],
        "career": ["Travel", "Sales", "Marketing", "Entrepreneur"],
        "lucky_colors": ["Green", "Turquoise", "Light blue"],
        "compatible_numbers": [1, 3, 5, 9],
        "neutral_numbers": [2, 7],
        "incompatible_numbers": [4, 6, 8]
    },
    6: {
        "title": "The Nurturer",
        "keywords": ["Love", "Responsibility", "Harmony", "Service"],
        "personality": "Caring, responsible, and nurturing. They seek harmony and enjoy helping others.",
        "strengths": ["Compassion", "Responsibility", "Balance", "Healing"],
        "weaknesses": ["Perfectionist", "Anxious", "Self-sacrificing", "Worry"],
        "career": ["Teacher", "Counselor", "Nurse", "Social worker"],
        "lucky_colors": ["Pink", "Blue", "Indigo"],
        "compatible_numbers": [2, 4, 6, 8],
        "neutral_numbers": [3, 9],
        "incompatible_numbers": [1, 5, 7]
    },
    7: {
        "title": "The Seeker",
        "keywords": ["Wisdom", "Spirituality", "Analysis", "Introspection"],
        "personality": "Analytical, spiritual, and introspective. They seek deeper truths and understanding.",
        "strengths": ["Wisdom", "Analysis", "Intuition", "Spirituality"],
        "weaknesses": ["Aloof", "Skeptical", "Secretive", "Isolated"],
        "career": ["Researcher", "Analyst", "Philosopher", "Scientist"],
        "lucky_colors": ["Purple", "Violet", "Sea green"],
        "compatible_numbers": [7],
        "neutral_numbers": [1, 2, 4, 5],
        "incompatible_numbers": [3, 6, 8, 9]
    },
    8: {
        "title": "The Powerhouse",
        "keywords": ["Power", "Success", "Abundance", "Authority"],
        "personality": "Ambitious, powerful, and success-oriented. They excel in business and material pursuits.",
        "strengths": ["Ambition", "Leadership", "Management", "Success"],
        "weaknesses": ["Materialistic", "Workaholic", "Controlling", "Impatient"],
        "career": ["Executive", "Banker", "CEO", "Entrepreneur"],
        "lucky_colors": ["Black", "Dark blue", "Purple"],
        "compatible_numbers": [2, 4, 6, 8],
        "neutral_numbers": [1],
        "incompatible_numbers": [3, 5, 7, 9]
    },
    9: {
        "title": "The Humanitarian",
        "keywords": ["Compassion", "Wisdom", "Idealism", "Service"],
        "personality": "Compassionate, idealistic, and humanitarian. They work for the greater good of humanity.",
        "strengths": ["Compassion", "Generosity", "Wisdom", "Tolerance"],
        "weaknesses": ["Impractical", "Moody", "Self-pitying", "Lost in dreams"],
        "career": ["Humanitarian", "Artist", "Teacher", "Healer"],
        "lucky_colors": ["Red", "Crimson", "Pink"],
        "compatible_numbers": [1, 3, 5, 9],
        "neutral_numbers": [2, 6],
        "incompatible_numbers": [4, 7, 8]
    },
    11: {
        "title": "The Spiritual Messenger (Master Number)",
        "keywords": ["Intuition", "Inspiration", "Spirituality", "Illumination"],
        "personality": "Highly intuitive and spiritual. They are visionaries with a mission to inspire others.",
        "strengths": ["Intuition", "Vision", "Inspiration", "Spiritual insight"],
        "weaknesses": ["Over-sensitive", "Impractical", "Nervous", "Dreamy"],
        "career": ["Spiritual teacher", "Artist", "Healer", "Motivator"],
        "lucky_colors": ["Silver", "White", "Gold"],
        "compatible_numbers": [2, 11, 22],
        "neutral_numbers": [1, 3, 9],
        "incompatible_numbers": [4, 5, 8]
    },
    22: {
        "title": "The Master Builder (Master Number)",
        "keywords": ["Vision", "Achievement", "Power", "Manifestation"],
        "personality": "Master builders who can turn dreams into reality. They have the vision and ability to create lasting legacies.",
        "strengths": ["Vision", "Practicality", "Leadership", "Manifestation"],
        "weaknesses": ["Overwhelmed", "Dominating", "Stressed", "Controlling"],
        "career": ["Architect", "Engineer", "Visionary leader", "Entrepreneur"],
        "lucky_colors": ["Coral", "Gold", "Crimson"],
        "compatible_numbers": [4, 11, 22],
        "neutral_numbers": [2, 6, 8],
        "incompatible_numbers": [1, 3, 5, 9]
    },
    33: {
        "title": "The Master Teacher (Master Number)",
        "keywords": ["Service", "Love", "Healing", "Teaching"],
        "personality": "Master teachers and healers. They are here to uplift humanity through love and service.",
        "strengths": ["Compassion", "Healing", "Teaching", "Service"],
        "weaknesses": ["Martyr complex", "Overwhelmed", "Emotional burden", "Self-sacrifice"],
        "career": ["Teacher", "Healer", "Counselor", "Spiritual guide"],
        "lucky_colors": ["Gold", "Crimson", "Emerald"],
        "compatible_numbers": [6, 11, 22, 33],
        "neutral_numbers": [2, 3, 9],
        "incompatible_numbers": [1, 4, 5, 8]
    }
}


def reduce_to_single_digit(number, keep_master=True):
    """
    Reduce a number to single digit (1-9) or master number (11, 22, 33)
    """
    if keep_master and number in [11, 22, 33]:
        return number
    
    while number > 9:
        if keep_master and number in [11, 22, 33]:
            return number
        number = sum(int(digit) for digit in str(number))
    
    return number


def calculate_name_number(name, system='pythagorean'):
    """
    Calculate the numerology value of a name
    """
    mapping = PYTHAGOREAN if system == 'pythagorean' else CHALDEAN
    name = name.upper().replace(' ', '')
    
    total = 0
    breakdown = []
    
    for char in name:
        if char.isalpha():
            value = mapping.get(char, 0)
            total += value
            breakdown.append({'letter': char, 'value': value})
    
    reduced = reduce_to_single_digit(total)
    
    return {
        'total': total,
        'reduced': reduced,
        'breakdown': breakdown
    }


def calculate_destiny_number(full_name, system='pythagorean'):
    """
    Destiny Number (Expression Number) - from full birth name
    Represents your life purpose and what you're meant to achieve
    """
    result = calculate_name_number(full_name, system)
    return {
        'number': result['reduced'],
        'calculation': result,
        'meaning': NUMBER_MEANINGS.get(result['reduced'], {}),
        'description': 'Your life purpose and natural talents'
    }


def calculate_soul_urge_number(full_name, system='pythagorean'):
    """
    Soul Urge Number (Heart's Desire) - from vowels in name
    Represents your inner desires and motivations
    """
    mapping = PYTHAGOREAN if system == 'pythagorean' else CHALDEAN
    name = full_name.upper().replace(' ', '')
    
    total = 0
    breakdown = []
    
    for char in name:
        if char in VOWELS:
            value = mapping.get(char, 0)
            total += value
            breakdown.append({'letter': char, 'value': value})
    
    reduced = reduce_to_single_digit(total)
    
    return {
        'number': reduced,
        'calculation': {'total': total, 'reduced': reduced, 'breakdown': breakdown},
        'meaning': NUMBER_MEANINGS.get(reduced, {}),
        'description': 'Your inner desires and heart\'s true wishes'
    }


def calculate_personality_number(full_name, system='pythagorean'):
    """
    Personality Number - from consonants in name
    Represents how others perceive you
    """
    mapping = PYTHAGOREAN if system == 'pythagorean' else CHALDEAN
    name = full_name.upper().replace(' ', '')
    
    total = 0
    breakdown = []
    
    for char in name:
        if char.isalpha() and char not in VOWELS:
            value = mapping.get(char, 0)
            total += value
            breakdown.append({'letter': char, 'value': value})
    
    reduced = reduce_to_single_digit(total)
    
    return {
        'number': reduced,
        'calculation': {'total': total, 'reduced': reduced, 'breakdown': breakdown},
        'meaning': NUMBER_MEANINGS.get(reduced, {}),
        'description': 'How others perceive you and your outer personality'
    }


def calculate_life_path_number(birth_date):
    """
    Life Path Number - from date of birth
    Most important number - represents your life journey
    """
    # Parse date if string
    if isinstance(birth_date, str):
        birth_date = datetime.strptime(birth_date, '%Y-%m-%d')
    
    day = birth_date.day
    month = birth_date.month
    year = birth_date.year
    
    # Reduce each component
    day_reduced = reduce_to_single_digit(day)
    month_reduced = reduce_to_single_digit(month)
    year_reduced = reduce_to_single_digit(year)
    
    # Sum and reduce
    total = day_reduced + month_reduced + year_reduced
    life_path = reduce_to_single_digit(total)
    
    return {
        'number': life_path,
        'calculation': {
            'day': day,
            'month': month,
            'year': year,
            'day_reduced': day_reduced,
            'month_reduced': month_reduced,
            'year_reduced': year_reduced,
            'total': total
        },
        'meaning': NUMBER_MEANINGS.get(life_path, {}),
        'description': 'Your life path and core journey'
    }


def calculate_compatibility(number1, number2):
    """
    Calculate compatibility between two numbers
    Returns compatibility score and analysis
    """
    info1 = NUMBER_MEANINGS.get(number1, {})
    info2 = NUMBER_MEANINGS.get(number2, {})
    
    # Check if numbers are in each other's compatible/neutral/incompatible lists
    compatible1 = info1.get('compatible_numbers', [])
    incompatible1 = info1.get('incompatible_numbers', [])
    
    if number2 in compatible1:
        compatibility = 'High'
        score = 85
        description = f"Number {number1} and {number2} are highly compatible. They complement each other well."
    elif number2 in incompatible1:
        compatibility = 'Low'
        score = 35
        description = f"Number {number1} and {number2} may face challenges. Different approaches to life."
    else:
        compatibility = 'Medium'
        score = 60
        description = f"Number {number1} and {number2} have neutral compatibility. Balance is key."
    
    return {
        'number1': number1,
        'number2': number2,
        'compatibility': compatibility,
        'score': score,
        'description': description,
        'number1_info': info1,
        'number2_info': info2
    }


def suggest_name_spellings(base_name, target_number, system='pythagorean', max_suggestions=10):
    """
    Suggest alternative spellings of a name to achieve a target number
    """
    suggestions = []
    
    # Try different variations
    # 1. Add/remove vowels
    # 2. Double letters
    # 3. Replace similar sounding letters
    
    vowels_to_add = ['A', 'E', 'I', 'O', 'U']
    common_doubles = ['N', 'L', 'R', 'S', 'T']
    
    base_name_upper = base_name.upper().replace(' ', '')
    
    # Original name
    original = calculate_name_number(base_name, system)
    if original['reduced'] == target_number:
        suggestions.append({
            'name': base_name,
            'number': original['reduced'],
            'exact_match': True,
            'variation_type': 'Original'
        })
    
    # Try adding vowels at the end
    for vowel in vowels_to_add:
        variant = base_name + vowel.lower()
        result = calculate_name_number(variant, system)
        if result['reduced'] == target_number:
            suggestions.append({
                'name': variant.title(),
                'number': result['reduced'],
                'exact_match': True,
                'variation_type': f'Added {vowel} at end'
            })
    
    # Try doubling letters
    for i, char in enumerate(base_name_upper):
        if char in common_doubles:
            variant = base_name[:i+1] + char.lower() + base_name[i+1:]
            result = calculate_name_number(variant, system)
            if result['reduced'] == target_number:
                suggestions.append({
                    'name': variant.title(),
                    'number': result['reduced'],
                    'exact_match': True,
                    'variation_type': f'Doubled {char}'
                })
    
    return suggestions[:max_suggestions]


def analyze_name(full_name, birth_date=None, system='pythagorean'):
    """
    Complete numerology analysis of a name
    """
    destiny = calculate_destiny_number(full_name, system)
    soul_urge = calculate_soul_urge_number(full_name, system)
    personality = calculate_personality_number(full_name, system)
    
    result = {
        'name': full_name,
        'system': system,
        'destiny_number': destiny,
        'soul_urge_number': soul_urge,
        'personality_number': personality,
    }
    
    if birth_date:
        life_path = calculate_life_path_number(birth_date)
        result['life_path_number'] = life_path
        
        # Check compatibility between life path and destiny
        compatibility = calculate_compatibility(life_path['number'], destiny['number'])
        result['life_path_destiny_compatibility'] = compatibility
    
    return result


def get_lucky_details(number):
    """
    Get detailed lucky information for a number
    """
    info = NUMBER_MEANINGS.get(number, {})
    
    return {
        'number': number,
        'title': info.get('title', ''),
        'lucky_colors': info.get('lucky_colors', []),
        'compatible_numbers': info.get('compatible_numbers', []),
        'career_paths': info.get('career', []),
        'strengths': info.get('strengths', []),
        'weaknesses': info.get('weaknesses', [])
    }


# Example usage and testing
if __name__ == '__main__':
    # Test name analysis
    print("=== Name Analysis ===")
    result = analyze_name("John Smith", "1990-05-15")
    print(json.dumps(result, indent=2))
    
    print("\n=== Compatibility Test ===")
    comp = calculate_compatibility(1, 5)
    print(json.dumps(comp, indent=2))
    
    print("\n=== Name Suggestions ===")
    suggestions = suggest_name_spellings("John", 8)
    print(json.dumps(suggestions, indent=2))

