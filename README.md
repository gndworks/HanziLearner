# What is this app?
This (WIP) app is aimed for those can speak Chinese but have lost the ability to read or write. It focuses only on the vocabulary based on the HSK 3.0 (1-7+) levels and contains useful tips on how to memorise them. By default, each session is designed to make you learn around 5 new Hanzi.

# What about other apps?
While most other apps are more feature rich, sometimes these features like pronounciation and additional context allows you to select the correct answer without actually knowing the word. Additionally, some flashcard apps do not provide a hints feature for you to properly memorise a character.

# Roadmap
The free version will allow a user to learn characters completely offline and progress is stored on the local device. This is a Flutter app so it is cross-platform and should work on browsers, Android and Apple devices. There will not be any Ads at this time.

I plan to implement a paid version that allows premium users to save their progress on the cloud and create discussion threads on each character they come across. The payment will be paying for the costs that these services require.

# How to Run Locally

If you want to run this app on your own machine, follow these steps:

### Prerequisites
1.  **Flutter SDK**: Ensure you have Flutter installed. You can check by running `flutter --version`. If not, follow the [official installation guide](https://docs.flutter.dev/get-started/install).
2.  **Platform Support**: Depending on your target, ensure you have an emulator (Android/iOS) or a browser (Chrome/Edge) ready.

### Steps
1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/[your-username]/HanziLearner.git
    cd HanziLearner
    ```
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the App**:
    ```bash
    flutter run
    ```
    *Note: Use `flutter run -d chrome` to run explicitly in the browser.*

# What it will kind of look like
![early screenshot](assets/images/readme/early_screenshot.png)
