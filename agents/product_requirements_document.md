# Product Requirements Document (PRD)
**Project Name:** Toko Awikwok (Latihan Responsi Mobile)
**Platform:** Mobile (Flutter)
**Context:** This document outlines the application flow and requirements based on "latres_si-d (1).pdf".

## 1. Application Overview
This is a mobile e-commerce application that allows users to browse products fetched from an external API, add them to a user-specific local cart, and manage their session. The app operates mostly offline for the cart, relying on local storage.

## 2. Technical Stack
- **Framework:** Flutter
- **State Management:** GetX (Optional, but recommended for clean architecture)
- **Network/API:** `http` package (Target API: `https://dummyjson.com/products`)
- **Local Storage (Session):** `shared_preferences`
- **Local Database (Cart Data):** `hive`

## 3. Core User Flow
1. **App Launch:** System checks `shared_preferences` for an active user session.
    - If user exists -> Navigate to **Main Page (Home)**.
    - If no user exists -> Navigate to **Login Page**.
2. **Authentication (Login):**
    - User enters any `username`.
    - User enters `password` (Must be the user's Student ID / NIM).
    - On success, save `username` to session and navigate to **Main Page**.
3. **Main Page (Bottom Navigation):**
    - Consists of two tabs: **Home** and **Profile**.
4. **Browsing Products (Home):**
    - Displays logged-in `username`.
    - Fetches and displays a list of products from `dummyjson.com`.
    - Tapping a product navigates to **Product Detail Page**.
    - Tapping the Cart icon navigates to **Cart Page**.
5. **Product Details:**
    - Displays detailed information about the selected product.
    - User can adjust quantity (Must be: `0 < qty <= totalQty`).
    - User taps "Add to Cart" -> Data (Product, Username, Qty) is saved to **Hive**.
6. **Cart Management:**
    - Displays items added by the *currently logged-in user* only. (Cart data is isolated per username).
    - User can delete items from the cart.
7. **Profile & Logout:**
    - Displays current `username` and a custom description.
    - User taps "Logout" -> Clears session in `shared_preferences` -> Navigate to **Login Page**.

## 4. Data Models (Expected)
### 4.1. Product (from API)
- `id` (int)
- `title` (String)
- `description` (String)
- `price` (double)
- `thumbnail` (String)
- `stock` (int) - used for `totalQty` limit.

### 4.2. Cart Item (Hive Object)
- `key` (auto-increment / uuid)
- `username` (String) - Critical for filtering cart per user.
- `productId` (int)
- `productName` (String)
- `price` (double)
- `quantity` (int)
- `imageUrl` (String)

## 5. Specific Constraints
- GitHub repository must be named `nim_latres_D`.
- Project must contain a `README.md` explaining the folder structure.
- Zip files are strictly prohibited for submission.