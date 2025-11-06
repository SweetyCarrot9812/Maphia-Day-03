import { RequirementsGenerator } from '@/lib/specs/ears/requirements-generator';
import { ConferenceRoomBookingDomain } from '@/domain/conference-room/conference-room-domain';

describe('Requirements Generation', () => {
  let generator: RequirementsGenerator;
  let conferenceDomain: ConferenceRoomBookingDomain;

  beforeEach(() => {
    conferenceDomain = new ConferenceRoomBookingDomain();
    generator = new RequirementsGenerator(conferenceDomain);
  });

  describe('Business Rule Extraction', () => {
    it('should extract concrete business rules from EARS template', () => {
      const earsTemplate = {
        event: 'User logs in to book conference room',
        action: 'Validate user credentials and room availability',
        response: 'Grant access or show authentication error',
        state: 'Booking authentication process'
      };

      const rules = generator.extractBusinessRules(earsTemplate);

      expect(rules).toHaveLength(2);
      expect(rules[0]).toHaveProperty('description', expect.stringContaining('Credential validation'));
      expect(rules[1]).toHaveProperty('description', expect.stringContaining('Access control'));
    });
  });

  describe('Acceptance Criteria Generation', () => {
    it('should generate precise acceptance criteria from EARS template', () => {
      const earsTemplate = {
        event: 'Administrator updates conference room configuration',
        action: 'Validate configuration parameters',
        response: 'Apply changes or reject with specific error messages',
        state: 'Room configuration management'
      };

      const acceptanceCriteria = generator.generateAcceptanceCriteria(earsTemplate);

      expect(acceptanceCriteria).toEqual([
        'Scenario: Administrator updates conference room configuration',
        'Given: A valid conference room booking context',
        'When: Validate configuration parameters',
        'Then: Apply changes or reject with specific error messages'
      ]);
    });
  });

  describe('Traceability Linking', () => {
    it('should create traceable links between EARS template and generated requirements', () => {
      const earsTemplate = {
        event: 'System detects conference room booking conflict',
        action: 'Log and notify conflicting booking details',
        response: 'Trigger conflict resolution workflow',
        state: 'Booking conflict detection'
      };

      const traceableRequirements = generator.generateTraceableRequirements(earsTemplate);

      expect(traceableRequirements).toHaveProperty('requirements');
      expect(traceableRequirements).toHaveProperty('tags');
      expect(traceableRequirements.tags).toHaveLength(2);
      expect(traceableRequirements.tags[1]).toBe('@SPEC-EARS');
    });
  });
});