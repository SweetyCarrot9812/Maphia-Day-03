import { z } from 'zod';
import { EARSTemplate } from '@/domain/ears/types';

/**
 * Zod schema for conference room booking validation
 * @tag CONFERENCE-DOMAIN-001
 */
export const ConferenceRoomBookingRulesSchema = z.object({
  maxBookingDuration: z.number().min(15).max(240), // 15 min to 4 hours
  bookingLeadTime: z.number().min(0).max(90), // 0 to 90 days in advance
  simultaneousBookings: z.number().min(1).max(10)
});

/**
 * Conference Room Booking Domain with EARS integration
 * @tag CONFERENCE-DOMAIN-002
 */
export class ConferenceRoomBookingDomain {
  private bookingRules: z.infer<typeof ConferenceRoomBookingRulesSchema>;

  constructor(
    bookingRules: z.infer<typeof ConferenceRoomBookingRulesSchema> = {
      maxBookingDuration: 120,
      bookingLeadTime: 30,
      simultaneousBookings: 3
    }
  ) {
    this.bookingRules = ConferenceRoomBookingRulesSchema.parse(bookingRules);
  }

  /**
   * Validate an EARS template in the context of conference room booking
   *
   * @param template - EARS template to validate
   * @tag CONFERENCE-DOMAIN-003
   */
  validateEARSTemplate(template: EARSTemplate): boolean {
    const bookingKeywords = [
      'book', 'reserve', 'schedule', 'meeting',
      'conference', 'room', 'availability'
    ];

    // Check if template is related to conference room booking
    const isBookingRelated = bookingKeywords.some(keyword =>
      Object.values(template).some(value =>
        value.toLowerCase().includes(keyword)
      )
    );

    return isBookingRelated;
  }

  /**
   * Get domain-specific booking rules
   *
   * @returns Current booking rules
   * @tag CONFERENCE-DOMAIN-004
   */
  getBookingRules() {
    return { ...this.bookingRules };
  }
}