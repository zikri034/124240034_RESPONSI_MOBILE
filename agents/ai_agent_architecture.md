# AI Agent Instructions & Roles
**Environment:** Antigravity (Gemini Models)
**Project:** Toko Awikwok Mobile App (Flutter)

This document defines the agentic workflow to build the application. The system should instantiate three distinct agents to handle different layers of the Flutter application.

## 1. System Orchestrator (Lead Agent)
**Role:** Project Manager & Architect.
**Responsibilities:**
- Reads the `prd.md` and `design.md`.
- Initializes the Flutter project structure (Feature-First or Clean Architecture).
- Orchestrates the creation of models, UI, and local storage by delegating to Sub-Agents.
- Ensures the final output complies with the constraint: *Must include README.md explaining folder structure.*

## 2. Backend & Data Agent (DataOps Agent)
**Role:** Handles all external and internal data flow.
**Instructions:**
- **API Integration:** Create a service to fetch `GET https://dummyjson.com/products`. Parse the JSON response into a Dart model.
- **Session Management:** Implement `shared_preferences` logic.
    - `saveUser(String username)`
    - `getUser() -> String?`
    - `logout()`
- **Local DB (Hive):**
    - Initialize Hive in `main.dart`.
    - Create a Hive adapter for `CartItem`.
    - Implement functions: `addToCart(CartItem item)`, `getCartByUser(String username)`, `deleteFromCart(int key)`.
- **Constraint Check:** Ensure cart retrieval strictly filters by the `username` stored in the current session.

## 3. UI/UX & State Agent (Frontend Agent)
**Role:** Builds the visual components and wires them to the state.
**Instructions:**
- Strictly follow the guidelines in `design.md` (colors, padding, flat design).
- **State Management:** Use GetX (as suggested in constraints). Create Controllers for:
    - `AuthController` (handles login/logout/session).
    - `ProductController` (handles API fetching and loading states).
    - `CartController` (handles Hive DB interactions, quantity logic, and price totals).
- **Widgets:** 
    - Build independent files for screens: `login_page.dart`, `main_page.dart` (contains BottomNav), `home_page.dart`, `detail_page.dart`, `cart_page.dart`, `profile_page.dart`.
    - Implement the counter logic in `detail_page.dart` ensuring `0 < qty <= max_stock`.
- **Routing:** Use GetX routing (`Get.to()`, `Get.offAll()`) to manage transitions smoothly.

## Agent Execution Flow
1. **DataOps Agent** generates Models and Hive Adapters.
2. **DataOps Agent** generates API Services and Local Storage Services.
3. **Frontend Agent** generates GetX Controllers utilizing the services.
4. **Frontend Agent** generates the UI pages and binds them to the Controllers.
5. **Lead Agent** reviews the integration in `main.dart`, sets up the initial route based on session check, and writes the `README.md`.