# EARS Requirements Methodology Guide

<!--
@DOC:EARS-GUIDE
@SPEC:EARS-001
@TEST:EARS-PROCESSOR-001
@TEST:EARS-GENERATOR-001
@CODE:EARS-PROCESSOR-001
@CODE:EARS-GENERATOR-001
-->

## Overview

The **EARS (Event-Action-Response-State)** methodology provides a structured approach to writing clear, testable requirements. This guide explains how to implement and use EARS in the Conference Room Booking System.

## EARS Structure

### Basic Template

```
When [Event], [Action], then [Response] [in State]
```

### Components

1. **Event**: The trigger or condition that initiates the requirement
2. **Action**: What the system or user does
3. **Response**: The expected outcome or system behavior
4. **State**: Optional context about the system state (when applicable)

## Implementation Components

### 1. EarsTemplateProcessor

Located: `src/domain/entities/EarsTemplateProcessor.ts`

**Purpose**: Parse and validate EARS template structure

```typescript
interface EarsTemplate {
  event: string;
  action: string;
  response: string;
  state?: string;
}
```

**Key Methods**:
- `parse(template)`: Validates and standardizes EARS input
- `generateRequirementStatement(template)`: Creates formatted requirement text

### 2. RequirementsGenerator

Located: `src/application/use-cases/RequirementsGenerator.ts`

**Purpose**: Convert EARS templates to acceptance criteria

**Key Methods**:
- `generateAcceptanceCriteria(template)`: Creates Given-When-Then format
- `generateRequirementTag(template)`: Creates unique @TAG identifiers

### 3. QualityMetrics

Located: `src/domain/value-objects/QualityMetrics.ts`

**Purpose**: Evaluate requirement quality

**Key Methods**:
- `calculateClarityScore(template)`: Returns 0-100 clarity score
- `isValidTemplate(template)`: Validates minimum quality standards

### 4. EarsExporter

Located: `src/infrastructure/ears/EarsExporter.ts`

**Purpose**: Export requirements to various formats

**Key Methods**:
- `exportToJson(template)`: Creates JSON representation
- Additional export formats (HTML, PDF) can be added

## Usage Examples

### Conference Room Booking Requirements

#### Example 1: Room Booking

```
Event: User selects available room and time slot
Action: User clicks 'Book Room' button
Response: System creates booking and sends confirmation
State: User is authenticated and has booking permissions
```

**Generated Acceptance Criteria**:
```
Given the system is in a valid state
When User selects available room and time slot
And User clicks 'Book Room' button
Then System creates booking and sends confirmation
And the system should be in User is authenticated and has booking permissions state
```

#### Example 2: Booking Conflict

```
Event: User attempts to book occupied time slot
Action: User submits booking form
Response: System displays conflict error and suggests alternatives
```

**Generated Acceptance Criteria**:
```
Given the system is in a valid state
When User attempts to book occupied time slot
And User submits booking form
Then System displays conflict error and suggests alternatives
```

#### Example 3: Admin Cancellation

```
Event: Admin views active booking
Action: Admin clicks 'Cancel Booking' button
Response: System cancels booking and notifies affected users
State: Admin has cancellation privileges
```

## Integration with Testing

### Test Structure

The EARS implementation includes comprehensive test suites:

- `src/__tests__/specs/ears/template-processor.test.ts`
- `src/__tests__/specs/ears/requirements-generator.test.ts`
- `src/__tests__/specs/ears/integration.test.ts`
- `src/__tests__/specs/ears/quality-gates.test.ts`

### Running Tests

```bash
npm test -- --testPathPattern="ears"
```

## Quality Standards

### Clarity Scoring

Requirements are scored based on:

1. **Event Clarity** (25 points): ≤10 words for clear trigger definition
2. **Action Specificity** (25 points): ≤15 words for precise action description
3. **Response Completeness** (25 points): ≤20 words for comprehensive outcome
4. **State Context** (25 points): Optional but adds clarity when provided

**Minimum Score**: 75/100 for acceptance

### Best Practices

#### DO:
- Use specific, measurable events
- Define clear actions with precise verbs
- Specify complete, verifiable responses
- Include state when it affects behavior
- Keep language simple and unambiguous

#### DON'T:
- Use vague terms like "appropriate" or "reasonable"
- Combine multiple events in one requirement
- Create overly complex nested conditions
- Assume implicit system knowledge
- Mix functional and non-functional requirements

## @TAG Traceability System

### Tag Format

```
@EARS-{event-slug}-{action-slug}
```

**Example**: `@EARS-user-selects-room-clicks-book`

### Traceability Chain

```
@SPEC:EARS-001 → @TEST:booking-flow → @CODE:booking-service → @DOC:api-guide
```

### Benefits

- **Forward Traceability**: Requirements → Tests → Code
- **Backward Traceability**: Code → Tests → Requirements
- **Impact Analysis**: Changes tracked across the entire system
- **Coverage Validation**: Ensures all requirements have corresponding tests

## Integration with Conference Room System

### Domain Integration

The EARS framework integrates with existing domain entities:

- **ConferenceRoom**: Room availability and booking rules
- **Booking**: Booking lifecycle and state management
- **PhoneNumber**: User validation and notification

### Repository Patterns

EARS templates can be persisted using the existing Supabase infrastructure:

```typescript
// Example repository usage
const earsRepository = new EarsTemplateRepository();
await earsRepository.save(processedTemplate);
```

### Real-time Updates

EARS requirements support real-time validation and updates through Supabase subscriptions.

## Advanced Features

### Template Caching

The system includes caching mechanisms for frequently used templates:

```typescript
// Automatic caching for performance
const processor = new EarsTemplateProcessor();
processor.enableCaching(true);
```

### Validation Schemas

Integration with Zod for type-safe validation:

```typescript
import { EarsTemplateSchema } from '../types/EarsTypes';

const validatedTemplate = EarsTemplateSchema.parse(userInput);
```

### Error Handling

Comprehensive error handling with domain-specific exceptions:

```typescript
try {
  const result = processor.parse(template);
} catch (error) {
  if (error instanceof InvalidEarsTemplateError) {
    // Handle validation errors
  }
}
```

## Development Workflow

### 1. Requirement Creation

1. Identify business requirement
2. Structure as EARS template
3. Validate quality score (≥75)
4. Generate acceptance criteria

### 2. Test Development

1. Create Given-When-Then test scenarios
2. Implement failing tests (RED phase)
3. Link tests with @TAG system

### 3. Implementation

1. Implement minimal solution (GREEN phase)
2. Refactor for quality (REFACTOR phase)
3. Ensure traceability chain completion

### 4. Documentation

1. Update requirement documentation
2. Generate export formats
3. Update traceability matrices

## Troubleshooting

### Common Issues

#### Template Validation Failures

**Problem**: Template rejected with low quality score
**Solution**: Review clarity scoring criteria and simplify language

#### Missing Traceability

**Problem**: @TAG links broken or missing
**Solution**: Ensure consistent tag generation and proper linking

#### Export Failures

**Problem**: Export to JSON/HTML fails
**Solution**: Validate template structure and quality threshold

### Debug Mode

Enable detailed logging for troubleshooting:

```typescript
const processor = new EarsTemplateProcessor({ debug: true });
```

## Future Enhancements

### Planned Features

1. **Template Versioning**: Track requirement evolution over time
2. **Collaborative Review**: Multi-stakeholder approval workflows
3. **AI Assistance**: Automated quality improvement suggestions
4. **Integration APIs**: REST endpoints for external tool integration
5. **Analytics Dashboard**: Requirement metrics and trends

### Contributing

To contribute to EARS framework development:

1. Review existing SPEC documentation in `.moai/specs/SPEC-EARS-001/`
2. Follow TDD practices for new features
3. Maintain comprehensive test coverage
4. Update documentation for all changes
5. Ensure backward compatibility

## Resources

- **SPEC Documentation**: `.moai/specs/SPEC-EARS-001/`
- **Test Suites**: `src/__tests__/specs/ears/`
- **Implementation Code**: `src/domain/entities/`, `src/application/use-cases/`
- **Usage Examples**: This guide and inline code comments

For questions or support, refer to the project's issue tracking system or review the comprehensive specifications in the project documentation.