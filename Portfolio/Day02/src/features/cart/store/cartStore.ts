// @TAG:CART-STORE-001 - GREEN Phase Implementation
import { create } from 'zustand'
import { devtools, persist } from 'zustand/middleware'
import { CartStore } from '@/shared/types/cart'
import { Product, CartItem } from '@/shared/types/product'

const computeState = (state: { items: CartItem[] }) => {
  const selectedItems = state.items.filter(item => item.selected)
  const subtotal = selectedItems.reduce(
    (sum, item) => sum + (item.product.price * item.quantity),
    0
  )
  const shippingFee = subtotal < 50000 ? 3000 : 0
  const total = subtotal + shippingFee

  return {
    selectedItems,
    subtotal,
    shippingFee,
    total
  }
}

export const useCartStore = create<CartStore>()(
  devtools(
    persist(
      (set, get) => ({
        items: [],

        addItem: (product: Product) => {
          set((state) => {
            const existingItem = state.items.find(item => item.product.id === product.id)

            let newItems
            if (existingItem) {
              newItems = state.items.map(item =>
                item.product.id === product.id
                  ? { ...item, quantity: item.quantity + 1 }
                  : item
              )
            } else {
              const newItem = {
                id: `cart-item-${Date.now()}`,
                product,
                quantity: 1,
                selected: true
              }
              newItems = [...state.items, newItem]
            }

            const computed = computeState({ items: newItems })
            return {
              ...state,
              items: newItems,
              ...computed
            }
          })
        },

        removeItem: (productId: string) => {
          set((state) => {
            const newItems = state.items.filter(item => item.product.id !== productId)
            const computed = computeState({ items: newItems })
            return {
              ...state,
              items: newItems,
              ...computed
            }
          })
        },

        updateQuantity: (productId: string, quantity: number) => {
          if (quantity < 0 || quantity > 99) {
            throw new Error(`Invalid quantity: ${quantity}. Must be between 1-99.`)
          }

          if (quantity === 0) {
            get().removeItem(productId)
            return
          }

          set((state) => {
            const newItems = state.items.map(item =>
              item.product.id === productId
                ? { ...item, quantity }
                : item
            )
            const computed = computeState({ items: newItems })
            return {
              ...state,
              items: newItems,
              ...computed
            }
          })
        },

        toggleSelect: (productId: string) => {
          set((state) => {
            const newItems = state.items.map(item =>
              item.product.id === productId
                ? { ...item, selected: !item.selected }
                : item
            )
            const computed = computeState({ items: newItems })
            return {
              ...state,
              items: newItems,
              ...computed
            }
          })
        },

        selectAll: (selected: boolean) => {
          set((state) => {
            const newItems = state.items.map(item => ({ ...item, selected }))
            const computed = computeState({ items: newItems })
            return {
              ...state,
              items: newItems,
              ...computed
            }
          })
        },

        clearCart: () => {
          set({
            items: [],
            selectedItems: [],
            subtotal: 0,
            shippingFee: 0,
            total: 0
          })
        },

        // Initial computed values - these will be updated by actions
        selectedItems: [],
        subtotal: 0,
        shippingFee: 0,
        total: 0
      }),
      {
        name: 'cart-storage',
        partialize: (state) => ({ items: state.items }),
        onRehydrateStorage: () => (state) => {
          if (state) {
            // Recompute derived values after rehydration
            const computed = computeState({ items: state.items })
            Object.assign(state, computed)
          }
        }
      }
    ),
    { name: 'CartStore' }
  )
)