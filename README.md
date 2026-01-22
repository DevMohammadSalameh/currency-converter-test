# Currency Converter

A Flutter currency converter application built with Clean Architecture and BLoC pattern. Features real-time currency conversion, currency listing with country flags, offline caching, and Material Design 3 theming.

## Table of Contents

- [Features](#features)
- [Build Instructions](#build-instructions)
- [Architecture](#architecture)
- [Image Loading Library](#image-loading-library)
- [Database](#database)
- [Tech Stack](#tech-stack)
- [API](#api)
- [Testing](#testing)

---

## Features

- **Currency Listing**: Browse all available currencies with country flags and search functionality
- **Real-time Conversion**: Convert between currencies with exchange rates
- **Historical Data**: View exchange rate trends with interactive charts
- **Offline Support**: SQLite caching for offline access
- **Material Design 3**: Modern UI with light/dark theme support

---

## Build Instructions

### Prerequisites

- **Flutter SDK**: 3.10.0 or higher
- **Dart SDK**: 3.10.0 or higher
- **Android Studio** or **VS Code** with Flutter extensions
- **Xcode** (for iOS builds on macOS)

### Step-by-Step Build Guide

#### 1. Clone and Setup

```bash
# Clone the repository
git clone <repository-url>
cd currency_converter

# Install dependencies
flutter pub get
```

#### 2. Generate Required Files

The project uses code generation for dependency injection and mocks:

```bash
# Generate injectable config and mock files
dart run build_runner build --delete-conflicting-outputs
```

#### 3. Run the Application

```bash
# Run in debug mode
flutter run

# Run on specific device
flutter devices                    # List available devices
flutter run -d <device-id>         # Run on specific device
```

#### 4. Build for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires macOS with Xcode)
flutter build ios --release

# Web
flutter build web --release
```

#### 5. Verify Build

```bash
# Run static analysis
flutter analyze

# Run all tests
flutter test
```

---

## Architecture

### Design Pattern: Clean Architecture + BLoC

This project implements **Clean Architecture** combined with the **BLoC (Business Logic Component)** pattern for state management.

#### Why Clean Architecture?

I used this architecture because the challenge required it. Otherwise I would have used **MVVM** or **MVC** for a project of this scale. Here are the benefits of using **Clean Architecture**:

| Benefit | Description |
|---------|-------------|
| **Separation of Concerns** | Each layer has a single responsibility, making the codebase easier to understand and maintain |
| **Testability** | Business logic is isolated from UI and external dependencies, enabling comprehensive unit testing |
| **Scalability** | New features can be added without affecting existing code; each feature is self-contained |
| **Framework Independence** | Core business logic doesn't depend on Flutter or any external framework |
| **Dependency Rule** | Dependencies point inward—outer layers depend on inner layers, never the reverse |

#### Why BLoC Pattern?

I used this pattern because it's the overall best suited state management pattern for Flutter apps. Although I would have used Cubit for a project of this scale.

| Benefit | Description |
|---------|-------------|
| **Predictable State** | Unidirectional data flow makes state changes predictable and debuggable |
| **Separation of UI and Logic** | UI components remain pure and focused on presentation |
| **Reactive Programming** | Built on Streams, providing reactive updates to the UI |
| **Testing** | BLoC logic can be tested independently using `bloc_test` package |
| **Flutter Ecosystem** | First-class support with `flutter_bloc` and strong community adoption |

#### Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│  ┌─────────┐  ┌─────────┐  ┌─────────────────────────────┐  │
│  │  Views  │──│ Widgets │──│  BLoC (Events → States)     │  │
│  └─────────┘  └─────────┘  └─────────────────────────────┘  │
└────────────────────────────────┬────────────────────────────┘
                                 │
┌────────────────────────────────▼────────────────────────────┐
│                      DOMAIN LAYER                           │
│  ┌──────────┐  ┌────────────────────┐  ┌─────────────────┐  │
│  │ Entities │  │Repository Contracts│  │    Use Cases    │  │
│  └──────────┘  └────────────────────┘  └─────────────────┘  │
└────────────────────────────────┬────────────────────────────┘
                                 │
┌────────────────────────────────▼────────────────────────────┐
│                       DATA LAYER                            │
│  ┌────────┐  ┌─────────────────┐  ┌───────────────────────┐ │
│  │ Models │  │  Data Sources   │  │ Repository Impls      │ │
│  │        │  │ (Remote/Local)  │  │                       │ │
│  └────────┘  └─────────────────┘  └───────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

#### Project Structure

```
lib/
├── core/                              # Shared utilities
│   ├── constants/                     # Database constants
│   ├── database/                      # SQLite database helper
│   ├── di/                            # Dependency injection modules
│   ├── enums/                         # Shared enumerations
│   ├── error/                         # Failures and exceptions
│   ├── network/                       # Network info and endpoints
│   ├── storage/                       # App preferences
│   └── usecases/                      # Base use case contract
├── features/
│   ├── converter/                     # Currency conversion feature
│   │   ├── data/
│   │   │   ├── datasources/           # Remote (API) and Local (SQLite)
│   │   │   ├── models/                # Data models with serialization
│   │   │   └── repositories/          # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/              # Business entities
│   │   │   ├── repositories/          # Repository contracts
│   │   │   └── usecases/              # GetCurrencies, ConvertCurrency
│   │   └── presentation/
│   │       ├── bloc/                  # CurrenciesConverterBloc
│   │       ├── view/                  # Screen widgets
│   │       └── widgets/               # Reusable UI components
│   └── history/                       # Historical rates feature
│       ├── data/
│       ├── domain/
│       └── presentation/
├── injection_container.dart           # DI configuration
├── injection_container.config.dart    # Generated DI config
└── main.dart                          # App entry point
```

#### Dependency Injection

The project uses **injectable** with **get_it** for dependency injection:

- **Why injectable?** Reduces boilerplate with annotation-based registration
- **Why get_it?** Simple, fast service locator with compile-time safety
- Annotations used: `@injectable`, `@lazySingleton`, `@LazySingleton(as: Interface)`, `@module`

---

## Image Loading Library

### Library: cached_network_image

This project uses **[cached_network_image](https://pub.dev/packages/cached_network_image)** for loading and displaying country flag images.

#### Why cached_network_image?

| Reason | Description |
|--------|-------------|
| **Automatic Caching** | Images are cached to disk automatically, reducing network requests and improving performance |
| **Memory Efficiency** | Intelligent memory management prevents OOM errors when displaying many images |
| **Placeholder Support** | Built-in support for loading placeholders and error widgets |
| **Fade Animation** | Smooth fade-in animation when images load |
| **Cache Control** | Configurable cache duration and size limits |
| **Flutter Ecosystem** | 5000+ likes on pub.dev, actively maintained, widely adopted |

#### Alternatives Considered

| Library | Why Not Chosen |
|---------|----------------|
| `Image.network` | No caching, no placeholder support, poor performance with many images |
| `extended_image` | More complex API, overkill for simple flag images |
| `fast_cached_network_image` | Less mature, smaller community |
| `octo_image` | Lower-level API, requires more boilerplate |

#### Usage in Project

Flag images are loaded from FlagCDN:

```dart
CachedNetworkImage(
  imageUrl: Endpoints.getFlagUrl(currency.countryCode),
  width: 32,
  height: 24,
  fit: BoxFit.cover,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.flag),
)
```

---

## Database

### Library: sqflite

This project uses **[sqflite](https://pub.dev/packages/sqflite)** for local data persistence and offline caching.

#### Why sqflite?

| Reason | Description |
|--------|-------------|
| **Native SQLite Access** | Direct access to SQLite database with no abstraction overhead, providing optimal performance |
| **Offline-First Support** | Enables full CRUD operations without network connectivity, essential for the caching requirement |
| **Structured Queries** | Full SQL support allows complex queries, joins, and indexing for efficient data retrieval |
| **Lightweight** | Minimal footprint compared to ORMs, suitable for mobile applications |
| **Flutter Favorite** | Official Flutter favorite package with excellent documentation and community support |
| **Platform Support** | Works on iOS, Android, and macOS with consistent API |

#### Alternatives Considered

| Library | Why Not Chosen |
|---------|----------------|
| `hive` | NoSQL approach less suitable for relational currency data with rates |
| `drift` (moor) | Adds complexity with code generation; overkill for simple caching needs |
| `isar` | Newer library with smaller community; sqflite is more battle-tested |
| `shared_preferences` | Only suitable for simple key-value pairs, not structured data |
| `objectbox` | Proprietary elements and larger package size |

#### Usage in Project

The database stores currencies and exchange rates for offline access:

```dart
// Cache currencies after API fetch
await localDataSource.cacheCurrencies(currencies);

// Retrieve cached data when offline
final cachedCurrencies = await localDataSource.getCachedCurrencies();
```

---

## Tech Stack

| Category | Technology | Version |
|----------|------------|---------|
| **Framework** | Flutter | 3.10.0+ |
| **State Management** | flutter_bloc | ^8.1.6 |
| **Dependency Injection** | injectable + get_it | ^2.5.0 / ^8.0.3 |
| **HTTP Client** | dio | ^5.7.0 |
| **Database** | sqflite | ^2.4.1 |
| **Image Loading** | cached_network_image | ^3.4.1 |
| **SVG Support** | flutter_svg | ^2.2.3 |
| **Charts** | fl_chart | ^0.69.2 |
| **Functional Programming** | dartz | ^2.0.7 |
| **Network Connectivity** | internet_connection_checker | ^3.0.1 |
| **Local Storage** | shared_preferences | ^2.2.2 |

### Dev Dependencies

| Category | Technology |
|----------|------------|
| **Testing** | flutter_test, mockito, bloc_test |
| **Code Generation** | build_runner, injectable_generator |
| **Linting** | flutter_lints |

---

## API

This app uses the [ExchangeRate-API](https://www.exchangerate-api.com/):

- **Exchange Rates**: `GET /v6/{API_KEY}/latest/{BASE_CURRENCY}`

Country flags are loaded from [FlagCDN](https://flagcdn.com/):

- **Flag Images**: `https://flagcdn.com/{country_code}.svg`
- **Country Codes**: `https://flagcdn.com/en/codes.json`

---

## Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/converter/domain/usecases/convert_currency_test.dart
```

### Generate Mocks

```bash
# Generate mock files (required before running tests)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for continuous generation
dart run build_runner watch --delete-conflicting-outputs
```

### Test Coverage

The project includes tests for:
- **Use Cases**: Business logic validation
- **BLoC**: State management and event handling
- **Models**: JSON/Database serialization

---

## Database Schema

```sql
-- Currencies table
CREATE TABLE currencies (
  id TEXT PRIMARY KEY,          -- Currency code (USD, EUR)
  name TEXT NOT NULL,           -- Full name
  symbol TEXT,                  -- Currency symbol
  country_code TEXT,            -- ISO country code
  rate REAL NOT NULL            -- Exchange rate
);

-- Exchange rates table (conversion caching)
CREATE TABLE exchange_rates (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  from_currency TEXT NOT NULL,
  to_currency TEXT NOT NULL,
  rate REAL NOT NULL,
  date TEXT NOT NULL,
  UNIQUE(from_currency, to_currency, date)
);
```

---
