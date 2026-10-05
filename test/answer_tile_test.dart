import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/widgets/quiz_surfaces.dart';

Future<Color> _answerBorderColor(
  WidgetTester tester, {
  required bool selected,
  required bool correct,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AnswerTile(
          index: 0,
          text: 'Answer',
          selected: selected,
          correct: correct,
          graded: true,
          revealed: selected,
          onTap: () {},
        ),
      ),
    ),
  );

  final tile = tester.widget<AnimatedContainer>(
    find
        .ancestor(
          of: find.text('Answer'),
          matching: find.byType(AnimatedContainer),
        )
        .first,
  );
  final decoration = tile.decoration! as BoxDecoration;
  return (decoration.border! as Border).top.color;
}

void main() {
  testWidgets('shows selected correct answers in green', (tester) async {
    expect(
      await _answerBorderColor(tester, selected: true, correct: true),
      const Color(0xFF538066).withValues(alpha: .7),
    );
  });

  testWidgets('shows selected wrong answers in red', (tester) async {
    expect(
      await _answerBorderColor(tester, selected: true, correct: false),
      const Color(0xFFB66A58).withValues(alpha: .7),
    );
  });
}
