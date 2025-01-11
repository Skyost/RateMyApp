import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';

import 'content.dart';

/// First plugin test method.
void main() {
  WidgetsFlutterBinding.ensureInitialized(); // This allows to use async methods in the main method without any problem.
  runApp(const _RateMyAppTestApp());
}

/// The body of the main Rate my app test widget.
class _RateMyAppTestApp extends StatefulWidget {
  /// Creates a new Rate my app test app instance.
  const _RateMyAppTestApp();

  @override
  State<StatefulWidget> createState() => _RateMyAppTestAppState();
}

/// The body state of the main Rate my app test widget.
class _RateMyAppTestAppState extends State<_RateMyAppTestApp> {
  /// The widget builder.
  WidgetBuilder builder = buildProgressIndicator;

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Rate my app !'),
          ),
          body: RateMyAppBuilder(
            rateMyApp: RateMyApp(
              googlePlayIdentifier: 'app.openauthenticator',
              appStoreIdentifier: '6479272927',
            ),
            builder: builder,
            onInitialized: (context, rateMyApp) {
              setState(() => builder = (context) => ContentWidget(rateMyApp: rateMyApp));
              for (Condition condition in rateMyApp.conditions) {
                if (condition is DebuggableCondition) {
                  condition.printToConsole(); // We iterate through our list of conditions and we print all debuggable ones.
                }
              }

              if (kDebugMode) {
                print('Are all conditions met : ${rateMyApp.shouldOpenDialog ? 'Yes' : 'No'}');
              }

              if (rateMyApp.shouldOpenDialog) {
                rateMyApp.showRateDialog(context);
              }
            },
          ),
        ),
      );

  /// Builds the progress indicator, allowing to wait for Rate my app to initialize.
  static Widget buildProgressIndicator(BuildContext context) => const Center(child: CircularProgressIndicator());
}
