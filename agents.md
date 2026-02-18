AGENTS.md - Instructions for AI Coding Agents

CRITICAL CONSTRAINT: STRICTLY NO STATIC DATA. Do not use hardcoded lists, mock maps, or dummy model instances for any domain feature (Catalog, Cart, Auth, Profile). All UI data must be fetched dynamically from Supabase via Riverpod providers. If data is unavailable, the UI must show a proper Loading or Empty state, never fake content

Project Overview
This project prioritizes professional-grade engineering: Modularity, SOLID principles, and Loose Coupling.
Engineering Principles (MANDATORY)
Modularity & Encapsulation:
Structure the app by feature (e.g., /features/auth/, /features/billing/).
Encapsulate data and logic within modules. Expose only necessary interfaces via public APIs.
Loose Coupling: Minimize dependencies between modules. Use abstract interfaces for external services (like Payments) to ensure they can be swapped without side effects.
SOLID Compliance:
Single Responsibility: Each class or function must have one, and only one, reason to change.
Open/Closed: Code entities should be open for extension but closed for modification. Use inheritance or composition to add features.
Maintainability:
Write self-documenting code with clear, descriptive names.
Keep functions small and focused.
Regularly refactor complex logic to simplify it.
Coding Standards & Tools
Style Guide: Strictly follow effective_dart and flutter_lints.
Formatting: Code MUST be formatted via dart format on every save.
Linting: Always run flutter analyze before finalizing any code suggestions.
Security & Privacy
Secrets Management: NEVER hardcode API keys or sensitive strings. Use .env files and flutter_secure_storage.
Data Isolation: Ensure sensitive data is only accessible to the module that requires it (Encapsulation).
Debugging & Monitoring
Logging: Implement the logger package. Log all significant business logic events, payment states, and errors with appropriate severity levels.
Error Handling: Use robust try-catch blocks. Never "swallow" an exception; always log it and provide user-friendly feedback.
Collaboration & Git Flow
When generating code for features, assume a GitHub Flow environment.
Create code that is ready for a Pull Request review, prioritizing readability and appropriate unit tests.
