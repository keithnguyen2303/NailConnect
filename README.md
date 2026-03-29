# 💅 NailConnect 
Connecting nail technicians and salon owners through a location-based matching platform.

## ❗ Problem
Nail technicians rely on informal networks to find jobs, while salon owners struggle to fill positions quickly, especially during peak periods.

## 💡 Solution
NailConnect provides a centralized platform that matches technicians and salon owners based on availability, location, and preferences.

## 🚀 Features
- Role-based system (Technician vs Salon Owner)
- Real-time matching based on availability and location
- Apple Maps integration for nearby opportunities
- Profile system with certifications and preferences
- Offer/Request system for job coordination
- Persistent data storage using Firebase + CoreData

## 🧠 Architecture
This project follows the MVVM pattern to separate UI, business logic, and data handling.

## 🛠 Tech Stack
- Swift / SwiftUI
- MVVM Architecture
- Firebase (Authentication & Data Storage)
- CoreData / SwiftData (local persistence)
- Apple Maps API
- REST API integration (Yelp API)

## 🔮 Future Improvements
- Real-time notifications for offers/requests
- In-app messaging system
- Advanced filtering (rating, experience)
- Deployment to App Store

## 🗂️ Project Structure

```text
NailConnect/
├── Main/              # App entry and root navigation
├── Models/            # Data models
├── ViewModels/        # Business logic and data handling
├── Views/
│   ├── Authentication/ # Login, signup, profile setup
│   └── Dashboard/      # Matching, map, profile, offers/requests
├── Resources/         # Assets, splash screen, UI helpers
├── GoogleService-Info.plist
└── Info.plist
```

## 🎥 Demo
[Watch Demo Video](https://youtu.be/qCv3sMDpbr4)

## Screenshots

| Icon | Welcome | Signup | Login |
|--------|--------|----------|-----|
| <img width="200" alt="image" src="https://github.com/user-attachments/assets/ec768757-4bc1-4fc8-938d-5c0771fdc99b" /> | <img width="200" alt="image" src="https://github.com/user-attachments/assets/122bbea0-9cb3-4ea2-9135-a42c8db0b55a" /> | <img width="200" alt="image" src="https://github.com/user-attachments/assets/aea759d8-08ad-4c11-81cb-3be1739a3878" /> | <img width="200" alt="image" src="https://github.com/user-attachments/assets/722f5539-ae02-4bb4-a1b7-234e177edb52" /> |  

| Profile | Dashboard #1 | Dashboard #2 | Matching |
|--------|----------|-----|---|
| <img width="200" alt="image" src="https://github.com/user-attachments/assets/2aea98ae-d79b-4d01-86d1-334b10efb559" /> | <img width="200" alt="image" src="https://github.com/user-attachments/assets/1d8e87a5-5323-4952-a3d3-80c3dfdd60be" /> | <img width="200" alt="image" src="https://github.com/user-attachments/assets/0d8ac1a7-afb9-4899-bef1-450fec346342" /> | <img width="200"  alt="image" src="https://github.com/user-attachments/assets/8d6ff069-8279-4f6c-be28-8cca9ebc8e0f" /> |

| Map | Request | Offer | Preference |
|--------|----------|-----|----|
| <img width="200" alt="image" src="https://github.com/user-attachments/assets/7cfb371a-10f2-4df2-9f53-6f894b5b1654" /> | <img width="200" alt="image" src="https://github.com/user-attachments/assets/d69f406f-a163-4008-8c05-85f0b3243da5" /> | <img width="200" alt="image" src="https://github.com/user-attachments/assets/5df39afb-21ae-413e-a171-82d1a89a9325" /> | <img width="200" alt="image" src="https://github.com/user-attachments/assets/bc6e0994-33a4-4f59-805b-9e91d13b272a" /> |




