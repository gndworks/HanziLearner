# Technical Design: HSK Level Selection & Character Progress Tracking

## Objective
Implement features to allow users to:
1. View overall progress across different HSK levels.
2. Select a specific HSK level to study.
3. View a detailed list of all characters in a specific HSK level and their learned status.

## Current System Context
Currently, the application:
- Operates primarily from `QuizPage` and uses `QuizService` for session state.
- Hardcodes HSK level 1 (`HSKData.getHSKLevel1()`).
- Tracks correct answers in-memory during a session (`_correctCountMap`) but lacks persistent local storage across sessions.

## Proposed Architecture & Changes

### 1. Persistent Storage Layer (New)
To track learned characters across sessions, we need local persistence.
- **Dependency**: Add `hive` and `hive_flutter`. Use `hive_generator` and `build_runner` for dev dependencies if we decide to use custom objects.
- **Implementation**: Use Hive "Boxes" to store character progress. 
  - A `progressBox` could store keys as character symbols (e.g., "我") and values as a `CharacterStats` object (or a simple Map/Int if we just want a learned flag for now).
- **Service**: Create `ProgressService` to manage the Hive lifecycle.
  - `Future<void> init()`: Initialize Hive and open necessary boxes.
  - `Future<void> markAsLearned(String symbol)`
  - `bool isLearned(String symbol)`
  - `List<String> getLearnedSymbols(int hskLevel)`
  - `int getLearnedCount(int hskLevel)`
  - **Advantage**: Fast synchronous reads (`isLearned`) after the box is opened, making UI updates snappy.

### 2. HSK Levels Progress Screen (New Route)
**Purpose**: A high-level overview screen to see all HSK levels (1-7+) and the user's progress.
- **UI Components**:
  - A `ListView` or `GridView` of level cards.
  - Each card shows: "HSK Level X", a progress bar/fraction (e.g., "15 / 150 Learned"), and an "Enter" or "Study" button.
- **State**: Fetches total character count for each level from `HSKData` and the learned character count from `ProgressService`.

### 3. Level Details Screen (New Route)
**Purpose**: A screen to see all characters of the selected HSK level and their individual learned status.
- **UI Components**:
  - A header summarizing stats for the level.
  - A `GridView` displaying all characters in the given level.
  - Each character cell shows the Hanzi text. If learned, it can have a different background color (e.g., green/gold) or a checkmark icon to distinguish it from unlearned characters.
  - Tapping a cell could optionally show the character's details/tip in a popup.
  - A "Start Session" FAB or prominent button that initializes `QuizPage` for this specific level.

### 4. Updates to `QuizService` & `HSKData`
- **`HSKData`**:
  - Update `getHSKLevel(int level)` to dynamically load the appropriate `assets/hsk/{level}.json` file instead of strictly level 1.
  - Add a method to get total character count for a specific level.
- **`QuizService`**:
  - Update initialization to accept an `hskLevel` parameter.
  - Filter `_allAvailableCharacters` by querying `ProgressService` so the quiz prioritizes unlearned characters or spaces out reviews.
  - When characters are completely marked as learned during the session (e.g., reaching our threshold of 2 correct answers), call `ProgressService.markAsLearned()` to persist the progress.

### 5. Routing Updates
- Update `main.dart` to use the new `LevelsProgressScreen` as the `home` widget instead of defaulting straight to `QuizPage`.
- Define navigation flows: 
  `LevelsProgressScreen` -> `LevelDetailsScreen` -> `QuizPage`

## Implementation Phases
1. **Phase 1: Persistence Setup**: Implement `ProgressService` with `hive`. Set up boxes for progress tracking.
2. **Phase 2: HSKData updates**: Refactor the data loading utility to allow dynamically loading levels other than just level 1.
3. **Phase 3: Screens Creation**:
   - `LevelsProgressScreen` UI
   - `LevelDetailsScreen` UI
4. **Phase 4: Integration**:
   - Wire up `LevelsProgressScreen` to be the app entry point.
   - Connect `LevelDetailsScreen` to launch `QuizPage` with the correct level parameters.
   - Update `QuizService` to write back to `ProgressService`.
