# Weekend Gateway

A community-driven travel itinerary sharing application with neo-brutalist design principles.

## Features

- **User Authentication**: Sign up, login, and password reset functionality
- **Itinerary Creation**: Create detailed travel itineraries with multiple days and activities
- **Itinerary Browsing**: Discover itineraries created by other users
- **Search & Filters**: Find itineraries by destination, duration, or rating
- **User Profiles**: View your created itineraries and personal information

## Design System

Weekend Gateway features a neo-brutalist design system with the following key principles:

- White backgrounds with black text
- Red/yellow accent colors
- Monospace typography
- Sharp corners with thick black borders
- Custom animations with abrupt transitions

## Tech Stack

- **Flutter**: UI framework
- **Supabase**: Backend as a Service
- **Provider**: State management
- **flutter_animate**: Animation library

## Getting Started

1. **Clone the repository**

```bash
git clone https://github.com/yourusername/weekend_gateway.git
cd weekend_gateway
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Setup environment variables**

Create a `.env` file in the root of the project with the following:

```
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

4. **Run the app**

```bash
flutter run
```

## Screenshots

(Screenshots will be added here)

## Folder Structure

```
lib/
├── config/            # Configuration files
├── core/              # Core utilities and helpers
├── data/              # Data layer with repositories and models
├── features/          # Feature-specific implementations
└── presentation/      # UI layer
    ├── commons/    # Reusable UI commons
    ├── screens/       # App screens
    └── theme/         # Theme configuration
```

## Contributing

1. Fork the repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
