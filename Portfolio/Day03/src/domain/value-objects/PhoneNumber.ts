/**
 * @SPEC:VO-001 Phone Number Value Object
 * Validates and manages phone number data
 */
export class PhoneNumber {
  private readonly value: string;

  constructor(phoneNumber: string) {
    if (!this.isValid(phoneNumber)) {
      throw new Error('Invalid phone number format');
    }
    this.value = this.normalize(phoneNumber);
  }

  private isValid(phoneNumber: string): boolean {
    // Korean phone number validation (010-XXXX-XXXX or international format)
    const koreanMobileRegex = /^010-\d{4}-\d{4}$/;
    const internationalRegex = /^\+\d{1,3}-\d{1,14}$/;

    return koreanMobileRegex.test(phoneNumber) || internationalRegex.test(phoneNumber);
  }

  private normalize(phoneNumber: string): string {
    return phoneNumber.trim();
  }

  getValue(): string {
    return this.value;
  }

  toString(): string {
    return this.value;
  }

  equals(other: PhoneNumber): boolean {
    return this.value === other.value;
  }
}