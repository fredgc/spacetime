import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:spacetime/my_app.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    PackageInfo.setMockInitialValues(
      appName: "Mock Spacetime",
      packageName: "spacetime.gchouse.org",
      version: "mock version",
      buildNumber: "mock build number",
      buildSignature: "signature",
    );
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();

    final app = MyApp.fullApp();
    app.manager.drive_access.isTesting = true;
    await app.initialize();
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();
  });
}
