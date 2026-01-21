# Currency Converter

A Flutter currency converter application built with Clean Architecture and BLoC pattern. Features real-time currency conversion, currency listing with country flags, and historical exchange rate visualization.

## Features

- **Currency Listing**: Browse all available currencies with country flags and search functionality
- **Real-time Conversion**: Convert between currencies with live exchange rates
- **Historical Data**: View exchange rate trends with interactive charts
- **Offline Support**: Cached data available when offline
- **Material Design 3**: Modern UI with light/dark theme support

## Architecture

This project follows Clean Architecture principles with the BLoC pattern for state management:

```
lib/
├── core/                          # Shared utilities
│   ├── constants/                 # API and database constants
│   ├── database/                  # Database helper
│   ├── error/                     # Failures and exceptions
│   ├── network/                   # Network connectivity
│   └── usecases/                  # Base use case
├── features/
│   ├── currencies/                # Currency listing feature
│   │   ├── data/                  # Data sources, models, repository impl
│   │   ├── domain/                # Entities, repository contracts, use cases
│   │   └── presentation/          # BLoC, views, widgets
│   ├── converter/                 # Currency conversion feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── history/                   # Historical data feature
│       ├── data/
│       ├── domain/
│       └── presentation/
├── injection_container.dart       # Dependency injection
└── main.dart                      # App entry point
```

## Tech Stack

| Category | Technology |
|----------|------------|
| State Management | flutter_bloc |
| Dependency Injection | get_it |
| HTTP Client | dio |
| Database | sqflite |
| Image Loading | cached_network_image |
| Charts | fl_chart |
| Functional Programming | dartz |

## Getting Started

### Prerequisites

- Flutter SDK 3.10.0 or higher
- Dart SDK 3.10.0 or higher

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd currency_converter
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate mock files for testing:
```bash
dart run build_runner build
```

4. Run the app:
```bash
flutter run
```

## Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Generate mocks (required before running tests)
dart run build_runner build --delete-conflicting-outputs
```

## API

This app uses the [Currency Converter API](https://free.currencyconverterapi.com/):

- **Currencies List**: `GET /currencies`
- **Convert**: `GET /convert?q=USD_EUR&compact=ultra`
- **Historical**: `GET /convert?q=USD_EUR&date=2024-01-01&endDate=2024-01-07`

Country flags are loaded from [FlagCDN](https://flagcdn.com/).

## Database Schema

```sql
-- Currencies table
CREATE TABLE currencies (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  symbol TEXT,
  country_code TEXT
);

-- Exchange rates table (for caching)
CREATE TABLE exchange_rates (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  from_currency TEXT NOT NULL,
  to_currency TEXT NOT NULL,
  rate REAL NOT NULL,
  date TEXT NOT NULL,
  UNIQUE(from_currency, to_currency, date)
);
```

## Project Structure Details

### Core Layer
- **Failures**: `ServerFailure`, `CacheFailure`, `NetworkFailure`, `ConversionFailure`
- **Exceptions**: `ServerException`, `CacheException`, `NetworkException`
- **NetworkInfo**: Checks internet connectivity using `internet_connection_checker`

### Feature Layers

Each feature follows the same structure:

**Data Layer**:
- Models (with JSON/Database serialization)
- Remote Data Source (API calls)
- Local Data Source (SQLite operations)
- Repository Implementation

**Domain Layer**:
- Entities (business objects)
- Repository Contracts (abstract classes)
- Use Cases (single responsibility)

**Presentation Layer**:
- BLoC (events, states, bloc)
- Views (UI screens)
- Widgets (reusable components)

## License

This project is licensed under the MIT License.
