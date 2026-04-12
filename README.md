# Nutri AI 🥗

Nutri AI is a SwiftUI iOS app for calorie tracking through food photos. It combines a personalized onboarding flow, AI-powered nutrition estimation, local-first persistence with SwiftData, and Firebase-backed sync so users can build a daily nutrition habit without manually entering every meal.

## Overview ✨

The app is built around three main ideas:

- A guided onboarding flow that collects profile data such as gender, age, height, weight, activity level, and goal.
- A custom nutrition plan that calculates BMR, TDEE, target calories, and daily macros, with editing support.
- A camera-based food logging experience that uses Firebase AI to estimate nutritional data from an image and then saves it locally and remotely.

## Features 🚀

- Google Sign-In with Firebase Authentication 🔐
- Multi-step onboarding with goal and lifestyle capture 📝
- Personalized calorie and macro recommendations 🎯
- Editable daily nutrition targets ✍️
- Camera-based food logging 📸
- AI nutrition analysis using `gemini-2.5-flash` through Firebase AI 🤖
- SwiftData local storage for user profile and food entries 💾
- Firestore + Firebase Storage sync for cloud-backed data ☁️
- Background retry queue for failed Firestore uploads 🔄
- Daily home dashboard with calorie and macro cards 📊
- Weekly date picker for browsing past meal logs 🗓️
- Skeleton/loading states while AI meal analysis is in progress ⏳
- Recently logged meal feed with photo, timestamp, and macro summary 🍽️
- Detailed nutrition view for each food entry 🔍
- Editable serving multiplier that recalculates calories and macros ⚖️
- Expanded nutrition facts including fiber, sugar, sodium, cholesterol, vitamins, iron, calcium, and more 🧪
- Food entry deletion 🗑️
- Save captured meal photos to the user photo library 🖼️
- Weekly progress chart with Charts 📈
- BMI and weight progress views 📉
- Goal weight and current weight management 🏁
- In-app editing for height, date of birth, and gender 👤
- Restore onboarding/profile data from Firestore after reinstall or sign-in on a new device ♻️
- Profile editing and account deletion ⚙️

## Tech Stack 🛠️

- SwiftUI
- SwiftData
- Firebase Auth
- Firebase Firestore
- Firebase Storage
- Firebase AI / Firebase AI Logic
- Google Sign-In for iOS
- Apple Charts
- BackgroundTasks

## Architecture 🧱

The codebase is organized into a few clear layers:

- `Nutri AI/Views`: SwiftUI screens for onboarding, home, growth/progress, profile, and tracking UI.
- `Nutri AI/ViewModels`: App state and feature logic such as auth, user info, food entry management, growth chart building, and nutrition analysis.
- `Nutri AI/FirebaseDB`: Firestore, Storage, sync, and remote mapping logic.
- `Nutri AI/Models`: SwiftData models and the nutrition response schema used by the AI pipeline.
- `Nutri AI/Miscellaneous` and `Nutri AI/Helper Views`: shared utilities, enums, calculations, and reusable UI.

Key flow:

1. `Nutri_AIApp.swift` configures Firebase, sets up SwiftData, and registers background sync.
2. `ContentView.swift` decides whether the user sees onboarding, auth, or the main app.
3. `UserInfoViewModel.swift` stores onboarding inputs and calculates nutrition targets.
4. `MainView.swift` hosts the tab bar and camera entry point.
5. `NutritionalAnalysisService.swift` sends food images to Firebase AI and decodes structured nutrition output.
6. `FoodRepository.swift` and `FirestoreDataSyncManager.swift` persist data locally first, then sync to Firestore/Storage with retry support.

## Main User Flow 🔄

1. Open the app and start onboarding or sign in with Google.
2. Complete onboarding to save profile details and generate a nutrition plan.
3. Review and optionally edit daily calories, carbs, protein, and fats.
4. Use the floating camera button on the home tab to capture a meal photo.
5. Let the AI model estimate nutrition and save the result as a food entry.
6. Track daily intake on the home screen and weekly macro calories on the progress screen.
7. Update weight, height, date of birth, or gender from the profile area as needed.

## Requirements ✅

- Xcode 26.1 or newer
- iOS 26.0+ deployment target
- Swift 5
- A Firebase project with Auth, Firestore, Storage, and Firebase AI configured

## Getting Started 🏃‍♀️

1. Clone the repository.
2. Open `Nutri AI.xcodeproj` in Xcode.
3. Create a Firebase iOS app with the bundle identifier `com.shreyaprasad.NutriAI`.
4. Download `GoogleService-Info.plist` and add it to the app target.
   This file is intentionally gitignored and is not included in the repo.
5. Enable Google sign-in in Firebase Authentication.
6. Enable Firestore Database and Firebase Storage.
7. Configure Firebase AI access for the model used in `Nutri AI/ViewModels/NutritionalAnalysisService.swift`, currently `gemini-2.5-flash`.
8. If you use a different Firebase project, update the Google URL scheme in `Nutri-AI-Info.plist` to match your reversed client ID.
9. Build and run on a simulator or device with camera access available.

## Persistence and Sync Notes 🔁

- User profile data is stored locally in SwiftData and mirrored to Firestore.
- Food entries are saved locally first, then uploaded to Firestore and Firebase Storage.
- If a cloud save fails, the app queues the entry and retries via `BGTaskScheduler`.
- On reinstall or device changes, the app attempts to restore onboarding/profile data from Firestore.

## Repository Status 📌

The GitHub repository is currently private, uses `main` as the default branch, and did not previously include a README. This document was written from the current codebase and GitHub repository structure so it stays aligned with the actual implementation.
