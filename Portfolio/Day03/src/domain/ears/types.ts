import { z } from 'zod';

/**
 * Zod schema for EARS template validation
 * @tag EARS-TYPES-001
 */
export const EARSTemplateSchema = z.object({
  event: z.string().min(5, { message: "Event must be descriptive" }),
  action: z.string().min(5, { message: "Action must be clear and actionable" }),
  response: z.string().min(5, { message: "Response must describe system behavior" }),
  state: z.string().optional()
});

/**
 * Type representing an EARS template
 * @tag EARS-TYPES-002
 */
export type EARSTemplate = z.infer<typeof EARSTemplateSchema>;

/**
 * Interface for EARS template processor
 * @tag EARS-TYPES-003
 */
export interface IEARSTemplateProcessor {
  validate(template: unknown): template is EARSTemplate;
  parse(template: EARSTemplate): EARSTemplate;
  validateLanguageClarity(template: EARSTemplate): void;
}

/**
 * Represents extracted business rules from an EARS template
 * @tag EARS-TYPES-004
 */
export interface BusinessRule {
  id: string;
  description: string;
  source: EARSTemplate;
}

/**
 * Represents traceable requirements
 * @tag EARS-TYPES-005
 */
export interface TraceableRequirements {
  requirements: string[];
  tags: string[];
  source: EARSTemplate;
}