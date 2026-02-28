# HanziLearner Codebase Analysis

## Overview
HanziLearner is a Flutter application designed for Chinese readers who have lost the ability to read/write but can speak the language. It targets the HSK 3.0 vocabulary (starting at level 1) and focuses on helping users memorize Hanzi by showing them character forms, pinyin, meaning, and radicals, alongside contextual mnemonics (tips).

## Directory Structure
- `lib/`: Contains the main application code
  - `models/`: Dart data models representing `HanziCharacter`, `Radical`, and related concepts.
  - `data/`: Loads static JSON data (such as HSK levels) from `assets/` and parses it into models.
  - `services/`: Business logic. Includes quiz session state, learning progression algorithms, radical lookups, and memorization tips.
  - `pages/`: Application screens (e.g., `quiz_page.dart`).
  - `widgets/`: Reusable UI components for displaying Hanzi, quiz options, radical buttons, and headers.
- `assets/`: Contains JSON files for HSK vocabularies (`hsk/`), mnemonics (`tips/`), and dictionaries (`radicals/`).
- `scripts/`: Dart command-line scripts for manipulating data, checking radical completeness, and generating dictionaries/tips.

## Architecture & State Management
- **State Management**: The app uses standard Flutter stateful widgets (`StatefulWidget`, `setState`) rather than a complex state management solution (like Riverpod or Provider). The state for the quiz is kept in `_QuizPageState` and delegated to `QuizService`.
- **Quiz Algorithm**:
  - `QuizService` maintains a pool of 5 "active" characters at a time.
  - Characters are rotated out once they are answered correctly twice without failure.
  - If a user answers incorrectly or selects "unsure", the character is reviewed again until it reaches the active learning threshold.
  - The session has a target (default is 5 new Hanzi), and progress is tracked against this target.
- **Data Loading**: `HSKData` and `RadicalsService` cache parsed JSON models statically for quick runtime access.

## Key Models
- **HanziCharacter**: Contains simplified character, traditional variants, pinyin (transcriptions), meanings, classifiers, POS, frequencies, HSK level, and a tip/mnemonic.
- **Radical**: Maps a radical symbol to its pinyin, English description, origin, and tip. Includes support for alternate symbols.

## UI Components
- **HanziDisplay**: Presents the main character in a large, clear format, with an italicized meaning underneath.
- **QuizOptions**: Displays multi-choice buttons for predicting the correct pinyin pronunciation. Supports revealing the correct/incorrect colors when an answer is selected.
- **RadicalButtons**: Lists the radicals for the character. Tapping them yields a popup dialog with origins and detailed tips (`RadicalInfoDialog`).
- **SessionHeader**: Displays the user's progress for the session (learned characters vs target).

## Data Processing
The `scripts/` directory (e.g., `generate_radicals_dictionary.dart`, `generate_tips.dart`, etc.) parses existing data to ensure that characters have matching radicals and contextual tips. This allows adding additional HSK level JSONs to `assets/hsk/` and processing them systematically.
