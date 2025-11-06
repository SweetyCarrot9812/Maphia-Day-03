import { EARSIntegrationManager } from '@/lib/specs/ears/integration-manager';
import { SpecBuilderAgent } from '@/lib/agents/spec-builder';
import { TAGSystem } from '@/lib/tags/tag-system';

describe('EARS Integration Points', () => {
  let integrationManager: EARSIntegrationManager;
  let specBuilder: SpecBuilderAgent;
  let tagSystem: TAGSystem;

  beforeEach(() => {
    tagSystem = new TAGSystem();
    specBuilder = new SpecBuilderAgent(tagSystem);
    integrationManager = new EARSIntegrationManager(specBuilder, tagSystem);
  });

  describe('@TAG System Integration', () => {
    it('should generate unique TAG for each EARS specification', () => {
      const earsTemplate = {
        event: 'User initiates system configuration',
        action: 'Validate configuration inputs',
        response: 'Apply changes or show validation errors',
        state: 'System configuration management'
      };

      const generatedTag = integrationManager.generateSpecificationTAG(earsTemplate);

      expect(generatedTag).toMatch(/^@SPEC-EARS-\d{3}$/);
      expect(tagSystem.registerTAG(generatedTag)).toBeTruthy();
    });
  });

  describe('Spec Builder Agent Integration', () => {
    it('should seamlessly process EARS templates through spec builder', () => {
      const earsTemplate = {
        event: 'System detects performance anomaly',
        action: 'Collect and analyze performance metrics',
        response: 'Generate performance optimization recommendation',
        state: 'Performance monitoring workflow'
      };

      const specificationResult = specBuilder.processEARSTemplate(earsTemplate);

      expect(specificationResult).toHaveProperty('specification');
      expect(specificationResult).toHaveProperty('status', 'draft');
    });
  });

  describe('Export Functionality', () => {
    it('should export EARS specification in multiple formats', () => {
      const earsTemplate = {
        event: 'Administrator manages user access',
        action: 'Validate and modify user roles',
        response: 'Update access control lists',
        state: 'User authorization management'
      };

      const exportFormats = ['json', 'markdown', 'pdf'];

      exportFormats.forEach(format => {
        const exportedSpec = integrationManager.exportSpecification(earsTemplate, format);
        expect(exportedSpec).toBeTruthy();
      });
    });
  });
});