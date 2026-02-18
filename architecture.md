
ARCHITECTURE.md - System Blueprint
1. Architectural Pattern: Clean Architecture
This project follows a layered "Clean Architecture" approach to ensure Loose Coupling and Modularity.
The Layers:
Presentation Layer (UI): - Contains Flutter Widgets and State Management (Riverpod).
It only talks to the Domain Layer.
Theming: Inherits styles from the AppTheme defined in core/theme.
Domain Layer (Business Logic):
The "Brain" of the app. Contains Entities (data models) and Use Cases (logic like ProcessPayment or FetchMeterReading).
This layer is independent of any database or UI framework.
Data Layer (Infrastructure):
Implements the interfaces defined in the Domain layer.
Contains Repositories that fetch data from Supabase, M-Pesa APIs, or local storage (Hive).
2. Directory Structure
All agents must adhere to this folder structure to maintain Modular Code:
lib/
├── core/                  # Global utilities, themes, and security (Encapsulation)
│   ├── theme/             # Material 3 Color System & AppTheme
│   ├── network/           # Supabase & API clients
│   └── error/             # Failure & Exception classes
├── features/              # Modular feature folders
│   ├── auth/              # Feature-specific Clean Architecture
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── billing/
│   └── shop/
└── main.dart              # Entry point

3. Material 3 Theme Architecture
This project uses the Material 3 (M3) Color System to ensure accessibility and consistent "vibes."
Seed-Based Theming: Themes are generated using ColorScheme.fromSeed(seedColor: Color).
Dynamic Roles: Agents must use semantic color roles (e.g., theme.colorScheme.primary, onSurface, secondaryContainer) instead of hardcoded hex values.
Surface System: Use the M3 Surface Tint and Tone-based Surface roles for elevated elements rather than traditional shadows.
Dark Mode: Support is native. The theme engine must generate both light and dark color schemes from the same seed color.
4. Data Flow & State Management
Unidirectional Data Flow: UI triggers a Use Case -> Use Case calls a Repository -> Repository fetches data -> Data flows back to UI via a Stream or Future.
State Management: Use Riverpod Providers to inject dependencies. This ensures that modules remain independent and easily testable.
5. Integration Logic (M-Pesa & Supabase)
Database: Supabase is accessed via a SupabaseService class in the Data layer.
Payments: The M-Pesa integration must be abstracted.
Create a PaymentRepository interface in the Domain layer.
Create a MpesaRepositoryImpl in the Data layer.
Why? This follows the Open/Closed Principle, allowing for future payment methods without UI changes.
6. Security Architecture
Row Level Security (RLS): All data fetching must assume Supabase RLS is active.
Encryption Layer: Sensitive data (Meter IDs, User Tokens) must pass through a SecurityService using flutter_secure_storage for Encapsulation and safety.
7. Error Handling Strategy
Use a functional approach (e.g., Either<Failure, Success>) for Use Cases.
This forces agents to handle "Failure" cases (like low network connectivity) proactively.
