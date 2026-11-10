# Keepr

Discover local shops and products near you.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Account screen copy

The account screen fetches its copy values from Firebase Remote Config. The
parameter names are the copy identifiers from `_defaultCopy` in
`lib/screens/account/account_screen.dart`. Add only the strings you want to
customize; unspecified parameters keep their built-in English defaults.

For example, create Remote Config parameters named `sign_in_title`,
`send_code`, `resend_countdown`, or `terms` to customize those strings. The
`resend_countdown` value should include `{seconds}` so the timer can insert the
remaining time. Publish the Remote Config template after editing it.

Changes are fetched on app startup; production clients use a one-hour minimum
fetch interval. The screen keeps its built-in copy if Remote Config is
unavailable.

## Live products, favourites, and nearby map

Product screens read published listings from the Firestore `products`
collection. Accounts with the Firebase custom claim `role: seller` can open
**Manage my products** from the account screen to add, edit, publish, or
unpublish listings. Other signed-in users have shopper access. Product photos
are uploaded to Firebase Storage. Favourites are stored under
`users/{userId}/favorites/{productId}` and are private to that account.
Published listings and their product images are publicly readable.

The seller role check in the Flutter app only controls the user interface.
Firestore and Storage security rules must also require an approved seller role
before accepting product or image writes; client-side checks are not a security
boundary. Seller application submission is not connected because no application
endpoint has been provided.

The Flutter package and displayed app name are now Keepr. Android and Apple
bundle identifiers remain `com.example.lumo` to match the currently configured
Firebase apps; register the final Keepr identifiers in Firebase before changing
those platform IDs. Replace the default Flutter launcher icons after the final
Keepr logo asset is supplied.

Enable Cloud Firestore and Firebase Storage in the `keepr-co` Firebase project,
then deploy the included ownership and publication rules:

```powershell
firebase deploy --project keepr-co --only firestore:rules,storage
```

Listings are not seeded with demonstration data. Sellers must sign in, create a
listing, and publish it before it appears in product search or the nearby map.
Map pins are shown only for listings with both shop latitude and longitude.

### Google Maps API key

Enable the Maps SDK for Android, Maps SDK for iOS, and Maps JavaScript API in
Google Cloud. Create a key restricted to this app/platform and API set.

- **Android:** set `MAPS_API_KEY=your-key` in
  `%USERPROFILE%\.gradle\gradle.properties`. The Android manifest reads this
  Gradle property; no key is checked into the repository.
- **iOS:** add a user-defined `MAPS_API_KEY` build setting to the Runner target
  in Xcode. `Info.plist` passes it to Google Maps at launch.
- **Web:** replace `YOUR_GOOGLE_MAPS_API_KEY` in `web/index.html` with a
  website-restricted key, or inject it during deployment. Restrict it to the
  deployed domain.

The app requests location permission when it needs GPS. If permission is
denied, the map remains usable but cannot show the user's location or compute
distances. Location is not reverse-geocoded; the header shows coordinates.
# Keepr
