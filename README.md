# 💅 NailConnect
Connecting nail technicians and salon owners through a location-based matching platform.

NailConnect is an iOS application that helps nail technicians find flexible work opportunities and enables salon owners to quickly connect with technicians during busy periods. The app replaces informal hiring methods with a centralized, location-aware matching system.

## 🎥 Demo
[Watch Demo Video](https://youtu.be/qCv3sMDpbr4)

## ❗ Problem
Nail technicians often rely on personal recommendations or direct phone contact to find work, while salon owners struggle to quickly fill staffing needs, especially during peak periods and holidays.

## 💡 Solution
NailConnect provides a centralized platform that matches technicians and salon owners based on availability, location, and user preferences.

## 🚀 Features
- Role-based experience for Nail Technicians and Salon Owners
- Location-based matching using availability and user preferences
- Apple Maps integration for viewing nearby opportunities
- Profile management with certifications, contact details, and scheduling preferences
- Offer and request workflow for job coordination
- Persistent data storage using Firebase and SwiftData

## 🧠 Architecture
This project follows the MVVM architecture pattern to separate UI, business logic, and data handling.

- `AuthManager` handles authentication, user data storage, and profile updates through Firebase
- `NailSalonViewModel` manages external API calls and salon data retrieval
- Views reactively update based on user state, role, and fetched data

This separation improves maintainability, scalability, and clarity across the application.

## 🛠 Tech Stack
- Swift
- SwiftUI
- MVVM Architecture
- Firebase Authentication
- Firebase Realtime Database
- SwiftData for local persistence
- Apple Maps
- REST API integration
- Yelp API

## ⚡ Challenges
- Managing role-based flows for technicians and salon owners within a single app
- Handling asynchronous data updates between Firebase and the SwiftUI interface
- Designing location-based matching while protecting technician privacy
- Organizing app logic cleanly through MVVM and multiple ViewModels

## 🔮 Future Improvements
- Push notifications for offers and requests
- In-app messaging system
- Advanced filtering by rating, experience, and distance
- Improved availability scheduling
- App Store deployment

## 🗂️ Project Structure

```text
NailConnect/
├── Main/               # App entry and root navigation
├── Models/             # Core data models
├── ViewModels/         # Business logic and API handling
├── Views/
│   ├── Authentication/ # Login, signup, and profile setup
│   └── Dashboard/      # Matching, map, profile, and offers/requests
├── Resources/          # Assets, splash screen, and UI helpers
├── GoogleService-Info.plist
└── Info.plist
```

## 📱 Screenshots

| Icon | Welcome | Signup | Login |
|---|---|---|---|
| <img width="200" alt="App Icon" src="https://github.com/user-attachments/assets/ec768757-4bc1-4fc8-938d-5c0771fdc99b" /> | <img width="200" alt="Welcome Screen" src="https://github.com/user-attachments/assets/122bbea0-9cb3-4ea2-9135-a42c8db0b55a" /> | <img width="200" alt="Signup Screen" src="https://github.com/user-attachments/assets/aea759d8-08ad-4c11-81cb-3be1739a3878" /> | <img width="200" alt="Login Screen" src="https://github.com/user-attachments/assets/722f5539-ae02-4bb4-a1b7-234e177edb52" /> |

| Profile | Dashboard #1 | Dashboard #2 | Matching |
|---|---|---|---|
| <img width="200" alt="Profile Screen" src="https://github.com/user-attachments/assets/2aea98ae-d79b-4d01-86d1-334b10efb559" /> | <img width="200" alt="Dashboard Screen 1" src="https://github.com/user-attachments/assets/1d8e87a5-5323-4952-a3d3-80c3dfdd60be" /> | <img width="200" alt="Dashboard Screen 2" src="https://github.com/user-attachments/assets/0d8ac1a7-afb9-4899-bef1-450fec346342" /> | <img width="200" alt="Matching Screen" src="https://github.com/user-attachments/assets/8d6ff069-8279-4f6c-be28-8cca9ebc8e0f" /> |

| Map | Request | Offer | Preference |
|---|---|---|---|
| <img width="200" alt="Map Screen" src="https://github.com/user-attachments/assets/7cfb371a-10f2-4df2-9f53-6f894b5b1654" /> | <img width="200" alt="Request Screen" src="https://github.com/user-attachments/assets/d69f406f-a163-4008-8c05-85f0b3243da5" /> | <img width="200" alt="Offer Screen" src="https://github.com/user-attachments/assets/5df39afb-21ae-413e-a171-82d1a89a9325" /> | <img width="200" alt="Preference Screen" src="https://github.com/user-attachments/assets/bc6e0994-33a4-4f59-805b-9e91d13b272a" /> |

