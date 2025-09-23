"""
API 비용 추적 모듈
모델별 API 사용 비용 계산 및 추적
"""

from typing import Dict, List, Optional
from dataclasses import dataclass
from datetime import datetime
import json
import os


@dataclass
class APIUsage:
    """API 사용 기록"""
    timestamp: str
    model: str
    operation: str  # image_analysis, text_generation, embedding
    input_tokens: int
    output_tokens: int
    cost: float
    metadata: Optional[Dict] = None


class APICostTracker:
    """API 비용 추적기"""

    def __init__(self):
        # 2025년 8월 기준 모델별 가격 (USD per 1M tokens)
        self.pricing = {
            # OpenAI GPT 시리즈
            'gpt-5': {
                'input': 1.25,
                'output': 10.00
            },
            'gpt-5-mini': {
                'input': 0.25,
                'output': 2.00
            },
            'gpt-5-nano': {
                'input': 0.10,
                'output': 1.00
            },
            'o3-mini': {
                'input': 0.15,
                'output': 0.15
            },

            # Google Gemini 시리즈
            'gemini-2.5-flash': {
                'input': 0.05,
                'output': 0.05
            },
            'gemini-2.5-flash-8b': {
                'input': 0.0375,
                'output': 0.15
            },
            'gemini-2.5-pro': {
                'input': 0.25,
                'output': 1.00
            },
            'text-embedding-004': {
                'input': 0.00625,  # $0.00625 per 1M tokens
                'output': 0.0
            },

            # Perplexity 시리즈
            'sonar': {
                'input': 1.00,
                'output': 1.00
            },
            'r1-small': {
                'input': 0.20,
                'output': 0.20
            }
        }

        # 사용 기록 저장 경로
        self.log_file = "monitoring/api_usage.jsonl"
        self.daily_summary_file = "monitoring/daily_summary.json"

        # 일일 한도 설정 (USD)
        self.daily_limits = {
            'total': 10.00,
            'gpt-5': 5.00,
            'gpt-5-mini': 3.00,
            'gemini': 2.00
        }

        # 현재 세션 사용량
        self.session_usage = {
            'total_cost': 0.0,
            'by_model': {},
            'by_operation': {}
        }

    def estimate_tokens(self, text: str = None, image_size: tuple = None) -> int:
        """토큰 수 추정"""
        if text:
            # 텍스트: 대략 4자 = 1토큰 (한국어는 더 많이 소비)
            if any('\uac00' <= char <= '\ud7af' for char in text):  # 한국어
                return len(text) // 2
            else:  # 영어
                return len(text) // 4

        if image_size:
            # 이미지: 크기에 따라 토큰 추정
            width, height = image_size
            pixels = width * height

            if pixels < 512 * 512:
                return 85  # 작은 이미지
            elif pixels < 1024 * 1024:
                return 170  # 중간 이미지
            else:
                return 765  # 큰 이미지

        return 100  # 기본값

    def calculate_cost(self, model: str, input_tokens: int,
                      output_tokens: int = 0) -> float:
        """비용 계산"""
        # 모델명 정규화
        model_key = self._normalize_model_name(model)

        if model_key not in self.pricing:
            print(f"[WARNING] 가격 정보 없음: {model}")
            model_key = 'gpt-5-mini'  # 기본값

        pricing = self.pricing[model_key]

        # 비용 계산 (1M 토큰당 가격)
        input_cost = (input_tokens / 1_000_000) * pricing['input']
        output_cost = (output_tokens / 1_000_000) * pricing['output']

        return round(input_cost + output_cost, 6)

    def estimate_cost(self, model: str, tokens_used: int) -> float:
        """간단한 비용 추정 (입력 토큰만)"""
        return self.calculate_cost(model, tokens_used, 0)

    def track_usage(self, model: str, operation: str,
                   input_tokens: int, output_tokens: int = 0,
                   metadata: Dict = None) -> APIUsage:
        """API 사용 기록"""
        cost = self.calculate_cost(model, input_tokens, output_tokens)

        usage = APIUsage(
            timestamp=datetime.now().isoformat(),
            model=model,
            operation=operation,
            input_tokens=input_tokens,
            output_tokens=output_tokens,
            cost=cost,
            metadata=metadata or {}
        )

        # 세션 사용량 업데이트
        self._update_session_usage(usage)

        # 파일에 기록
        self._log_usage(usage)

        # 일일 한도 체크
        if self._check_daily_limit(model, cost):
            print(f"[WARNING] {model} 일일 한도 초과 주의")

        return usage

    def get_session_summary(self) -> Dict:
        """현재 세션 사용 요약"""
        return {
            'total_cost': round(self.session_usage['total_cost'], 4),
            'by_model': self.session_usage['by_model'],
            'by_operation': self.session_usage['by_operation'],
            'timestamp': datetime.now().isoformat()
        }

    def get_daily_summary(self) -> Dict:
        """일일 사용 요약"""
        try:
            if os.path.exists(self.daily_summary_file):
                with open(self.daily_summary_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
        except Exception as e:
            print(f"[ERROR] 일일 요약 로드 실패: {e}")

        return {'date': datetime.now().date().isoformat(), 'total': 0.0}

    def get_cost_by_model(self, model: str = None) -> float:
        """모델별 비용 조회"""
        if model:
            model_key = self._normalize_model_name(model)
            return self.session_usage['by_model'].get(model_key, 0.0)

        return self.session_usage['by_model']

    def get_cost_by_operation(self, operation: str = None) -> float:
        """작업별 비용 조회"""
        if operation:
            return self.session_usage['by_operation'].get(operation, 0.0)

        return self.session_usage['by_operation']

    def optimize_model_selection(self, required_quality: str,
                                token_count: int) -> str:
        """비용 최적화된 모델 선택"""
        quality_models = {
            'high': ['gpt-5', 'gemini-2.5-pro'],
            'medium': ['gpt-5-mini', 'gemini-2.5-flash'],
            'low': ['gpt-5-nano', 'gemini-2.5-flash-8b']
        }

        candidates = quality_models.get(required_quality, ['gpt-5-mini'])

        # 가장 저렴한 모델 선택
        best_model = None
        min_cost = float('inf')

        for model in candidates:
            if model in self.pricing:
                cost = self.estimate_cost(model, token_count)
                if cost < min_cost:
                    min_cost = cost
                    best_model = model

        return best_model or 'gpt-5-mini'

    def _normalize_model_name(self, model: str) -> str:
        """모델명 정규화"""
        model_lower = model.lower()

        # 별칭 매핑
        aliases = {
            'gemini': 'gemini-2.5-flash',
            'gemini-flash': 'gemini-2.5-flash',
            'flash-8b': 'gemini-2.5-flash-8b',
            'gpt5': 'gpt-5',
            'gpt5-mini': 'gpt-5-mini',
            'gpt5-nano': 'gpt-5-nano',
            'o3': 'o3-mini'
        }

        for alias, actual in aliases.items():
            if alias in model_lower:
                return actual

        # 정확한 매칭
        for key in self.pricing.keys():
            if key in model_lower:
                return key

        return model_lower

    def _update_session_usage(self, usage: APIUsage):
        """세션 사용량 업데이트"""
        self.session_usage['total_cost'] += usage.cost

        # 모델별
        model_key = self._normalize_model_name(usage.model)
        if model_key not in self.session_usage['by_model']:
            self.session_usage['by_model'][model_key] = 0.0
        self.session_usage['by_model'][model_key] += usage.cost

        # 작업별
        if usage.operation not in self.session_usage['by_operation']:
            self.session_usage['by_operation'][usage.operation] = 0.0
        self.session_usage['by_operation'][usage.operation] += usage.cost

    def _log_usage(self, usage: APIUsage):
        """사용 기록 파일 저장"""
        try:
            os.makedirs(os.path.dirname(self.log_file), exist_ok=True)

            with open(self.log_file, 'a', encoding='utf-8') as f:
                f.write(json.dumps(usage.__dict__, ensure_ascii=False) + '\n')

        except Exception as e:
            print(f"[ERROR] 사용 기록 저장 실패: {e}")

    def _check_daily_limit(self, model: str, cost: float) -> bool:
        """일일 한도 체크"""
        daily = self.get_daily_summary()
        current_total = daily.get('total', 0.0) + cost

        # 전체 한도
        if current_total > self.daily_limits['total']:
            return True

        # 모델별 한도
        model_key = self._normalize_model_name(model)
        for limit_key, limit_value in self.daily_limits.items():
            if limit_key in model_key:
                model_usage = daily.get(model_key, 0.0) + cost
                if model_usage > limit_value:
                    return True

        return False

    def reset_session(self):
        """세션 사용량 리셋"""
        self.session_usage = {
            'total_cost': 0.0,
            'by_model': {},
            'by_operation': {}
        }

    def generate_cost_report(self) -> str:
        """비용 리포트 생성"""
        session = self.get_session_summary()
        daily = self.get_daily_summary()

        report = f"""
[API 비용 리포트]
================

세션 사용량:
- 총 비용: ${session['total_cost']:.4f}
- 시간: {session['timestamp']}

모델별 비용:
"""
        for model, cost in session['by_model'].items():
            report += f"  - {model}: ${cost:.4f}\n"

        report += "\n작업별 비용:\n"
        for op, cost in session['by_operation'].items():
            report += f"  - {op}: ${cost:.4f}\n"

        report += f"""
일일 사용량:
- 날짜: {daily.get('date', 'N/A')}
- 총 비용: ${daily.get('total', 0.0):.4f}
- 한도: ${self.daily_limits['total']:.2f}
- 남은 예산: ${max(0, self.daily_limits['total'] - daily.get('total', 0.0)):.4f}
"""

        return report


# 싱글톤 인스턴스
api_cost_tracker = APICostTracker()


__all__ = ['APICostTracker', 'APIUsage', 'api_cost_tracker']