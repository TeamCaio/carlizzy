# Muse - AI Virtual Try-On App

AI-powered virtual try-on app for clothes. Users can upload a photo of themselves and try on different garments virtually using AI. Features community sharing, affiliate shopping, and manual face blur for privacy.

## Tech Stack

- **Framework**: Flutter (Dart SDK >=3.0.0)
- **State Management**: flutter_bloc
- **Dependency Injection**: get_it
- **Backend**: Supabase (auth, database, storage)
- **AI Provider**: FitRoom API for virtual try-on
- **HTTP Client**: Dio

## Architecture

Clean Architecture with feature-based organization:

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # App widget and routing
├── injection_container.dart  # DI setup (get_it)
├── core/
│   ├── ai_providers/         # FitRoom AI integration
│   ├── constants/            # API constants, themes
│   ├── errors/               # Exceptions and failures
│   ├── network/              # Network connectivity
│   └── services/             # Supabase, credits, saved outfits
└── features/
    ├── auth/                 # Authentication, subscriptions
    ├── browse/               # Browse clothes
    ├── home/                 # Home screen
    ├── settings/             # App settings
    ├── virtual_tryon/        # Core try-on feature (BLoC pattern)
    └── wardrobe/             # User's wardrobe
```

## Key Files

- `lib/injection_container.dart` - All dependency registration
- `lib/core/ai_providers/fitroom_provider.dart` - FitRoom API integration
- `lib/core/services/supabase_service.dart` - Supabase client setup
- `lib/features/virtual_tryon/presentation/bloc/tryon_bloc.dart` - Main try-on logic
- `supabase_schema.sql` - Database schema

## Development

```bash
# Run on iOS simulator
./run-simulator.sh

# Run on physical iPhone
./run-iphone.sh

# General run
./run.sh

# Or standard Flutter commands
flutter pub get
flutter run
```

## Authentication

- Apple Sign In
- Google Sign In
- Managed via Supabase Auth

## Credits System

Users have credits for try-on operations, managed by `CreditsService`.
