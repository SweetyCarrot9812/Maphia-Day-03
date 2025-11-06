import { v4 as uuidv4 } from 'uuid';
import {
  EARSTemplate,
  BusinessRule,
  TraceableRequirements
} from '@/domain/ears/types';
import {
  ConferenceRoomBookingDomain
} from '@/domain/conference-room/conference-room-domain';

/**
 * Generates requirements from EARS templates with integration to conference room booking domain
 *
 * @tag EARS-GENERATOR-001
 */
export class RequirementsGenerator {
  private domain: ConferenceRoomBookingDomain;

  constructor(domain: ConferenceRoomBookingDomain) {
    this.domain = domain;
  }

  /**
   * Extract business rules from an EARS template
   *
   * @param template - EARS template to extract rules from
   * @returns Array of extracted business rules
   *
   * @tag EARS-GENERATOR-002
   */
  extractBusinessRules(template: EARSTemplate): BusinessRule[] {
    const rules: BusinessRule[] = [];

    // Context-aware rule extraction based on event and action
    if (template.event.includes('book') || template.event.includes('reservation')) {
      rules.push({
        id: uuidv4(),
        description: `Credential validation for booking: ${template.action}`,
        source: template
      });
    }

    if (template.action.includes('validate') || template.action.includes('check')) {
      rules.push({
        id: uuidv4(),
        description: `Access control rule: ${template.action}`,
        source: template
      });
    }

    return rules;
  }

  /**
   * Generate acceptance criteria from EARS template
   *
   * @param template - EARS template to generate criteria from
   * @returns Array of acceptance criteria
   *
   * @tag EARS-GENERATOR-003
   */
  generateAcceptanceCriteria(template: EARSTemplate): string[] {
    return [
      `Scenario: ${template.event}`,
      `Given: A valid conference room booking context`,
      `When: ${template.action}`,
      `Then: ${template.response}`
    ];
  }

  /**
   * Generate traceable requirements with unique tags
   *
   * @param template - EARS template to generate requirements from
   * @returns Traceable requirements object
   *
   * @tag EARS-GENERATOR-004
   */
  generateTraceableRequirements(template: EARSTemplate): TraceableRequirements {
    const baseTag = 'SPEC-EARS';
    const uniqueTag = `${baseTag}-${Math.random().toString(36).substr(2, 9).toUpperCase()}`;

    return {
      requirements: this.generateAcceptanceCriteria(template),
      tags: [uniqueTag, `@${baseTag}`],
      source: template
    };
  }
}