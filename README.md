# Notes App 📝

A beautiful, professional, and responsive Flutter application designed for managing personal notes offline with premium styling and dynamic features.

## 🌟 Key Features

- **Dynamic Search Filtering**: Search note titles and content in real-time as you type.
- **Premium Design Theme**: Designed with an elegant, custom dark mode (`0xff121214`) using a professional indigo accent color.
- **Harmonious Pastel Palettes**: Notes are displayed in high-contrast, soft pastel colors ensuring optimal readability and a modern aesthetic.
- **Persistent Offline Storage**: Powered by **Hive** for fast, reliable, and lightweight local database management.
- **Robust State Management**: Managed via **Flutter BLoC/Cubit** pattern for predictable states and clear separation of concerns.
- **Flexible Edit/Create flows**: Seamlessly create or edit notes, complete with pre-filled inputs and real-time validation.

## 🛠 Tech Stack

- **Framework**: Flutter (Dart)
- **Local Storage**: Hive & Hive Flutter
- **State Management**: flutter_bloc
- **Formatting Utilities**: intl
- **Design System**: Material Design with custom HSL/HEX coloring and Poppins typography.

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the Flutter SDK installed on your machine. For setup instructions, visit the [official Flutter documentation](https://docs.flutter.dev/get-started/install).

### Installation

1. **Clone the repository**:
   ```bash
   git clone <repository_url>
   cd Notes_App
   ```

2. **Get dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the App**:
   ```bash
   flutter run
   ```

### Code Structure

- `lib/models/`: Contains the Hive `NoteModel` schema.
- `lib/cubits/`: Holds the BLoCs/Cubits for adding notes (`AddNoteCubit`) and querying/filtering notes (`NotesCubit`).
- `lib/views/`: Contains page widgets (`NotesView`, `EditNoteView`) and modular, reusable UI components.
- `lib/constants.dart`: Stores the styling color tokens and storage key constants.
