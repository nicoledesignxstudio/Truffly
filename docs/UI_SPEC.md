# TRUFFLY – UI SPECIFICATION DOCUMENT (FINAL MVP)

This document defines visual structure, layout, navigation, and UI behavior for Truffly mobile app.

Platform: iOS & Android (Flutter)

---

# 1. DESIGN SYSTEM

## Colors

Primary Accent: #FE4F18  
Primary Text: #151618  
Background: #FFFFFF  
Secondary Background / Soft Surfaces: #F5F5F5  

### Color Usage Rules

#FE4F18 is used ONLY for:
- Primary CTA buttons
- Active states (selected chips, selected tab)
- Favorite icon (heart)
- Important badges
- Highlights

#FFFFFF is the main background of all screens.

#F5F5F5 is used for:
- Light surfaces
- Skeleton loaders
- Inactive chips
- Section separation backgrounds

Never use the primary color as full-screen background.

---

## Typography

Font: Google Sans

### Hierarchy

H1: 34px – Medium  
H2: 24px – Medium  
Section Title: 18px – Medium  
Body: 16px – Regular  
Caption: 14px – Regular  
Micro: 12px – Regular  

Line height: 1.4  
Compact vertical spacing preferred.

---

## Layout Principles

- Mobile-first
- Clean, compact layout
- Border radius: 8px
- Soft subtle shadows on cards
- White surfaces
- Minimal dividers
- Elegant spacing (not overly airy)

---

# 2. NAVIGATION STRUCTURE

Bottom Navigation (5 tabs):

1. Home
2. Truffles
3. Sellers
4. Guides
5. Account

Active tab:
- Icon color → #ffffff
- background: dark circle 

Inactive tab:
- #151618 with reduced opacity

---

# 3. SCREENS STRUCTURE

---

# SPLASH SCREEN

- White background
- Centered Truffly logo
- Subtle fade animation (1.5s)
- No additional text

---

# AUTH FLOW

## Welcome Screen

Structure:

- Value proposition headline
- Supporting text
- Clean hero image
- Buttons:
  - Sign Up (primary)
  - Login (secondary)
  - Continue with Google

Primary button → #FE4F18  
Secondary button → outlined style

---

## Login / Sign Up

Fields:
- Email
- Password
- Confirm password (sign up only)

Inline validation
Password strength indicator

---

# ONBOARDING FLOW

## Step 1 – Role Selection

Two selection cards:
- Buyer
- Seller

Selected card:
- Accent border #FE4F18

---

## Buyer Onboarding Pages

- Escrow explanation
- Freshness guarantee
- Verified sellers
- Enable notifications screen

Final screen:
- Welcome message
- CTA → Enter App

---

## Seller Onboarding Pages

- 10% commission explanation
- 48-hour shipping rule
- Escrow explanation
- Tesserino upload
- Stripe onboarding explanation
- Enable notifications screen

Final screen:
- Welcome message
- CTA → Enter App

---

# HOMEPAGE

Background: #FFFFFF

## Top Bar

Left:
- User avatar

Right:
- Notification icon
- Favorites icon

---

## Buyer Homepage Structure

1. Greeting (Hello + name)
2. Seasonal Highlight Card
3. Latest Truffles (horizontal scroll)
4. Sellers Preview (horizontal scroll)

---

## Seller Homepage Structure

1. Bento layout with: publish truffle button + active orders + active truffles
3. Latest Truffles (horizontal scroll)
4. Sellers Preview (horizontal scroll)

---

### Truffle Cards

Compact card layout:

- Image
- Quality badge
- Name
- Latin name (smaller text)
- Price (bold)
- Region
- Harvest date
- Favorite icon (bottom right)

---

# TRUFFLES PAGE

## Visible Filters (Choice Chips)

Horizontal scroll:

- Bianco Pregiato
- Scorzone
- Nero Pregiato
- Uncinato
- Brumale
- Bianchetto
- All

Selected chip → #FE4F18 background

---

## Additional Filters (Bottom Sheet)

Triggered by filter icon.

Options:

- Quality (1°, 2°, 3°)
- Region
- Price range (slider)
- Weight range (slider)

Bottom sheet can open/close smoothly.

---

# PRODUCT PAGE

Structure:

1. Image carousel
2. Title + Quality badge
3. Price (bold) + price per kg + weight in grams
4. Seller preview
5. Shipping cost
6. Harvest date + region
7. Sticky bottom CTA: Buy Now

Background white.

---

# CHECKOUT

Steps:

1. Select address
2. Select payment method
3. Order summary
4. Confirm payment

Clean card layout.

---

# SELLERS PAGE

## Visible Filters (Choice Chips)

- Region

---

## Additional Filters (Bottom Sheet)

- Rating (4+ etc.)
- Completed orders (minimum threshold)

---

Seller Card:

- Profile image
- Name
- Region
- Rating
- "View profile" button

---

# SELLER PROFILE

Sections:

- Profile header
- Bio
- Rating summary
- Reviews preview
- Published truffles

---

# REVIEWS PAGE

- Large average rating
- Distribution bars
- Review list

---

# FAVORITES PAGE

Grid layout
White background
Empty state illustration

---

# NOTIFICATIONS PAGE

List layout
Unread items subtly highlighted
Mark as read interaction

---

# GUIDES PAGE

List layout
Minimal thumbnails
Short description preview

---

# GUIDE DETAIL PAGE

- Large heading
- Structured readable content
- Clear typographic hierarchy

---

# ACCOUNT PAGE

Grouped into sections:

---

## Buyer Structure

### Business
- My orders
- My favorites
- Become a seller

### Personal
- Account details
- Shipping
- Payments

### Support
- Guide to Truffly
- Support
- Settings
- Log out

---

## Seller Structure

### Business
- Seller profile
- My orders
- My truffles

### Personal
- My favorites
- Account details
- Shipping
- Payments

### Support
- Guide to Truffly
- Support
- Settings
- Log out

---

# MY ORDERS PAGE

Tabs:

- In progress
- Cancelled
- Completed
- All

Compact card style.

---

# ORDER DETAIL PAGE

Sections:

- Product info
- Status timeline
- Shipping snapshot
- Tracking code
- Action button (Confirm delivery if buyer)

---

# ADDRESSES PAGE

List layout
Add address button

---

# ADD ADDRESS PAGE

Simple vertical form layout.

---

# PAYMENTS PAGE

List saved cards
Add new card

Stripe UI components for card management.

---

# MY TRUFFLES PAGE

Sections:

- Active
- Sold

Minimal card layout.

---

# BECOME SELLER PAGE

Explains:
- Commission
- Rules
- Verification
- Stripe onboarding

CTA: Request Approval

---

# SUPPORT & FAQ PAGE

Expandable FAQ items
Contact support button

---

# SETTINGS PAGE

- Language selector
- Notification toggle
- Privacy policy
- Terms
- Delete account