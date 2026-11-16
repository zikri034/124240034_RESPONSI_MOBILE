# UI/UX Design Specification
**Theme:** Minimalism
**Project:** Toko Awikwok Mobile App

## 1. Design Philosophy
The UI will adopt a minimalist design language emphasizing whitespace, clean typography, and a limited color palette. The goal is to reduce cognitive load and focus the user's attention on the product content and core actions.

## 2. Color Palette
- **Primary Color:** `#2196F3` (Material Blue) - Used for primary buttons, app bar accents, and active states.
- **Background Color:** `#FAFAFA` (Off-White) - Used for the main scaffold background to provide a soft contrast against cards.
- **Surface Color:** `#FFFFFF` (Pure White) - Used for product cards, input fields, and bottom navigation.
- **Text Primary:** `#212121` (Dark Grey) - For main titles and body text.
- **Text Secondary:** `#757575` (Medium Grey) - For subtitles, descriptions, and placeholders.
- **Error/Destructive:** `#F44336` (Red) - Used for delete buttons in the cart and the logout button.

## 3. Typography
- **Font Family:** `Inter` or standard system sans-serif (Roboto/San Francisco).
- **Headings (H1/H2):** Bold, 20px - 24px, Text Primary.
- **Body Text:** Regular, 14px, Text Primary.
- **Captions/Labels:** Regular, 12px, Text Secondary.

## 4. Component Guidelines
### 4.1. Buttons
- **Primary Button:** Full width, rounded corners (BorderRadius: 8px), Primary Color background, White text. No shadows (flat design).
- **Destructive Button:** Same as Primary, but with Error/Destructive background color.
- **Icon Button:** Minimal padding, unboxed or circular background with subtle grey tint.

### 4.2. Input Fields (TextFormField)
- Minimalist borders: OutlineInputBorder with a light grey border color (`#E0E0E0`).
- Focused state changes the border color to Primary Color.
- Generous internal padding (e.g., 16px all sides).

### 4.3. Product Cards
- **Background:** Surface Color (White).
- **Elevation:** Minimal to none (0 or 1). Use a very subtle border (`#EEEEEE`) instead of heavy drop shadows.
- **Border Radius:** 12px.
- **Layout:** Row-based for lists (Image on left, details on right).

## 5. Screen-by-Screen Layout

### 5.1. Login Screen
- Centered layout.
- App Logo / Icon (Shopping Bag icon, Blue).
- App Name ("Toko Awikwok") centered below logo.
- Two Input Fields: Username (prefix icon: user) and Password (prefix icon: lock).
- Full-width Login Button.

### 5.2. Home Screen (Tab 1)
- **App Bar:** Greeting ("Hi, [Username]") aligned left. Cart icon aligned right. No background color (transparent/white) with zero elevation.
- **Body:** `ListView.builder` for products.
- **Product Item:** Minimal card. Left: Square thumbnail (rounded corners). Right: Title, Category (subtitle), and Price.

### 5.3. Product Detail Screen
- **App Bar:** Back button, Title "Detail Produk".
- **Image:** Large, edge-to-edge or generously padded product image.
- **Content:** Title (H1), Price (Primary Color, large), Rating/Stock info.
- **Description:** Body text, secondary color.
- **Bottom Action Area:** 
    - Quantity selector: `[ - ] [ 1 ] [ + ]` (Minimalist counter).
    - "Add to Cart" button.

### 5.4. Cart Screen
- **App Bar:** Back button, Title "Keranjang Belanja".
- **Body:** List of cart items.
    - Each item shows image, name, qty, price.
    - Trailing icon: Red trash bin for deletion.
- **Bottom Bar:** Total Price calculation and potential "Checkout" placeholder (if needed, though not strictly requested).

### 5.5. Profile Screen (Tab 2)
- **Header:** Large circular avatar (default icon), below it is the large centered Username.
- **Body:** Divider line, "Kesan" and "Pesan" (description texts) aligned left.
- **Bottom:** Large, full-width red "Logout" button with an exit icon.