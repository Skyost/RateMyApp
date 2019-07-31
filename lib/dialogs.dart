import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

/// The Android rate my app dialog.
class RateMyAppDialog extends StatelessWidget {
  /// The rate my app instance.
  final RateMyApp _rateMyApp;

  /// The dialog's title.
  final String _title;

  /// The dialog's message.
  final String _message;

  /// The dialog's rate button.
  final String _rateButton;

  /// The dialog's no button.
  final String _noButton;

  /// The dialog's later button.
  final String _laterButton;

  /// Creates a new rate my app dialog.
  RateMyAppDialog(this._rateMyApp, this._title, this._message, this._rateButton, this._noButton, this._laterButton);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(_title),
        content: SingleChildScrollView(
          child: Text(_message),
        ),
        actions: [
          Wrap(
            alignment: WrapAlignment.end,
            children: [
              FlatButton(
                child: Text(_rateButton),
                onPressed: () {
                  _rateMyApp.doNotOpenAgain = true;
                  _rateMyApp.save().then((v) {
                    Navigator.pop(context);
                    _rateMyApp.launchStore();
                  });
                },
              ),
              FlatButton(
                child: Text(_laterButton),
                onPressed: () {
                  _rateMyApp.baseLaunchDate = _rateMyApp.baseLaunchDate.add(Duration(
                    days: _rateMyApp.remindDays,
                  ));
                  _rateMyApp.launches -= _rateMyApp.remindLaunches;
                  _rateMyApp.save().then((v) => Navigator.pop(context));
                },
              ),
              FlatButton(
                child: Text(_noButton),
                onPressed: () {
                  _rateMyApp.doNotOpenAgain = true;
                  _rateMyApp.save().then((v) => Navigator.pop(context));
                },
              ),
            ],
          ),
        ],
      );

  /// Opens the dialog.
  static Future<void> openDialog(BuildContext context, RateMyApp rateMyApp, String title, String message, String rateButton, String noButton, String laterButton) async => await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => RateMyAppDialog(rateMyApp, title, message, rateButton, noButton, laterButton),
      );
}

/// The rate my app star dialog.
class RateMyAppStarDialog extends StatefulWidget {
  /// The dialog's title.
  final String _title;

  /// The dialog's message.
  final String _message;

  /// The rating changed callback.
  final List<Widget> Function(double) _onRatingChanged;

  /// The smooth star rating style.
  final StarRatingOptions _starRatingOptions;

  /// Creates a new rate my app star dialog.
  RateMyAppStarDialog(this._title, this._message, this._onRatingChanged, this._starRatingOptions);

  @override
  State<StatefulWidget> createState() => RateMyAppStarDialogState();

  /// Opens the dialog.
  static Future<void> openDialog(BuildContext context, String title, String message, List<Widget> Function(double) onRatingChanged, StarRatingOptions starRatingOptions) async => await showDialog(
        context: context,
        builder: (context) => RateMyAppStarDialog(title, message, onRatingChanged, starRatingOptions),
      );
}

/// The rate my app star dialog state.
class RateMyAppStarDialogState extends State<RateMyAppStarDialog> {
  /// The current rating.
  double _currentRating;

  @override
  void initState() {
    _currentRating = widget._starRatingOptions.initialRating;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget._title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              child: Text(widget._message),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: SmoothStarRating(
                onRatingChanged: (rating) {
                  setState(() {
                    _currentRating = rating;
                  });
                },
                color: widget._starRatingOptions.starsFillColor,
                borderColor: widget._starRatingOptions.starsBorderColor,
                spacing: widget._starRatingOptions.starsSpacing,
                size: widget._starRatingOptions.starsSize,
                allowHalfRating: widget._starRatingOptions.allowHalfRating,
                rating: _currentRating == null ? 0 : _currentRating.toDouble(),
              ),
            ),
          ],
        ),
        actions: widget._onRatingChanged(_currentRating),
      );
}
