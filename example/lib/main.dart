import 'package:flutter/material.dart';

import 'package:rate_my_app/rate_my_app.dart';

/// Main rate my app instance.
RateMyApp _rateMyApp = RateMyApp();

/// First plugin test method.
void main() {
  _rateMyApp.init().then((v) {
    runApp(_RateMyAppTestApp());
    print('Minimum days : ' + _rateMyApp.minDays.toString());
    print('Minimum launches : ' + _rateMyApp.minLaunches.toString());

    print('Base launch : ' + _dateToString(_rateMyApp.baseLaunchDate));
    print('Launches : ' + _rateMyApp.launches.toString());
    print('Do not open again ? ' + (_rateMyApp.doNotOpenAgain ? 'Yes' : 'No'));

    print('Are conditions met ? ' + (_rateMyApp.shouldOpenDialog ? 'Yes' : 'No'));
  });
}

/// Returns a formatted date string.
String _dateToString(DateTime date) => date.day.toString().padLeft(2, '0') + '/' + date.month.toString().padLeft(2, '0') + '/' + date.year.toString();

/// The main rate my app test widget.
class _RateMyAppTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('Rate my app !'),
          ),
          body: _RateMyAppTestAppBody(),
        ),
      );
}

/// The body of the main rate my app test widget.
class _RateMyAppTestAppBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RateMyAppTestAppBodyState();
}

/// The body state of the main rate my app test widget.
class _RateMyAppTestAppBodyState extends State<_RateMyAppTestAppBody> {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Minimum days : ' + _rateMyApp.minDays.toString()),
            Text('Minimum launches : ' + _rateMyApp.minLaunches.toString()),
            Text('Base launch : ' + _dateToString(_rateMyApp.baseLaunchDate)),
            Text('Launches : ' + _rateMyApp.launches.toString()),
            Text('Do not open again ? ' + (_rateMyApp.doNotOpenAgain ? 'Yes' : 'No')),
            Text('Are conditions met ? ' + (_rateMyApp.shouldOpenDialog ? 'Yes' : 'No')),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: RaisedButton(
                child: Text('Launch "Rate my app" dialog'),
                onPressed: () => _rateMyApp.showRateDialog(context).then((v) => setState(() {})),
              ),
            ),
            RaisedButton(
              child: Text('Reset'),
              onPressed: () => _rateMyApp.reset().then((v) => setState(() {})),
            )
          ],
        ),
      );
}
