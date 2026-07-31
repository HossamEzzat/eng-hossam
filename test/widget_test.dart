import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/main.dart';

void main() {
  testWidgets('App boots', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: EngHossamApp()));
    await tester.pump(const Duration(milliseconds: 500));
    final hasInstructor =
        find.textContaining('بشمهندس').evaluate().isNotEmpty ||
            find.textContaining('Eng. Hossam').evaluate().isNotEmpty;
    expect(hasInstructor, isTrue);
  });
}
