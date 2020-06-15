import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';

/// Should be called once Rate my app has been initialized.
typedef RateMyAppInitializedCallback = Function(BuildContext context, RateMyApp rateMyApp);

/// Allows to build a widget and initialize Rate my app.
class RateMyAppBuilder extends StatefulWidget {
  /// The widget builder.
  final WidgetBuilder builder;

  /// The Rate my app instance.
  final RateMyApp rateMyApp;

  /// Called when rate my app has been initialized.
  final RateMyAppInitializedCallback onInitialized;

  /// Creates a new rate my app builder instance.
  const RateMyAppBuilder({
    @required this.builder,
    this.rateMyApp,
    this.onInitialized,
  }) : assert(builder != null);

  @override
  State<StatefulWidget> createState() => _RateMyAppBuilderState();
}

/// The rate my app builder state.
class _RateMyAppBuilderState extends State<RateMyAppBuilder> {
  /// The current Rate my app instance.
  RateMyApp rateMyApp;

  @override
  void initState() {
    super.initState();

    rateMyApp = widget.rateMyApp ?? RateMyApp();
    initRateMyApp();
  }

  /// Allows to init rate my app. Should be called one time per app launch.
  Future<void> initRateMyApp() async {
    await rateMyApp.init();

    if (widget.onInitialized != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onInitialized(context, rateMyApp);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
