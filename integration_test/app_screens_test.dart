
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wilson_crepe/main.dart' as app;

void main() {
  final binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Launch Wilson Crepe and capture initial screen', (
    tester,
  ) async {
    await app.main();

    // Wait for the splash animation and navigation.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 5)),
    );

    await tester.pumpAndSettle(
      const Duration(milliseconds: 500),
    );

    await binding.takeScreenshot('wilson-crepe-initial-screen');
  });
}
