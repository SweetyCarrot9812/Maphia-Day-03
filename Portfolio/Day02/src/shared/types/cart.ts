// @TAG:CART-TYPES-001
import { CartItem, Product } from './product'

export interface CartStore {
  // State
  items: CartItem[]

  // Actions
  addItem: (product: Product) => void
  removeItem: (productId: string) => void
  updateQuantity: (productId: string, quantity: number) => void
  toggleSelect: (productId: string) => void
  selectAll: (selected: boolean) => void
  clearCart: () => void

  // Computed values - use selectors instead
  selectedItems: CartItem[]
  subtotal: number
  shippingFee: number
  total: number
}

// Computed selectors for use in components
export const selectSelectedItems = (state: CartStore): CartItem[] =>
  state.items.filter(item => item.selected)

export const selectSubtotal = (state: CartStore): number =>
  selectSelectedItems(state).reduce(
    (sum, item) => sum + (item.product.price * item.quantity),
    0
  )

export const selectShippingFee = (state: CartStore): number =>
  selectSubtotal(state) < 50000 ? 3000 : 0

export const selectTotal = (state: CartStore): number =>
  selectSubtotal(state) + selectShippingFee(state)