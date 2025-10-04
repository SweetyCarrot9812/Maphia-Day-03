"""
Question Types Definition for AI Question Generation
8 different question types with strict formatting requirements
"""

from typing import List, Dict, Any, Optional
from pydantic import BaseModel, Field, validator
from enum import Enum

class QuestionType(str, Enum):
    MCQ = "MCQ"  # Multiple Choice Question
    CASE = "Case"  # Case-based question
    IMAGE = "Image"  # Image-based question
    ORDERED = "Ordered"  # Ordering/sequence question
    MATCHING = "Matching"  # Matching pairs question
    BRANCHING = "Branching"  # Branching logic question
    DRAG_DROP = "DragDrop"  # Drag and drop question
    MULTI_STEP = "MultiStep"  # Multi-step problem solving

class QuestionFormat(BaseModel):
    """Base format for all question types"""
    type: QuestionType
    question_text: str = Field(..., description="Question text without explanations")
    choices: List[str] = Field(..., min_items=5, max_items=5, description="Exactly 5 choices")
    correct_answer: int = Field(..., ge=1, le=5, description="Index of correct answer (1-5)")
    difficulty: str = Field("medium", pattern="^(easy|medium|hard)$")
    tags: List[str] = Field(default_factory=list)
    subject: str = ""
    explanation: str = Field("", description="Explanation kept separate from question")

    @validator('choices')
    def validate_choices(cls, v):
        if len(v) != 5:
            raise ValueError("Must have exactly 5 choices")
        return v

    @validator('correct_answer')
    def validate_answer(cls, v):
        if not 1 <= v <= 5:
            raise ValueError("Correct answer must be index 1-5")
        return v

class MCQQuestion(QuestionFormat):
    """Standard multiple choice question"""
    type: QuestionType = QuestionType.MCQ

    def get_prompt_template(self) -> str:
        return """Create a multiple choice question with exactly 5 choices.
Question should be clear and direct without explanations.
Format:
- Question text (no explanations)
- 5 choices labeled 1-5
- Single correct answer
- Keep explanations separate"""

class CaseQuestion(QuestionFormat):
    """Case-based clinical scenario question"""
    type: QuestionType = QuestionType.CASE
    case_scenario: str = Field(..., description="Clinical case description")

    def get_prompt_template(self) -> str:
        return """Create a case-based clinical question.
Format:
- Present clinical scenario (patient history, symptoms, etc.)
- Ask specific question about diagnosis/treatment/management
- Provide exactly 5 choices
- Single correct answer based on clinical reasoning
- No explanations in question text"""

class ImageQuestion(QuestionFormat):
    """Image-based question (requires Gemini 2.5 Flash)"""
    type: QuestionType = QuestionType.IMAGE
    image_url: Optional[str] = None
    image_base64: Optional[str] = None
    image_description: str = Field(..., description="What the image shows")

    def get_prompt_template(self) -> str:
        return """Analyze the provided medical image and create a question.
Format:
- Reference specific features visible in the image
- Ask about diagnosis, anatomy, pathology, or clinical significance
- Provide exactly 5 choices
- Single correct answer based on image analysis
- Keep explanations separate"""

    @validator('image_url', 'image_base64')
    def validate_image(cls, v, values):
        if not values.get('image_url') and not values.get('image_base64'):
            raise ValueError("Either image_url or image_base64 must be provided")
        return v

class OrderedQuestion(QuestionFormat):
    """Ordering/sequence question"""
    type: QuestionType = QuestionType.ORDERED
    items_to_order: List[str] = Field(..., min_items=5, max_items=5)
    correct_sequence: List[int] = Field(..., min_items=5, max_items=5)

    def get_prompt_template(self) -> str:
        return """Create a sequencing/ordering question.
Format:
- Present items that need to be ordered (procedures, stages, priorities)
- Ask to arrange in correct sequence
- Provide exactly 5 items to order
- Correct answer is the proper sequence
- Medical procedures, treatment steps, or diagnostic workflow"""

class MatchingQuestion(QuestionFormat):
    """Matching pairs question"""
    type: QuestionType = QuestionType.MATCHING
    left_items: List[str] = Field(..., min_items=5, max_items=5)
    right_items: List[str] = Field(..., min_items=5, max_items=5)
    correct_pairs: Dict[int, int] = Field(...)

    def get_prompt_template(self) -> str:
        return """Create a matching question with two columns.
Format:
- Left column: 5 items (diseases, symptoms, drugs, etc.)
- Right column: 5 items to match (treatments, causes, mechanisms, etc.)
- Each left item matches exactly one right item
- Medical terminology and clinical relevance required"""

class BranchingQuestion(QuestionFormat):
    """Branching logic/decision tree question"""
    type: QuestionType = QuestionType.BRANCHING
    decision_points: List[Dict[str, Any]] = Field(...)

    def get_prompt_template(self) -> str:
        return """Create a clinical decision-making question with branching logic.
Format:
- Present initial scenario
- Based on answer, scenario evolves
- Each branch leads to different clinical consideration
- Final question based on decision path
- Exactly 5 final choices"""

class DragDropQuestion(QuestionFormat):
    """Drag and drop interactive question"""
    type: QuestionType = QuestionType.DRAG_DROP
    drop_zones: List[str] = Field(..., min_items=5, max_items=5)
    draggable_items: List[str] = Field(..., min_items=5, max_items=5)
    correct_placement: Dict[str, str] = Field(...)

    def get_prompt_template(self) -> str:
        return """Create a drag-and-drop categorization question.
Format:
- Define 5 categories or zones (anatomical regions, disease types, etc.)
- Provide 5 items to be placed
- Each item belongs to exactly one category
- Medical/clinical context required"""

class MultiStepQuestion(QuestionFormat):
    """Multi-step problem solving question"""
    type: QuestionType = QuestionType.MULTI_STEP
    steps: List[Dict[str, str]] = Field(..., min_items=2)

    def get_prompt_template(self) -> str:
        return """Create a multi-step clinical problem.
Format:
- Present complex scenario requiring multiple calculations or decisions
- Break down into logical steps
- Each step builds on previous
- Final answer requires completing all steps
- Exactly 5 choices for final answer"""

class QuestionGenerator:
    """Main class for generating questions based on type"""

    TYPE_MAP = {
        QuestionType.MCQ: MCQQuestion,
        QuestionType.CASE: CaseQuestion,
        QuestionType.IMAGE: ImageQuestion,
        QuestionType.ORDERED: OrderedQuestion,
        QuestionType.MATCHING: MatchingQuestion,
        QuestionType.BRANCHING: BranchingQuestion,
        QuestionType.DRAG_DROP: DragDropQuestion,
        QuestionType.MULTI_STEP: MultiStepQuestion
    }

    @staticmethod
    def create_question(type: QuestionType, **kwargs) -> QuestionFormat:
        """Factory method to create questions of specific type"""
        question_class = QuestionGenerator.TYPE_MAP.get(type)
        if not question_class:
            raise ValueError(f"Unknown question type: {type}")
        return question_class(**kwargs)

    @staticmethod
    def get_ai_model(type: QuestionType, complexity: str = "medium") -> str:
        """Determine which AI model to use based on question type and complexity"""
        if type == QuestionType.IMAGE:
            return "gemini-2.5-flash"  # Image-based always uses Gemini
        elif complexity == "hard" or type in [QuestionType.BRANCHING, QuestionType.MULTI_STEP]:
            return "gpt-4o"  # Complex questions use GPT-4o
        else:
            return "gpt-4o-mini"  # Default for standard questions

    @staticmethod
    def validate_question(question: Dict[str, Any]) -> bool:
        """Validate question meets all requirements"""
        required = ['question_text', 'choices', 'correct_answer', 'type']

        # Check required fields
        if not all(field in question for field in required):
            return False

        # Check exactly 5 choices
        if len(question.get('choices', [])) != 5:
            return False

        # Check correct answer in valid range
        if not 1 <= question.get('correct_answer', -1) <= 5:
            return False

        # Check no explanation in question text
        question_text = question.get('question_text', '')
        if any(keyword in question_text.lower() for keyword in ['explanation:', 'because', 'note:']):
            return False

        return True

# Question generation prompts for each type
GENERATION_PROMPTS = {
    QuestionType.MCQ: """Generate a {difficulty} multiple choice question about {subject}.
Topic: {topic}
Requirements:
- Question text should be clear and concise
- Exactly 5 choices (numbered 1-5)
- Only ONE correct answer
- No explanations in the question text
- Separate explanation field for rationale
Format as JSON with fields: question_text, choices (array of 5), correct_answer (1-5), explanation""",

    QuestionType.CASE: """Generate a {difficulty} case-based clinical question about {subject}.
Topic: {topic}
Requirements:
- Start with patient presentation/scenario
- Ask specific clinical question
- Exactly 5 answer choices
- Single best answer based on clinical reasoning
- Include case_scenario field
Format as JSON with fields: case_scenario, question_text, choices (array of 5), correct_answer (1-5), explanation""",

    QuestionType.IMAGE: """Analyze this medical image and generate a {difficulty} question about {subject}.
Topic: {topic}
Image shows: {image_description}
Requirements:
- Reference specific features in the image
- Ask about diagnosis, anatomy, or pathology
- Exactly 5 choices
- Single correct answer
Format as JSON with fields: image_description, question_text, choices (array of 5), correct_answer (1-5), explanation""",

    QuestionType.ORDERED: """Generate a {difficulty} ordering question about {subject}.
Topic: {topic}
Requirements:
- List 5 items that need to be arranged in order
- Ask for correct sequence (e.g., steps in procedure, stages of disease)
- Provide the correct order as answer
Format as JSON with fields: question_text, items_to_order (array of 5), correct_sequence (array of indices), explanation""",

    QuestionType.MATCHING: """Generate a {difficulty} matching question about {subject}.
Topic: {topic}
Requirements:
- Create 5 items in left column
- Create 5 corresponding items in right column
- Each left item matches exactly one right item
- Medical/clinical relevance
Format as JSON with fields: question_text, left_items (array of 5), right_items (array of 5), correct_pairs (dict), explanation""",

    QuestionType.BRANCHING: """Generate a {difficulty} clinical decision question about {subject}.
Topic: {topic}
Requirements:
- Initial scenario that branches based on decisions
- Each decision leads to new information
- Final question with 5 choices
- Decision tree logic
Format as JSON with fields: question_text, decision_points, choices (array of 5), correct_answer (0-4), explanation""",

    QuestionType.DRAG_DROP: """Generate a {difficulty} categorization question about {subject}.
Topic: {topic}
Requirements:
- Define 5 categories or drop zones
- Create 5 items to be categorized
- Each item belongs to exactly one category
Format as JSON with fields: question_text, drop_zones (array of 5), draggable_items (array of 5), correct_placement (dict), explanation""",

    QuestionType.MULTI_STEP: """Generate a {difficulty} multi-step problem about {subject}.
Topic: {topic}
Requirements:
- Complex scenario requiring multiple steps
- Each step builds on previous
- Show intermediate calculations/decisions
- Final answer with 5 choices
Format as JSON with fields: question_text, steps (array), choices (array of 5), correct_answer (1-5), explanation"""
}

def get_generation_prompt(type: QuestionType, **kwargs) -> str:
    """Get the appropriate prompt template for question generation"""
    template = GENERATION_PROMPTS.get(type)
    if not template:
        raise ValueError(f"No prompt template for type: {type}")
    return template.format(**kwargs)