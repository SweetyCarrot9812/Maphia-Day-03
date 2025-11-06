# 포트폴리오 쇼핑몰 PRD v1.0

## Meta
- 작성일: 2025-11-07
- 작성자: Portfolio Developer
- 상태: Draft
- 최종 수정일: 2025-11-07

---

## 1. 제품 개요

### 배경 & 목적
포트폴리오용 쇼핑몰 웹 애플리케이션으로, 프론트엔드 개발 역량을 종합적으로 어필하기 위한 프로젝트입니다. 실무에서 요구되는 핵심 쇼핑 기능(상품 선택, 수량 조절, 장바구니, 결제 계산)과 반응형 디자인을 통해 개발자의 기술적 숙련도를 증명합니다.

### 타겟 사용자
- **Primary**: 채용 담당자, 기술 면접관
- **Secondary**: 동료 개발자, 포트폴리오 리뷰어
- **Persona**: 웹 개발 실무 경험을 평가하고자 하는 의사결정권자

### 성공 지표
| 지표 | 베이스라인 | 목표 | 측정 방법 |
|------|------------|------|-----------|
| 기능 완성도 | 0% | 100% | 모든 필수 조건 통과 |
| 반응형 호환성 | 0% | 100% | 데스크톱/모바일 정상 조회 |
| 코드 품질 점수 | N/A | A+ | 코드 리뷰 체크리스트 |
| 로딩 성능 | N/A | <3초 | 페이지 로드 시간 측정 |

### 범위
- ✅ **In Scope**:
  - 상품 목록 표시 및 선택 기능
  - 개별/전체 선택 토글 기능
  - 수량 조절 인터페이스 (증가/감소)
  - 실시간 가격 계산 (상품금액 + 배송비 + 총액)
  - 5만원 미만 배송비 자동 적용 로직
  - 데스크톱/모바일 반응형 디자인
  - 현대적인 UI/UX 디자인

- ❌ **Out of Scope**:
  - 실제 결제 시스템 연동
  - 사용자 회원가입/로그인
  - 백엔드 API 서버
  - 상품 관리 시스템
  - 주문 히스토리
  - 실제 배송 연동

---

## 2. 기능 요구사항

| 기능 | RICE | MoSCoW | Acceptance Criteria |
|------|------|--------|---------------------|
| 상품 선택/해제 | 150 | Must | - 개별 상품 체크박스 동작<br>- 전체 선택 체크박스 동작<br>- 선택 상태 시각적 피드백 |
| 수량 조절 | 120 | Must | - +/- 버튼으로 수량 증감<br>- 최소 1개, 최대 99개 제한<br>- 실시간 금액 업데이트 |
| 배송비 계산 | 100 | Must | - 5만원 미만 시 3천원 자동 추가<br>- 5만원 이상 시 무료배송<br>- 실시간 조건 체크 |
| 가격 표시 | 90 | Must | - 상품 금액 합계<br>- 배송비 표시<br>- 총 결제금액 표시<br>- 천 단위 콤마 formatting |
| 반응형 디자인 | 80 | Must | - 모바일(320px~768px) 레이아웃<br>- 태블릿(768px~1024px) 레이아웃<br>- 데스크톱(1024px+) 레이아웃 |
| UI 애니메이션 | 40 | Could | - 버튼 hover 효과<br>- 수량 변경 transition<br>- 체크박스 애니메이션 |

---

## 3. 사용자 여정 (주요 시나리오)

### 주요 사용자 플로우
1. **랜딩**: 포트폴리오 사이트에서 쇼핑몰 프로젝트 링크 클릭
2. **상품 탐색**: 상품 목록 확인 (5-10개 샘플 상품)
3. **상품 선택**: 개별 또는 전체 선택을 통한 장바구니 구성
4. **수량 조절**: +/- 버튼으로 원하는 수량 설정
5. **가격 확인**: 실시간으로 계산되는 총 금액 확인 (배송비 포함)
6. **기능 체험**: 다양한 조합으로 배송비 로직 확인

### 반응형 경험 플로우
1. **데스크톱**: 큰 화면에서 그리드 레이아웃으로 상품 나열
2. **모바일**: 세로 스크롤 리스트 형태로 최적화된 UI 체험
3. **화면 크기 변경**: 브라우저 크기 조절 시 자연스러운 레이아웃 전환

---

## 4. 기술 요구사항

### 프론트엔드 스택
- **Framework**: React.js 18+ 또는 Vue.js 3+ (현대적 컴포넌트 기반)
- **Styling**: CSS3, Styled-components 또는 Tailwind CSS
- **Build Tool**: Vite 또는 Webpack
- **Package Manager**: npm 또는 yarn

### 성능 요구사항 (SLO)
- **First Contentful Paint**: p95 < 1.5초
- **Largest Contentful Paint**: p95 < 2.5초
- **Cumulative Layout Shift**: < 0.1
- **Time to Interactive**: < 3초

### 호환성 요구사항
- **브라우저**: Chrome 90+, Firefox 88+, Safari 14+, Edge 90+
- **디바이스**: iOS Safari, Android Chrome
- **화면 크기**: 320px ~ 1920px 까지 모든 breakpoint 지원

### 접근성 요구사항
- **WCAG 2.1 Level A** 준수
- **키보드 네비게이션** 지원
- **Screen Reader** 호환성
- **Color Contrast** 4.5:1 이상

---

## 5. 정보 구조 (IA)

```
Portfolio Shopping Mall
├── Header
│   ├── Logo/Title
│   └── Cart Summary (선택 상품 수)
├── Product List
│   ├── Select All Checkbox
│   └── Product Items (5-10개)
│       ├── Product Image
│       ├── Product Info (이름, 가격)
│       ├── Select Checkbox
│       └── Quantity Controls (+/- buttons)
├── Cart Summary Panel
│   ├── Selected Items Count
│   ├── Subtotal (상품 금액 합)
│   ├── Shipping Fee (배송비)
│   ├── Total Amount (총 결제금액)
│   └── Shipping Notice (5만원 이상 무료배송 안내)
└── Footer
    └── Portfolio Link
```

---

## 6. 실험 설계

### A/B 테스트 계획
| 실험명 | 가설 | 대조군 | 실험군 | 측정 지표 | 기간 |
|--------|------|--------|--------|----------|------|
| 수량 컨트롤 UI | 큰 버튼이 사용성을 높인다 | 작은 +/- 버튼 | 큰 +/- 버튼 | 클릭률, 사용 편의성 | 1주 |
| 가격 표시 방식 | 실시간 계산이 더 직관적이다 | 정적 가격 표시 | 동적 실시간 업데이트 | 사용자 체류시간 | 1주 |

### 사용자 테스트
- **대상**: 개발자 5명, 비개발자 5명
- **시나리오**: 3개 상품 선택하여 총 금액 10만원 만들기
- **측정**: 작업 완료 시간, 오류 횟수, 만족도 (1-5점)

---

## 7. 릴리즈 계획

### Phase 1: Core MVP (Week 1-2)
- 기본 상품 목록 렌더링
- 선택/해제 기능 구현
- 수량 조절 기본 기능
- 가격 계산 로직

### Phase 2: Enhanced UX (Week 2-3)
- 반응형 디자인 적용
- 배송비 로직 구현
- UI 애니메이션 추가
- 접근성 개선

### Phase 3: Polish & Deploy (Week 3-4)
- 성능 최적화
- 크로스브라우저 테스트
- 포트폴리오 사이트 통합
- 최종 QA 및 배포

---

## 8. 오픈 이슈

- [ ] **[2025-11-07]** 결정 필요: 상품 데이터 구조 정의 (하드코딩 vs JSON 파일)
- [ ] **[2025-11-07]** 결정 필요: 디자인 시스템 선택 (Custom CSS vs UI Library)
- [ ] **[2025-11-07]** 검증 필요: 접근성 요구사항 레벨 (Level A vs AA)
- [ ] **[2025-11-07]** 확인 필요: 브라우저 지원 범위 (IE11 포함 여부)

---

## 9. 데이터 계약

### 상품 데이터 스키마
```typescript
interface Product {
  id: string;
  name: string;
  price: number;
  image: string;
  description?: string;
}

interface CartItem {
  productId: string;
  quantity: number;
  selected: boolean;
}

interface CartSummary {
  subtotal: number;
  shippingFee: number;
  total: number;
  selectedCount: number;
}
```

### 이벤트 추적
```javascript
// 상품 선택 이벤트
trackEvent('product_selected', {
  product_id: string,
  selected: boolean,
  timestamp: Date
});

// 수량 변경 이벤트
trackEvent('quantity_changed', {
  product_id: string,
  old_quantity: number,
  new_quantity: number,
  timestamp: Date
});

// 배송비 적용 이벤트
trackEvent('shipping_fee_applied', {
  subtotal: number,
  shipping_fee: number,
  free_shipping: boolean,
  timestamp: Date
});
```

---

## 10. 의사결정 로그

### 2025-11-07: 프레임워크 선택
- **쟁점**: React vs Vue vs Vanilla JS
- **대안**:
  1. React (장점: 인지도, 생태계 / 단점: 복잡성)
  2. Vue (장점: 학습곡선, 간결함 / 단점: 상대적 낮은 인지도)
  3. Vanilla JS (장점: 순수 기술력 어필 / 단점: 개발 시간)
- **결정**: React 선택
- **근거**: 채용 시장에서 가장 요구도가 높고, 포트폴리오 어필 효과 극대화
- **결정자**: Portfolio Developer

### 2025-11-07: 디자인 복잡도 수준
- **쟁점**: 단순한 기능 구현 vs 세련된 디자인
- **결정**: 기능 완성도 우선, 디자인은 깔끔하고 실용적으로
- **근거**: 포트폴리오의 목적이 기술 역량 증명이므로 기능적 완성도가 더 중요