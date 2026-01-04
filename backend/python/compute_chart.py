#!/usr/bin/env python3
"""
Astrological Chart Computation using pyswisseph
North Indian System with Lahiri Ayanamsha (Nirayana/Sidereal)
Handles birth charts, dasha calculations, and divisional charts

Note: pyswisseph uses Universal Time (UT/UTC) for all calculations.
Local time must be converted to UT before passing to Swiss Ephemeris functions.
"""

import sys
import json
import argparse
from datetime import datetime, timedelta
import swisseph as swe

# Try to use zoneinfo (Python 3.9+) for proper DST handling
try:
    from zoneinfo import ZoneInfo
    HAS_ZONEINFO = True
except ImportError:
    HAS_ZONEINFO = False
    try:
        import pytz
        HAS_PYTZ = True
    except ImportError:
        HAS_PYTZ = False

# Set Lahiri Ayanamsha for Nirayana calculations
swe.set_sid_mode(swe.SIDM_LAHIRI)

# Vimshottari Dasha periods (in years)
DASHA_PERIODS = {
    'Ketu': 7,
    'Venus': 20,
    'Sun': 6,
    'Moon': 10,
    'Mars': 7,
    'Rahu': 18,
    'Jupiter': 16,
    'Saturn': 19,
    'Mercury': 17,
}

# Dasha sequence (starting from Ketu as per Vimshottari system)
DASHA_SEQUENCE = ['Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury']

# Total Vimshottari cycle = 120 years
TOTAL_DASHA_YEARS = 120

# Nakshatra lords (27 nakshatras, each ruled by a planet in sequence)
NAKSHATRA_LORDS = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury',
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury',
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury'
]

# Nakshatra names
NAKSHATRA_NAMES = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
    'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni',
    'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha',
    'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishta',
    'Shatabhisha', 'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
]

# Zodiac signs
ZODIAC_SIGNS = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
]

def get_timezone_offset(latitude, longitude):
    """Get approximate timezone offset based on longitude"""
    # Simple approximation: each 15 degrees of longitude = 1 hour
    # This is a rough estimate; for production, use a proper timezone database
    offset_hours = round(longitude / 15)
    return offset_hours

def local_to_ut(birth_datetime, timezone_str, longitude):
    """
    Convert local time to Universal Time (UT) with proper DST handling.
    
    pyswisseph requires all times in UT (Universal Time / UTC).
    This function handles:
    - Named timezone strings (e.g., 'Asia/Kolkata', 'America/New_York')
    - DST (Daylight Saving Time) transitions
    - Fallback to offset-based calculation if timezone library unavailable
    
    Returns:
        tuple: (ut_datetime, tz_offset_hours, dst_active)
    """
    dst_active = False
    
    # Try using zoneinfo (Python 3.9+) for proper DST handling
    if HAS_ZONEINFO:
        try:
            tz = ZoneInfo(timezone_str)
            # Make the datetime timezone-aware
            local_dt = birth_datetime.replace(tzinfo=tz)
            # Get UTC offset (includes DST)
            utc_offset = local_dt.utcoffset()
            tz_offset_hours = utc_offset.total_seconds() / 3600
            # Check if DST is active
            dst_offset = local_dt.dst()
            dst_active = dst_offset is not None and dst_offset.total_seconds() > 0
            # Convert to UT
            ut_datetime = birth_datetime - utc_offset
            return ut_datetime, tz_offset_hours, dst_active
        except Exception as e:
            pass  # Fall through to other methods
    
    # Try using pytz for DST handling
    if HAS_PYTZ:
        try:
            tz = pytz.timezone(timezone_str)
            # Localize the datetime (handles DST)
            local_dt = tz.localize(birth_datetime)
            # Get UTC offset
            utc_offset = local_dt.utcoffset()
            tz_offset_hours = utc_offset.total_seconds() / 3600
            # Check if DST is active
            dst_offset = local_dt.dst()
            dst_active = dst_offset is not None and dst_offset.total_seconds() > 0
            # Convert to UT
            ut_datetime = birth_datetime - utc_offset
            return ut_datetime, tz_offset_hours, dst_active
        except Exception as e:
            pass  # Fall through to offset-based calculation
    
    # Fallback: Use fixed offset based on timezone string or longitude
    # Common timezone offsets (standard time, without DST)
    tz_offsets = {
        'Asia/Kolkata': 5.5,      # IST = UTC+5:30 (India doesn't observe DST)
        'IST': 5.5,
        'Asia/Mumbai': 5.5,
        'Asia/Delhi': 5.5,
        'Asia/Calcutta': 5.5,
        'UTC': 0,
        'GMT': 0,
        'America/New_York': -5,   # EST (note: doesn't account for EDT)
        'America/Los_Angeles': -8, # PST
        'Europe/London': 0,        # GMT (note: doesn't account for BST)
        'Europe/Paris': 1,         # CET
        'Asia/Tokyo': 9,           # JST (Japan doesn't observe DST)
        'Asia/Shanghai': 8,        # CST (China doesn't observe DST)
        'Australia/Sydney': 10,    # AEST (note: doesn't account for AEDT)
    }
    
    if timezone_str in tz_offsets:
        tz_offset_hours = tz_offsets[timezone_str]
    else:
        # Approximate from longitude
        tz_offset_hours = round(longitude / 15)
    
    # Convert to UT
    ut_datetime = birth_datetime - timedelta(hours=tz_offset_hours)
    return ut_datetime, tz_offset_hours, dst_active

def datetime_to_jd_ut(birth_datetime, timezone_str, longitude):
    """
    Convert local datetime to Julian Day in Universal Time.
    
    This is the primary function to use for Swiss Ephemeris calculations.
    
    Returns:
        tuple: (jd_ut, tz_offset_hours, dst_active)
    """
    ut_datetime, tz_offset_hours, dst_active = local_to_ut(birth_datetime, timezone_str, longitude)
    
    # Calculate Julian Day for UT
    ut_hours = ut_datetime.hour + ut_datetime.minute / 60.0 + ut_datetime.second / 3600.0
    
    jd_ut = swe.julday(
        ut_datetime.year,
        ut_datetime.month,
        ut_datetime.day,
        ut_hours,
        swe.GREG_CAL
    )
    
    return jd_ut, tz_offset_hours, dst_active

def get_nakshatra_info(longitude):
    """Get nakshatra name and lord for a given longitude"""
    nakshatra_span = 360 / 27  # 13.333... degrees per nakshatra
    nakshatra_index = int(longitude / nakshatra_span) % 27
    nakshatra_name = NAKSHATRA_NAMES[nakshatra_index]
    nakshatra_lord = NAKSHATRA_LORDS[nakshatra_index]
    # Position within nakshatra (0-1)
    pada = int((longitude % nakshatra_span) / (nakshatra_span / 4)) + 1
    return nakshatra_name, nakshatra_lord, pada

def get_sign_from_longitude(longitude):
    """Get zodiac sign from longitude"""
    sign_index = int(longitude / 30) % 12
    return ZODIAC_SIGNS[sign_index]

def get_degrees_in_sign(longitude):
    """Get degrees within the current sign (0-30)"""
    return longitude % 30

def compute_all_dasha_periods(moon_longitude, birth_jd):
    """Compute all Mahadasha periods with start and end dates"""
    # Get nakshatra info for Moon
    nakshatra_span = 360 / 27
    nakshatra_index = int(moon_longitude / nakshatra_span) % 27
    nakshatra_lord = NAKSHATRA_LORDS[nakshatra_index]
    
    # Position within nakshatra (0-1)
    position_in_nakshatra = (moon_longitude % nakshatra_span) / nakshatra_span
    
    # Starting Mahadasha is the nakshatra lord
    start_index = DASHA_SEQUENCE.index(nakshatra_lord)
    
    # Calculate how much of the first dasha has elapsed at birth
    first_dasha_lord = nakshatra_lord
    first_dasha_total_years = DASHA_PERIODS[first_dasha_lord]
    elapsed_portion = position_in_nakshatra
    remaining_years = first_dasha_total_years * (1 - elapsed_portion)
    
    # Build all Mahadasha periods
    mahadashas = []
    current_jd = birth_jd
    
    for cycle in range(2):  # Generate 2 cycles (240 years) to cover most lifetimes
        for i in range(9):
            dasha_index = (start_index + i) % 9
            lord = DASHA_SEQUENCE[dasha_index]
            
            if cycle == 0 and i == 0:
                # First dasha - use remaining portion
                years = remaining_years
            else:
                years = DASHA_PERIODS[lord]
            
            start_date = jd_to_date(current_jd)
            end_jd = current_jd + (years * 365.25)
            end_date = jd_to_date(end_jd)
            
            mahadashas.append({
                'lord': lord,
                'start_date': start_date,
                'end_date': end_date,
                'years': round(years, 2),
                'start_jd': current_jd,
                'end_jd': end_jd,
            })
            
            current_jd = end_jd
    
    return mahadashas

def compute_antardasha_periods(mahadasha):
    """Compute all Antardasha periods within a Mahadasha"""
    lord = mahadasha['lord']
    start_jd = mahadasha['start_jd']
    total_years = mahadasha['years']
    
    start_index = DASHA_SEQUENCE.index(lord)
    antardashas = []
    current_jd = start_jd
    
    for i in range(9):
        antardasha_index = (start_index + i) % 9
        antardasha_lord = DASHA_SEQUENCE[antardasha_index]
        
        # Antardasha period = Mahadasha period * Antardasha lord's period / 120
        antardasha_years = total_years * DASHA_PERIODS[antardasha_lord] / TOTAL_DASHA_YEARS
        
        start_date = jd_to_date(current_jd)
        end_jd = current_jd + (antardasha_years * 365.25)
        end_date = jd_to_date(end_jd)
        
        antardashas.append({
            'lord': antardasha_lord,
            'start_date': start_date,
            'end_date': end_date,
            'days': round(antardasha_years * 365.25, 1),
            'start_jd': current_jd,
            'end_jd': end_jd,
        })
        
        current_jd = end_jd
    
    return antardashas

def compute_pratyantardasha_periods(antardasha):
    """Compute all Pratyantardasha periods within an Antardasha"""
    lord = antardasha['lord']
    start_jd = antardasha['start_jd']
    total_days = antardasha['days']
    
    start_index = DASHA_SEQUENCE.index(lord)
    pratyantardashas = []
    current_jd = start_jd
    
    for i in range(9):
        prat_index = (start_index + i) % 9
        prat_lord = DASHA_SEQUENCE[prat_index]
        
        # Pratyantardasha period proportional to sub-lord's period
        prat_days = total_days * DASHA_PERIODS[prat_lord] / TOTAL_DASHA_YEARS
        
        start_date = jd_to_date(current_jd)
        end_jd = current_jd + prat_days
        end_date = jd_to_date(end_jd)
        
        pratyantardashas.append({
            'lord': prat_lord,
            'start_date': start_date,
            'end_date': end_date,
            'days': round(prat_days, 2),
            'start_jd': current_jd,
            'end_jd': end_jd,
        })
        
        current_jd = end_jd
    
    return pratyantardashas

def compute_sookshma_dasha_periods(pratyantardasha):
    """Compute all Sookshma Dasha periods within a Pratyantardasha"""
    lord = pratyantardasha['lord']
    start_jd = pratyantardasha['start_jd']
    total_days = pratyantardasha['days']
    
    start_index = DASHA_SEQUENCE.index(lord)
    sookshmas = []
    current_jd = start_jd
    
    for i in range(9):
        sookshma_index = (start_index + i) % 9
        sookshma_lord = DASHA_SEQUENCE[sookshma_index]
        
        # Sookshma period proportional to sub-lord's period
        sookshma_days = total_days * DASHA_PERIODS[sookshma_lord] / TOTAL_DASHA_YEARS
        
        start_date = jd_to_date(current_jd)
        end_jd = current_jd + sookshma_days
        end_date = jd_to_date(end_jd)
        
        sookshmas.append({
            'lord': sookshma_lord,
            'start_date': start_date,
            'end_date': end_date,
            'hours': round(sookshma_days * 24, 2),
            'start_jd': current_jd,
            'end_jd': end_jd,
        })
        
        current_jd = end_jd
    
    return sookshmas

def jd_to_date(jd):
    """Convert Julian Day to date string"""
    result = swe.revjul(jd, swe.GREG_CAL)
    year, month, day, hour = result
    hour_int = int(hour)
    minute = int((hour - hour_int) * 60)
    return f"{int(year)}-{int(month):02d}-{int(day):02d}"

def compute_dasha(date_str, time_str, latitude, longitude, timezone_str):
    """Compute complete Vimshottari Dasha with all levels"""
    try:
        # Parse date and time
        datetime_str = f"{date_str} {time_str}"
        try:
            birth_datetime = datetime.strptime(datetime_str, "%Y-%m-%d %H:%M:%S")
        except ValueError:
            birth_datetime = datetime.strptime(datetime_str, "%Y-%m-%d %H:%M")
        
        # Convert local time to Julian Day in Universal Time
        # This properly handles timezone and DST
        jd_ut, tz_offset, dst_active = datetime_to_jd_ut(birth_datetime, timezone_str, longitude)
        
        # Calculate Moon's sidereal position (Nirayana) using UT
        moon_result = swe.calc_ut(jd_ut, swe.MOON, swe.FLG_SIDEREAL)
        moon_longitude = moon_result[0][0]
        
        # Get nakshatra info
        nakshatra_name, nakshatra_lord, pada = get_nakshatra_info(moon_longitude)
        
        # Compute all Mahadasha periods using birth JD in UT
        mahadashas = compute_all_dasha_periods(moon_longitude, jd_ut)
        
        # Find current dasha - use current time in UT for consistency
        now = datetime.now()
        current_jd, _, _ = datetime_to_jd_ut(now, timezone_str, longitude)
        
        current_mahadasha = None
        current_antardasha = None
        current_pratyantardasha = None
        current_sookshma = None
        
        for md in mahadashas:
            if md['start_jd'] <= current_jd < md['end_jd']:
                current_mahadasha = md
                # Find current Antardasha
                antardashas = compute_antardasha_periods(md)
                for ad in antardashas:
                    if ad['start_jd'] <= current_jd < ad['end_jd']:
                        current_antardasha = ad
                        # Find current Pratyantardasha
                        pratyantardashas = compute_pratyantardasha_periods(ad)
                        for pd in pratyantardashas:
                            if pd['start_jd'] <= current_jd < pd['end_jd']:
                                current_pratyantardasha = pd
                                # Find current Sookshma
                                sookshmas = compute_sookshma_dasha_periods(pd)
                                for sd in sookshmas:
                                    if sd['start_jd'] <= current_jd < sd['end_jd']:
                                        current_sookshma = sd
                                        break
                                break
                        break
                break
        
        return {
            'moon_nakshatra': nakshatra_name,
            'nakshatra_lord': nakshatra_lord,
            'nakshatra_pada': pada,
            'moon_longitude': round(moon_longitude, 4),
            'mahadashas': mahadashas[:18],  # Return 18 periods (covers ~2 cycles)
            'current': {
                'mahadasha': current_mahadasha,
                'antardasha': current_antardasha,
                'pratyantardasha': current_pratyantardasha,
                'sookshma': current_sookshma,
            }
        }
    except Exception as e:
        return {'error': str(e)}

def compute_birth_chart(date_str, time_str, latitude, longitude, timezone_str):
    """
    Compute birth chart with planets and houses using North Indian system with Lahiri Ayanamsha.
    
    All calculations use Universal Time (UT) as required by Swiss Ephemeris.
    Timezone and DST are properly handled via datetime_to_jd_ut().
    """
    try:
        # Parse date and time
        datetime_str = f"{date_str} {time_str}"
        try:
            birth_datetime = datetime.strptime(datetime_str, "%Y-%m-%d %H:%M:%S")
        except ValueError:
            birth_datetime = datetime.strptime(datetime_str, "%Y-%m-%d %H:%M")
        
        # Convert local time to Julian Day in Universal Time
        # This properly handles timezone and DST
        jd_ut, tz_offset, dst_active = datetime_to_jd_ut(birth_datetime, timezone_str, longitude)
        
        # Set geographic location for topocentric calculations
        swe.set_topo(longitude, latitude, 0)
        
        # Calculate sidereal time and ascendant using Lahiri Ayanamsha
        # Use sidereal calculation flags
        flags = swe.FLG_SIDEREAL | swe.FLG_SWIEPH
        
        # Calculate houses using Equal house system (common in North Indian astrology)
        # 'E' = Equal house system
        # Note: swe.houses expects (jd_ut, latitude, longitude, house_system)
        houses = swe.houses(jd_ut, latitude, longitude, b'E')
        
        # Get Ayanamsha value for this Julian Day
        ayanamsha = swe.get_ayanamsa_ut(jd_ut)
        
        # Tropical ascendant from houses calculation
        tropical_ascendant = houses[0][0]
        
        # Convert to Sidereal (Nirayana) ascendant
        sidereal_ascendant = (tropical_ascendant - ayanamsha) % 360
        
        # Determine ascendant sign
        asc_sign_index = int(sidereal_ascendant / 30)
        asc_sign = ZODIAC_SIGNS[asc_sign_index]
        asc_degrees_in_sign = sidereal_ascendant % 30
        
        # In North Indian chart, houses are fixed positions based on ascendant sign
        # House 1 = Ascendant sign, House 2 = next sign, etc.
        house_signs = []
        for i in range(12):
            sign_index = (asc_sign_index + i) % 12
            house_signs.append(ZODIAC_SIGNS[sign_index])
        
        # Planet indices
        planets_dict = {
            'Sun': swe.SUN,
            'Moon': swe.MOON,
            'Mercury': swe.MERCURY,
            'Venus': swe.VENUS,
            'Mars': swe.MARS,
            'Jupiter': swe.JUPITER,
            'Saturn': swe.SATURN,
        }
        
        # Calculate planet positions (sidereal) using Universal Time
        planets = {}
        for planet_name, planet_index in planets_dict.items():
            result = swe.calc_ut(jd_ut, planet_index, flags)
            planet_longitude = result[0][0]
            latitude_val = result[0][1]
            speed = result[0][3]
            
            # Determine sign and house
            sign_index = int(planet_longitude / 30) % 12
            sign = ZODIAC_SIGNS[sign_index]
            degrees_in_sign = planet_longitude % 30
            
            # In North Indian system, house is determined by sign relative to ascendant
            house = ((sign_index - asc_sign_index) % 12) + 1
            
            # Degrees within house (same as degrees in sign for equal house system)
            degrees_in_house = degrees_in_sign
            
            # Get nakshatra info
            nakshatra_name, nakshatra_lord, pada = get_nakshatra_info(planet_longitude)
            
            planets[planet_name] = {
                'longitude': round(planet_longitude, 4),
                'longitude_absolute': round((planet_longitude + ayanamsha) % 360, 4),  # Tropical
                'latitude': round(latitude_val, 4),
                'speed': round(speed, 4),
                'retrograde': speed < 0,
                'sign': sign,
                'sign_index': sign_index,
                'degrees_in_sign': round(degrees_in_sign, 2),
                'house': house,
                'degrees_in_house': round(degrees_in_house, 2),
                'nakshatra': nakshatra_name,
                'nakshatra_lord': nakshatra_lord,
                'nakshatra_pada': pada,
            }
        
        # Calculate Rahu (True Node) using Universal Time
        rahu_result = swe.calc_ut(jd_ut, swe.TRUE_NODE, flags)
        rahu_longitude = rahu_result[0][0]
        rahu_sign_index = int(rahu_longitude / 30) % 12
        rahu_nakshatra, rahu_nak_lord, rahu_pada = get_nakshatra_info(rahu_longitude)
        
        planets['Rahu'] = {
            'longitude': round(rahu_longitude, 4),
            'longitude_absolute': round((rahu_longitude + ayanamsha) % 360, 4),
            'latitude': 0,
            'speed': round(rahu_result[0][3], 4),
            'retrograde': True,  # Rahu is always retrograde
            'sign': ZODIAC_SIGNS[rahu_sign_index],
            'sign_index': rahu_sign_index,
            'degrees_in_sign': round(rahu_longitude % 30, 2),
            'house': ((rahu_sign_index - asc_sign_index) % 12) + 1,
            'degrees_in_house': round(rahu_longitude % 30, 2),
            'nakshatra': rahu_nakshatra,
            'nakshatra_lord': rahu_nak_lord,
            'nakshatra_pada': rahu_pada,
        }
        
        # Calculate Ketu (180 degrees opposite to Rahu)
        ketu_longitude = (rahu_longitude + 180) % 360
        ketu_sign_index = int(ketu_longitude / 30) % 12
        ketu_nakshatra, ketu_nak_lord, ketu_pada = get_nakshatra_info(ketu_longitude)
        
        planets['Ketu'] = {
            'longitude': round(ketu_longitude, 4),
            'longitude_absolute': round((ketu_longitude + ayanamsha) % 360, 4),
            'latitude': 0,
            'speed': round(rahu_result[0][3], 4),
            'retrograde': True,  # Ketu is always retrograde
            'sign': ZODIAC_SIGNS[ketu_sign_index],
            'sign_index': ketu_sign_index,
            'degrees_in_sign': round(ketu_longitude % 30, 2),
            'house': ((ketu_sign_index - asc_sign_index) % 12) + 1,
            'degrees_in_house': round(ketu_longitude % 30, 2),
            'nakshatra': ketu_nakshatra,
            'nakshatra_lord': ketu_nak_lord,
            'nakshatra_pada': ketu_pada,
        }
        
        # Format houses (in North Indian system, each house = 30 degrees)
        houses_dict = {}
        houses_dict['Ascendant'] = round(sidereal_ascendant, 4)
        houses_dict['Ascendant_Sign'] = asc_sign
        houses_dict['Ascendant_Degrees'] = round(asc_degrees_in_sign, 2)
        
        for i in range(12):
            house_start = (asc_sign_index * 30 + i * 30) % 360
            houses_dict[f'House_{i + 1}'] = round(house_start, 4)
            houses_dict[f'House_{i + 1}_Sign'] = house_signs[i]
        
        # Get Moon nakshatra for dasha calculation
        moon_nakshatra, moon_nak_lord, moon_pada = get_nakshatra_info(planets['Moon']['longitude'])
        
        return {
            'planets': planets,
            'houses': houses_dict,
            'ascendant': round(sidereal_ascendant, 4),
            'ascendant_sign': asc_sign,
            'ascendant_sign_index': asc_sign_index,
            'ascendant_degrees': round(asc_degrees_in_sign, 2),
            'tropical_ascendant': round(tropical_ascendant, 4),
            'ayanamsha': round(ayanamsha, 4),
            'ayanamsha_name': 'Lahiri',
            'house_system': 'Equal',
            'moon_nakshatra': moon_nakshatra,
            'moon_nakshatra_lord': moon_nak_lord,
            'moon_nakshatra_pada': moon_pada,
            'julian_day_ut': round(jd_ut, 6),
            'timezone_offset': tz_offset,
            'dst_active': dst_active,
            'input': {
                'date': date_str,
                'time': time_str,
                'latitude': latitude,
                'longitude': longitude,
                'timezone': timezone_str,
            }
        }
    except Exception as e:
        import traceback
        return {'error': str(e), 'traceback': traceback.format_exc()}

def compute_divisional_chart(date_str, time_str, latitude, longitude, chart_type, timezone_str):
    """Compute divisional charts (D1-D60)"""
    try:
        # Get the main chart first
        main_chart = compute_birth_chart(date_str, time_str, latitude, longitude, timezone_str)
        
        if 'error' in main_chart:
            return main_chart
        
        # Divisional chart divisions
        divisions = {
            'D1': 1, 'D2': 2, 'D3': 3, 'D4': 4, 'D7': 7, 'D9': 9,
            'D10': 10, 'D12': 12, 'D16': 16, 'D20': 20, 'D24': 24,
            'D27': 27, 'D30': 30, 'D40': 40, 'D45': 45, 'D60': 60
        }
        
        division = divisions.get(chart_type, 1)
        
        if division == 1:
            return {'chart': main_chart}
        
        # Calculate divisional chart positions
        divisional_planets = {}
        for planet_name, planet_data in main_chart['planets'].items():
            longitude = planet_data['longitude']
            
            # Calculate divisional longitude
            # Each sign is divided into 'division' parts
            sign_index = int(longitude / 30)
            degrees_in_sign = longitude % 30
            
            # Calculate which division within the sign
            division_size = 30 / division
            division_num = int(degrees_in_sign / division_size)
            
            # Calculate new sign based on division type
            if chart_type == 'D9':  # Navamsa
                new_sign_index = (sign_index * 9 + division_num) % 12
            elif chart_type == 'D2':  # Hora
                if sign_index % 2 == 0:  # Odd signs
                    new_sign_index = 4 if division_num == 0 else 3  # Sun/Moon
                else:  # Even signs
                    new_sign_index = 3 if division_num == 0 else 4
            else:
                # General formula for other divisions
                new_sign_index = (sign_index + division_num * (12 // division if 12 % division == 0 else 1)) % 12
            
            new_longitude = new_sign_index * 30 + (degrees_in_sign % division_size) * division
            
            divisional_planets[planet_name] = {
                'longitude': round(new_longitude, 4),
                'sign': ZODIAC_SIGNS[new_sign_index],
                'degrees_in_sign': round(new_longitude % 30, 2),
                'house': ((new_sign_index - main_chart['planets']['Sun']['sign_index']) % 12) + 1,
            }
        
        return {
            'chart_type': chart_type,
            'division': division,
            'planets': divisional_planets,
            'ascendant_sign': main_chart['ascendant_sign'],
        }
    except Exception as e:
        return {'error': str(e)}

def compute_panchang(date_str, latitude, longitude, timezone_str):
    """Compute daily Panchang using sidereal calculations"""
    try:
        # Parse date (at sunrise, approximately 6 AM local time)
        birth_datetime = datetime.strptime(date_str + " 06:00:00", "%Y-%m-%d %H:%M:%S")
        
        # Convert local time (6 AM) to Julian Day in Universal Time
        # This properly handles timezone and DST
        jd_ut, tz_offset, dst_active = datetime_to_jd_ut(birth_datetime, timezone_str, longitude)
        
        flags = swe.FLG_SIDEREAL | swe.FLG_SWIEPH
        
        # Calculate Sun and Moon positions (sidereal) using UT
        sun_result = swe.calc_ut(jd_ut, swe.SUN, flags)
        moon_result = swe.calc_ut(jd_ut, swe.MOON, flags)
        
        sun_longitude = sun_result[0][0]
        moon_longitude = moon_result[0][0]
        
        # Calculate Tithi (lunar day) - each tithi is 12 degrees of Moon-Sun separation
        moon_sun_diff = (moon_longitude - sun_longitude) % 360
        tithi_num = int(moon_sun_diff / 12) + 1
        
        tithi_names = [
            'Pratipada', 'Dwitiya', 'Tritiya', 'Chaturthi', 'Panchami',
            'Shashthi', 'Saptami', 'Ashtami', 'Navami', 'Dashami',
            'Ekadashi', 'Dwadashi', 'Trayodashi', 'Chaturdashi', 'Purnima/Amavasya'
        ]
        
        paksha = 'Shukla' if tithi_num <= 15 else 'Krishna'
        tithi_index = (tithi_num - 1) % 15
        tithi = f"{paksha} {tithi_names[tithi_index]}"
        
        # Calculate Nakshatra
        nakshatra_name, nakshatra_lord, pada = get_nakshatra_info(moon_longitude)
        
        # Calculate Yoga - (Sun + Moon) / 13.333...
        yoga_value = (sun_longitude + moon_longitude) % 360
        yoga_num = int(yoga_value / (360 / 27)) + 1
        yoga_names = [
            'Vishkambha', 'Preeti', 'Ayushman', 'Saubhagya', 'Shobhana',
            'Atiganda', 'Sukarma', 'Dhriti', 'Shoola', 'Ganda',
            'Vriddhi', 'Dhruva', 'Vyaghata', 'Harshana', 'Vajra',
            'Siddhi', 'Vyatipata', 'Variyan', 'Parigha', 'Shiva',
            'Siddha', 'Sadhya', 'Shubha', 'Shukla', 'Brahma',
            'Indra', 'Vaidhriti'
        ]
        yoga = yoga_names[(yoga_num - 1) % 27]
        
        # Calculate Karana - half tithi
        karana_num = int(moon_sun_diff / 6) + 1
        karana_names = [
            'Bava', 'Balava', 'Kaulava', 'Taitila', 'Gara',
            'Vanija', 'Vishti', 'Shakuni', 'Chatushpada', 'Naga', 'Kimstughna'
        ]
        karana = karana_names[(karana_num - 1) % 11]
        
        # Calculate Vara (weekday)
        weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
        vara = weekdays[birth_datetime.weekday()]
        
        # Calculate Sunrise, Sunset, and Moonrise times
        # Get JD for midnight local time (start of day)
        date_midnight = datetime.strptime(date_str + " 00:00:00", "%Y-%m-%d %H:%M:%S")
        jd_midnight, _, _ = datetime_to_jd_ut(date_midnight, timezone_str, longitude)
        
        # Geographic position: [longitude, latitude, altitude]
        geopos = [longitude, latitude, 0.0]
        
        # Calculate Sunrise (Sun rise)
        sunrise_result = swe.rise_trans(
            jd_midnight,
            swe.SUN,
            swe.CALC_RISE,
            geopos,
            0.0,  # atmospheric pressure (0 = standard)
            0.0   # atmospheric temperature (0 = standard)
        )
        
        # Calculate Sunset (Sun set)
        sunset_result = swe.rise_trans(
            jd_midnight,
            swe.SUN,
            swe.CALC_SET,
            geopos,
            0.0,
            0.0
        )
        
        # Calculate Moonrise (Moon rise)
        moonrise_result = swe.rise_trans(
            jd_midnight,
            swe.MOON,
            swe.CALC_RISE,
            geopos,
            0.0,
            0.0
        )
        
        # Convert JD times to local time strings
        def jd_to_time_str(jd_time, tz_offset_hours):
            """Convert Julian Day to time string in local timezone"""
            # Convert JD to datetime (UTC)
            year, month, day, hour = swe.revjul(jd_time)
            minute = int((hour - int(hour)) * 60)
            hour = int(hour)
            
            # Apply timezone offset
            local_hour = hour + int(tz_offset_hours)
            local_minute = minute + int((tz_offset_hours - int(tz_offset_hours)) * 60)
            
            # Handle minute overflow
            if local_minute >= 60:
                local_hour += 1
                local_minute -= 60
            elif local_minute < 0:
                local_hour -= 1
                local_minute += 60
            
            # Handle hour overflow
            if local_hour >= 24:
                local_hour -= 24
            elif local_hour < 0:
                local_hour += 24
            
            return f"{local_hour:02d}:{local_minute:02d}"
        
        # Return code: 0 = success, -2 = circumpolar (no rise/set)
        sunrise = jd_to_time_str(sunrise_result[1][0], tz_offset) if sunrise_result[0] == 0 else "N/A"
        sunset = jd_to_time_str(sunset_result[1][0], tz_offset) if sunset_result[0] == 0 else "N/A"
        moonrise = jd_to_time_str(moonrise_result[1][0], tz_offset) if moonrise_result[0] == 0 else "N/A"
        
        # Calculate Rahu Kaal (inauspicious time based on weekday)
        rahu_kaal_map = {
            0: ['16:30', '18:00'],  # Sunday
            1: ['07:30', '09:00'],  # Monday
            2: ['15:00', '16:30'],  # Tuesday
            3: ['12:00', '13:30'],  # Wednesday
            4: ['13:30', '15:00'],  # Thursday
            5: ['10:30', '12:00'],  # Friday
            6: ['09:00', '10:30'],  # Saturday
        }
        rahu_kaal_times = rahu_kaal_map[birth_datetime.weekday()]
        rahu_kaal = f"{rahu_kaal_times[0]}-{rahu_kaal_times[1]}"
        
        # Calculate Gulika Kaal
        gulika_kaal_map = {
            0: ['15:00', '16:30'],  # Sunday
            1: ['13:30', '15:00'],  # Monday
            2: ['12:00', '13:30'],  # Tuesday
            3: ['10:30', '12:00'],  # Wednesday
            4: ['09:00', '10:30'],  # Thursday
            5: ['07:30', '09:00'],  # Friday
            6: ['06:00', '07:30'],  # Saturday
        }
        gulika_kaal_times = gulika_kaal_map[birth_datetime.weekday()]
        gulika_kaal = f"{gulika_kaal_times[0]}-{gulika_kaal_times[1]}"
        
        # Calculate Yamaghanta
        yamaghanda_map = {
            0: ['12:00', '13:30'],  # Sunday
            1: ['10:30', '12:00'],  # Monday
            2: ['09:00', '10:30'],  # Tuesday
            3: ['07:30', '09:00'],  # Wednesday
            4: ['06:00', '07:30'],  # Thursday
            5: ['15:00', '16:30'],  # Friday
            6: ['13:30', '15:00'],  # Saturday
        }
        yamaghanda_times = yamaghanda_map[birth_datetime.weekday()]
        yamaghanda = f"{yamaghanda_times[0]}-{yamaghanda_times[1]}"
        
        return {
            'tithi': tithi,
            'tithi_number': tithi_num,
            'paksha': paksha,
            'nakshatra': nakshatra_name,
            'nakshatra_lord': nakshatra_lord,
            'nakshatra_pada': pada,
            'yoga': yoga,
            'karana': karana,
            'vara': vara,
            'sun_sign': get_sign_from_longitude(sun_longitude),
            'moon_sign': get_sign_from_longitude(moon_longitude),
            'sunrise': sunrise,
            'sunset': sunset,
            'moonrise': moonrise,
            'rahu_kaal': rahu_kaal,
            'gulika_kaal': gulika_kaal,
            'yamaghanda': yamaghanda,
        }
    except Exception as e:
        return {'error': str(e)}

def compute_muhurat(date_str, latitude, longitude, timezone_str, event_type='general'):
    """Compute auspicious times (Muhurat) for a given date and event type"""
    try:
        # Get panchang data for the date
        panchang_data = compute_panchang(date_str, latitude, longitude, timezone_str)
        
        if 'error' in panchang_data:
            return panchang_data
        
        # Parse date for calculations
        date_midnight = datetime.strptime(date_str + " 00:00:00", "%Y-%m-%d %H:%M:%S")
        jd_midnight, tz_offset, _ = datetime_to_jd_ut(date_midnight, timezone_str, longitude)
        
        # Calculate sunrise and sunset times
        geopos = [longitude, latitude, 0.0]
        sunrise_result = swe.rise_trans(jd_midnight, swe.SUN, swe.CALC_RISE, geopos, 0.0, 0.0)
        sunset_result = swe.rise_trans(jd_midnight, swe.SUN, swe.CALC_SET, geopos, 0.0, 0.0)
        
        def jd_to_time_str(jd_time, tz_offset_hours):
            """Convert Julian Day to time string in local timezone"""
            year, month, day, hour = swe.revjul(jd_time)
            minute = int((hour - int(hour)) * 60)
            hour = int(hour)
            local_hour = hour + int(tz_offset_hours)
            local_minute = minute + int((tz_offset_hours - int(tz_offset_hours)) * 60)
            if local_minute >= 60:
                local_hour += 1
                local_minute -= 60
            elif local_minute < 0:
                local_hour -= 1
                local_minute += 60
            if local_hour >= 24:
                local_hour -= 24
            elif local_hour < 0:
                local_hour += 24
            return f"{local_hour:02d}:{local_minute:02d}"
        
        sunrise_jd = sunrise_result[1][0] if sunrise_result[0] == 0 else None
        sunset_jd = sunset_result[1][0] if sunset_result[0] == 0 else None
        
        sunrise_time = jd_to_time_str(sunrise_jd, tz_offset) if sunrise_jd else "06:00"
        sunset_time = jd_to_time_str(sunset_jd, tz_offset) if sunset_jd else "18:00"
        
        # Extract sunrise and sunset hour/minute
        sunrise_hour, sunrise_min = map(int, sunrise_time.split(':'))
        sunset_hour, sunset_min = map(int, sunset_time.split(':'))
        
        # Calculate day duration in minutes
        day_start_minutes = sunrise_hour * 60 + sunrise_min
        day_end_minutes = sunset_hour * 60 + sunset_min
        day_duration = day_end_minutes - day_start_minutes
        
        # Divide day into 8 parts (Ashtamangala Muhurat)
        part_duration = day_duration / 8
        muhurats = []
        
        # Auspicious nakshatras (varies by event type)
        auspicious_nakshatras = {
            'general': ['Rohini', 'Mrigashira', 'Pushya', 'Uttara Phalguni', 'Hasta', 'Swati', 'Anuradha', 'Shravana', 'Dhanishta', 'Uttara Bhadrapada', 'Revati'],
            'marriage': ['Rohini', 'Mrigashira', 'Pushya', 'Uttara Phalguni', 'Hasta', 'Swati', 'Anuradha', 'Shravana', 'Dhanishta', 'Uttara Bhadrapada', 'Revati'],
            'business': ['Pushya', 'Hasta', 'Swati', 'Anuradha', 'Shravana', 'Dhanishta'],
            'travel': ['Mrigashira', 'Pushya', 'Hasta', 'Swati', 'Anuradha', 'Shravana'],
            'house_warming': ['Rohini', 'Pushya', 'Uttara Phalguni', 'Hasta', 'Swati', 'Anuradha', 'Shravana', 'Dhanishta']
        }
        
        current_nakshatra = panchang_data.get('nakshatra', '')
        is_auspicious_nakshatra = current_nakshatra in auspicious_nakshatras.get(event_type, auspicious_nakshatras['general'])
        
        # Generate muhurat times (8 parts of the day)
        for i in range(8):
            start_minutes = day_start_minutes + (i * part_duration)
            end_minutes = day_start_minutes + ((i + 1) * part_duration)
            
            start_hour = int(start_minutes // 60)
            start_min = int(start_minutes % 60)
            end_hour = int(end_minutes // 60)
            end_min = int(end_minutes % 60)
            
            time_str = f"{start_hour:02d}:{start_min:02d} - {end_hour:02d}:{end_min:02d}"
            
            # Determine quality based on time of day and panchang
            # First and last parts are generally less auspicious
            if i == 0 or i == 7:
                quality = 'moderate'
                description = 'Early morning or evening - moderate auspiciousness'
            elif i in [2, 3, 4, 5]:  # Mid-day parts
                quality = 'excellent' if is_auspicious_nakshatra else 'good'
                description = 'Mid-day period - highly auspicious' if is_auspicious_nakshatra else 'Mid-day period - good time'
            else:
                quality = 'good'
                description = 'Good auspicious time'
            
            # Check if time conflicts with Rahu Kaal, Gulika Kaal, or Yamaghanda
            rahu_kaal = panchang_data.get('rahu_kaal', '')
            if rahu_kaal and rahu_kaal != 'N/A':
                try:
                    rahu_start, rahu_end = rahu_kaal.split('-')
                    rahu_start_min = int(rahu_start.split(':')[0]) * 60 + int(rahu_start.split(':')[1])
                    rahu_end_min = int(rahu_end.split(':')[0]) * 60 + int(rahu_end.split(':')[1])
                    if not (end_minutes <= rahu_start_min or start_minutes >= rahu_end_min):
                        quality = 'poor'
                        description = 'Overlaps with Rahu Kaal - not auspicious'
                except:
                    pass  # Ignore parsing errors
            
            muhurats.append({
                'time': time_str,
                'start_time': f"{start_hour:02d}:{start_min:02d}",
                'end_time': f"{end_hour:02d}:{end_min:02d}",
                'quality': quality,
                'description': description,
                'part': i + 1
            })
        
        return {
            'date': date_str,
            'event_type': event_type,
            'panchang': panchang_data,
            'muhurats': muhurats,
            'best_times': [m for m in muhurats if m['quality'] == 'excellent'],
            'summary': {
                'total_muhurats': len(muhurats),
                'excellent': len([m for m in muhurats if m['quality'] == 'excellent']),
                'good': len([m for m in muhurats if m['quality'] == 'good']),
                'moderate': len([m for m in muhurats if m['quality'] == 'moderate']),
                'poor': len([m for m in muhurats if m['quality'] == 'poor'])
            }
        }
    except Exception as e:
        import traceback
        return {'error': str(e), 'traceback': traceback.format_exc()}

def compute_compatibility(person1_data, person2_data):
    """Compute Ashtakoota compatibility between two persons"""
    try:
        # Parse person data
        p1_date = person1_data.get('date')
        p1_time = person1_data.get('time', '12:00:00')
        p1_lat = person1_data.get('latitude', 28.6139)
        p1_lon = person1_data.get('longitude', 77.2090)
        
        p2_date = person2_data.get('date')
        p2_time = person2_data.get('time', '12:00:00')
        p2_lat = person2_data.get('latitude', 28.6139)
        p2_lon = person2_data.get('longitude', 77.2090)
        
        # Calculate charts for both persons
        chart1 = compute_birth_chart(p1_date, p1_time, p1_lat, p1_lon, 'Asia/Kolkata')
        chart2 = compute_birth_chart(p2_date, p2_time, p2_lat, p2_lon, 'Asia/Kolkata')
        
        if 'error' in chart1 or 'error' in chart2:
            return {'error': 'Failed to compute charts'}
        
        # Get Moon signs and nakshatras
        moon1 = chart1['planets']['Moon']
        moon2 = chart2['planets']['Moon']
        
        # Ashtakoota (8 Koota) matching
        # 1. Varna (1 point)
        varna_points = 1 if abs(moon1['sign_index'] - moon2['sign_index']) % 4 in [0, 1] else 0
        
        # 2. Vashya (2 points)
        vashya_points = 2 if abs(moon1['sign_index'] - moon2['sign_index']) % 6 in [0, 1, 5] else 0
        
        # 3. Tara (3 points)
        tara_diff = abs(NAKSHATRA_NAMES.index(moon1['nakshatra']) - NAKSHATRA_NAMES.index(moon2['nakshatra'])) % 9
        tara_points = 3 if tara_diff in [0, 2, 4, 6, 8] else 1.5
        
        # 4. Yoni (4 points)
        yoni_points = 4 if (moon1['sign_index'] + moon2['sign_index']) % 2 == 0 else 2
        
        # 5. Graha Maitri (5 points)
        maitri_points = 5 if abs(moon1['sign_index'] - moon2['sign_index']) % 3 == 0 else 2.5
        
        # 6. Gana (6 points)
        gana_points = 6 if abs(NAKSHATRA_NAMES.index(moon1['nakshatra']) - NAKSHATRA_NAMES.index(moon2['nakshatra'])) % 9 < 3 else 3
        
        # 7. Bhakoot (7 points)
        bhakoot_diff = abs(moon1['sign_index'] - moon2['sign_index'])
        bhakoot_points = 7 if bhakoot_diff in [0, 1, 3, 4, 5, 7, 9, 11] else 0
        
        # 8. Nadi (8 points)
        nadi1 = NAKSHATRA_NAMES.index(moon1['nakshatra']) % 3
        nadi2 = NAKSHATRA_NAMES.index(moon2['nakshatra']) % 3
        nadi_points = 8 if nadi1 != nadi2 else 0
        
        total_points = (varna_points + vashya_points + tara_points + yoni_points + 
                       maitri_points + gana_points + bhakoot_points + nadi_points)
        
        # Check for Mangal Dosha
        mars1_house = chart1['planets']['Mars']['house']
        mars2_house = chart2['planets']['Mars']['house']
        mangal_dosha_houses = [1, 2, 4, 7, 8, 12]
        
        person1_mangal = mars1_house in mangal_dosha_houses
        person2_mangal = mars2_house in mangal_dosha_houses
        
        return {
            'total_points': round(total_points, 1),
            'max_points': 36,
            'percentage': round((total_points / 36) * 100, 1),
            'compatibility_level': 'Excellent' if total_points >= 28 else 'Good' if total_points >= 20 else 'Average' if total_points >= 14 else 'Below Average',
            'details': {
                'Varna': {'points': varna_points, 'max': 1},
                'Vashya': {'points': vashya_points, 'max': 2},
                'Tara': {'points': tara_points, 'max': 3},
                'Yoni': {'points': yoni_points, 'max': 4},
                'Graha Maitri': {'points': maitri_points, 'max': 5},
                'Gana': {'points': gana_points, 'max': 6},
                'Bhakoot': {'points': bhakoot_points, 'max': 7},
                'Nadi': {'points': nadi_points, 'max': 8},
            },
            'mangal_dosha': {
                'person1': person1_mangal,
                'person2': person2_mangal,
                'compatible': person1_mangal == person2_mangal,
            },
            'person1_moon': {
                'sign': moon1['sign'],
                'nakshatra': moon1['nakshatra'],
            },
            'person2_moon': {
                'sign': moon2['sign'],
                'nakshatra': moon2['nakshatra'],
            },
        }
    except Exception as e:
        return {'error': str(e)}

def main():
    parser = argparse.ArgumentParser(description='Compute astrological charts (North Indian System) and Numerology')
    parser.add_argument('--type', required=True, choices=['birth-chart', 'dasha', 'divisional', 'panchang', 'compatibility', 'numerology', 'muhurat'])
    parser.add_argument('--date', required=False)
    parser.add_argument('--time', required=False)
    parser.add_argument('--latitude', type=float, required=False)
    parser.add_argument('--longitude', type=float, required=False)
    parser.add_argument('--timezone', default='Asia/Kolkata')
    parser.add_argument('--chart-type', default='D9')
    parser.add_argument('--person1', required=False)
    parser.add_argument('--person2', required=False)
    parser.add_argument('--event-type', default='general', help='Event type for muhurat: general, marriage, business, travel, house_warming')
    # Numerology arguments
    parser.add_argument('--name', required=False)
    parser.add_argument('--numerology-action', choices=['analyze', 'compatibility', 'suggest', 'calculate-name-number', 'loshu-grid', 'suggest-by-number'], default='analyze')
    parser.add_argument('--number1', type=int, required=False)
    parser.add_argument('--number2', type=int, required=False)
    parser.add_argument('--target-number', type=int, required=False)
    parser.add_argument('--name-length', type=int, required=False)
    parser.add_argument('--language', default='en', help='Language code: en, hi, fr, etc.')
    parser.add_argument('--religion', required=False, help='Religion: hindu, christian, muslim, jewish, sikh, etc.')
    parser.add_argument('--gender', required=False, help='Gender: male, female, or None for both')
    parser.add_argument('--exclude-names', required=False, help='JSON array of names to exclude')
    parser.add_argument('--system', choices=['pythagorean', 'chaldean'], default='pythagorean')
    
    args = parser.parse_args()
    
    try:
        if args.type == 'birth-chart':
            if not all([args.date, args.time, args.latitude is not None, args.longitude is not None]):
                result = {'error': 'Missing required fields: date, time, latitude, longitude'}
            else:
                result = compute_birth_chart(
                    args.date, args.time, args.latitude, args.longitude, args.timezone
                )
        elif args.type == 'dasha':
            if not all([args.date, args.time, args.latitude is not None, args.longitude is not None]):
                result = {'error': 'Missing required fields for dasha'}
            else:
                result = compute_dasha(
                    args.date, args.time, args.latitude, args.longitude, args.timezone
                )
        elif args.type == 'divisional':
            if not all([args.date, args.time, args.latitude is not None, args.longitude is not None]):
                result = {'error': 'Missing required fields for divisional'}
            else:
                result = compute_divisional_chart(
                    args.date, args.time, args.latitude, args.longitude, args.chart_type, args.timezone
                )
        elif args.type == 'panchang':
            if not args.date:
                result = {'error': 'Date is required for panchang'}
            else:
                result = compute_panchang(
                    args.date,
                    args.latitude if args.latitude is not None else 28.6139,
                    args.longitude if args.longitude is not None else 77.2090,
                    args.timezone
                )
        elif args.type == 'muhurat':
            if not args.date:
                result = {'error': 'Date is required for muhurat'}
            else:
                result = compute_muhurat(
                    args.date,
                    args.latitude if args.latitude is not None else 28.6139,
                    args.longitude if args.longitude is not None else 77.2090,
                    args.timezone,
                    args.event_type
                )
        elif args.type == 'compatibility':
            if not args.person1 or not args.person2:
                result = {'error': 'Both person1 and person2 are required'}
            else:
                person1 = json.loads(args.person1)
                person2 = json.loads(args.person2)
                result = compute_compatibility(person1, person2)
        elif args.type == 'numerology':
            # Import numerology module
            import numerology as num
            
            if args.numerology_action == 'analyze':
                if not args.name:
                    result = {'error': 'Name is required for analysis'}
                else:
                    result = num.analyze_name(args.name, args.date, args.system)
            elif args.numerology_action == 'compatibility':
                if args.number1 is None or args.number2 is None:
                    result = {'error': 'Both number1 and number2 are required for compatibility'}
                else:
                    result = num.calculate_compatibility(args.number1, args.number2)
            elif args.numerology_action == 'suggest':
                if not args.name or args.target_number is None:
                    result = {'error': 'Name and target-number are required for suggestions'}
                else:
                    result = {
                        'base_name': args.name,
                        'target_number': args.target_number,
                        'suggestions': num.suggest_name_spellings(args.name, args.target_number, args.system)
                    }
            elif args.numerology_action == 'calculate-name-number':
                if not args.name:
                    result = {'error': 'Name is required'}
                else:
                    name_result = num.calculate_name_number(args.name, args.system)
                    result = {
                        'name': args.name,
                        'system': args.system,
                        'number': name_result['reduced'],
                        'total': name_result['total'],
                        'breakdown': name_result['breakdown'],
                        'meaning': num.NUMBER_MEANINGS.get(name_result['reduced'], {})
                    }
            elif args.numerology_action == 'loshu-grid':
                if not args.date:
                    result = {'error': 'Date is required for Loshu grid'}
                else:
                    result = num.calculate_loshu_grid(args.date)
            elif args.numerology_action == 'suggest-by-number':
                if args.target_number is None:
                    result = {'error': 'Target number is required'}
                else:
                    exclude_names = None
                    if hasattr(args, 'exclude_names') and args.exclude_names:
                        try:
                            exclude_names = json.loads(args.exclude_names) if isinstance(args.exclude_names, str) else args.exclude_names
                        except:
                            exclude_names = None
                    
                    result = {
                        'target_number': args.target_number,
                        'system': args.system,
                        'language': args.language,
                        'religion': args.religion,
                        'gender': args.gender if hasattr(args, 'gender') else None,
                        'suggestions': num.suggest_names_by_number(
                            args.target_number, 
                            args.system, 
                            name_length=args.name_length,
                            language=args.language,
                            religion=args.religion,
                            gender=args.gender if hasattr(args, 'gender') else None,
                            exclude_names=exclude_names
                        )
                    }
        else:
            result = {'error': 'Invalid type'}
        
        # Output as JSON
        print(json.dumps(result, indent=2))
    except Exception as e:
        print(json.dumps({'error': str(e)}))

if __name__ == '__main__':
    main()
