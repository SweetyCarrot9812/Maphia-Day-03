"""
AI Batch Question Generator
 - 텍스트 기반: OpenAI GPT-4o-mini 기본, GPT-4o로 고난도/검증
 - 이미지 기반: Gemini 2.5 Flash
 - 중복 방지: 간단 해시/벡터 유사도(옵션) 훅
"""
from typing import List, Dict, Any, Optional
from dataclasses import dataclass
from datetime import datetime

import json
import hashlib

import google.generativeai as genai
from openai import OpenAI

from config import (
    OPENAI_API_KEY, GEMINI_API_KEY,
    CHAT_MODEL, CHAT_MODEL_ADVANCED, GEMINI_MODEL, GEMINI_MODEL_PRO,
    EMBEDDING_MODEL, MAX_TOKENS, TEMPERATURE
)
from rag_engine import rag_engine


@dataclass
class BatchGenRequest:
    count: int
    subject: str
    difficulty: str
    types: List[str]
    keywords: List[str]
    language: str = 'ko'
    validate_with_gpt5: bool = True
    include_image: bool = False


class AIBatchGenerator:
    def __init__(self) -> None:
        self.openai = OpenAI(api_key=OPENAI_API_KEY) if OPENAI_API_KEY else None
        if GEMINI_API_KEY:
            genai.configure(api_key=GEMINI_API_KEY)
        self.primary_model = CHAT_MODEL
        self.adv_model = CHAT_MODEL_ADVANCED
        self.gemini_model = GEMINI_MODEL

    def _hash_question(self, q: Dict[str, Any]) -> str:
        base = f"{q.get('stem')}{q.get('choices')}"
        return hashlib.sha256(base.encode('utf-8', errors='ignore')).hexdigest()

    def _prompt_text_batch(self, req: BatchGenRequest) -> str:
        return f"""
너는 대한민국 간호/의료 기준을 따르는 문제 생성기이다.
아래 제약을 모두 지켜서 {req.count}개의 문제를 JSON 배열로 생성하라.

제약:
- 반드시 5지선다 (choices 5개)
- 정답은 단일 인덱스(answer: 0~4)
- 해설(explanation)은 별도 필드로 제공하되, 문제문에 해설 포함 금지
- 언어: {req.language}
- 과목: {req.subject}
- 난이도: {req.difficulty}
- 문제 타입: {', '.join(req.types)} (각 문제는 type 필드 포함)
- 키워드(가능하다면 반영): {', '.join(req.keywords)}

출력 JSON 스키마:
[
  {{
    "type": "MCQ|Case|Image|Ordered|Matching|Branching|DragDrop|MultiStep",
    "subject": "{req.subject}",
    "difficulty": "{req.difficulty}",
    "stem": "문제문",
    "choices": ["보기1","보기2","보기3","보기4","보기5"],
    "answer": 0,
    "explanation": "해설",
    "tags": ["키워드1","키워드2"],
    "imageUrl": null
  }}
]

반드시 JSON만 출력하라.
""".strip()

    def _call_openai_json(self, prompt: str, model: Optional[str] = None) -> List[Dict[str, Any]]:
        if not self.openai:
            raise RuntimeError("OPENAI_API_KEY not configured")
        mdl = model or self.primary_model
        resp = self.openai.chat.completions.create(
            model=mdl,
            messages=[{"role": "system", "content": "당신은 문제 생성기입니다. JSON만 반환하세요."},
                      {"role": "user", "content": prompt}],
            max_tokens=MAX_TOKENS,
            temperature=TEMPERATURE
        )
        txt = resp.choices[0].message.content.strip()
        if txt.startswith('```'):
            txt = txt.strip('`')
            txt = txt.replace('json', '')
        try:
            data = json.loads(txt)
            if isinstance(data, dict):
                data = [data]
            return data
        except Exception as e:
            raise RuntimeError(f"JSON 파싱 실패: {e}\n원문: {txt[:300]}")

    def generate_batch(self, req: BatchGenRequest) -> List[Dict[str, Any]]:
        prompt = self._prompt_text_batch(req)
        items = self._call_openai_json(prompt, model=self.primary_model)

        # 선택적으로 고급 검증
        if req.validate_with_gpt5 and self.adv_model:
            try:
                val_prompt = (
                    "아래 문제들의 형식/정답 일관성을 검증하고, 오류가 있으면 수정해서 동일 스키마로 반환하라.\n\n" +
                    json.dumps(items, ensure_ascii=False)
                )
                items = self._call_openai_json(val_prompt, model=self.adv_model)
            except Exception:
                pass

        # 중복 방지(간단 해시 + RAG 유사도 훅 자리)
        seen = set()
        result: List[Dict[str, Any]] = []
        for q in items:
            h = self._hash_question(q)
            if h in seen:
                continue
            seen.add(h)
            # RAG 삽입/메타 적재
            try:
                payload = {
                    'id': q.get('id') or h[:12],
                    'questionText': q.get('stem',''),
                    'choices': q.get('choices', []),
                    'correctAnswer': q.get('choices', [])[q.get('answer', 0)] if q.get('choices') else '',
                    'explanation': q.get('explanation',''),
                    'subject': q.get('subject', req.subject),
                    'difficulty': q.get('difficulty', req.difficulty),
                    'tags': q.get('tags', []),
                    'imageUrls': [q['imageUrl']] if q.get('imageUrl') else [],
                    'createdBy': 'ai_batch',
                    'createdAt': datetime.now().isoformat(),
                }
                rag_engine.add_question(payload)
            except Exception:
                pass
            result.append(q)

        return result


# 싱글턴
ai_batch_generator = AIBatchGenerator()

