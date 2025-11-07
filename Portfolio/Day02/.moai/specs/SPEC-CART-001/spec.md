---
title: "장바구니 핵심 기능 명세"
spec_id: "CART-001"
version: "1.0.0"
status: "ready"
priority: "high"
created_at: "2025-11-07"
category: "feature"
tags: ["cart", "e-commerce", "react", "zustand"]
---

# SPEC-CART-001: 장바구니 핵심 기능

## @SPEC:OVERVIEW-001

### Purpose
포트폴리오용 쇼핑카트의 핵심 상태 관리 및 비즈니스 로직을 구현하여 React 18 + TypeScript + Zustand 기술 역량을 입증

### Scope
- 장바구니 상태 관리 (Zustand)
- 상품 추가/제거/수량 변경
- 전체 선택/해제 기능
- 실시간 금액 계산 (소계, 배송비, 총합)
- 로컬스토리지 지속성

---

## @SPEC:FUNCTIONAL-001

### FR-001: 상품 장바구니 추가
**Given** 상품 목록에서 상품을 선택하고
**When** "장바구니 담기" 버튼을 클릭하면
**Then** 상품이 장바구니에 추가되고 초기 수량은 1개로 설정됨

### FR-002: 수량 조절
**Given** 장바구니에 상품이 있고
**When** 수량 증가(+) 또는 감소(-) 버튼을 클릭하면
**Then** 수량이 1-99 범위 내에서 변경되고 0이 되면 상품이 제거됨

### FR-003: 개별 상품 선택/해제
**Given** 장바구니에 여러 상품이 있고
**When** 개별 상품의 체크박스를 클릭하면
**Then** 해당 상품의 선택 상태가 토글되고 금액이 재계산됨

### FR-004: 전체 선택/해제
**Given** 장바구니에 여러 상품이 있고
**When** "전체선택" 체크박스를 클릭하면
**Then** 모든 상품의 선택 상태가 동일하게 변경됨

### FR-005: 실시간 금액 계산
**Given** 선택된 상품들이 있고
**When** 수량이나 선택 상태가 변경되면
**Then** 소계, 배송비(5만원 이상 시 무료), 총합이 즉시 재계산됨

---

## @SPEC:TECHNICAL-001

### Architecture Requirements
```typescript
// Zustand Store Structure
interface CartStore {
  items: CartItem[]
  addItem: (product: Product) => void
  removeItem: (productId: string) => void
  updateQuantity: (productId: string, quantity: number) => void
  toggleSelect: (productId: string) => void
  selectAll: (selected: boolean) => void
  clearCart: () => void

  // Computed values
  selectedItems: CartItem[]
  subtotal: number
  shippingFee: number
  total: number
}

interface CartItem {
  id: string
  product: Product
  quantity: number
  selected: boolean
}
```

### Performance Requirements
- React.memo를 통한 불필요한 리렌더링 방지
- useMemo를 통한 금액 계산 최적화
- Zustand persistence를 통한 브라우저 새로고침 시 상태 유지

### Type Safety Requirements
- 모든 함수와 상태에 완전한 TypeScript 타입 정의
- strict mode에서 0 에러
- quantity 범위 validation (1-99)

---

## @SPEC:TESTING-001

### Unit Test Coverage
```typescript
// Store Tests
describe('CartStore', () => {
  test('addItem should add new product with quantity 1')
  test('updateQuantity should update existing item quantity')
  test('updateQuantity with 0 should remove item')
  test('toggleSelect should toggle individual item selection')
  test('selectAll should update all items selection state')
  test('subtotal should calculate sum of selected items')
  test('shippingFee should return 3000 if subtotal < 50000, else 0')
  test('total should return subtotal + shippingFee')
})
```

### Component Integration Tests
```typescript
// Cart Components Tests
describe('Cart Integration', () => {
  test('adding product should update cart display')
  test('quantity controls should modify store state')
  test('select all checkbox should sync with individual checkboxes')
  test('amounts should update in real-time')
})
```

---

## @SPEC:ACCEPTANCE-001

### AC-001: 기본 장바구니 조작
- ✅ 상품을 장바구니에 추가할 수 있다
- ✅ 수량을 1-99 범위에서 조절할 수 있다
- ✅ 개별 상품을 선택/해제할 수 있다
- ✅ 전체 선택/해제 기능이 동작한다

### AC-002: 실시간 금액 계산
- ✅ 선택된 상품만 소계에 포함된다
- ✅ 5만원 이상 시 배송비가 0원이다
- ✅ 5만원 미만 시 배송비가 3,000원이다
- ✅ 총합이 소계 + 배송비로 정확히 계산된다

### AC-003: 상태 지속성
- ✅ 브라우저 새로고침 후에도 장바구니 내용이 유지된다
- ✅ 탭을 닫았다 열어도 선택 상태가 유지된다

---

## @TAG:IMPLEMENTATION-001

### Development Order
1. **@TAG:CART-STORE-001**: Zustand store 기본 구조
2. **@TAG:CART-TYPES-001**: TypeScript 타입 정의
3. **@TAG:CART-ACTIONS-001**: 액션 함수들 (addItem, updateQuantity 등)
4. **@TAG:CART-COMPUTED-001**: 계산된 값들 (subtotal, shippingFee, total)
5. **@TAG:CART-PERSIST-001**: localStorage 지속성
6. **@TAG:CART-VALIDATION-001**: 입력 검증 (수량 범위 등)

### Test-First Implementation
각 @TAG마다 다음 TDD 사이클 적용:
1. **RED**: 실패하는 테스트 작성
2. **GREEN**: 최소한의 코드로 테스트 통과
3. **REFACTOR**: 코드 품질 개선 및 최적화

---

## HISTORY

### v1.0.0 (2025-11-07)
- **CREATED**: TDD 구현을 위한 상세 기능 명세
- **FOCUS**: React 18 + Zustand 기술 역량 입증을 위한 포트폴리오 최적화
- **SCOPE**: 장바구니 핵심 기능 완전 구현