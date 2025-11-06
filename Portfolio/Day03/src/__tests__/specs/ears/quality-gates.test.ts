import { QualityGateManager } from '@/lib/specs/ears/quality-gate-manager';

describe('EARS Specification Quality Gates', () => {
  let qualityGateManager: QualityGateManager;

  beforeEach(() => {
    qualityGateManager = new QualityGateManager();
  });

  describe('Clarity Scoring Algorithm', () => {
    it('should calculate clarity score for EARS template', () => {
      const clearTemplate = {
        event: 'User attempts to log in',
        action: 'Validate user credentials against database',
        response: 'Grant access to authenticated users or show specific error message',
        state: 'User authentication workflow'
      };

      const ambiguousTemplate = {
        event: 'Something happens',
        action: 'Do something',
        response: 'Something occurs',
        state: 'Some state'
      };

      const clearTemplateScore = qualityGateManager.calculateClarityScore(clearTemplate);
      const ambiguousTemplateScore = qualityGateManager.calculateClarityScore(ambiguousTemplate);

      expect(clearTemplateScore).toBeGreaterThan(0.7);
      expect(ambiguousTemplateScore).toBeLessThan(0.5);
    });
  });

  describe('Completeness Validation', () => {
    it('should validate specification completeness', () => {
      const incompleteSpec = {
        event: 'User interaction',
        action: null,  // Deliberately missing
        response: 'Generic response',
        state: 'Undefined'
      };

      const completeSpec = {
        event: 'User requests password reset',
        action: 'Send verification email with reset link',
        response: 'Display confirmation message and send email',
        state: 'Password recovery workflow'
      };

      const incompleteValidation = qualityGateManager.validateCompleteness(incompleteSpec);
      const completeValidation = qualityGateManager.validateCompleteness(completeSpec);

      expect(incompleteValidation.isComplete).toBeFalsy();
      expect(completeValidation.isComplete).toBeTruthy();
    });
  });

  describe('Review Workflow Management', () => {
    it('should manage specification review lifecycle', () => {
      const specification = {
        event: 'System requires performance optimization',
        action: 'Analyze and identify bottlenecks',
        response: 'Generate performance improvement recommendations',
        state: 'Performance monitoring and optimization'
      };

      const reviewWorkflow = qualityGateManager.initiateReviewWorkflow(specification);

      expect(reviewWorkflow).toEqual(
        expect.objectContaining({
          status: 'draft',
          reviewStages: expect.arrayContaining([
            'initial_review',
            'stakeholder_validation',
            'final_approval'
          ])
        })
      );
    });
  });
});