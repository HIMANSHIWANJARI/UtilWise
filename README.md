## UtilWise

**UtilWise** is a community-driven expense management mobile app designed to help users effortlessly track, split, and settle shared expenses within various groups such as families, friends, travel companions, or roommates. It simplifies group budgeting by ensuring transparency, reducing confusion, and making financial collaboration seamless.



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


