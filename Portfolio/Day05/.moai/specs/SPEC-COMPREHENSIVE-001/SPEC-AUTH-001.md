# SPEC-AUTH-001: User Registration & Role Selection

## Objective
Design a flexible user registration system that supports multiple user roles with granular permission management.

## Key Requirements
1. Support registration via email/social login
2. Role selection during registration
3. Role-based access control
4. Profile completion workflow

## User Roles
- Student
- Instructor
- Admin
- Guest

## Registration Flow
1. Capture basic information
2. Role selection
3. Optional profile completion
4. Email verification

## Security Considerations
- Secure password hashing
- Multi-factor authentication
- Role-based permission inheritance

## Technical Constraints
- Use Firebase Authentication
- Implement role mapping in Firestore
- Support SSO (Single Sign-On)