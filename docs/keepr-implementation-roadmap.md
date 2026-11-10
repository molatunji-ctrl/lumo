# Keepr Implementation Roadmap

This roadmap prioritizes the supplied Keepr requirements around the core
shopper journey: find a real product, identify the physical shop that has it,
and plan a visit. It assumes Keepr already has a backend. Frontend work should
integrate with that backend through documented contracts; it should not create
a replacement backend or silently treat Firebase as the source of truth where
the backend owns the data.

## Current baseline

- Firebase Authentication is integrated in the account screen.
- User-facing app, splash, platform display, and Flutter package branding now
  use Keepr. Native Android/Apple bundle IDs remain unchanged to preserve the
  existing Firebase registrations; the launcher icon still needs the final
  Keepr logo asset.
- Published product discovery and seller product editing currently use
  Firestore directly.
- The account screen and seller product screen now check the Firebase custom
  claim `role: seller` before showing seller actions; product service writes
  also check the claim. This is a frontend guard and must be backed by server
  or Firestore/Storage security rules.
- Seller-application submission remains blocked on a backend endpoint and
  approval workflow; shoppers currently see that seller tools require approval.
- Product documents include shop name and location fields, but there is no
  separate shop registration or multi-shop management flow.
- Shop and market discovery still includes mock data.
- An admin dashboard route exists and checks the `role=admin` Firebase custom
  claim, but its seller, activity, and product sections are placeholders.
- No seller application, admin data, shop management, or activity API contract
  has been supplied yet.

## P0 — Foundation for a trustworthy MVP

### 1. Confirm product and access contracts

**Dependencies:** Backend owner supplies API documentation and staging access.

- Document the existing backend's authentication method, API base URLs, error
  format, pagination convention, and environment setup.
- Confirm which system owns users, seller approval, shops, products, locations,
  and listing availability.
- Define account roles: shopper, seller, administrator. Seller and admin
  privileges must be granted by trusted backend code, never by client-selected
  signup fields.
- Choose whether the frontend will use Firebase ID tokens with the backend,
  Firebase custom claims, or another established auth integration.
- Define contracts for seller applications, seller administration, shops,
  products, and activity before connecting screens.

**Exit criteria:** Each client-facing feature has an agreed request/response
shape and authorization rule. The app can obtain credentials accepted by the
backend without putting privileged credentials in the client.

### 2. Establish Keepr branding and UI foundations

**Dependencies:** Final Keepr logo/assets, approved name, and brand guidance.

- Finish removing old names from external configuration such as Firebase
  Remote Config templates and platform package IDs after their Firebase
  registrations are migrated.
- Replace the default launcher icon after the final Keepr logo asset is
  provided.
- Standardize theme colors, typography, spacing, card treatment, buttons, and
  responsive breakpoints.
- Improve loading, empty, and error states; use skeletons where data contracts
  support predictable layouts.
- Keep liquid-glass effects selective and maintain accessible contrast and
  performance.

**Exit criteria:** No unintended legacy branding remains in user-facing app
surfaces; light and dark modes remain readable; launcher icons use approved
Keepr assets.

### 3. Enforce role-aware seller and admin access

**Dependencies:** Agreed role contract and backend/Firestore security changes.

- Make shopper the default account experience.
- Show seller application and seller tools only for the appropriate approval
  state.
- Gate seller product and shop-management screens on the approved seller role.
- Gate admin routes and controls on the administrator role.
- Enforce these permissions at the backend and data-rule layer as well as in
  the UI. A hidden button or client-side claim check alone is not authorization.
- Ensure changes to roles or approval state take effect predictably after token
  refresh or sign-in.

**Exit criteria:** A shopper cannot create, edit, publish, or delete seller
listings by navigating directly to a route or calling the data service. An
approved seller can manage only their own resources. Non-admins cannot retrieve
admin data.

### 4. Complete real shop and seller onboarding

**Dependencies:** Seller application and shop API contracts; approval workflow.

- Build seller application, business profile, verification progress, and
  approval/rejection states.
- Build shop registration and editing using the backend's shop schema.
- Support multiple shops/branches per seller; products should refer to a stable
  shop ID rather than relying only on copied shop name/location text.
- Capture physical address, city/state/LGA, market or district, contact details,
  operating hours, and coordinates as allowed by the contract.
- Provide map selection and manual location entry so GPS permission is not
  mandatory.

**Exit criteria:** An approved seller can register multiple real shops and
select the appropriate shop while creating a listing. Shoppers never see
fictional or unverified shop data presented as real.

### 5. Finish live product discovery and listing management

**Dependencies:** Product/shop API contract and role enforcement.

- Replace direct Firestore product access with the agreed backend integration
  where the backend is the source of truth.
- Support product creation, editing, publish/unpublish, availability, category,
  brand, condition, variations, and multiple images according to API capability.
- Associate products with shop IDs and display honest price, availability, and
  last-confirmed information.
- Add search, filtering, sorting, pagination, and refresh against real listings.
- Retain explicit loading, empty, and actionable error states; do not silently
  substitute mock products for failed live requests.

**Exit criteria:** Shopper home, search, product detail, and nearby views show
the same live published data. Product and shop ownership rules are enforced by
the backend.

### 6. Deliver usable seller and admin operations

**Dependencies:** Seller/shop/product APIs, admin API, and audit/event contract.

- Expand the seller screen into an overview with shops, product counts,
  published/draft/unavailable listings, recent activity, and listing
  moderation status.
- Expand the admin dashboard with seller search/filter, seller profiles and
  status, seller activity, products grouped by seller, shop review, and
  moderation actions.
- Add pagination for administrative lists and confirmation for destructive or
  privilege-changing actions.
- Record admin decisions and sensitive changes in backend audit history.
- Keep unavailable sections visibly disconnected until their endpoint exists;
  never use sample records as platform totals.

**Exit criteria:** Admins can find a seller, inspect that seller's shops and
products, review recent product/shop changes, and perform only backend-approved
actions. The backend records who performed each administrative action.

## P1 — Improve trust, communication, and retention

### 7. Improve discovery and location

- Replace mock shops and markets with live backend data.
- Add manual location search, map/list switching, distance, open-now filters,
  and nearby shop sorting.
- Add recent searches, suggestions, debouncing, typo handling, and search
  pagination where supported.
- Add refresh, skeleton loading, and empty/error states across discovery.
- Avoid unsupported claims such as verified, open, in-stock, rating, or
  distance unless those values come from reliable data.

### 8. Add shopper-seller communication

- Prioritize call, WhatsApp, copy contact details, directions, and share shop or
  product.
- Add in-app and push notifications only after notification preferences and
  event contracts are defined.
- Add seller notifications for application decisions and listing moderation.

### 9. Add reviews and reports

- Add shop reviews and ratings with backend rules for duplicates, edits, and
  moderation.
- Let shoppers report incorrect location, price, availability, fake shops, or
  inappropriate listings.
- Add report status and an admin resolution workflow with audit history.

### 10. Expand saved items and profile

- Add favourite shops, markets, and locations alongside product favourites.
- Add profile photo and contact/profile editing, preferred locations, account
  deletion, and sign-out confirmation.
- Handle removed or suspended resources in saved lists.

## Cross-cutting engineering work

Do this incrementally alongside feature slices rather than blocking the MVP on
a large rewrite:

- Introduce repositories and centralized API/error handling as live backend
  features are connected.
- Add dependency injection and reusable validation where it reduces current
  duplication.
- Adopt a feature-based directory structure and Riverpod only with an agreed
  migration plan and tests; avoid moving unrelated screens in one pass.
- Separate development, staging, and production configuration.
- Add tests for role-gated navigation, seller ownership, API parsing, loading,
  empty, and error states.
- Run formatting, `dart analyze`, Flutter tests, and web/mobile builds for
  affected slices.

## Suggested delivery order

1. Backend/API and role contracts.
2. Keepr brand assets and shared UI foundation.
3. Role-aware account and protected seller/admin access.
4. Seller application and multi-shop registration.
5. Live product/shop discovery and seller product management.
6. Admin seller/shop/product oversight and audit history.
7. Location/search polish, communications, reports/reviews, and expanded
   favourites/profile.

## Immediate blockers

The next connected implementation step needs the existing backend's contracts
for seller application/status, shop CRUD, product CRUD/listing, admin seller
and activity queries, and auth-token verification. Until those are available,
frontend work can produce layouts and local interaction states, but cannot
truthfully show real seller rosters, activity, shops, or admin totals.
