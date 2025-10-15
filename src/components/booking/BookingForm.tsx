'use client';

import { useForm } from 'react-hook-form';
import { BookingFormData } from '@/types';
import {
  validateName,
  validatePhone,
  validateEmail,
  validateBirthdate,
} from '@/lib/utils/validation';

interface BookingFormProps {
  onSubmit: (data: BookingFormData) => Promise<void>;
  loading?: boolean;
}

export default function BookingForm({ onSubmit, loading = false }: BookingFormProps) {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<BookingFormData>();

  const handleFormSubmit = async (data: BookingFormData) => {
    await onSubmit(data);
  };

  return (
    <form onSubmit={handleSubmit(handleFormSubmit)} className="space-y-6">
      <div>
        <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-2">
          이름 <span className="text-red-500">*</span>
        </label>
        <input
          id="name"
          type="text"
          {...register('name', {
            required: '이름을 입력해주세요',
            validate: (value) => {
              const result = validateName(value);
              return result.valid || result.message || '유효하지 않은 이름입니다';
            },
          })}
          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          placeholder="홍길동"
          disabled={loading}
        />
        {errors.name && (
          <p className="mt-1 text-sm text-red-500">{errors.name.message}</p>
        )}
      </div>

      <div>
        <label htmlFor="phone" className="block text-sm font-medium text-gray-700 mb-2">
          전화번호 <span className="text-red-500">*</span>
        </label>
        <input
          id="phone"
          type="tel"
          {...register('phone', {
            required: '전화번호를 입력해주세요',
            validate: (value) => {
              const result = validatePhone(value);
              return result.valid || result.message || '유효하지 않은 전화번호입니다';
            },
          })}
          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          placeholder="010-1234-5678"
          disabled={loading}
        />
        {errors.phone && (
          <p className="mt-1 text-sm text-red-500">{errors.phone.message}</p>
        )}
      </div>

      <div>
        <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
          이메일 <span className="text-red-500">*</span>
        </label>
        <input
          id="email"
          type="email"
          {...register('email', {
            required: '이메일을 입력해주세요',
            validate: (value) => {
              const result = validateEmail(value);
              return result.valid || result.message || '유효하지 않은 이메일입니다';
            },
          })}
          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          placeholder="example@email.com"
          disabled={loading}
        />
        {errors.email && (
          <p className="mt-1 text-sm text-red-500">{errors.email.message}</p>
        )}
      </div>

      <div>
        <label htmlFor="birthdate" className="block text-sm font-medium text-gray-700 mb-2">
          생년월일 (선택)
        </label>
        <input
          id="birthdate"
          type="date"
          {...register('birthdate', {
            validate: (value) => {
              if (!value) return true;
              const result = validateBirthdate(value);
              return result.valid || result.message || '유효하지 않은 날짜입니다';
            },
          })}
          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          disabled={loading}
        />
        {errors.birthdate && (
          <p className="mt-1 text-sm text-red-500">{errors.birthdate.message}</p>
        )}
      </div>

      <button
        type="submit"
        disabled={loading}
        className="w-full bg-blue-600 text-white py-3 rounded-lg font-semibold hover:bg-blue-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {loading ? '예약 중...' : '예약하기'}
      </button>
    </form>
  );
}
