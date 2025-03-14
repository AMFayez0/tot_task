# Shopping Cart Application

## Project Overview

This is a Flutter shopping cart application built using Clean Architecture principles and Riverpod for state management. The application allows users to browse products, add them to a cart, apply coupons, and manage their shopping experience.

## Architecture

The project follows Clean Architecture principles, separating the codebase into three main layers:

### Domain Layer

The domain layer contains the core business logic and rules of the application. It is independent of any external frameworks or implementations.

- **Entities**: Core business objects (Product, CartItem, User, Coupon)
- **Repositories**: Abstract interfaces defining data operations
- **Use Cases**: Business logic operations (AddProductToCart, RemoveProductFromCart, etc.)

### Data Layer

The data layer implements the repository interfaces defined in the domain layer and handles data sources.

- **Data Sources**: Local database service using SQLite (via sqflite)
- **Repository Implementations**: Concrete implementations of domain repositories
- **Data Initializer**: Handles initial data setup for the application

### Presentation Layer

The presentation layer handles UI components and state management.

- **Pages**: UI screens (HomePage, CartPage)
- **Widgets**: Reusable UI components (ProductCard)
- **Providers**: State management using Riverpod
- **DI**: Dependency injection setup

## Key Features

### Product Browsing

Users can browse a grid of products on the home page. Each product is displayed with its image, name, and price. The product data is fetched from a local SQLite database.

### Cart Management

Users can:
- Add products to their cart
- View their cart items
- Update item quantities
- Remove items from the cart
- Clear the entire cart

### Coupon System

The application includes a coupon system that allows users to apply discount coupons to their cart. The total price is automatically recalculated when a coupon is applied.

## State Management

The application uses Riverpod for state management, which provides several benefits:

- **Providers**: Declarative state management with dependency tracking
- **Family Providers**: Parameterized providers for user-specific data
- **Future Providers**: Handling asynchronous data loading
- **State Notifiers**: Managing complex state with reducers

## Dependency Injection

Dependency injection is implemented using Riverpod's provider overrides. The `DISetup` widget wraps the application and overrides the repository providers with their concrete implementations.

```dart
class DISetup extends StatelessWidget {
  final Widget child;

  const DISetup({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        // Override the repository providers with the implementations
        productRepositoryProvider.overrideWithProvider(di.productRepositoryProvider),
        userRepositoryProvider.overrideWithProvider(di.userRepositoryProvider),
        cartRepositoryProvider.overrideWithProvider(di.cartRepositoryProvider),
        couponRepositoryProvider.overrideWithProvider(di.couponRepositoryProvider),
      ],
      child: child,
    );
  }
}
```

## Data Persistence

The application uses SQLite (via the sqflite package) for local data storage. The `LocalDBService` class handles database operations, including:

- Database initialization
- CRUD operations for entities
- Transaction management

## Getting Started

### Prerequisites

- Flutter SDK (version ^3.7.0)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

### Dependencies

- **flutter_riverpod**: State management
- **sqflite**: SQLite database
- **path**: File system path operations
- **path_provider**: Access to file system locations

## Project Structure

```
lib/
  ├── data/                  # Data layer
  │   ├── data_sources/      # Data sources (local database)
  │   └── repositories/      # Repository implementations
  ├── domain/                # Domain layer
  │   ├── entities/          # Business entities
  │   ├── repositories/      # Repository interfaces
  │   └── usecases/          # Business logic
  ├── presentation/          # Presentation layer
  │   ├── di/                # Dependency injection
  │   ├── pages/             # UI screens
  │   ├── providers/         # State management
  │   └── widgets/           # Reusable UI components
  ├── di_setup.dart          # DI setup for the app
  └── main.dart              # Application entry point
```

## Development Approach

The development approach for this project focused on:

1. **Separation of Concerns**: Clear separation between business logic, data handling, and UI
2. **Testability**: Architecture designed to facilitate unit testing
3. **Maintainability**: Clean code organization for easier maintenance and extension
4. **Scalability**: Structure that allows for easy addition of new features

## Future Improvements

- User authentication and profile management
- Product categories and filtering
- Order processing and history
- Payment integration
- Remote data synchronization
- Unit and widget tests
