# **🏛️ Modular Clean Architecture: E-Commerce Edition**

## **📂 Feature-First Structure**

### **1\. Catalog Feature (`features/catalog/`)**

* Handles product discovery and detail views.  
* Uses `StreamProvider` for real-time stock updates.

### **2\. Cart Feature (`features/cart/`)**

* Manages local state synced with Supabase `cart_items`.  
* **Logic**: Use `NotifierProvider<CartNotifier, CartState>` for total calculations.

### **3\. Checkout Feature (`features/checkout/`)**

* Handles M-Pesa STK Push and Stripe transaction flows.  
* **Service Layer**: Connects directly to the `Daraja` service in `core/`.

## **🏗️ Core Layer (`lib/core/`)**

* **network/**: Supabase initialization.  
* **router/**: Central navigation with "Auth Guards."  
* **theme/**: Modern Retail UI tokens (Colors, Typography).  
* **services/**: Global Payment and Location services.

