import { EARSTemplateSchema, EARSTemplate, IEARSTemplateProcessor } from '@/domain/ears/types';
import { ZodError } from 'zod';

/**
 * Processor for EARS (Event-Action-Response-State) templates
 * Provides validation, parsing, and language clarity checks
 *
 * @tag EARS-PROCESSOR-001
 */
export class EARSTemplateProcessor implements IEARSTemplateProcessor {
  private cache: Map<string, EARSTemplate> = new Map();

  /**
   * Validate an EARS template using Zod schema
   *
   * @param template - The template to validate
   * @returns Boolean indicating template validity
   * @throws {Error} If template is invalid
   *
   * @tag EARS-PROCESSOR-002
   */
  validate(template: unknown): template is EARSTemplate {
    try {
      const validatedTemplate = EARSTemplateSchema.parse(template);
      this.cacheTemplate(validatedTemplate);
      return true;
    } catch (error) {
      if (error instanceof ZodError) {
        const firstError = error.errors[0];
        throw new Error(`Invalid template: ${firstError.message}`);
      }
      throw new Error('Invalid EARS template structure');
    }
  }

  /**
   * Parse a validated EARS template
   *
   * @param template - The EARS template to parse
   * @returns Parsed template
   *
   * @tag EARS-PROCESSOR-003
   */
  parse(template: EARSTemplate): EARSTemplate {
    this.validate(template);
    return { ...template };
  }

  /**
   * Validate language clarity in the template
   * Checks for ambiguous or vague language
   *
   * @param template - The EARS template to check
   * @throws {Error} If language is ambiguous
   *
   * @tag EARS-PROCESSOR-004
   */
  validateLanguageClarity(template: EARSTemplate): void {
    const ambiguousKeywords = ['something', 'stuff', 'things', 'do'];

    Object.entries(template).forEach(([key, value]) => {
      if (ambiguousKeywords.some(keyword => value.toLowerCase().includes(keyword))) {
        throw new Error(`Ambiguous language detected in ${key}: ${value}`);
      }
    });
  }

  /**
   * Cache processed templates for performance optimization
   *
   * @param template - The template to cache
   *
   * @tag EARS-PROCESSOR-005
   */
  private cacheTemplate(template: EARSTemplate): void {
    const cacheKey = JSON.stringify(template);
    if (!this.cache.has(cacheKey)) {
      this.cache.set(cacheKey, template);
    }
  }

  /**
   * Get a cached template
   *
   * @param template - The template to retrieve from cache
   * @returns Cached template or undefined
   *
   * @tag EARS-PROCESSOR-006
   */
  getCachedTemplate(template: EARSTemplate): EARSTemplate | undefined {
    const cacheKey = JSON.stringify(template);
    return this.cache.get(cacheKey);
  }
}