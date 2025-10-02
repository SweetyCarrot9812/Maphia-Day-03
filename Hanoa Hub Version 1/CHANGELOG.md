# Hanoa Hub Version 1 - Changelog

## 2025-01-XX - Fitness Form Exercise Subcategory & CrossFit Support

### Added
- **Exercise Subcategory System**: "헬스", "크로스핏", "해당 없음" 옵션
- **Exercise Name Field**: 모든 운동 종목에 운동명 입력 필드 추가
- **CrossFit Reps Field**: 크로스핏 선택 시 Reps 입력 필드 표시
- **Firebase Complete Save**: exercise_subcategory, exercise_name, reps 필드 Firebase 저장 지원

### Fixed
- **Category Conditional Logic Bug**: 건강 선택 시 영양 필드 나타나던 버그 수정
  - 모든 `else:` 블록을 `elif concept_category == "영양":` 으로 변경
  - UI fields (line 134-148), data save (line 265-268), document (line 357-362), ChromaDB metadata (line 421-424), Firebase data (line 467-470)
- **Form Conditional Fields**: 분류/운동 종목 선택을 폼 외부로 이동하여 실시간 조건부 필드 표시 지원
- **Firebase Save Missing Fields**: exercise_subcategory, exercise_name, reps 필드가 Firebase에 저장되지 않던 문제 수정

### Changed
- **"해당 없음" Option**: 영양소 유형에 "해당 없음" 추가
- **Firebase Stats Removed**: 간호문제, 의학문제, 간호 개념, 의학 개념 Firebase 통계 제거 (운동/영양/건강만 유지)
- **Simplified Summary Metrics**: 총 문제, 총 개념, 전체 데이터 3개 컬럼으로 단순화

### Technical Details
**Modified Files**:
- `backend/fitness_manual_form.py`:
  - Line 90-106: Category/Subcategory selection moved outside form
  - Line 132-159: Exercise fields with CrossFit Reps
  - Line 160-175: Nutrition fields
  - Line 288-301: Data saving with subcategory and reps
  - Line 496-507: Firebase data preparation with all fields

- `backend/services/firebase_service.py`:
  - Line 243-277: Added `get_nursing_problems()`, `get_medical_problems()`, `get_fitness_concepts()`

- `backend/app.py`:
  - Line 1236-1254: Removed medical/nursing Firebase stats, simplified summary metrics

**Data Schema**:
```python
# Exercise concept with subcategory
{
    'category': '운동',
    'exercise_subcategory': '크로스핏',  # NEW
    'exercise_name': 'Fran',              # NEW
    'exercise_type': '전신',
    'equipment': ['바벨'],
    'reps': '21-15-9'                     # NEW (CrossFit only)
}
```

**UI Behavior**:
1. User selects "분류" (운동/영양/건강) → Conditional fields appear
2. If "운동" selected → "운동 종목" appears (헬스/크로스핏/해당 없음)
3. If "크로스핏" selected → "Reps" field appears
4. All "해당 없음" values filtered out before database save

**Known Issues**: None

---

## Previous Changes
(이전 변경사항은 여기에 기록)
