import 'package:flutter/material.dart';

import '../viewmodels/quiz_view_model.dart';
import '../widgets/quiz_surfaces.dart';

class CategoryListView extends StatelessWidget {
  const CategoryListView({
    super.key,
    required this.viewModel,
    required this.onSelect,
  });

  final QuizViewModel viewModel;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'YOUR LEARNING PATH',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontFamily: 'sans-serif',
          fontSize: 10,
          letterSpacing: 2.2,
          color: const Color(0xFF67806D),
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'One topic at a time.',
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontSize: MediaQuery.sizeOf(context).width >= 850 ? 48 : 38,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Complete each topic to unlock the next.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 28),
      QuizCard(
        child: Padding(
          padding: EdgeInsets.all(
            MediaQuery.sizeOf(context).width >= 850 ? 30 : 18,
          ),
          child: Column(
            children: [
              for (var index = 0; index < viewModel.categories.length; index++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: index == viewModel.categories.length - 1 ? 0 : 12,
                  ),
                  child: _CategoryTile(
                    index: index,
                    category: viewModel.categories[index],
                    questionCount: viewModel.questionCountFor(
                      viewModel.categories[index],
                    ),
                    unlocked: viewModel.isCategoryUnlocked(
                      viewModel.categories[index],
                    ),
                    completed: viewModel.isCategoryCompleted(
                      viewModel.categories[index],
                    ),
                    onTap: () => onSelect(viewModel.categories[index]),
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.index,
    required this.category,
    required this.questionCount,
    required this.unlocked,
    required this.completed,
    required this.onTap,
  });

  final int index;
  final String category;
  final int questionCount;
  final bool unlocked;
  final bool completed;
  final VoidCallback onTap;

  Color get _categoryColor {
    final normalized = category.toLowerCase();
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

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor;
    final status = completed
        ? 'COMPLETED'
        : unlocked
        ? 'AVAILABLE'
        : 'COMPLETE PREVIOUS FIRST';

    return Material(
      color: unlocked ? const Color(0xFFFCFCFA) : const Color(0xFFF5F5F1),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: unlocked
                  ? const Color(0xFFE5E7E0)
                  : const Color(0xFFECECE7),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: unlocked
                      ? color.withValues(alpha: .10)
                      : const Color(0xFFE9EAE5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: unlocked
                    ? Text(
                        '${index + 1}'.padLeft(2, '0'),
                        style: TextStyle(
                          fontFamily: 'sans-serif',
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      )
                    : const Icon(
                        Icons.lock_outline_rounded,
                        size: 18,
                        color: Color(0xFF8B9189),
                      ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 17,
                        color: const Color(0xFF354339),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$questionCount ${questionCount == 1 ? 'question' : 'questions'} · $status',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'sans-serif',
                        fontSize: 9,
                        letterSpacing: .7,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                completed
                    ? Icons.check_circle_outline_rounded
                    : unlocked
                    ? Icons.arrow_forward_rounded
                    : Icons.lock_outline_rounded,
                size: 19,
                color: unlocked ? color : const Color(0xFF9A9F98),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
