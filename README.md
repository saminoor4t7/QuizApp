# Fieldnotes — The Daily Quiz

A responsive Flutter quiz using Riverpod and MVVM. Question data is loaded from the backend each time the quiz starts or is refreshed, so questions added by an administrator appear without an app update.

## Run the app

```sh
flutter pub get
flutter run
```

The API base URL defaults to `http://127.0.0.1:8000` on desktop and `http://192.168.1.15:8000` on Android. The Android default is the development PC's current Wi-Fi address; change it if that address changes. Override the base URL with a Dart define when needed:

```sh
flutter run -d windows --dart-define=API_BASE_URL=http://127.0.0.1:8000
flutter run -d <android-device-id> --dart-define=API_BASE_URL=http://<pc-wifi-ip>:8000
```

For an Android emulator, use `http://10.0.2.2:8000`; a physical Android device needs the development PC's Wi-Fi/LAN address, and both devices must be on the same network. The backend must listen on `0.0.0.0:8000`, allow the PC's LAN address in its host configuration (for example Django `ALLOWED_HOSTS`), and be allowed through the PC firewall. Android permits local HTTP traffic in the app manifest. On Windows, `127.0.0.1` refers to the development PC. For web, the backend must also allow requests from the app's origin.

## API response

The questions endpoint can return a JSON array or a paginated object with a `results` array. Each question must include `id`, `category`, `prompt`, and a list of string `options`.

After all questions in a category are answered, the app sends them to `POST /api/quiz/submit/` as `{"answers":[{"question_id":16,"answer":"var"}]}`. The submission endpoint grades the answers and returns `attempt_id`, `score`, `total`, `percentage`, and per-question `results` containing `question_id`, `correct`, `correct_answer`, and `explanation`. That server-calculated percentage controls category progression: users need at least 60% to unlock the next category; otherwise they can retry.

## Project structure

- `lib/models/question.dart` and `lib/models/quiz_submission.dart` — separate question and grading-response models.
- `lib/services/question_service.dart` and `lib/services/quiz_submission_service.dart` — separate question-fetch and answer-submission APIs.
- `lib/repositories/` — repository contract and API-backed implementation composed from the services.
- `lib/services/quiz_progress_store.dart` — saves and restores the active attempt with `shared_preferences`.
- `lib/providers/quiz_providers.dart` — Riverpod API, progress-store, repository, and view-model providers.
- `lib/viewmodels/quiz_view_model.dart` — quiz state, navigation, scoring, and refresh.
- `lib/views/` — separate category-list, question, results, and page views.
- `lib/widgets/quiz_surfaces.dart` — reusable cards, answer options, feedback, timer, and progress widgets.

Categories are discovered from the all-questions response. Each category is loaded from `/api/questions/?category=<category>` when selected. Each question has a 30-second timer; unanswered questions are submitted as empty answers, marked incorrect, and automatically advance. To pass a category and unlock the next one, users need at least 60% correct; lower scores show a **Try again** action.

An unfinished attempt is saved locally, including the current category and question, selected answers, remaining question time, elapsed quiz time, and unlocked categories. Reopening the app resumes the attempt from that point.
