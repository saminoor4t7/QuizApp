import 'package:flutter/material.dart';

import '../viewmodels/quiz_view_model.dart';

extension on String {
  Color get categoryColor {
    final normalized = toLowerCase();
    if (normalized.contains('variable') || normalized.contains('constant')) {
      return const Color(0xFF786194);
    }
    if (normalized.contains('collection')) return const Color(0xFF537B68);
    if (normalized.contains('async') || normalized.contains('future')) {
      return const Color(0xFFBE7950);
    }
    if (normalized.contains('class') || normalized.contains('object')) {
      return const Color(0xFF577793);
    }
    return const Color(0xFF998047);
  }
}

class QuizCard extends StatelessWidget {
  const QuizCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFE8E7E0)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0B1B2A20),
          blurRadius: 28,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: child,
  );
}

class QuizIntro extends StatelessWidget {
  const QuizIntro({super.key, required this.isWide, required this.viewModel});
  final bool isWide;
  final QuizViewModel viewModel;

  @override
  Widget build(BuildContext context) => isWide
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _copy(context)),
            _TimerPill(viewModel: viewModel),
          ],
        )
      : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _copy(context),
            const SizedBox(height: 16),
            _TimerPill(viewModel: viewModel),
          ],
        );

  Widget _copy(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'CURIOSITY, IN SESSION',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontFamily: 'sans-serif',
          fontSize: 10,
          letterSpacing: 2.2,
          color: const Color(0xFF67806D),
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'A moment to\nthink differently.',
        style: Theme.of(
          context,
        ).textTheme.headlineLarge?.copyWith(fontSize: isWide ? 50 : 38),
      ),
      const SizedBox(height: 12),
      Text(
        'A thoughtful little challenge for your curious mind.',
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontSize: isWide ? 16 : 14),
      ),
    ],
  );
}

class _TimerPill extends StatelessWidget {
  const _TimerPill({required this.viewModel});
  final QuizViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final isUrgent = viewModel.secondsRemaining <= 5;
    final timerColor = isUrgent
        ? const Color(0xFFB66A58)
        : const Color(0xFF45574A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      decoration: BoxDecoration(
        color: isUrgent ? const Color(0xFFF8ECE8) : const Color(0xFFEDEFE9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 16, color: timerColor),
          const SizedBox(width: 8),
          Text(
            viewModel.questionTimeRemaining,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: timerColor,
            ),
          ),
          const SizedBox(width: 9),
          const Text(
            'TIME LEFT',
            style: TextStyle(
              fontFamily: 'sans-serif',
              fontSize: 9,
              letterSpacing: 1.2,
              color: Color(0xFF858D84),
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressStrip extends StatelessWidget {
  const ProgressStrip({super.key, required this.viewModel});
  final QuizViewModel viewModel;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        '${viewModel.currentIndex + 1}'.padLeft(2, '0'),
        style: const TextStyle(
          fontFamily: 'sans-serif',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF405849),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: LinearProgressIndicator(
            value: viewModel.progress,
            minHeight: 5,
            backgroundColor: const Color(0xFFE5E5DE),
            color: const Color(0xFF66836D),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Text(
        '${viewModel.currentIndex + 1} OF ${viewModel.totalQuestions}',
        style: const TextStyle(
          fontFamily: 'sans-serif',
          fontSize: 10,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
          color: Color(0xFF858D84),
        ),
      ),
    ],
  );
}

class CategoryPill extends StatelessWidget {
  const CategoryPill({super.key, required this.category});
  final String category;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: category.categoryColor.withValues(alpha: .09),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      category.toUpperCase(),
      style: TextStyle(
        fontFamily: 'sans-serif',
        fontSize: 9,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w700,
        color: category.categoryColor,
      ),
    ),
  );
}

class AnswerTile extends StatelessWidget {
  const AnswerTile({
    super.key,
    required this.index,
    required this.text,
    required this.selected,
    required this.correct,
    required this.graded,
    required this.revealed,
    required this.onTap,
  });
  final int index;
  final String text;
  final bool selected;
  final bool correct;
  final bool graded;
  final bool revealed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final revealCorrect = revealed && correct;
    final selectedCorrect = selected && graded && correct;
    final selectedWrong = selected && graded && !correct;
    final active = selected || revealCorrect;
    final color = selectedCorrect || (!selected && revealCorrect)
        ? const Color(0xFF538066)
        : selectedWrong
        ? const Color(0xFFB66A58)
        : const Color(0xFF718078);
    return Semantics(
      button: true,
      selected: selected,
      label:
          'Option ${String.fromCharCode(65 + index)}: $text'
          '${revealCorrect ? ', correct answer' : ''}',
      child: Material(
        color: active ? color.withValues(alpha: .055) : const Color(0xFFFCFCFA),
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: revealed ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: active
                    ? color.withValues(alpha: .7)
                    : const Color(0xFFE8E9E3),
                width: active ? 1.3 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active
                        ? color.withValues(alpha: .12)
                        : const Color(0xFFF0F1ED),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: active ? color : const Color(0xFF777F77),
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 14,
                      color: const Color(0xFF374239),
                    ),
                  ),
                ),
                if (revealCorrect)
                  Icon(Icons.check_circle_rounded, size: 19, color: color),
                if (selectedWrong && revealed)
                  Icon(Icons.cancel_rounded, size: 19, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExplanationBox extends StatelessWidget {
  const ExplanationBox({
    super.key,
    required this.correct,
    required this.explanation,
  });
  final bool correct;
  final String explanation;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xFFF6F6F1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          correct ? Icons.lightbulb_outline_rounded : Icons.menu_book_outlined,
          size: 18,
          color: const Color(0xFF71806F),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                correct ? 'A little more context' : 'Here’s the idea',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF36453A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                explanation,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: Color(0xFF69736A),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class NextButton extends StatelessWidget {
  const NextButton({super.key, required this.isLast, required this.onPressed});
  final bool isLast;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFF344C3C),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    ),
    iconAlignment: IconAlignment.end,
    label: Text(
      isLast ? 'See your results' : 'Next question',
      style: const TextStyle(
        fontFamily: 'sans-serif',
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
  );
}

class TodayNote extends StatelessWidget {
  const TodayNote({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(
            Icons.wb_twilight_rounded,
            color: Color(0xFF9C8454),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'A THOUGHT FOR TODAY',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontFamily: 'sans-serif',
              fontSize: 9,
              letterSpacing: 1.2,
              color: const Color(0xFF73786E),
            ),
          ),
        ],
      ),
      const SizedBox(height: 17),
      const Text(
        '“The more that you read, the more things you will know. The more that you learn, the more places you’ll go.”',
        style: TextStyle(
          fontSize: 17,
          height: 1.5,
          fontStyle: FontStyle.italic,
          color: Color(0xFF455349),
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        '— DR. SEUSS',
        style: TextStyle(
          fontFamily: 'sans-serif',
          fontSize: 9,
          letterSpacing: 1.6,
          color: Color(0xFF92988F),
        ),
      ),
    ],
  );
}

class ScoreCard extends StatelessWidget {
  const ScoreCard({super.key, required this.viewModel});
  final QuizViewModel viewModel;
  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
    stream: viewModel.scoreUpdates,
    initialData: viewModel.score,
    builder: (context, snapshot) => Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF1EB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.auto_graph_rounded,
            color: Color(0xFF5E795F),
            size: 21,
          ),
        ),
        const SizedBox(width: 13),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'YOUR SCORE',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontFamily: 'sans-serif',
                fontSize: 9,
                letterSpacing: 1.4,
                color: const Color(0xFF858D84),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${snapshot.data ?? viewModel.score} correct so far',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 14,
                color: const Color(0xFF425349),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
