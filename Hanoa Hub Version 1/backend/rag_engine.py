"""
RAG Engine for Hanoa Hub - ChromaDB integration and vector search
"""
import json
import uuid
from datetime import datetime
from typing import List, Dict, Any, Optional

import chromadb
import google.generativeai as genai
import openai
from chromadb.config import Settings

from config import (
    CHROMA_DIR, GEMINI_API_KEY, OPENAI_API_KEY,
    COLLECTION_NAME_QUESTIONS, COLLECTION_NAME_CONCEPTS,
    EMBEDDING_MODEL, CHAT_MODEL, CHAT_MODEL_ADVANCED, MAX_TOKENS, TEMPERATURE
)


class RAGEngine:
    """RAG Engine for nursing questions and concepts"""

    def __init__(self):
        self.chroma_client = None
        self.questions_collection = None
        self.concepts_collection = None
        self.setup_clients()

    def setup_clients(self):
        """Initialize ChromaDB and AI clients"""
        try:
            # ChromaDB setup
            self.chroma_client = chromadb.PersistentClient(
                path=str(CHROMA_DIR),
                settings=Settings(anonymized_telemetry=False)
            )

            # Get or create collections
            self.questions_collection = self.chroma_client.get_or_create_collection(
                name=COLLECTION_NAME_QUESTIONS,
                metadata={"description": "Nursing questions for RAG"}
            )

            self.concepts_collection = self.chroma_client.get_or_create_collection(
                name=COLLECTION_NAME_CONCEPTS,
                metadata={"description": "Nursing concepts for RAG"}
            )

            # AI clients setup
            genai.configure(api_key=GEMINI_API_KEY)
            openai.api_key = OPENAI_API_KEY

            print("[SUCCESS] RAG Engine initialized successfully")

        except Exception as e:
            print(f"[ERROR] Failed to initialize RAG Engine: {e}")
            raise

    def generate_embedding(self, text: str) -> List[float]:
        """Generate embedding using Gemini text-embedding-004"""
        try:
            # Use the latest Gemini embedding model
            result = genai.embed_content(
                model=EMBEDDING_MODEL,  # text-embedding-004
                content=text,
                task_type="retrieval_document"
            )
            return result['embedding']

        except Exception as e:
            print(f"[ERROR] Embedding generation failed: {e}")
            # Fallback to simple hash-based embedding for testing
            return [hash(text) % 1000 / 1000.0] * 768

    def add_question(self, question_data: Dict[str, Any]) -> str:
        """Add a nursing question to the vector database"""
        try:
            question_id = question_data.get('id', str(uuid.uuid4()))

            # Prepare content for embedding
            content = f"""
            문제: {question_data.get('questionText', '')}
            선택지: {', '.join(question_data.get('choices', []))}
            정답: {question_data.get('correctAnswer', '')}
            해설: {question_data.get('explanation', '')}
            """

            # Generate embedding
            embedding = self.generate_embedding(content.strip())

            # Prepare metadata
            metadata = {
                'type': 'question',
                'subject': question_data.get('subject', ''),
                'difficulty': question_data.get('difficulty', 'medium'),
                'tags': json.dumps(question_data.get('tags', [])),
                'created_at': datetime.now().isoformat(),
                'created_by': question_data.get('createdBy', 'system')
            }

            # Add to ChromaDB
            self.questions_collection.add(
                documents=[content.strip()],
                embeddings=[embedding],
                metadatas=[metadata],
                ids=[question_id]
            )

            print(f"[SUCCESS] Question added: {question_id}")
            return question_id

        except Exception as e:
            print(f"[ERROR] Failed to add question: {e}")
            raise

    def add_concept(self, concept_data: Dict[str, Any]) -> str:
        """Add a nursing concept to the vector database"""
        try:
            concept_id = concept_data.get('id', str(uuid.uuid4()))

            # Prepare content for embedding
            content = f"""
            개념: {concept_data.get('title', '')}
            설명: {concept_data.get('description', '')}
            카테고리: {concept_data.get('category', '')}
            """

            # Generate embedding
            embedding = self.generate_embedding(content.strip())

            # Prepare metadata
            metadata = {
                'type': 'concept',
                'category': concept_data.get('category', ''),
                'tags': json.dumps(concept_data.get('tags', [])),
                'created_at': datetime.now().isoformat()
            }

            # Add to ChromaDB
            self.concepts_collection.add(
                documents=[content.strip()],
                embeddings=[embedding],
                metadatas=[metadata],
                ids=[concept_id]
            )

            print(f"[SUCCESS] Concept added: {concept_id}")
            return concept_id

        except Exception as e:
            print(f"[ERROR] Failed to add concept: {e}")
            raise

    def search(self, query: str, collection_type: str = "both", n_results: int = 5) -> Dict[str, Any]:
        """Search for similar questions or concepts"""
        try:
            # Generate query embedding
            query_embedding = self.generate_embedding(query)

            results = {'questions': [], 'concepts': []}

            # Search questions
            if collection_type in ["both", "questions"]:
                question_results = self.questions_collection.query(
                    query_embeddings=[query_embedding],
                    n_results=n_results,
                    include=['documents', 'metadatas', 'distances']
                )

                for i, doc in enumerate(question_results['documents'][0]):
                    results['questions'].append({
                        'id': question_results['ids'][0][i],
                        'content': doc,
                        'metadata': question_results['metadatas'][0][i],
                        'distance': question_results['distances'][0][i]
                    })

            # Search concepts
            if collection_type in ["both", "concepts"]:
                concept_results = self.concepts_collection.query(
                    query_embeddings=[query_embedding],
                    n_results=n_results,
                    include=['documents', 'metadatas', 'distances']
                )

                for i, doc in enumerate(concept_results['documents'][0]):
                    results['concepts'].append({
                        'id': concept_results['ids'][0][i],
                        'content': doc,
                        'metadata': concept_results['metadatas'][0][i],
                        'distance': concept_results['distances'][0][i]
                    })

            return results

        except Exception as e:
            print(f"[ERROR] Search failed: {e}")
            return {'questions': [], 'concepts': []}

    def generate_answer(self, query: str, context: List[Dict[str, Any]]) -> str:
        """Generate AI answer based on search results"""
        try:
            # Prepare context
            context_text = "\n\n".join([
                f"참고자료 {i+1}:\n{item['content']}"
                for i, item in enumerate(context[:3])  # Top 3 results
            ])

            # Create prompt
            prompt = f"""
            다음 간호학 관련 질문에 대해 제공된 참고자료를 바탕으로 정확하고 도움이 되는 답변을 작성해주세요.

            질문: {query}

            참고자료:
            {context_text}

            답변 시 다음 사항을 고려해주세요:
            1. 간호학적 근거를 제시해주세요
            2. 실무에 적용 가능한 구체적인 내용을 포함해주세요
            3. 안전하고 윤리적인 간호 실무를 강조해주세요
            4. 참고자료의 내용을 적절히 인용해주세요

            답변:
            """

            # Generate response using latest OpenAI models (GPT-5 Mini)
            response = openai.chat.completions.create(
                model=CHAT_MODEL,  # GPT-5 Mini
                messages=[
                    {"role": "system", "content": "당신은 간호학 전문가입니다. 정확하고 근거 있는 답변을 제공해주세요."},
                    {"role": "user", "content": prompt}
                ],
                max_tokens=MAX_TOKENS,
                temperature=TEMPERATURE
            )

            return response.choices[0].message.content

        except Exception as e:
            print(f"[ERROR] Answer generation failed: {e}")
            return "죄송합니다. 답변 생성 중 오류가 발생했습니다."

    def get_stats(self) -> Dict[str, Any]:
        """Get database statistics"""
        try:
            question_count = self.questions_collection.count()
            concept_count = self.concepts_collection.count()

            return {
                'questions': question_count,
                'concepts': concept_count,
                'total': question_count + concept_count,
                'collections': {
                    'questions': COLLECTION_NAME_QUESTIONS,
                    'concepts': COLLECTION_NAME_CONCEPTS
                }
            }

        except Exception as e:
            print(f"[ERROR] Failed to get stats: {e}")
            return {'questions': 0, 'concepts': 0, 'total': 0}


# Global instance
rag_engine = RAGEngine()


if __name__ == "__main__":
    # Test the RAG engine
    try:
        stats = rag_engine.get_stats()
        print(f"[STATS] RAG Engine Stats: {stats}")

        # Test search
        results = rag_engine.search("혈압 측정", n_results=3)
        print(f"[SEARCH] Search results: {len(results['questions'])} questions, {len(results['concepts'])} concepts")

    except Exception as e:
        print(f"[ERROR] RAG Engine test failed: {e}")