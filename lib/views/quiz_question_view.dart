import 'package:flutter/material.dart';

import '../viewmodels/quiz_view_model.dart';
import '../widgets/quiz_surfaces.dart';

class QuizQuestionView extends StatelessWidget {
  const QuizQuestionView({
    super.key,
    required this.viewModel,
    required this.isWide,
  });

  final QuizViewModel viewModel;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final question = viewModel.currentQuestion;
    if (question == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final mainContent = QuizCard(
      child: Padding(
        padding: EdgeInsets.all(isWide ? 42 : 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CategoryPill(category: question.category),
                const Spacer(),
                const Icon(
                  Icons.schedule_rounded,
                  size: 15,
                  color: Color(0xFF8A9088),
                ),
                const SizedBox(width: 5),
                Text(
                  '30 sec per question',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 29),
            Text(
              'QUESTION ${viewModel.currentIndex + 1}',
              style: theme.textTheme.labelLarge?.copyWith(
                fontFamily: 'sans-serif',
                fontSize: 10,
                letterSpacing: 2,
                color: const Color(0xFF8B9189),
              ),
            ),
            const SizedBox(height: 13),
            Text(
              question.prompt,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: isWide ? 32 : 25,
              ),
            ),
            const SizedBox(height: 11),
            Text(
              'Choose the best answer to continue.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 25),
            ...List.generate(
              question.options.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AnswerTile(
                  index: index,
                  text: question.options[index],
                  selected: viewModel.selectedIndex == index,
                  correct: viewModel.correctAnswerIndexFor(question) == index,
                  graded: viewModel.correctAnswerIndexFor(question) != null,
                  revealed: viewModel.isAnswered,
                  onTap: () => viewModel.selectAnswer(index),
                ),
              ),
            ),
            if (viewModel.timedOut) ...[
              const SizedBox(height: 7),
              const Text(
                "Time's up — marked incorrect. Moving to the next question...",
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB66A58),
                ),
              ),
            ],
            if (viewModel.isAnswered &&
                viewModel.isCorrect != null &&
                question.explanation != null) ...[
              const SizedBox(height: 7),
              ExplanationBox(
                correct: viewModel.isCorrect!,
                explanation: question.explanation!,
              ),
              const SizedBox(height: 20),
            ],
            const SizedBox(height: 9),
            Row(
              children: [
                if (viewModel.isAnswered) ...[
                  Icon(
                    viewModel.timedOut
                        ? Icons.highlight_off_rounded
                        : viewModel.isCorrect == true
                        ? Icons.check_circle_outline
                        : viewModel.isCorrect == false
                        ? Icons.highlight_off_rounded
                        : Icons.bookmark_added_outlined,
                    color: viewModel.timedOut || viewModel.isCorrect == false
                        ? const Color(0xFFB66A58)
                        : const Color(0xFF538066),
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    viewModel.timedOut
                        ? "Time's up — incorrect"
                        : viewModel.isCorrect == null
                        ? 'Answer recorded'
                        : viewModel.isCorrect!
                        ? 'Nicely done'
                        : 'Keep learning',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: viewModel.timedOut || viewModel.isCorrect == false
                          ? const Color(0xFFB66A58)
                          : const Color(0xFF538066),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  NextButton(
                    isLast: viewModel.isLastQuestion,
                    onPressed: viewModel.nextQuestion,
                  ),
                ] else
                  Text('Select one option', style: theme.textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );

    final sidePanel = Column(
      children: [
        QuizCard(
          child: Padding(padding: const EdgeInsets.all(23), child: TodayNote()),
        ),
        const SizedBox(height: 15),
        QuizCard(
          child: Padding(
            padding: const EdgeInsets.all(23),
            child: ScoreCard(viewModel: viewModel),
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (viewModel.progressError != null) ...[
          Text(
            'Quiz progress could not be saved: ${viewModel.progressError}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFB66A58),
            ),
          ),
          const SizedBox(height: 12),
        ],
        QuizIntro(isWide: isWide, viewModel: viewModel),
        const SizedBox(height: 28),
        ProgressStrip(viewModel: viewModel),
        const SizedBox(height: 17),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: mainContent),
              const SizedBox(width: 18),
              Expanded(flex: 3, child: sidePanel),
            ],
          )
        else
          Column(
            children: [mainContent, const SizedBox(height: 15), sidePanel],
          ),
      ],
    );
  }
}
