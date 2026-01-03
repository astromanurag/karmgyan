#!/usr/bin/env python3
"""
AI-Powered Astrological Predictions Service
Uses OpenAI GPT-4 or Anthropic Claude for chart interpretation
"""

import os
import json
from datetime import datetime
from typing import Optional, List, Dict, Any

# Try to import AI libraries (they may not be installed)
try:
    import openai
    OPENAI_AVAILABLE = True
except ImportError:
    OPENAI_AVAILABLE = False

try:
    import anthropic
    ANTHROPIC_AVAILABLE = True
except ImportError:
    ANTHROPIC_AVAILABLE = False


class AIAstrologyService:
    """AI-powered astrological predictions service"""
    
    def __init__(self, provider: str = 'openai'):
        """
        Initialize AI service with specified provider
        
        Args:
            provider: 'openai' or 'anthropic'
        """
        self.provider = provider
        self.client = None
        
        if provider == 'openai' and OPENAI_AVAILABLE:
            api_key = os.getenv('OPENAI_API_KEY')
            if api_key:
                self.client = openai.OpenAI(api_key=api_key)
        elif provider == 'anthropic' and ANTHROPIC_AVAILABLE:
            api_key = os.getenv('ANTHROPIC_API_KEY')
            if api_key:
                self.client = anthropic.Anthropic(api_key=api_key)
    
    def is_available(self) -> bool:
        """Check if AI service is available"""
        return self.client is not None
    
    def get_system_prompt(self) -> str:
        """Create expert Vedic astrologer system prompt"""
        return """You are an expert Vedic astrologer with 25+ years of experience in chart analysis and predictions.

Your expertise includes:
- Traditional Vedic astrology principles (Parashara, Jaimini systems)
- Planetary positions, strengths, and dignities
- House analysis and lord placements
- Dasha (planetary period) interpretations
- Nakshatra (lunar mansion) analysis
- Yoga (special combinations) identification
- Transit predictions
- Remedial measures and upayas

When providing predictions:
1. Always reference specific chart factors (planets, houses, dashas) to support your analysis
2. Give time frames when possible (based on dasha periods and transits)
3. Be balanced - mention both positive aspects and challenges
4. Provide practical remedies when appropriate
5. Use encouraging and constructive language
6. Be specific to the querent's chart, not generic
7. Consider the current dasha period for timing predictions

Response Format:
- Start with a direct answer to the question
- Explain the astrological reasoning
- Mention relevant time periods
- Conclude with practical advice or remedies if applicable

Remember: You are a wise counselor providing guidance, not just predictions. Help the querent understand their chart and make informed decisions."""

    def prepare_chart_context(self, chart_data: Dict[str, Any]) -> str:
        """
        Convert chart data to a detailed natural language context
        
        Args:
            chart_data: Dictionary containing birth chart information
        
        Returns:
            Formatted string with chart details
        """
        context = []
        
        # Basic info
        if chart_data.get('name'):
            context.append(f"Native's Name: {chart_data['name']}")
        
        context.append(f"Birth Date: {chart_data.get('date', 'Unknown')}")
        context.append(f"Birth Time: {chart_data.get('time', 'Unknown')}")
        context.append(f"Birth Place: {chart_data.get('place', 'Unknown')}")
        context.append("")
        
        # Ascendant
        context.append("=== ASCENDANT (LAGNA) ===")
        asc = chart_data.get('ascendant', {})
        if isinstance(asc, dict):
            context.append(f"Ascendant Sign: {asc.get('sign', 'Unknown')}")
            context.append(f"Ascendant Degree: {asc.get('degree', 0):.2f}°")
            if asc.get('nakshatra'):
                context.append(f"Ascendant Nakshatra: {asc.get('nakshatra')}")
        elif isinstance(asc, str):
            context.append(f"Ascendant Sign: {asc}")
        context.append("")
        
        # Planets
        context.append("=== PLANETARY POSITIONS ===")
        planets = chart_data.get('planets', {})
        
        if isinstance(planets, dict):
            for planet, data in planets.items():
                if isinstance(data, dict):
                    line = f"{planet}: {data.get('sign', '?')} "
                    line += f"(House {data.get('house', '?')}), "
                    line += f"{data.get('degree', 0):.2f}°"
                    if data.get('nakshatra'):
                        line += f", Nakshatra: {data.get('nakshatra')}"
                    if data.get('is_retrograde'):
                        line += " [R - Retrograde]"
                    context.append(line)
        elif isinstance(planets, list):
            for p in planets:
                if isinstance(p, dict):
                    line = f"{p.get('name', '?')}: {p.get('sign', '?')} "
                    line += f"(House {p.get('house', '?')}), "
                    line += f"{p.get('longitude', 0):.2f}°"
                    context.append(line)
        context.append("")
        
        # Houses
        context.append("=== HOUSE CUSPS ===")
        houses = chart_data.get('houses', {})
        if isinstance(houses, dict):
            for house, data in houses.items():
                if isinstance(data, dict):
                    planets_in_house = data.get('planets', [])
                    planets_str = ', '.join(planets_in_house) if planets_in_house else 'Empty'
                    context.append(f"House {house}: {data.get('sign', '?')} - Planets: {planets_str}")
        elif isinstance(houses, list):
            for i, h in enumerate(houses, 1):
                if isinstance(h, dict):
                    context.append(f"House {i}: {h.get('sign', '?')}")
        context.append("")
        
        # Current Dasha
        context.append("=== CURRENT DASHA PERIOD ===")
        dasha = chart_data.get('current_dasha', chart_data.get('dasha', {}))
        if dasha:
            if isinstance(dasha, dict):
                context.append(f"Mahadasha: {dasha.get('mahadasha', 'Unknown')}")
                context.append(f"Antardasha: {dasha.get('antardasha', 'Unknown')}")
                if dasha.get('pratyantar'):
                    context.append(f"Pratyantardasha: {dasha.get('pratyantar')}")
                if dasha.get('start_date'):
                    context.append(f"Period: {dasha.get('start_date')} to {dasha.get('end_date', 'ongoing')}")
        context.append("")
        
        # Yogas
        yogas = chart_data.get('yogas', [])
        if yogas:
            context.append("=== SPECIAL YOGAS ===")
            for yoga in yogas:
                if isinstance(yoga, str):
                    context.append(f"- {yoga}")
                elif isinstance(yoga, dict):
                    context.append(f"- {yoga.get('name', 'Unknown')}: {yoga.get('description', '')}")
        
        # Additional info
        if chart_data.get('moon_sign'):
            context.append(f"\nMoon Sign (Rashi): {chart_data['moon_sign']}")
        if chart_data.get('sun_sign'):
            context.append(f"Sun Sign: {chart_data['sun_sign']}")
        if chart_data.get('nakshatra'):
            context.append(f"Birth Nakshatra: {chart_data['nakshatra']}")
        
        return "\n".join(context)
    
    def ask_question(
        self,
        chart_data: Dict[str, Any],
        question: str,
        conversation_history: Optional[List[Dict]] = None
    ) -> Dict[str, Any]:
        """
        Ask a question about the birth chart
        
        Args:
            chart_data: Birth chart data
            question: User's question
            conversation_history: Previous messages in conversation
        
        Returns:
            Dictionary with answer, usage stats, and metadata
        """
        if not self.is_available():
            return self._get_mock_response(chart_data, question)
        
        # Prepare context
        chart_context = self.prepare_chart_context(chart_data)
        system_prompt = self.get_system_prompt()
        
        # Build messages
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "system", "content": f"Birth Chart Data:\n{chart_context}"},
        ]
        
        # Add conversation history
        if conversation_history:
            messages.extend(conversation_history)
        
        # Add current question
        messages.append({"role": "user", "content": question})
        
        try:
            if self.provider == 'openai':
                return self._call_openai(messages)
            elif self.provider == 'anthropic':
                return self._call_anthropic(messages)
        except Exception as e:
            return {
                'success': False,
                'error': str(e),
                'answer': f"Sorry, I encountered an error: {str(e)}",
                'usage': {'total_tokens': 0, 'cost': 0}
            }
    
    def _call_openai(self, messages: List[Dict]) -> Dict[str, Any]:
        """Call OpenAI API"""
        response = self.client.chat.completions.create(
            model="gpt-4-turbo-preview",
            messages=messages,
            temperature=0.7,
            max_tokens=1500
        )
        
        answer = response.choices[0].message.content
        usage = response.usage
        
        # Calculate cost (GPT-4 Turbo pricing)
        input_cost = (usage.prompt_tokens / 1000) * 0.01
        output_cost = (usage.completion_tokens / 1000) * 0.03
        total_cost = input_cost + output_cost
        
        return {
            'success': True,
            'answer': answer,
            'usage': {
                'prompt_tokens': usage.prompt_tokens,
                'completion_tokens': usage.completion_tokens,
                'total_tokens': usage.total_tokens,
                'cost_usd': round(total_cost, 4)
            },
            'model': 'gpt-4-turbo-preview',
            'timestamp': datetime.now().isoformat()
        }
    
    def _call_anthropic(self, messages: List[Dict]) -> Dict[str, Any]:
        """Call Anthropic Claude API"""
        # Extract system messages
        system_content = ""
        user_messages = []
        
        for msg in messages:
            if msg['role'] == 'system':
                system_content += msg['content'] + "\n\n"
            else:
                user_messages.append(msg)
        
        response = self.client.messages.create(
            model="claude-3-opus-20240229",
            max_tokens=1500,
            system=system_content,
            messages=user_messages
        )
        
        answer = response.content[0].text
        usage = response.usage
        
        # Calculate cost (Claude Opus pricing)
        input_cost = (usage.input_tokens / 1000) * 0.015
        output_cost = (usage.output_tokens / 1000) * 0.075
        total_cost = input_cost + output_cost
        
        return {
            'success': True,
            'answer': answer,
            'usage': {
                'input_tokens': usage.input_tokens,
                'output_tokens': usage.output_tokens,
                'total_tokens': usage.input_tokens + usage.output_tokens,
                'cost_usd': round(total_cost, 4)
            },
            'model': 'claude-3-opus-20240229',
            'timestamp': datetime.now().isoformat()
        }
    
    def _get_mock_response(self, chart_data: Dict, question: str) -> Dict[str, Any]:
        """Generate mock response when AI is not available"""
        
        # Extract some chart info for personalized mock response
        asc = chart_data.get('ascendant', {})
        asc_sign = asc.get('sign', asc) if isinstance(asc, dict) else asc
        
        dasha = chart_data.get('current_dasha', chart_data.get('dasha', {}))
        mahadasha = dasha.get('mahadasha', 'Unknown') if isinstance(dasha, dict) else 'Unknown'
        
        # Generate contextual mock response
        question_lower = question.lower()
        
        if 'marriage' in question_lower or 'relationship' in question_lower:
            answer = f"""Based on your {asc_sign} ascendant chart analysis:

**Marriage Prospects:**
Your 7th house and Venus placement suggest good marriage prospects. The current {mahadasha} dasha period indicates relationship developments between 2025-2027.

**Key Indicators:**
- 7th lord placement is favorable for committed relationships
- Venus aspects indicate attraction and harmony in partnerships
- Jupiter's transit through your 7th house in late 2025 is particularly auspicious

**Recommended Period:** October 2025 - March 2026 appears most favorable for marriage-related events.

**Remedies:**
1. Wear a diamond or white sapphire on Friday
2. Offer white flowers to Goddess Lakshmi on Fridays
3. Chant "Om Shukraya Namaha" 108 times daily

*Note: This is a sample prediction. For personalized AI predictions, please configure your OpenAI API key.*"""
        
        elif 'career' in question_lower or 'job' in question_lower or 'business' in question_lower:
            answer = f"""Based on your {asc_sign} ascendant chart analysis:

**Career Prospects:**
Your 10th house and Saturn placement indicate a strong professional foundation. The current {mahadasha} dasha brings opportunities for career advancement.

**Suitable Fields:**
- Management and leadership roles
- Technology and analytical work
- Finance and business consulting
- Creative industries (if Venus is well-placed)

**Career Growth Periods:**
- 2025: Good for job changes or promotions
- 2026: Favorable for starting own venture
- 2027: Recognition and rewards period

**Advice:**
1. Focus on skill development during current period
2. Network actively, especially during Jupiter transits
3. Consider multiple income streams

*Note: This is a sample prediction. For personalized AI predictions, please configure your OpenAI API key.*"""
        
        elif 'money' in question_lower or 'finance' in question_lower or 'wealth' in question_lower:
            answer = f"""Based on your {asc_sign} ascendant chart analysis:

**Financial Outlook:**
Your 2nd and 11th house placements indicate potential for wealth accumulation. The {mahadasha} dasha period brings financial opportunities.

**Wealth Indicators:**
- 2nd house lord suggests steady income growth
- 11th house aspects indicate gains from multiple sources
- Jupiter's influence promises expansion in finances

**Best Periods for Financial Growth:**
- 2025 Q2-Q3: Investment opportunities
- 2026: Property-related gains possible
- 2027: Significant income increase

**Financial Advice:**
1. Save at least 20% of income during favorable periods
2. Avoid speculation during Rahu-Ketu transit periods
3. Invest in real estate during Jupiter dasha

*Note: This is a sample prediction. For personalized AI predictions, please configure your OpenAI API key.*"""
        
        elif 'health' in question_lower:
            answer = f"""Based on your {asc_sign} ascendant chart analysis:

**Health Overview:**
Your 6th house and Mars placement indicate overall vitality. Some attention needed during specific planetary periods.

**Areas to Focus:**
- Digestive system (common for {asc_sign} ascendants)
- Stress management during Saturn transits
- Physical exercise for maintaining energy

**Preventive Measures:**
1. Regular exercise, especially yoga
2. Balanced diet with seasonal foods
3. Meditation for mental wellness

**Favorable Periods for Health:**
- Jupiter transit: General improvement
- Venus dasha: Good vitality

*Note: This is a sample prediction. For personalized AI predictions, please configure your OpenAI API key.*"""
        
        else:
            answer = f"""Based on your {asc_sign} ascendant birth chart:

**General Analysis:**
Your chart shows a unique combination of planetary energies. The current {mahadasha} Mahadasha period is significant for your life journey.

**Key Points:**
1. Your ascendant ({asc_sign}) gives you natural qualities of leadership and determination
2. Current planetary period favors personal growth and development
3. Upcoming transits bring opportunities for positive changes

**Recommendations:**
- Trust your intuition during this period
- Focus on long-term goals rather than short-term gains
- Practice patience, especially during challenging transits

**Timing:**
The next 12-18 months are particularly important for setting the foundation for future success.

*Note: This is a sample prediction. For personalized AI predictions, please configure your OpenAI API key. Set OPENAI_API_KEY environment variable.*"""
        
        return {
            'success': True,
            'answer': answer,
            'usage': {
                'prompt_tokens': 0,
                'completion_tokens': 0,
                'total_tokens': 0,
                'cost_usd': 0
            },
            'model': 'mock',
            'is_mock': True,
            'timestamp': datetime.now().isoformat()
        }
    
    def generate_report(
        self,
        chart_data: Dict[str, Any],
        report_type: str = 'comprehensive'
    ) -> Dict[str, Any]:
        """
        Generate a detailed astrological report
        
        Args:
            chart_data: Birth chart data
            report_type: Type of report to generate
        
        Returns:
            Dictionary with report content and metadata
        """
        report_prompts = {
            'comprehensive': """Generate a comprehensive life reading report for this native covering ALL of the following sections in detail:

1. **PERSONALITY PROFILE**
   - Core personality traits based on ascendant and Moon sign
   - Strengths and natural talents
   - Areas for growth and development

2. **CAREER & PROFESSION**
   - Most suitable career paths
   - Business vs Service suitability
   - Career growth timeline
   - Challenges and how to overcome them

3. **RELATIONSHIPS & MARRIAGE**
   - Marriage prospects and timing
   - Partner characteristics
   - Relationship dynamics
   - Children and family life

4. **FINANCES & WEALTH**
   - Wealth accumulation potential
   - Income sources
   - Best investment periods
   - Financial challenges to watch

5. **HEALTH & WELLBEING**
   - Health strengths and vulnerabilities
   - Periods requiring extra care
   - Preventive recommendations

6. **CURRENT PERIOD ANALYSIS**
   - Current dasha effects
   - What to expect in next 2-3 years
   - Key dates and events

7. **REMEDIES & RECOMMENDATIONS**
   - Gemstones
   - Mantras
   - Favorable days and colors
   - General guidance

Make each section detailed with specific references to planetary positions.""",

            'career': """Generate a detailed CAREER GUIDANCE report covering:

1. **Natural Talents & Abilities**
   - Strengths indicated by planetary positions
   - Skills to develop

2. **Suitable Career Paths**
   - Top 5 recommended careers with reasoning
   - Industries to focus on

3. **Business vs Employment**
   - Which is more favorable and why
   - If business, what type

4. **Career Timeline**
   - Best periods for job changes
   - Promotion windows
   - Challenging periods

5. **Professional Relationships**
   - Working with authority
   - Team dynamics

6. **Financial Growth Through Career**
   - Income growth potential
   - Multiple income streams

7. **Actionable Recommendations**
   - Immediate steps
   - Long-term planning""",

            'marriage': """Generate a detailed MARRIAGE & RELATIONSHIP report covering:

1. **Marriage Timing**
   - Most favorable periods
   - Specific year/month predictions

2. **Partner Profile**
   - Expected characteristics
   - Profession and background
   - Compatibility factors

3. **Relationship Dynamics**
   - Harmony areas
   - Potential challenges
   - Communication patterns

4. **After Marriage Life**
   - Domestic happiness
   - In-law relationships
   - Adjustments needed

5. **Children & Family**
   - Children timing
   - Number of children indicated
   - Parent-child relationships

6. **Remedies for Happy Marriage**
   - Pre-marriage preparations
   - Post-marriage harmony tips
   - Specific remedies if delays indicated""",

            'yearly': """Generate a detailed YEARLY FORECAST for the next 12 months covering:

**Monthly Breakdown:**
For each month, provide:
- General theme
- Career prospects
- Relationship updates
- Financial outlook
- Health considerations
- Key dates

**Overall Year Theme:**
- Major transits affecting the native
- Best months for major decisions
- Challenging periods and how to handle

**Specific Predictions:**
- Career milestones expected
- Relationship developments
- Financial changes
- Health advice

**Month-by-Month Summary Table**"""
        }
        
        prompt = report_prompts.get(report_type, report_prompts['comprehensive'])
        return self.ask_question(chart_data, prompt)


def process_ai_request(action: str, chart_data: Dict, **kwargs) -> Dict:
    """
    Process AI request from backend
    
    Args:
        action: 'ask' or 'report'
        chart_data: Birth chart data
        **kwargs: Additional arguments (question, report_type, etc.)
    
    Returns:
        AI response dictionary
    """
    # Determine provider from environment
    provider = os.getenv('AI_PROVIDER', 'openai')
    service = AIAstrologyService(provider=provider)
    
    if action == 'ask':
        question = kwargs.get('question', '')
        history = kwargs.get('conversation_history', [])
        return service.ask_question(chart_data, question, history)
    
    elif action == 'report':
        report_type = kwargs.get('report_type', 'comprehensive')
        return service.generate_report(chart_data, report_type)
    
    else:
        return {'error': f'Unknown action: {action}'}


# CLI interface
if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser(description='AI Astrology Service')
    parser.add_argument('--action', required=True, choices=['ask', 'report'])
    parser.add_argument('--chart-data', required=True, help='JSON string of chart data')
    parser.add_argument('--question', help='Question to ask')
    parser.add_argument('--report-type', default='comprehensive')
    parser.add_argument('--history', help='JSON string of conversation history')
    
    args = parser.parse_args()
    
    try:
        chart_data = json.loads(args.chart_data)
        history = json.loads(args.history) if args.history else None
        
        result = process_ai_request(
            action=args.action,
            chart_data=chart_data,
            question=args.question,
            report_type=args.report_type,
            conversation_history=history
        )
        
        print(json.dumps(result, indent=2))
        
    except Exception as e:
        print(json.dumps({'error': str(e)}))

