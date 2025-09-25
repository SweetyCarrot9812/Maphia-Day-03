"""
Batch AI Question Generation Service for Hanoa Hub
Handles batch generation with proper model routing and validation
"""

import os
import json
import asyncio
from typing import List, Dict, Any, Optional
from datetime import datetime
import openai
import google.generativeai as genai
from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, firestore
from question_types import (
    QuestionType, QuestionGenerator, QuestionFormat,
    GENERATION_PROMPTS, get_generation_prompt
)

# Load environment variables
load_dotenv()

# Configure AI APIs
openai.api_key = os.getenv('OPENAI_API_KEY')
genai.configure(api_key=os.getenv('GEMINI_API_KEY'))

# Initialize Firebase
if not firebase_admin._apps:
    cred = credentials.Certificate('path/to/serviceAccountKey.json')
    firebase_admin.initialize_app(cred)

db = firestore.client()

class BatchQuestionGenerator:
    """Service for batch generating questions with AI"""

    def __init__(self):
        self.openai_client = openai.OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
        self.gemini_model = genai.GenerativeModel('gemini-2.0-flash-exp')
        self.generation_stats = {
            'total_requested': 0,
            'total_generated': 0,
            'failed': 0,
            'models_used': {}
        }

    async def generate_batch(
        self,
        count: int,
        subject: str,
        topics: List[str],
        question_types: List[QuestionType],
        difficulty: str = "medium",
        save_to_firebase: bool = True
    ) -> Dict[str, Any]:
        """
        Generate a batch of questions with specified parameters

        Args:
            count: Number of questions to generate
            subject: Subject area (nursing, medical, etc.)
            topics: List of topics to cover
            question_types: Types of questions to generate
            difficulty: Difficulty level (easy, medium, hard)
            save_to_firebase: Whether to save to Firebase

        Returns:
            Dictionary with generated questions and statistics
        """
        self.generation_stats = {
            'total_requested': count,
            'total_generated': 0,
            'failed': 0,
            'models_used': {},
            'start_time': datetime.now().isoformat()
        }

        generated_questions = []

        # Distribute questions across types and topics
        questions_per_type = count // len(question_types) or 1
        questions_per_topic = count // len(topics) or 1

        for q_type in question_types:
            for topic in topics:
                num_questions = min(questions_per_type, questions_per_topic)

                # Generate questions for this type/topic combination
                for _ in range(num_questions):
                    if len(generated_questions) >= count:
                        break

                    try:
                        question = await self._generate_single_question(
                            question_type=q_type,
                            subject=subject,
                            topic=topic,
                            difficulty=difficulty
                        )

                        if question and QuestionGenerator.validate_question(question):
                            generated_questions.append(question)
                            self.generation_stats['total_generated'] += 1

                            if save_to_firebase:
                                await self._save_to_firebase(question)
                        else:
                            self.generation_stats['failed'] += 1

                    except Exception as e:
                        print(f"Error generating question: {e}")
                        self.generation_stats['failed'] += 1

                if len(generated_questions) >= count:
                    break

        self.generation_stats['end_time'] = datetime.now().isoformat()

        return {
            'questions': generated_questions,
            'stats': self.generation_stats,
            'success': len(generated_questions) > 0
        }

    async def _generate_single_question(
        self,
        question_type: QuestionType,
        subject: str,
        topic: str,
        difficulty: str
    ) -> Optional[Dict[str, Any]]:
        """Generate a single question using appropriate AI model"""

        # Determine which model to use
        model = QuestionGenerator.get_ai_model(question_type, difficulty)

        # Track model usage
        self.generation_stats['models_used'][model] = \
            self.generation_stats['models_used'].get(model, 0) + 1

        # Get generation prompt
        prompt = get_generation_prompt(
            question_type,
            difficulty=difficulty,
            subject=subject,
            topic=topic
        )

        try:
            if model == "gemini-2.5-flash":
                # Use Gemini for image-based questions
                return await self._generate_with_gemini(prompt, question_type)
            elif model == "gpt-5":
                # Use GPT-5 for complex questions
                return await self._generate_with_gpt5(prompt, question_type)
            else:
                # Default to GPT-5-mini
                return await self._generate_with_gpt5_mini(prompt, question_type)
        except Exception as e:
            print(f"Model {model} failed: {e}")
            return None

    async def _generate_with_gpt5_mini(
        self,
        prompt: str,
        question_type: QuestionType
    ) -> Dict[str, Any]:
        """Generate question using GPT-5-mini"""

        response = self.openai_client.chat.completions.create(
            model="gpt-5-mini",  # Using actual GPT-5 mini
            messages=[
                {"role": "system", "content": "You are a medical education expert creating examination questions. Always return valid JSON."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,
            max_tokens=1000,
            response_format={"type": "json_object"}
        )

        question_data = json.loads(response.choices[0].message.content)
        question_data['type'] = question_type.value
        question_data['generated_by'] = 'gpt-5-mini'
        question_data['timestamp'] = datetime.now().isoformat()

        return self._format_question(question_data, question_type)

    async def _generate_with_gpt5(
        self,
        prompt: str,
        question_type: QuestionType
    ) -> Dict[str, Any]:
        """Generate complex question using GPT-5"""

        response = self.openai_client.chat.completions.create(
            model="gpt-5",  # Using actual GPT-5
            messages=[
                {"role": "system", "content": "You are a senior medical education expert creating complex clinical examination questions. Ensure high clinical accuracy and reasoning. Always return valid JSON."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,
            max_tokens=1500,
            response_format={"type": "json_object"}
        )

        question_data = json.loads(response.choices[0].message.content)
        question_data['type'] = question_type.value
        question_data['generated_by'] = 'gpt-5'
        question_data['timestamp'] = datetime.now().isoformat()

        return self._format_question(question_data, question_type)

    async def _generate_with_gemini(
        self,
        prompt: str,
        question_type: QuestionType,
        image_data: Optional[bytes] = None
    ) -> Dict[str, Any]:
        """Generate image-based question using Gemini 2.5 Flash"""

        generation_config = {
            "temperature": 0.7,
            "top_p": 0.95,
            "top_k": 40,
            "max_output_tokens": 1500,
            "response_mime_type": "application/json"
        }

        # Add system instruction for JSON output
        full_prompt = f"""You are a medical education expert analyzing medical images.
Create a question based on the image provided.
{prompt}

IMPORTANT: Return only valid JSON with these fields:
- image_description: Description of what's shown in the image
- question_text: The question about the image
- choices: Array of exactly 5 answer choices
- correct_answer: Index (1-5) of the correct choice
- explanation: Medical explanation for the answer"""

        if image_data:
            # If image data is provided, include it in the generation
            response = self.gemini_model.generate_content([full_prompt, image_data])
        else:
            response = self.gemini_model.generate_content(full_prompt)

        # Parse the response
        try:
            question_data = json.loads(response.text)
        except json.JSONDecodeError:
            # Try to extract JSON from the response
            import re
            json_match = re.search(r'\{.*\}', response.text, re.DOTALL)
            if json_match:
                question_data = json.loads(json_match.group())
            else:
                raise ValueError("Could not parse Gemini response as JSON")

        question_data['type'] = question_type.value
        question_data['generated_by'] = 'gemini-2.5-flash'
        question_data['timestamp'] = datetime.now().isoformat()

        return self._format_question(question_data, question_type)

    def _format_question(
        self,
        raw_data: Dict[str, Any],
        question_type: QuestionType
    ) -> Dict[str, Any]:
        """Format and validate generated question data"""

        formatted = {
            'type': question_type.value,
            'question_text': raw_data.get('question_text', ''),
            'choices': raw_data.get('choices', []),
            'correct_answer': raw_data.get('correct_answer', 0),
            'difficulty': raw_data.get('difficulty', 'medium'),
            'explanation': raw_data.get('explanation', ''),
            'generated_by': raw_data.get('generated_by', 'unknown'),
            'timestamp': raw_data.get('timestamp', datetime.now().isoformat()),
            'tags': raw_data.get('tags', [])
        }

        # Type-specific fields
        if question_type == QuestionType.CASE:
            formatted['case_scenario'] = raw_data.get('case_scenario', '')
        elif question_type == QuestionType.IMAGE:
            formatted['image_description'] = raw_data.get('image_description', '')
            formatted['image_url'] = raw_data.get('image_url', '')
        elif question_type == QuestionType.ORDERED:
            formatted['items_to_order'] = raw_data.get('items_to_order', [])
            formatted['correct_sequence'] = raw_data.get('correct_sequence', [])
        elif question_type == QuestionType.MATCHING:
            formatted['left_items'] = raw_data.get('left_items', [])
            formatted['right_items'] = raw_data.get('right_items', [])
            formatted['correct_pairs'] = raw_data.get('correct_pairs', {})

        # Ensure exactly 5 choices
        if len(formatted['choices']) != 5:
            # Pad or trim to exactly 5
            if len(formatted['choices']) < 5:
                while len(formatted['choices']) < 5:
                    formatted['choices'].append(f"Option {len(formatted['choices']) + 1}")
            else:
                formatted['choices'] = formatted['choices'][:5]

        # Ensure correct_answer is valid
        if not 1 <= formatted['correct_answer'] <= 5:
            formatted['correct_answer'] = 1

        return formatted

    async def _save_to_firebase(self, question: Dict[str, Any]) -> bool:
        """Save generated question to Firebase"""
        try:
            # Add to nursing_problems collection
            doc_ref = db.collection('nursing_problems').add({
                **question,
                'created_at': firestore.SERVER_TIMESTAMP,
                'created_by': 'ai_batch_generator',
                'source': 'hanoa_hub'
            })

            print(f"Saved question to Firebase: {doc_ref[1].id}")
            return True
        except Exception as e:
            print(f"Failed to save to Firebase: {e}")
            return False

    async def generate_from_image(
        self,
        image_path: str,
        subject: str,
        topic: str,
        difficulty: str = "medium"
    ) -> Optional[Dict[str, Any]]:
        """Generate question from a medical image"""

        # Read image file
        with open(image_path, 'rb') as f:
            image_data = f.read()

        prompt = get_generation_prompt(
            QuestionType.IMAGE,
            difficulty=difficulty,
            subject=subject,
            topic=topic,
            image_description="Medical image provided for analysis"
        )

        return await self._generate_with_gemini(
            prompt,
            QuestionType.IMAGE,
            image_data
        )

class BatchGeneratorAPI:
    """API endpoints for batch generation"""

    def __init__(self):
        self.generator = BatchQuestionGenerator()

    async def handle_batch_request(self, request_data: Dict) -> Dict:
        """Handle batch generation API request"""

        # Parse request
        count = request_data.get('count', 10)
        subject = request_data.get('subject', 'nursing')
        topics = request_data.get('topics', ['general'])
        question_types = [
            QuestionType(t) for t in request_data.get('types', ['MCQ'])
        ]
        difficulty = request_data.get('difficulty', 'medium')
        save_to_firebase = request_data.get('save', True)

        # Generate batch
        result = await self.generator.generate_batch(
            count=count,
            subject=subject,
            topics=topics,
            question_types=question_types,
            difficulty=difficulty,
            save_to_firebase=save_to_firebase
        )

        return {
            'status': 'success' if result['success'] else 'partial',
            'data': result
        }

    async def handle_image_generation(self, image_path: str, metadata: Dict) -> Dict:
        """Handle image-based question generation"""

        question = await self.generator.generate_from_image(
            image_path=image_path,
            subject=metadata.get('subject', 'medical'),
            topic=metadata.get('topic', 'radiology'),
            difficulty=metadata.get('difficulty', 'medium')
        )

        if question:
            return {
                'status': 'success',
                'question': question
            }
        else:
            return {
                'status': 'error',
                'message': 'Failed to generate question from image'
            }

# Example usage
async def main():
    """Example batch generation"""
    generator = BatchQuestionGenerator()

    # Generate a batch of mixed question types
    result = await generator.generate_batch(
        count=20,
        subject="nursing",
        topics=["pharmacology", "anatomy", "patient care"],
        question_types=[
            QuestionType.MCQ,
            QuestionType.CASE,
            QuestionType.ORDERED
        ],
        difficulty="medium",
        save_to_firebase=True
    )

    print(f"Generated {result['stats']['total_generated']} questions")
    print(f"Models used: {result['stats']['models_used']}")
    print(f"Failed: {result['stats']['failed']}")

if __name__ == "__main__":
    asyncio.run(main())