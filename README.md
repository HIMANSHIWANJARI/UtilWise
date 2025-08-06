## UtilWise

**UtilWise** is a community-driven expense management mobile app designed to help users effortlessly track, split, and settle shared expenses within various groups such as families, friends, travel companions, or roommates. It simplifies group budgeting by ensuring transparency, reducing confusion, and making financial collaboration seamless.



---

## Features

Here’s a refined and enhanced version of your feature list with clearer structure and slight improvements in wording:

---

## Key Features

* **Community Management**
  Create, join, and manage multiple communities with ease, allowing members to collaborate on shared expenses.

* **Predefined Expense Categories**
  Organize expenses under common categories such as Education, Travel, Shopping, Vehicle, and more for better tracking.

* **Customizable Expense Splitting**
  Flexibly assign who paid and decide how each expense is split among community members.

* **"Settle All" Multi-Payment Optimization**
  Efficiently settle multiple outstanding expenses at once, minimizing the number of transactions required.

* **Comprehensive Expense Summaries**
  Visualize expense data with interactive pie charts and detailed breakdowns.

* **Date Range Filtering**
  Filter expense summaries and reports using customizable date ranges for focused insights.

* **Secure OTP-Based Login**
  Login securely with email and One-Time Password (OTP) verification to protect user accounts.

* **Detailed Settled Expense History**
  Access a complete history of all settled payments with summaries for transparency and record-keeping.


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
   git clone https://github.com/HIMANSHIWANJARI/UtilWise.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```


