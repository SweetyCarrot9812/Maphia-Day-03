# Conference Room Booking System

A modern, responsive conference room booking system built with Next.js 14, TypeScript, and Supabase.

## Features

- **Real-time Availability**: Check room availability in real-time
- **Smart Booking**: Intuitive booking process with conflict detection
- **Admin Dashboard**: Comprehensive admin panel for room and booking management
- **Mobile Responsive**: Optimized for all device sizes
- **Type-Safe**: Full TypeScript implementation with domain-driven design
- **Real-time Updates**: Live updates using Supabase real-time features
- **EARS Requirements Framework**: Event-Action-Response-State methodology for clear, testable requirements

## Tech Stack

- **Frontend**: Next.js 14 with App Router, TypeScript, Tailwind CSS
- **Backend**: Supabase (PostgreSQL + Real-time + Auth)
- **State Management**: Zustand + TanStack Query
- **Architecture**: Simple Layered + DDD Lite
- **Deployment**: Vercel

## Quick Start

### Prerequisites

- Node.js 18.0.0 or higher
- npm or yarn
- Supabase account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd conference-room-booking
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Environment Setup**
   ```bash
   cp .env.local.example .env.local
   ```

   Update `.env.local` with your Supabase credentials:
   ```env
   NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Database Setup**

   Run the SQL migration in your Supabase SQL Editor:
   ```sql
   -- Execute the contents of src/infrastructure/database/migrations/001_initial_schema.sql
   ```

5. **Start Development Server**
   ```bash
   npm run dev
   ```

   Visit [http://localhost:3000](http://localhost:3000)

## Project Structure

```
src/
├── app/                        # Next.js 14 App Router
│   ├── layout.tsx             # Root layout
│   ├── page.tsx               # Home page
│   └── globals.css            # Global styles
│
├── domain/                     # Domain Layer (DDD)
│   ├── entities/              # Domain entities
│   │   ├── ConferenceRoom.ts  # Conference room business logic
│   │   ├── Booking.ts         # Booking business logic
│   │   └── EarsTemplateProcessor.ts # EARS template processing
│   ├── value-objects/         # Value objects
│   │   ├── PhoneNumber.ts     # Phone number validation
│   │   └── QualityMetrics.ts  # EARS quality scoring
│   └── types/                 # Domain types
│       └── common.ts          # Shared types
│
├── application/               # Application Layer
│   ├── use-cases/            # Use case implementations
│   │   └── RequirementsGenerator.ts # EARS requirements generation
│   └── services/             # Application services
│
├── infrastructure/           # Infrastructure Layer
│   ├── database/            # Database implementations
│   │   ├── supabase.ts      # Supabase client config
│   │   ├── migrations/      # SQL migrations
│   │   └── repositories/    # Repository implementations
│   ├── ears/                # EARS framework integration
│   │   └── EarsExporter.ts  # Export functionality
│   └── lib/                 # External libraries
│
└── presentation/            # Presentation Layer
    ├── components/          # React components
    ├── stores/             # Zustand stores
    │   ├── uiStore.ts      # UI state management
    │   ├── bookingStore.ts # Booking flow state
    │   └── adminStore.ts   # Admin state
    ├── hooks/              # Custom hooks
    │   ├── useConferenceRooms.ts # Room data hooks
    │   └── useBookings.ts  # Booking data hooks
    └── providers/          # React providers
        └── QueryProvider.tsx # TanStack Query setup
```

## Development

### Scripts

```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run start        # Start production server
npm run lint         # Run ESLint
npm run type-check   # TypeScript type checking
npm run test         # Run tests
npm run test:coverage # Run tests with coverage
```

### Database Migrations

SQL migrations are located in `src/infrastructure/database/migrations/`.

To apply migrations:
1. Copy the SQL content
2. Run in Supabase SQL Editor
3. Verify the tables are created correctly

### State Management

The application uses a hybrid state management approach:

- **Server State**: TanStack Query for API data, caching, and synchronization
- **Client State**: Zustand stores for UI, booking flow, and admin state
- **Persistence**: Selected state persisted to localStorage via Zustand middleware

### API Integration

All API interactions go through the repository pattern:
- Domain entities encapsulate business logic
- Repositories handle data persistence
- React Query hooks provide caching and synchronization
- Real-time updates via Supabase subscriptions

## Architecture

### Domain-Driven Design (DDD Lite)

The project follows DDD principles:

- **Entities**: `ConferenceRoom`, `Booking` with business logic
- **Value Objects**: `PhoneNumber` with validation
- **Repositories**: Data access abstraction
- **Use Cases**: Application-specific business rules

### Layered Architecture

- **Presentation**: React components, stores, hooks
- **Application**: Use cases and application services
- **Domain**: Business entities and rules
- **Infrastructure**: Database, external services

### EARS Requirements Methodology

The project implements the **EARS (Event-Action-Response-State)** methodology for requirements specification:

#### Core Components

- **Event**: Trigger condition for the requirement
- **Action**: System behavior or user action
- **Response**: Expected system response
- **State**: Optional system state context

#### Example EARS Requirement

```
When [user selects room and time slot],
and [clicks book button],
then [system validates availability and creates booking],
in [authenticated user state]
```

#### EARS Implementation

- **Template Processor**: Parses and validates EARS format
- **Requirements Generator**: Creates Given-When-Then acceptance criteria
- **Quality Metrics**: Scoring system for requirement clarity
- **Traceability**: Links requirements to tests and code via @TAG system

#### Benefits

- **Clarity**: Structured format reduces ambiguity
- **Testability**: Direct mapping to test scenarios
- **Traceability**: Complete requirement lifecycle tracking
- **Validation**: Automated quality scoring and validation

#### Usage in Booking System

The EARS framework is applied to conference room booking requirements:

- Room availability checking
- Booking conflict detection
- User authentication flows
- Admin management operations

See `.moai/specs/SPEC-EARS-001/` for detailed EARS specification and examples.

## Admin Features

### Default Admin Account

- **Username**: `admin`
- **Password**: `admin123`

⚠️ **Change the default password immediately in production!**

### Admin Capabilities

- View all bookings
- Manage conference rooms
- Cancel bookings
- View utilization statistics
- System settings

## Deployment

### Vercel Deployment

1. **Connect to Vercel**
   ```bash
   npx vercel
   ```

2. **Environment Variables**

   Set in Vercel dashboard:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`

3. **Deploy**
   ```bash
   npx vercel --prod
   ```

### Database Setup for Production

1. Create production Supabase project
2. Run migrations in production SQL Editor
3. Update environment variables
4. Configure Row Level Security policies

## Business Rules

### Booking Constraints

- **Duration**: 30 minutes to 8 hours
- **Advance Booking**: No past bookings allowed
- **Conflicts**: Automatic conflict detection
- **Phone Validation**: Korean mobile (010-XXXX-XXXX) or international format

### Room Management

- **Capacity**: 1-100 people
- **Amenities**: Configurable list
- **Status**: Active/Inactive rooms

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check the documentation in the `docs/` directory
- Review the comprehensive specifications in the project documentation