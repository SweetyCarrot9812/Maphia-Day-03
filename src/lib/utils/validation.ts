export function validateName(name: string): { valid: boolean; message?: string } {
  if (!name || name.length < 2) {
    return { valid: false, message: '이름은 최소 2자 이상이어야 합니다' };
  }
  if (name.length > 20) {
    return { valid: false, message: '이름은 최대 20자까지 입력 가능합니다' };
  }
  const nameRegex = /^[가-힣a-zA-Z\s]+$/;
  if (!nameRegex.test(name)) {
    return { valid: false, message: '이름은 한글 또는 영문만 입력 가능합니다' };
  }
  return { valid: true };
}

export function validatePhone(phone: string): { valid: boolean; message?: string } {
  const phoneRegex = /^010-\d{4}-\d{4}$/;
  if (!phoneRegex.test(phone)) {
    return { valid: false, message: '010-XXXX-XXXX 형식으로 입력해주세요' };
  }
  return { valid: true };
}

export function validateEmail(email: string): { valid: boolean; message?: string } {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return { valid: false, message: '올바른 이메일 형식이 아닙니다' };
  }
  return { valid: true };
}

export function validateBirthdate(birthdate: string): { valid: boolean; message?: string } {
  const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
  if (!dateRegex.test(birthdate)) {
    return { valid: false, message: 'YYYY-MM-DD 형식으로 입력해주세요' };
  }
  const date = new Date(birthdate);
  if (date > new Date()) {
    return { valid: false, message: '미래 날짜는 입력할 수 없습니다' };
  }
  return { valid: true };
}
