// @TAG:CART-STORE-001 - RED Phase Tests
import { describe, test, expect, beforeEach } from 'vitest'
import { useCartStore } from './cartStore'
import { Product } from '@/shared/types/product'

const mockProduct1: Product = {
  id: 'product-1',
  name: 'Test Product 1',
  price: 10000,
  image: '/test-image-1.jpg',
  category: 'test'
}

const mockProduct2: Product = {
  id: 'product-2',
  name: 'Test Product 2',
  price: 30000,
  image: '/test-image-2.jpg',
  category: 'test'
}

describe('CartStore', () => {
  beforeEach(() => {
    // Reset store state before each test
    useCartStore.getState().clearCart()
  })

  describe('addItem', () => {
    test('should add new product with quantity 1 and selected true', () => {
      useCartStore.getState().addItem(mockProduct1)

      const items = useCartStore.getState().items
      expect(items).toHaveLength(1)
      expect(items[0]?.product.id).toBe('product-1')
      expect(items[0]?.quantity).toBe(1)
      expect(items[0]?.selected).toBe(true)
    })

    test('should increment quantity if product already exists', () => {
      useCartStore.getState().addItem(mockProduct1)
      useCartStore.getState().addItem(mockProduct1)

      const items = useCartStore.getState().items
      expect(items).toHaveLength(1)
      expect(items[0]?.quantity).toBe(2)
    })
  })

  describe('updateQuantity', () => {
    test('should update existing item quantity', () => {
      useCartStore.getState().addItem(mockProduct1)
      useCartStore.getState().updateQuantity('product-1', 5)

      const item = useCartStore.getState().items.find(item => item.product.id === 'product-1')
      expect(item?.quantity).toBe(5)
    })

    test('should remove item when quantity is 0', () => {
      useCartStore.getState().addItem(mockProduct1)
      useCartStore.getState().updateQuantity('product-1', 0)

      expect(useCartStore.getState().items).toHaveLength(0)
    })

    test('should throw error for invalid quantity (< 0 or > 99)', () => {
      useCartStore.getState().addItem(mockProduct1)

      const store = useCartStore.getState()
      expect(() => store.updateQuantity('product-1', -1)).toThrow('Invalid quantity: -1. Must be between 1-99.')
      expect(() => store.updateQuantity('product-1', 100)).toThrow('Invalid quantity: 100. Must be between 1-99.')
    })
  })

  describe('toggleSelect', () => {
    test('should toggle individual item selection', () => {
      useCartStore.getState().addItem(mockProduct1)
      expect(useCartStore.getState().items[0]?.selected).toBe(true)

      useCartStore.getState().toggleSelect('product-1')
      expect(useCartStore.getState().items[0]?.selected).toBe(false)

      useCartStore.getState().toggleSelect('product-1')
      expect(useCartStore.getState().items[0]?.selected).toBe(true)
    })
  })

  describe('selectAll', () => {
    test('should update all items selection state', () => {
      useCartStore.getState().addItem(mockProduct1)
      useCartStore.getState().addItem(mockProduct2)

      useCartStore.getState().selectAll(false)
      expect(useCartStore.getState().items.every(item => !item.selected)).toBe(true)

      useCartStore.getState().selectAll(true)
      expect(useCartStore.getState().items.every(item => item.selected)).toBe(true)
    })
  })

  describe('computed values', () => {
    test('selectedItems should return only selected items', () => {
      useCartStore.getState().addItem(mockProduct1)
      useCartStore.getState().addItem(mockProduct2)
      useCartStore.getState().toggleSelect('product-1') // unselect first item

      const selectedItems = useCartStore.getState().selectedItems
      expect(selectedItems).toHaveLength(1)
      expect(selectedItems[0]?.product.id).toBe('product-2')
    })

    test('subtotal should calculate sum of selected items', () => {
      useCartStore.getState().addItem(mockProduct1) // 10000
      useCartStore.getState().addItem(mockProduct2) // 30000
      useCartStore.getState().updateQuantity('product-1', 2) // 20000

      expect(useCartStore.getState().subtotal).toBe(50000) // 20000 + 30000
    })

    test('shippingFee should return 3000 if subtotal < 50000, else 0', () => {
      useCartStore.getState().addItem(mockProduct1) // 10000
      expect(useCartStore.getState().shippingFee).toBe(3000)

      useCartStore.getState().updateQuantity('product-1', 5) // 50000
      expect(useCartStore.getState().shippingFee).toBe(0)
    })

    test('total should return subtotal + shippingFee', () => {
      useCartStore.getState().addItem(mockProduct1) // 10000
      expect(useCartStore.getState().total).toBe(13000) // 10000 + 3000

      useCartStore.getState().updateQuantity('product-1', 5) // 50000
      expect(useCartStore.getState().total).toBe(50000) // 50000 + 0
    })
  })
})