import { EARSTemplateProcessor } from '@/lib/specs/ears/template-processor';
import { ConferenceRoomBookingDomain } from '@/domain/conference-room/conference-room-domain';

describe('EARS Template Processing', () => {
  let processor: EARSTemplateProcessor;
  let conferenceDomain: ConferenceRoomBookingDomain;

  beforeEach(() => {
    conferenceDomain = new ConferenceRoomBookingDomain();
    processor = new EARSTemplateProcessor();
  });

  describe('Template Structure Validation', () => {
    it('should validate complete EARS template', () => {
      const completeTemplate = {
        event: 'User attempts to book conference room',
        action: 'Validate room availability and user credentials',
        response: 'Show booking confirmation or error message',
        state: 'Booking process initiated'
      };

      expect(processor.validate(completeTemplate)).toBe(true);
    });

    it('should reject templates with invalid structure', () => {
      const incompleteTemplate = {
        event: 'User logs in',
        action: 'Validate credentials'
        // missing response and state
      };

      expect(() => processor.validate(incompleteTemplate)).toThrow('Invalid EARS template structure');
    });
  });

  describe('Parsing and Caching', () => {
    it('should cache and retrieve parsed templates', () => {
      const template = {
        event: 'Conference room booking request',
        action: 'Check room availability',
        response: 'Confirm or deny booking',
        state: 'Booking validation'
      };

      const parsedTemplate = processor.parse(template);
      const cachedTemplate = processor.getCachedTemplate(template);

      expect(parsedTemplate).toEqual(template);
      expect(cachedTemplate).toEqual(template);
    });
  });

  describe('Language Clarity Validation', () => {
    it('should reject ambiguous language', () => {
      const ambiguousTemplate = {
        event: 'Something happens with conference room',
        action: 'Do some stuff with booking',
        response: 'Something occurs',
        state: 'Some booking state'
      };

      expect(() => processor.validateLanguageClarity(ambiguousTemplate)).toThrow('Ambiguous language detected');
    });
  });
});