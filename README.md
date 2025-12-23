# Virtual Wardrobe - AI-Powered Virtual Try-On App

A Flutter mobile application that allows users to virtually try on clothes using AI. Users can upload a selfie and describe the clothes they want to try on using natural language prompts.

## Features

- 📸 Photo selection from camera or gallery
- 🎨 AI-powered garment generation from text descriptions
- 👕 Virtual try-on using state-of-the-art AI models
- 📱 Cross-platform support (iOS & Android)
- 🎯 Multiple clothing categories (tops, bottoms, dresses)

## Architecture

This app follows **Clean Architecture** principles with **BLoC** pattern for state management:

```
lib/
├── core/                      # Core utilities and constants
│   ├── constants/            # API and theme constants
│   ├── errors/               # Error handling
│   ├── network/              # Network connectivity
│   └── utils/                # Image utilities
├── features/virtual_tryon/   # Main feature
│   ├── data/                 # Data layer
│   │   ├── datasources/     # API and local data sources
│   │   ├── models/          # Data models
│   │   └── repositories/    # Repository implementations
│   ├── domain/              # Business logic layer
│   │   ├── entities/        # Domain entities
│   │   ├── repositories/    # Repository interfaces
│   │   └── usecases/        # Use cases
│   └── presentation/        # UI layer
│       ├── bloc/            # State management
│       ├── screens/         # UI screens
│       └── widgets/         # Reusable widgets
└── injection_container.dart  # Dependency injection
```

## AI Pipeline

The app uses a two-stage AI pipeline powered by Replicate:

1. **FLUX Schnell** (Text-to-Image)
   - Generates garment images from text descriptions
   - Processing time: ~2-5 seconds
   - Cost: ~$0.003 per generation

2. **IDM-VTON** (Virtual Try-On)
   - Applies generated garment to user's photo
   - Processing time: ~28 seconds
   - Cost: ~$0.023 per try-on

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Xcode (for iOS development)
- Android Studio (for Android development)
- Replicate API account and token

## Setup Instructions

### 1. Clone and Install Dependencies

```bash
cd wardrobe
flutter pub get
```

### 2. Configure Replicate API Token

Open `lib/injection_container.dart` and replace the placeholder with your Replicate API token:

```dart
const String replicateApiToken = 'YOUR_REPLICATE_API_TOKEN_HERE';
```

To get your API token:
1. Sign up at [Replicate](https://replicate.com)
2. Go to [Account Settings](https://replicate.com/account/api-tokens)
3. Create a new API token

### 3. Platform-Specific Setup

#### iOS

No additional setup required. Permissions are already configured in `Info.plist`.

#### Android

Make sure you have the minimum SDK version set. Open `android/app/build.gradle` and ensure:

```gradle
minSdkVersion 21
```

### 4. Run the App

```bash
# For iOS
flutter run -d ios

# For Android
flutter run -d android

# For a specific device
flutter devices
flutter run -d <device-id>
```

## Usage

1. **Launch the app** and tap "Get Started"
2. **Select a photo** from your gallery or take a new one with the camera
3. **Describe the clothing** you want to try on (e.g., "red leather jacket")
4. **Select the category** (Top, Bottom, or Dress)
5. **Wait for processing** (approximately 30 seconds)
6. **View your result** and optionally try different outfits

### Tips for Best Results

- Use photos with good lighting
- Ensure clear, unobstructed view of your body
- Prefer neutral backgrounds
- Use front-facing pose
- Full body or upper body shots work best

## Project Structure Details

### Key Files

- **`lib/injection_container.dart`** - Dependency injection setup
- **`lib/app.dart`** - Main app widget with theme configuration
- **`lib/main.dart`** - App entry point
- **`lib/features/virtual_tryon/data/datasources/replicate_remote_datasource.dart`** - Replicate API integration
- **`lib/features/virtual_tryon/presentation/bloc/tryon_bloc.dart`** - State management
- **`lib/core/constants/api_constants.dart`** - API configuration

### Dependencies

Key packages used in this project:

- `flutter_bloc` - State management
- `get_it` - Dependency injection
- `dio` - HTTP client for API calls
- `image_picker` - Photo selection
- `cached_network_image` - Image caching
- `connectivity_plus` - Network connectivity checking
- `flutter_spinkit` - Loading animations
- `dartz` - Functional programming (Either type)

## Cost Estimation

Each virtual try-on costs approximately **$0.026**:
- Garment generation: $0.003
- Virtual try-on: $0.023

**Example monthly costs:**
- 10 try-ons/day = ~$7.80/month
- 50 try-ons/day = ~$39/month
- 100 try-ons/day = ~$78/month

## Troubleshooting

### Common Issues

**Issue: "No internet connection" error**
- Check your network connectivity
- Ensure the device has internet access

**Issue: API authentication failed**
- Verify your Replicate API token is correct
- Check that the token hasn't expired

**Issue: Image processing takes too long**
- This is normal - virtual try-on can take up to 30 seconds
- Ensure stable internet connection

**Issue: Poor try-on results**
- Use higher quality photos
- Ensure good lighting and clear view
- Try different photo angles

### Debug Mode

To enable debug logging, check the console for detailed error messages when running the app in debug mode.

## Future Enhancements

- [ ] Garment library to save and reuse generated clothes
- [ ] Try-on history with cloud sync
- [ ] Social sharing features
- [ ] Multiple garments in one session
- [ ] Custom garment upload (skip text generation)
- [ ] AR preview integration
- [ ] Style recommendations
- [ ] Shopping integration

## Development

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

### Format Code

```bash
flutter format .
```

## Resources

- [Replicate API Documentation](https://replicate.com/docs)
- [FLUX Schnell Model](https://replicate.com/black-forest-labs/flux-schnell)
- [IDM-VTON Model](https://replicate.com/cuuupid/idm-vton)
- [Flutter Documentation](https://docs.flutter.dev)
- [Flutter BLoC Package](https://pub.dev/packages/flutter_bloc)

## License

This project is for educational and demonstration purposes.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues and questions, please open an issue in the GitHub repository.
