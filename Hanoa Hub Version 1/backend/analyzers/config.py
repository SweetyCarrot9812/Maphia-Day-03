"""
Configuration for Clintest AI analyzers
OpenAI API key and other settings
"""
import os
from pathlib import Path

# Load from parent directory's .env file
parent_dir = Path(__file__).parent.parent
env_file = parent_dir / ".env"

# Try to load from .env file if it exists
if env_file.exists():
    with open(env_file, 'r') as f:
        for line in f:
            if line.strip() and not line.startswith('#'):
                key, value = line.strip().split('=', 1)
                os.environ[key] = value

# OpenAI API configuration
OPENAI_API_KEY = os.getenv('OPENAI_API_KEY', '')

if not OPENAI_API_KEY:
    print("[WARNING] OPENAI_API_KEY not found. Please set it in .env file or environment variables.")
    print("Some AI features may not work without API key.")

# Model configurations
DEFAULT_GPT5_MINI_MODEL = "gpt-4o-mini"  # Fallback to available model
DEFAULT_GPT5_MODEL = "gpt-4o"  # Fallback to available model

# Confidence thresholds
CONFIDENCE_THRESHOLD = 0.70
MIN_ATTEMPTS_FOR_ANALYSIS = 2

# Other configurations
MAX_RETRIES = 3
REQUEST_TIMEOUT = 30