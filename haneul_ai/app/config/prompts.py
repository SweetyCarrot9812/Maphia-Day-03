"""
Haneul AI Agent - AI Prompts Configuration
Centralized prompt templates for AI interactions
"""

PRIORITY_SCORING_PROMPT = """
당신은 개인 생산성 전문가입니다. 다음 작업/아이디어에 대해 우선순위를 점수화해주세요.

작업 내용: {content}
컨텍스트: {context}

다음 기준으로 1-10점 사이로 점수를 매겨주세요:
1. 시급성 (1=언젠가, 10=지금 당장)
2. 중요도 (1=별로 중요하지 않음, 10=매우 중요함)

응답 형식:
```json
{
    "urgency": 숫자,
    "importance": 숫자,
    "total_score": 숫자,
    "reasoning": "점수 부여 이유 설명",
    "suggested_tags": ["태그1", "태그2"],
    "estimated_time": "예상 소요 시간 (예: 30분, 2시간, 1일)"
}
```

간결하고 정확하게 평가해주세요.
"""

TAG_CLASSIFICATION_PROMPT = """
다음 노트 내용을 분석하여 적절한 태그를 추천해주세요.

내용: {content}

사용 가능한 태그 카테고리:
- 프로젝트: #개발, #디자인, #글쓰기, #연구
- 영역: #업무, #개인, #학습, #건강
- 우선순위: #긴급, #중요, #나중에
- 상태: #아이디어, #진행중, #완료, #보류

응답 형식:
```json
{
    "recommended_tags": ["태그1", "태그2", "태그3"],
    "category": "주요 카테고리",
    "confidence": 0.85
}
```
"""

DAILY_SUMMARY_PROMPT = """
오늘의 할 일 요약을 작성해주세요.

완료된 작업:
{completed_tasks}

진행 중인 작업:
{in_progress_tasks}

우선순위 TOP 3:
{top_priorities}

다음과 같은 형식으로 요약해주세요:

📊 **오늘의 진행 상황**
✅ 완료: {완료 개수}개
🔄 진행 중: {진행 개수}개

🎯 **내일 집중할 TOP 3**
1. [우선순위 점수] 작업명 - 예상시간
2. [우선순위 점수] 작업명 - 예상시간  
3. [우선순위 점수] 작업명 - 예상시간

💡 **한 줄 조언**
[생산성 향상을 위한 간단한 조언]

긍정적이고 동기부여가 되는 톤으로 작성해주세요.
"""

OBSIDIAN_NOTE_TEMPLATE = """
# {title}

## 메타데이터
- 생성일: {created_date}
- 우선순위: {priority_score}/20
- 시급성: {urgency}/10
- 중요도: {importance}/10
- 태그: {tags}
- 예상 소요시간: {estimated_time}

## 내용
{content}

## AI 분석
{ai_reasoning}

## 다음 행동
- [ ] {next_action}

---
*AI Agent에 의해 자동 생성됨*
"""

EMAIL_NOTIFICATION_TEMPLATE = """
안녕하세요! 🌟

오늘도 생산적인 하루를 위한 Haneul AI의 우선순위 알림입니다.

🎯 **오늘 집중할 TOP 3 작업**

{top_tasks}

💡 **오늘의 팁**
가장 어려운 일을 먼저 처리하면 나머지는 훨씬 쉬워집니다!

📅 **캘린더 추가**
위 작업들을 캘린더에 자동으로 추가하려면 [여기를 클릭]({calendar_link})하세요.

---
🤖 Haneul AI Agent | 설정 변경: {settings_link}
"""