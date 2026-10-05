import 'package:flutter/material.dart';

import '../viewmodels/quiz_view_model.dart';
import '../widgets/quiz_surfaces.dart';

class ResultsPanel extends StatelessWidget {
  const ResultsPanel({super.key, required this.viewModel});
  final QuizViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final passed = viewModel.passedCurrentCategory;
    final headline = passed ? 'Category complete.' : 'Almost there.';
    final message = viewModel.hasUnscoredQuestions
        ? 'Some questions are missing a correctAnswer from the server. Add answer keys to enable accurate scoring and category unlocks.'
        : passed
        ? 'You scored at least $categoryPassingPercentage%. The next category is unlocked.'
        : 'You need at least $categoryPassingPercentage% to unlock the next category. Try this category again.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'YOUR DAILY PAUSE',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontFamily: 'sans-serif',
            fontSize: 10,
            letterSpacing: 2.2,
            color: const Color(0xFF67806D),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Well, that was\nworth knowing.',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontSize: 46),
        ),
        const SizedBox(height: 26),
        QuizCard(
          child: Padding(
            padding: EdgeInsets.all(
              MediaQuery.sizeOf(context).width > 650 ? 40 : 24,
            ),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF1E9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD9E1D5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${viewModel.percentage}%',
                      style: TextStyle(
                        fontFamily: 'sans-serif',
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: passed
                            ? const Color(0xFF435D49)
                            : const Color(0xFFB66A58),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 19),
                Text(
                  passed ? headline : '$headline Keep going.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 27),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _ResultStat(
                        value: '${viewModel.score}/${viewModel.submittedTotal}',
                        label: 'CORRECT',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 37,
                      color: const Color(0xFFE7E8E2),
                    ),
                    Expanded(
                      child: _ResultStat(
                        value: '${viewModel.submittedTotal - viewModel.score}',
                        label: 'TO EXPLORE',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 37,
                      color: const Color(0xFFE7E8E2),
                    ),
                    Expanded(
                      child: _ResultStat(
                        value: viewModel.elapsedTime,
                        label: 'TIME',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 27),
                SizedBox(
                  height: 1,
                  child: ColoredBox(color: Color(0xFFE7E8E2)),
                ),
                const SizedBox(height: 23),
                _AnswerReview(viewModel: viewModel),
                const SizedBox(height: 23),
                FilledButton.icon(
                  onPressed: passed
                      ? viewModel.returnToCategories
                      : viewModel.retry,
                  icon: Icon(
                    passed ? Icons.grid_view_rounded : Icons.refresh_rounded,
                    size: 18,
                  ),
                  label: Text(passed ? 'Back to all categories' : 'Try again'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF344C3C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontFamily: 'sans-serif',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF354A3B),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(
          fontFamily: 'sans-serif',
          fontSize: 8,
          letterSpacing: 1.2,
          color: Color(0xFF899087),
        ),
      ),
    ],
  );
}

class _AnswerReview extends StatelessWidget {
  const _AnswerReview({required this.viewModel});
  final QuizViewModel viewModel;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'A LOOK BACK',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontFamily: 'sans-serif',
            fontSize: 9,
            letterSpacing: 1.5,
            color: const Color(0xFF858D84),
          ),
        ),
      ),
      const SizedBox(height: 9),
      ...List.generate(viewModel.totalQuestions, (index) {
        final question = viewModel.questions[index];
        final answer = viewModel.answerHistory.length > index
            ? viewModel.answerHistory[index]
            : -1;
        final result = viewModel.resultForQuestion(question.id);
        final gotIt = result?.correct ?? question.isCorrect(answer);
        final selectedAnswer = answer >= 0 && answer < question.options.length
            ? question.options[answer]
            : null;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    gotIt == true
                        ? Icons.check_circle_rounded
                        : gotIt == null
                        ? Icons.bookmark_added_outlined
                        : Icons.radio_button_unchecked_rounded,
                    size: 16,
                    color: gotIt == true
                        ? const Color(0xFF5E8065)
                        : gotIt == null
                        ? const Color(0xFF71806F)
                        : const Color(0xFFB66A58),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      question.category.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'sans-serif',
                        fontSize: 10,
                        letterSpacing: .6,
                        color: Color(0xFF68736A),
                      ),
                    ),
                  ),
                  Text(
                    gotIt == null
                        ? (answer < 0 ? 'Not graded' : 'Answer recorded')
                        : gotIt
                        ? 'Correct'
                        : 'Incorrect',
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: gotIt == true
                          ? const Color(0xFF5E8065)
                          : gotIt == null
                          ? const Color(0xFF71806F)
                          : const Color(0xFFB66A58),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                question.prompt,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Color(0xFF455349),
                ),
              ),
              if (selectedAnswer != null) ...[
                const SizedBox(height: 7),
                _ReviewedAnswer(
                  label: 'Your answer',
                  answer: selectedAnswer,
                  correct: gotIt == true,
                ),
              ],
              if (result != null &&
                  !result.correct &&
                  result.correctAnswer.isNotEmpty) ...[
                const SizedBox(height: 5),
                _ReviewedAnswer(
                  label: 'Correct answer',
                  answer: result.correctAnswer,
                  correct: true,
                ),
              ],
              if (result != null && result.explanation.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  result.explanation,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFF69736A),
                  ),
                ),
              ],
              if (index < viewModel.totalQuestions - 1)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Divider(height: 1, color: Color(0xFFE7E8E2)),
                ),
            ],
          ),
        );
      }),
    ],
  );
}

class _ReviewedAnswer extends StatelessWidget {
  const _ReviewedAnswer({
    required this.label,
    required this.answer,
    required this.correct,
  });

  final String label;
  final String answer;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final color = correct ? const Color(0xFF538066) : const Color(0xFFB66A58);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'sans-serif',
              fontSize: 10,
              color: Color(0xFF858D84),
            ),
          ),
        ),
        Expanded(
          child: Text(
            answer,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
