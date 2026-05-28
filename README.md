# 📚 Smart Tutor

A full-featured **tutor-guardian matching platform** built with Flutter and Firebase. Smart Tutor connects guardians looking for home tutors with qualified tutors seeking tuition opportunities — all managed through a streamlined, role-based mobile application.

---

## 🌟 Overview

Smart Tutor is a three-sided marketplace app where:

- **Guardians** post tuition requirements and find suitable tutors for their children
- **Tutors** browse tuition postings, apply for positions, and manage their professional profiles
- **Admins** oversee the platform — verifying tutors, managing users, and providing support

The app handles the full lifecycle: from tutor discovery and application, to hiring, in-app messaging, and post-hire ratings.

---

## ✨ Features

### 🔐 Authentication & Role Management
- Email/password registration and login via Firebase Auth
- Role-based routing on login — users are directed to their respective dashboards (Tutor / Guardian / Admin) automatically
- Secure user records stored in Firestore with role metadata

### 👩‍🏫 Tutor Features
- Build a rich tutor profile including qualifications, subjects taught, preferred class levels, teaching style, expected salary, available days, tutoring mode (online/offline), and bio
- Upload academic documents for verification
- Browse a live **Tuition Feed** of guardian-posted tuition requests
- Apply to tuition posts with a single tap (duplicate application prevention built in)
- Track application statuses (pending / accepted / rejected)
- Manage experience, schedule, and subjects from a dedicated dashboard
- Pay a **verification fee** to unlock profile approval by admin
- View payment status and verification progress
- In-app chat with guardians and admin support

### 👨‍👩‍👧 Guardian Features
- Create a guardian profile with child details, location, budget, and subject preferences
- **Post tuition requests** with subject, class, schedule, budget, and preferred tutor gender/mode
- Browse the **tutor directory** and view detailed tutor profiles
- Receive and review applications from tutors on each post
- Accept or reject tutor applications
- Rate and review hired tutors (reflected in tutor's public rating)
- In-app chat with tutors and admin support

### 🛡️ Admin Features
- Full **admin dashboard** with platform statistics
- Manage all registered users (tutors and guardians)
- Review and approve/reject tutor profiles with an admin rating system
- Monitor verification payments and approve tutor verifications
- View and manage all guardian profiles
- Admin support chat — receive and respond to messages from any user

### 💬 Chat System
- Real-time messaging between guardians and tutors (tied to specific tuition requests)
- Separate admin support chat channel for each user
- Block and hide chat functionality
- Live message read/unread status

### ⭐ Rating & Reviews
- Guardians can rate tutors after an engagement
- Ratings are aggregated in real time and stored on the tutor's public profile
- Admin can also assign a separate admin rating to each tutor

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Backend / Database | Firebase Firestore |
| Authentication | Firebase Auth |
| File Storage | Firebase (via file_picker + HTTP upload) |
| State Management | `setState` / `StreamBuilder` |
| UI | Material Design 3 |

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/         # Firestore collection name constants
│   └── utils/             # Input validators
├── models/
│   ├── app_user_model.dart
│   ├── tutor_profile_model.dart
│   ├── guardian_profile_model.dart
│   └── verification_payment_model.dart
├── screens/
│   ├── auth/              # Login & Registration screens
│   ├── common/            # Home screen, Role router
│   ├── tutor/             # All tutor-facing screens
│   ├── guardian/          # All guardian-facing screens
│   ├── admin/             # Admin dashboard & management screens
│   └── chat/              # Chat list & chat screen
├── services/
│   ├── auth_service.dart
│   ├── chat_service.dart
│   ├── tutor_profile_service.dart
│   ├── guardian_profile_service.dart
│   ├── tutor_rating_service.dart
│   ├── file_upload_service.dart
│   ├── verification_payment_service.dart
│   └── admin_verification_service.dart
├── theme/
│   └── app_theme.dart     # App-wide Material theme
├── widgets/
│   └── app_input_field.dart
├── firebase_options.dart
└── main.dart
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.5.3`
- A Firebase project with **Firestore**, **Firebase Auth**, and **Firebase Storage** enabled

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/smart_tutor.git
   cd smart_tutor
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Add Android and/or iOS apps to the project
   - Download `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS) and place them in the appropriate directories
   - Replace the contents of `lib/firebase_options.dart` with your project's generated options (using the FlutterFire CLI: `flutterfire configure`)

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 🗄️ Firestore Collections

| Collection | Description |
|---|---|
| `users` | Core user records with role and profile completion status |
| `tutor_profiles` | Full tutor profile data including ratings and verification status |
| `guardian_profiles` | Guardian profile data including child info and preferences |
| `tuition_posts` | Tuition requests posted by guardians |
| `applications` | Tutor applications to tuition posts |
| `chats` | Chat metadata for tutor–guardian and support conversations |
| `reviews` | Guardian ratings and reviews for tutors |
| `payments` | Verification payment records |
| `admin_ratings` | Admin-assigned tutor ratings |

---

## 📦 Dependencies

```yaml
firebase_core: ^4.5.0
firebase_auth: ^6.2.0
cloud_firestore: ^6.1.3
file_picker: ^8.1.2
http: ^1.2.2
cupertino_icons: ^1.0.8
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to open an issue or submit a pull request.

This project is licensed under the MIT License.
