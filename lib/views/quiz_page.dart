import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/quiz_providers.dart';
import '../viewmodels/quiz_view_model.dart';
import 'category_list_view.dart';
import 'quiz_question_view.dart';
import 'quiz_results_view.dart';
import '../widgets/quiz_surfaces.dart';

class QuizPage extends ConsumerWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(quizViewModelProvider);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 850;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 64 : 22,
                vertical: isWide ? 26 : 18,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Masthead(
                        isWide: isWide,
                        onRefresh: viewModel.refreshCategories,
                      ),
                      SizedBox(height: isWide ? 44 : 30),
                      switch (viewModel.phase) {
                        QuizPhase.loading => const _LoadingPanel(),
                        QuizPhase.submitting => const _LoadingPanel(),
                        QuizPhase.error => _ErrorPanel(
                          message:
                              '${viewModel.error ?? 'Something went wrong.'}',
                          onRetry: viewModel.retry,
                        ),
                        QuizPhase.categories => CategoryListView(
                          viewModel: viewModel,
                          onSelect: (category) {
                            if (!viewModel.isCategoryUnlocked(category)) {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Complete the previous category first.',
                                    ),
                                  ),
                                );
                              return;
                            }
                            unawaited(viewModel.openCategory(category));
                          },
                        ),
                        QuizPhase.complete => ResultsPanel(
                          viewModel: viewModel,
                        ),
                        QuizPhase.ready => QuizQuestionView(
                          viewModel: viewModel,
                          isWide: isWide,
                        ),
                      },
                      const SizedBox(height: 38),
                      const _Footer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Masthead extends StatelessWidget {
  const _Masthead({required this.isWide, required this.onRefresh});
  final bool isWide;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF26382C),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFFE7DAB8),
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TECHAXE QUIZ APP',
              style: TextStyle(
                fontFamily: 'sans-serif',
                fontSize: 12,
                letterSpacing: 2.3,
                fontWeight: FontWeight.w800,
                color: Color(0xFF29382F),
              ),
            ),
            Text(
              'THE DAILY QUIZ',
              style: TextStyle(
                fontFamily: 'sans-serif',
                fontSize: 9,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (isWide) ...[
          const Text(
            'A little curiosity, every day.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF737B74),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 24),
        ],
        IconButton(
          tooltip: 'Refresh questions from the server',
          onPressed: onRefresh,
          icon: const Icon(
            Icons.refresh_rounded,
            size: 19,
            color: Color(0xFF697B6D),
          ),
        ),
        const Icon(Icons.wb_sunny_outlined, size: 18, color: Color(0xFF958864)),
        if (isWide) ...[
          const SizedBox(width: 8),
          const Text(
            'TODAY’S EDITION',
            style: TextStyle(
              fontFamily: 'sans-serif',
              fontSize: 10,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w600,
              color: Color(0xFF787C72),
            ),
          ),
        ],
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.eco_outlined, size: 14, color: Color(0xFF92988F)),
      SizedBox(width: 7),
      Text(
        'MADE FOR THE JOY OF KNOWING',
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

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 450,
    child: Center(
      child: CircularProgressIndicator(
        color: Color(0xFF4D715A),
        strokeWidth: 2,
      ),
    ),
  );
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => QuizCard(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 38,
            color: Color(0xFF787C72),
          ),
          const SizedBox(height: 18),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}
