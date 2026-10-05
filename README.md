# Fieldnotes — The Daily Quiz

A responsive Flutter quiz using Riverpod and MVVM. Question data is loaded from the backend each time the quiz starts or is refreshed, so questions added by an administrator appear without an app update.

## Run the app

```sh
flutter pub get
flutter run
```

The default API URL is `http://127.0.0.1:8000/api/questions/`. If the backend runs on a different host, set its base URL with a Dart define:

```sh
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Use `10.0.2.2` to reach the development machine from an Android emulator. On an iOS simulator or desktop, `127.0.0.1` refers to the development machine. A physical device needs the development machine's LAN address, and the backend must allow requests from the app's origin when running on web.

## API response

The questions endpoint can return a JSON array or a paginated object with a `results` array. Each question must include `id`, `category`, `prompt`, and a list of string `options`.

After all questions in a category are answered, the app sends them to `POST /api/quiz/submit/` as `{"answers":[{"question_id":16,"answer":"var"}]}`. The submission endpoint grades the answers and returns `attempt_id`, `score`, `total`, `percentage`, and per-question `results` containing `question_id`, `correct`, `correct_answer`, and `explanation`. That server-calculated percentage controls category progression: users need at least 60% to unlock the next category; otherwise they can retry.

## Project structure

- `lib/models/question.dart` and `lib/models/quiz_submission.dart` — separate question and grading-response models.
- `lib/services/question_service.dart` and `lib/services/quiz_submission_service.dart` — separate question-fetch and answer-submission APIs.
- `lib/repositories/` — repository contract and API-backed implementation composed from the services.
- `lib/providers/quiz_providers.dart` — Riverpod API, repository, and view-model providers.
- `lib/viewmodels/quiz_view_model.dart` — quiz state, navigation, scoring, and refresh.
- `lib/views/` — separate category-list, question, results, and page views.
- `lib/widgets/quiz_surfaces.dart` — reusable cards, answer options, feedback, timer, and progress widgets.

Categories are discovered from the all-questions response. Each category is loaded from `/api/questions/?category=<category>` when selected. Each question has a 30-second timer; unanswered questions are submitted as empty answers, marked incorrect, and automatically advance. To pass a category and unlock the next one, users need at least 60% correct; lower scores show a **Try again** action.
