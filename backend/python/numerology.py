#!/usr/bin/env python3
"""
Numerology Calculations and Analysis
Supports both Pythagorean and Chaldean systems
"""

import json
import sys
from datetime import datetime
import random

# Try to import Faker, but make it optional
try:
    from faker import Faker
    FAKER_AVAILABLE = True
except ImportError:
    FAKER_AVAILABLE = False
    Faker = None

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


def suggest_name_spellings(base_name, target_number, system='pythagorean', max_suggestions=20):
    """
    Suggest alternative spellings of a name to achieve a target number
    Enhanced with more variations and common name patterns
    """
    suggestions = []
    seen_names = set()
    
    vowels_to_add = ['A', 'E', 'I', 'O', 'U']
    common_doubles = ['N', 'L', 'R', 'S', 'T', 'M', 'P']
    
    # Letter substitutions that maintain similar sound
    letter_substitutions = {
        'C': ['K', 'S'],
        'K': ['C', 'Q'],
        'S': ['C', 'Z'],
        'Z': ['S'],
        'F': ['PH'],
        'PH': ['F'],
        'J': ['G'],
        'G': ['J'],
        'X': ['KS', 'Z'],
        'Q': ['K', 'KW'],
    }
    
    base_name_upper = base_name.upper().replace(' ', '')
    
    def add_suggestion(name, number, variation_type, exact_match=True):
        """Helper to add unique suggestions"""
        name_lower = name.lower()
        if name_lower not in seen_names and number == target_number:
            seen_names.add(name_lower)
            suggestions.append({
                'name': name.title(),
                'number': number,
                'exact_match': exact_match,
                'variation_type': variation_type
            })
    
    # Original name
    original = calculate_name_number(base_name, system)
    if original['reduced'] == target_number:
        add_suggestion(base_name, original['reduced'], 'Original')
    
    # Try adding vowels at the end
    for vowel in vowels_to_add:
        variant = base_name + vowel.lower()
        result = calculate_name_number(variant, system)
        add_suggestion(variant, result['reduced'], f'Added {vowel} at end')
    
    # Try adding vowels at the beginning
    for vowel in vowels_to_add:
        variant = vowel.lower() + base_name
        result = calculate_name_number(variant, system)
        add_suggestion(variant, result['reduced'], f'Added {vowel} at start')
    
    # Try doubling letters
    for i, char in enumerate(base_name_upper):
        if char in common_doubles:
            variant = base_name[:i+1] + char.lower() + base_name[i+1:]
            result = calculate_name_number(variant, system)
            add_suggestion(variant, result['reduced'], f'Doubled {char}')
    
    # Try letter substitutions
    for i, char in enumerate(base_name_upper):
        if char in letter_substitutions:
            for sub in letter_substitutions[char]:
                variant = base_name[:i] + sub.lower() + base_name[i+1:]
                result = calculate_name_number(variant, system)
                add_suggestion(variant, result['reduced'], f'Replaced {char} with {sub}')
    
    # Try adding common suffixes
    common_suffixes = ['a', 'e', 'i', 'ia', 'ya', 'an', 'en', 'in', 'on', 'un']
    for suffix in common_suffixes:
        variant = base_name + suffix
        result = calculate_name_number(variant, system)
        add_suggestion(variant, result['reduced'], f'Added suffix "{suffix}"')
    
    # Try adding common prefixes
    common_prefixes = ['a', 'e', 'i', 'o', 'u', 'de', 'le', 'la']
    for prefix in common_prefixes:
        variant = prefix + base_name
        result = calculate_name_number(variant, system)
        add_suggestion(variant, result['reduced'], f'Added prefix "{prefix}"')
    
    # Try removing last letter
    if len(base_name) > 2:
        variant = base_name[:-1]
        result = calculate_name_number(variant, system)
        add_suggestion(variant, result['reduced'], 'Removed last letter')
    
    # Try removing first letter
    if len(base_name) > 2:
        variant = base_name[1:]
        result = calculate_name_number(variant, system)
        add_suggestion(variant, result['reduced'], 'Removed first letter')
    
    # Generate names from common name database (if we had one)
    # For now, return what we have
    return suggestions[:max_suggestions]


# Locale mapping for Faker
LOCALE_MAP = {
    'en': 'en_US',
    'hi': 'hi_IN',
    'fr': 'fr_FR',
}

# Cache for Faker instances
_faker_cache = {}

def _get_faker(locale):
    """Get or create a cached Faker instance for the locale"""
    if not FAKER_AVAILABLE:
        raise ImportError("Faker library is not installed")
    if locale not in _faker_cache:
        try:
            _faker_cache[locale] = Faker(locale)
        except Exception as e:
            # Fallback to default locale if specified locale fails
            print(f"Warning: Failed to create Faker with locale {locale}: {e}, using en_US", file=sys.stderr)
            _faker_cache[locale] = Faker('en_US')
    return _faker_cache[locale]

def _generate_faker_names(language, gender, count=100):
    """
    Generate names using Faker library
    Args:
        language: Language code (en, hi, fr)
        gender: 'male', 'female', or None for both
        count: Number of names to generate
    Returns:
        List of generated names
    """
    try:
        locale = LOCALE_MAP.get(language, 'en_US')
        faker = _get_faker(locale)
        
        names = []
        
        # Generate names based on gender
        if gender == 'male':
            for _ in range(count):
                names.append(faker.first_name_male())
        elif gender == 'female':
            for _ in range(count):
                names.append(faker.first_name_female())
        else:
            # Mix of both
            for _ in range(count):
                if random.random() < 0.5:
                    names.append(faker.first_name_male())
                else:
                    names.append(faker.first_name_female())
        
        # Remove duplicates while preserving order
        seen = set()
        unique_names = []
        for name in names:
            name_lower = name.lower()
            if name_lower not in seen:
                seen.add(name_lower)
                unique_names.append(name)
        
        return unique_names
    except Exception as e:
        # If Faker fails, return empty list and let algorithmic generation handle it
        # Print to stderr to avoid interfering with JSON output
        print(f"Warning: Faker name generation failed: {e}", file=sys.stderr)
        return []

def _find_close_matches(names, target_number, system):
    """
    Find names that are close to the target numerology number
    Returns names that are within 2 numbers of the target
    """
    close_matches = []
    for name in names:
        result = calculate_name_number(name, system)
        current_num = result['reduced']
        # Include if within 2 numbers (accounting for wrap-around)
        diff = abs(current_num - target_number)
        # Check for wrap-around (e.g., 9 is close to 1)
        wrap_diff = min(diff, 9 - diff + 1) if target_number <= 9 else diff
        if wrap_diff <= 2:
            close_matches.append(name)
    return close_matches

def _modify_names_to_match(names, target_number, system, exclude_set, max_variations=5):
    """
    Algorithmically modify names to match target numerology number
    Returns list of modified names that match the target
    """
    suggestions = []
    mapping = PYTHAGOREAN if system == 'pythagorean' else CHALDEAN
    
    for name in names[:20]:  # Limit to first 20 for performance
        if name.lower() in exclude_set:
            continue
            
        name_upper = name.upper()
        current_result = calculate_name_number(name, system)
        current_num = current_result['reduced']
        
        if current_num == target_number:
            continue  # Already matches
        
        # Try adding letters to adjust the number
        # Common letters and their values for quick adjustment
        adjustment_letters = ['A', 'E', 'I', 'O', 'U', 'L', 'N', 'R', 'S', 'T']
        
        for letter in adjustment_letters:
            letter_value = mapping.get(letter, 0)
            if letter_value == 0:
                continue
            
            # Try adding letter at the end
            new_name = name + letter.lower()
            new_result = calculate_name_number(new_name, system)
            if new_result['reduced'] == target_number and new_name.lower() not in exclude_set:
                suggestions.append(new_name)
                exclude_set.add(new_name.lower())
                if len(suggestions) >= max_variations:
                    return suggestions
            
            # Try adding letter at the beginning
            new_name = letter.lower() + name
            new_result = calculate_name_number(new_name, system)
            if new_result['reduced'] == target_number and new_name.lower() not in exclude_set:
                suggestions.append(new_name)
                exclude_set.add(new_name.lower())
                if len(suggestions) >= max_variations:
                    return suggestions
        
        # Try doubling a letter
        for i, char in enumerate(name_upper):
            if char.isalpha():
                new_name = name[:i+1] + char.lower() + name[i+1:]
                new_result = calculate_name_number(new_name, system)
                if new_result['reduced'] == target_number and new_name.lower() not in exclude_set:
                    suggestions.append(new_name)
                    exclude_set.add(new_name.lower())
                    if len(suggestions) >= max_variations:
                        return suggestions
                    break
    
    return suggestions

def _generate_names_algorithmically(target_number, system, language, gender, exclude_set, count=10):
    """
    Generate names algorithmically to match target numerology number
    This is a fallback when Faker doesn't provide enough matches
    """
    suggestions = []
    mapping = PYTHAGOREAN if system == 'pythagorean' else CHALDEAN
    
    # Common name patterns/roots by language
    name_roots = {
        'en': ['Alex', 'Sam', 'John', 'Mary', 'Emma', 'Liam', 'Noah', 'Olivia', 'Sophia', 'James', 'Anna', 'David', 'Sarah', 'Michael', 'Emily', 'Daniel', 'Jessica', 'Matthew', 'Ashley', 'Christopher', 'Robert', 'Jennifer', 'William', 'Elizabeth', 'Thomas', 'Lisa', 'Richard', 'Nancy', 'Joseph', 'Karen'],
        'hi': ['Arjun', 'Priya', 'Rohan', 'Ananya', 'Krishna', 'Sneha', 'Aryan', 'Kavya', 'Aditya', 'Divya', 'Rahul', 'Meera', 'Vikram', 'Pooja', 'Amit', 'Sunita', 'Raj', 'Kavita', 'Abhishek', 'Ritu'],
        'fr': ['Pierre', 'Marie', 'Jean', 'Sophie', 'Louis', 'Camille', 'Antoine', 'Claire', 'François', 'Élise', 'Henri', 'Juliette', 'Charles', 'Amélie', 'Philippe', 'Céline'],
    }
    
    roots = name_roots.get(language, name_roots['en'])
    
    attempts = 0
    max_attempts = count * 30  # Increased attempts
    
    # Try different approaches
    suffixes = ['a', 'e', 'i', 'ia', 'ya', 'ie', 'y', 'an', 'en', 'in', 'on', 'ah', 'eh', 'oh', 'ee', 'ay']
    prefixes = ['a', 'e', 'i', 'o', 'u']
    
    while len(suggestions) < count and attempts < max_attempts:
        attempts += 1
        
        # Start with a root name
        root = random.choice(roots)
        
        # Approach 1: Try adding suffixes
        for suffix in suffixes:
            name = root + suffix
            if name.lower() in exclude_set:
                continue
            
            result = calculate_name_number(name, system)
            if result['reduced'] == target_number:
                suggestions.append(name)
                exclude_set.add(name.lower())
                if len(suggestions) >= count:
                    return suggestions
                break
        
        # Approach 2: Try adding prefixes
        for prefix in prefixes:
            name = prefix + root.lower()
            if name.lower() in exclude_set:
                continue
            
            result = calculate_name_number(name, system)
            if result['reduced'] == target_number:
                suggestions.append(name)
                exclude_set.add(name.lower())
                if len(suggestions) >= count:
                    return suggestions
                break
        
        # Approach 3: Try modifying letters
        if len(root) > 2:
            for i in range(len(root)):
                for letter in 'aeiou':
                    name = root[:i] + letter + root[i+1:]
                    if name.lower() in exclude_set:
                        continue
                    
                    result = calculate_name_number(name, system)
                    if result['reduced'] == target_number:
                        suggestions.append(name)
                        exclude_set.add(name.lower())
                        if len(suggestions) >= count:
                            return suggestions
                        break
                if len(suggestions) >= count:
                    break
    
    return suggestions

def suggest_names_by_number(target_number, system='pythagorean', max_suggestions=20, name_length=None, language='en', religion=None, gender=None, exclude_names=None):
    """
    Suggest names that match a target number
    Uses Faker library for authentic cultural names, with algorithmic fallback
    Supports multiple languages, religions, and genders
    """
    suggestions = []
    exclude_set = set(name.lower() for name in (exclude_names or []))
    
    # Step 1: Use Faker to generate authentic names
    faker_names = _generate_faker_names(language, gender, count=100)
    
    # Step 2: Filter by numerology and exclude duplicates
    for name in faker_names:
        if name.lower() in exclude_set:
            continue
        result = calculate_name_number(name, system)
        if result['reduced'] == target_number:
            suggestions.append({
                'name': name,
                'number': result['reduced'],
                'exact_match': True,
                'variation_type': f'{language.upper()} name'
            })
            exclude_set.add(name.lower())
            if len(suggestions) >= max_suggestions:
                return suggestions
    
    # Step 3: If not enough matches, try algorithmic modification
    if len(suggestions) < max_suggestions:
        close_matches = _find_close_matches(faker_names, target_number, system)
        modified = _modify_names_to_match(close_matches, target_number, system, exclude_set, max_variations=max_suggestions - len(suggestions))
        for name in modified:
            result = calculate_name_number(name, system)
            suggestions.append({
                'name': name,
                'number': result['reduced'],
                'exact_match': True,
                'variation_type': 'Modified name'
            })
            exclude_set.add(name.lower())
    
    # Step 4: If still not enough, generate algorithmically
    if len(suggestions) < max_suggestions:
        generated = _generate_names_algorithmically(target_number, system, language, gender, exclude_set, count=max_suggestions - len(suggestions))
        for name in generated:
            result = calculate_name_number(name, system)
            suggestions.append({
                'name': name,
                'number': result['reduced'],
                'exact_match': True,
                'variation_type': 'Generated name'
            })
            exclude_set.add(name.lower())
    
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


def calculate_loshu_grid(birth_date):
    """
    Calculate Loshu Grid (Magic Square) based on date of birth
    Loshu Grid is a 3x3 grid where numbers 1-9 are placed based on date of birth
    
    Grid layout:
    4 | 9 | 2
    ---------
    3 | 5 | 7
    ---------
    8 | 1 | 6
    
    Each position represents different aspects of life:
    - Top row: Mental plane (4=Education, 9=Spirituality, 2=Emotions)
    - Middle row: Physical plane (3=Creativity, 5=Communication, 7=Intuition)
    - Bottom row: Material plane (8=Authority, 1=Self, 6=Service)
    
    Numbers from date of birth are placed in the grid.
    Missing numbers indicate areas that need development.
    """
    # Parse date if string
    if isinstance(birth_date, str):
        birth_date = datetime.strptime(birth_date, '%Y-%m-%d')
    
    day = birth_date.day
    month = birth_date.month
    year = birth_date.year
    
    # Extract all digits from date
    date_str = f"{day:02d}{month:02d}{year}"
    digits = [int(d) for d in date_str if d.isdigit()]
    
    # Count occurrences of each number (1-9) in the date
    number_counts = {i: digits.count(i) for i in range(1, 10)}
    
    # Loshu Grid positions (traditional layout)
    grid_positions = {
        1: {'row': 2, 'col': 1, 'aspect': 'Self, Leadership, Independence', 'plane': 'Material'},
        2: {'row': 0, 'col': 2, 'aspect': 'Emotions, Cooperation, Partnership', 'plane': 'Mental'},
        3: {'row': 1, 'col': 0, 'aspect': 'Creativity, Expression, Communication', 'plane': 'Physical'},
        4: {'row': 0, 'col': 0, 'aspect': 'Education, Knowledge, Foundation', 'plane': 'Mental'},
        5: {'row': 1, 'col': 1, 'aspect': 'Communication, Versatility, Freedom', 'plane': 'Physical'},
        6: {'row': 2, 'col': 2, 'aspect': 'Service, Responsibility, Nurturing', 'plane': 'Material'},
        7: {'row': 1, 'col': 2, 'aspect': 'Intuition, Spirituality, Analysis', 'plane': 'Physical'},
        8: {'row': 2, 'col': 0, 'aspect': 'Authority, Material Success, Power', 'plane': 'Material'},
        9: {'row': 0, 'col': 1, 'aspect': 'Spirituality, Wisdom, Completion', 'plane': 'Mental'},
    }
    
    # Build grid (3x3)
    grid = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]
    grid_details = []
    
    for num in range(1, 10):
        count = number_counts.get(num, 0)
        pos = grid_positions[num]
        row = pos['row']
        col = pos['col']
        
        # Place number in grid (use count as indicator, or just 1 if present)
        grid[row][col] = num if count > 0 else 0
        
        grid_details.append({
            'number': num,
            'count': count,
            'present': count > 0,
            'row': row,
            'col': col,
            'aspect': pos['aspect'],
            'plane': pos['plane'],
            'meaning': NUMBER_MEANINGS.get(num, {}).get('title', ''),
        })
    
    # Calculate missing numbers (weak areas)
    missing_numbers = [num for num in range(1, 10) if number_counts.get(num, 0) == 0]
    
    # Calculate strong numbers (appear multiple times)
    strong_numbers = [num for num in range(1, 10) if number_counts.get(num, 0) > 1]
    
    # Calculate life path for additional context
    life_path = calculate_life_path_number(birth_date)
    
    return {
        'grid': grid,
        'grid_details': grid_details,
        'number_counts': number_counts,
        'missing_numbers': missing_numbers,
        'strong_numbers': strong_numbers,
        'life_path_number': life_path['number'],
        'date': birth_date.strftime('%Y-%m-%d'),
        'interpretation': {
            'missing': f"Numbers {', '.join(map(str, missing_numbers))} are missing - these areas may need development",
            'strong': f"Numbers {', '.join(map(str, strong_numbers))} appear multiple times - these are your strengths",
            'summary': f"Your Loshu Grid shows {len([n for n in range(1, 10) if number_counts.get(n, 0) > 0])} numbers present out of 9"
        }
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

