"""
Base Persona Class for Haneul AI Agent
Abstract base class for all AI personas
"""

from abc import ABC, abstractmethod
from typing import Dict, Any, List
from app.models.schemas import PriorityAnalysis


class BasePersona(ABC):
    """Base class for all AI personas"""
    
    def __init__(self, name: str, description: str, model: str = "gpt-5"):
        self.name = name
        self.description = description
        self.model = model
        self.specialized_prompts = {}
    
    @abstractmethod
    async def analyze_priority(self, content: str, context: str = "") -> PriorityAnalysis:
        """Analyze task priority based on persona's specialty"""
        pass
    
    @abstractmethod
    async def generate_suggestion(self, content: str, context: str = "") -> str:
        """Generate persona-specific suggestions"""
        pass
    
    @abstractmethod
    def get_system_prompt(self) -> str:
        """Get persona-specific system prompt"""
        pass
    
    def get_persona_info(self) -> Dict[str, Any]:
        """Get basic persona information"""
        return {
            "name": self.name,
            "description": self.description,
            "model": self.model,
            "capabilities": self.get_capabilities()
        }
    
    @abstractmethod
    def get_capabilities(self) -> List[str]:
        """Get list of persona capabilities"""
        pass