import { format } from 'date-fns';
import { ko } from 'date-fns/locale';

export function formatDate(dateString: string): string {
  try {
    const date = new Date(dateString);
    return format(date, 'yyyy년 MM월 dd일 (EEE) HH:mm', { locale: ko });
  } catch {
    return dateString;
  }
}

export function formatCurrency(amount: number): string {
  return amount.toLocaleString('ko-KR') + '원';
}

export function formatPhone(phone: string): string {
  const cleaned = phone.replace(/\D/g, '');
  if (cleaned.length === 11) {
    return `${cleaned.slice(0, 3)}-${cleaned.slice(3, 7)}-${cleaned.slice(7)}`;
  }
  return phone;
}
