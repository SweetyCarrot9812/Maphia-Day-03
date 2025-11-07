import React from 'react'

const CartPage: React.FC = () => {
  return (
    <div className="container mx-auto px-4 py-8">
      <header className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">
          Portfolio Shopping Cart
        </h1>
        <p className="text-gray-600">
          React 18 + TypeScript + Zustand + Tailwind CSS
        </p>
      </header>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2">
          <div className="card">
            <h2 className="text-xl font-semibold mb-4">상품 목록</h2>
            <p className="text-gray-500">상품 목록이 여기에 표시됩니다.</p>
          </div>
        </div>

        <div className="lg:col-span-1">
          <div className="card">
            <h2 className="text-xl font-semibold mb-4">주문 요약</h2>
            <p className="text-gray-500">주문 요약이 여기에 표시됩니다.</p>
          </div>
        </div>
      </div>
    </div>
  )
}

export default CartPage