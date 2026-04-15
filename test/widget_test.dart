import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_score/main.dart';
import 'package:get/get.dart';
import 'package:cricket_score/features/app_controller.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    Get.put(AppController());
    await tester.pumpWidget(const CricketScoreApp());
    expect(find.text('Cricket Scorer Pro'), findsOneWidget);
  });
}
