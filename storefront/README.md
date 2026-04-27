# FreshKe — Flutter Storefront

Fresh produce delivery app for Kenya, powered by Medusa. Targets **Android**, **iOS**, and **Web** from a single codebase.

## Stack

| Layer | Choice |
|---|---|
| Framework | Flutter 3.x |
| State | Riverpod 2 |
| Navigation | GoRouter |
| HTTP | Dio |
| Backend | Medusa v2 Store API |

## Quick Start

### 1. Prerequisites

- Flutter 3.16+ (`flutter --version`)
- A running Medusa v2 backend

### 2. Configure environment

Set your backend URL at build time:

```bash
# Development
flutter run --dart-define=MEDUSA_URL=http://localhost:9000 \
            --dart-define=MEDUSA_PUBLISHABLE_KEY=pk_your_key

# Production
flutter build apk --dart-define=MEDUSA_URL=https://api.yourstore.ke \
                  --dart-define=MEDUSA_PUBLISHABLE_KEY=pk_your_key
```

### 3. Install & run

```bash
flutter pub get
flutter run          # pick device interactively
flutter run -d web   # web browser
flutter run -d android
flutter run -d ios
```

## Medusa Backend Setup

### Kenya Region

In your Medusa admin, create a region:

- **Name**: Kenya
- **Currency**: KES (Kenyan Shilling)
- **Countries**: Kenya (KE)
- **Tax rate**: 16% (standard VAT)

### Product Categories (recommended)

Create these in `/admin/categories`:

- Vegetables
- Fruits
- Dairy & Eggs
- Meat & Fish
- Bakery
- Beverages
- Grains & Pulses
- Herbs & Spices

### M-Pesa Payment Provider

Install a Medusa M-Pesa plugin (e.g. `medusa-payment-mpesa`) and configure with your Safaricom Daraja API credentials:

```ts
// medusa-config.ts
modules: {
  payment: {
    resolve: "@medusajs/payment",
    options: {
      providers: [
        {
          resolve: "medusa-payment-mpesa",
          id: "mpesa",
          options: {
            consumerKey: process.env.MPESA_CONSUMER_KEY,
            consumerSecret: process.env.MPESA_CONSUMER_SECRET,
            businessShortcode: process.env.MPESA_SHORTCODE,
            passkey: process.env.MPESA_PASSKEY,
            environment: "sandbox", // or "production"
            callbackUrl: "https://api.yourstore.ke/hooks/mpesa",
          },
        },
      ],
    },
  },
},
```

### Publishable API Key

In Medusa Admin → Settings → API Key Management, create a Publishable key and add your storefront domain to its allowed origins.

## App Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # Router + theme wiring
├── core/
│   ├── api/                     # Medusa API clients
│   │   ├── medusa_client.dart   # Dio base client + auth
│   │   ├── products_api.dart
│   │   ├── cart_api.dart
│   │   ├── auth_api.dart
│   │   └── orders_api.dart
│   ├── models/                  # Plain Dart models
│   │   ├── product.dart
│   │   ├── cart.dart
│   │   ├── order.dart
│   │   └── customer.dart
│   ├── providers/               # Riverpod providers
│   │   ├── app_providers.dart
│   │   ├── auth_provider.dart
│   │   ├── cart_provider.dart
│   │   ├── products_provider.dart
│   │   └── orders_provider.dart
│   └── theme/
│       └── app_theme.dart       # Green fresh-produce palette
├── features/
│   ├── splash/
│   ├── onboarding/              # 3-slide intro
│   ├── home/                    # Banner carousel + category grid + products
│   ├── products/                # Listing + detail
│   ├── cart/
│   ├── checkout/                # Address → M-Pesa → success
│   ├── orders/                  # List + detail with delivery timeline
│   ├── auth/                    # Login + register
│   └── profile/
└── shared/
    ├── widgets.dart             # Shared UI components
    └── scaffold_with_nav.dart   # Bottom nav shell
```

## Screens

| Screen | Route |
|---|---|
| Splash | `/splash` |
| Onboarding | `/onboarding` |
| Home | `/home` |
| Shop (all products) | `/products` |
| Product Detail | `/products/:id` |
| Cart | `/cart` |
| Checkout | `/checkout` |
| M-Pesa Payment | `/checkout/payment` |
| Order Success | `/checkout/success` |
| Orders | `/orders` |
| Order Detail | `/orders/:id` |
| Login | `/auth/login` |
| Register | `/auth/register` |
| Profile | `/profile` |

## Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release

# Web
flutter build web --release
```
