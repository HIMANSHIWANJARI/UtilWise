# Utilwise

**Utilwise** is a community-based expense management mobile app that helps users efficiently track, split, and settle shared expenses within different groups like families, friends, travel teams, or roommates.

---

## Features

- **Community Management**: Create and manage multiple communities with members.
- **Predefined Object Categories**: Add expenses under categories like Education, Travel, Shopping, Vehicle, etc.
- **Custom Expense Splitting**: Choose who paid and how the expense is split among members.
- **"Settle All" Payments**: Settle multiple expenses at once with minimized transactions.
- **Expense Summary**: View visual breakdowns of expenses using pie charts.
- **Date Filtering**: Filter summaries by custom date ranges.
- **OTP-based Login**: Secure login using email and OTP verification.
- **Settled Expense History**: View a detailed summary of past settlements.

---

## Tech Stack

- **Frontend**: Flutter
- **Backend/Database**: Firebase (Firestore, Auth)

---

## Screenshots
- Login Screen
  <p >
  <img src="https://github.com/user-attachments/assets/02967631-78d8-4997-b07c-22603e58d004" width="150"/>
  <img src="https://github.com/user-attachments/assets/736e1a69-cd6c-4f6a-86fd-c236af919a49" width="150"/>
 </p>
 
- Home Screen
  <p >
  <img src="https://github.com/user-attachments/assets/b9b0a063-c18d-43e6-b25e-9b2d78b809fc" width="150"/>
  <img src="https://github.com/user-attachments/assets/a689b80e-6a96-40cd-9699-453820e72b4e" width="150"/>
  <img src="https://github.com/user-attachments/assets/31e0473c-16d0-46c2-b3e3-63cbf9dec704" width="150"/>
 </p>
 
- Community Screen
  <p>
  <img src="https://github.com/user-attachments/assets/3ce0845e-8ed4-43f7-b4bd-a593cbc826d7" width="150"/>
  <img src="https://github.com/user-attachments/assets/577d7dd8-a867-44d1-8dab-24c4c4f2d4bb" width="150"/>
  <img src="https://github.com/user-attachments/assets/d10429e8-2b11-4a6d-a3a4-b21c8ef66e26" width="150"/>
 </p>

- Add Expense Screen
  <p >
  <img src="https://github.com/user-attachments/assets/00f699a2-9a94-456d-b4af-a38ea7dc44cb" width="150"/>
  </p>
 
- Settle All Payments Screen
  <p >
  <img src="https://github.com/user-attachments/assets/7be2e9a5-395a-4889-bd7a-21021c0c7b8c" width="150"/>
  <img src="https://github.com/user-attachments/assets/22402c57-fa0b-49de-9d72-234e303d53bf" width="150"/>
  </p>

- Pie Chart Summary Screen
  <p >
  <img src="https://github.com/user-attachments/assets/111d897f-2cd7-4ff6-b0b9-d48da90f52e2" width="150"/>
  </p>

---


## Project Structure

```
lib/
│
├── assets/ # Images and icons
├── models/ # Data models (Expense, MemberSplit, etc.)
├── Pages/ # Authentiaction and home screen Pages
├── screens/ # UI screens for settle, summary, etc.
├── provider/ # Firebase and business logic
├── components/ # Reusable UI components
└── main.dart # App entry point
```
## How to Run

1. Clone this repo:
   ```bash
   git clone https://github.com/Prathisthapandey12/utilwise.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Authors & Contributions

## Developed by
- **Prathistha Pandey**
- **Sneha Sahu**  

## Acknowledgements

Special thanks to **Dr. Puneet Goyal** for his constant guidance and feedback throughout the project.  
Also thanks to our seniors for providing the base code, which we extended and improved.



