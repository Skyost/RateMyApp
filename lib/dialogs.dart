import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

/// The Android rate my app dialog.
class RateMyAppDialog extends StatelessWidget {
  /// The rate my app instance.
  final RateMyApp _rateMyApp;

  /// The dialog's title.
  final String _title;

  /// The dialog's title alignment.
  final TextAlign _titleAlign;

  /// The dialog's message.
  final String _message;

  /// The dialog's message alignment.
  final TextAlign _messageAlign;

  /// The dialog's rate button.
  final String _rateButton;

  /// The dialog's no button.
  final String _noButton;

  /// The dialog's later button.
  final String _laterButton;

  // The dialogs content padding
  final EdgeInsetsGeometry _titlePadding;

  // The dialogs content padding
  final EdgeInsetsGeometry _contentPadding;

  // The dialogs button text color
  final TextStyle _buttonTextStyle;

  /// Creates a new rate my app dialog.
  RateMyAppDialog(this._rateMyApp, this._title, this._titleAlign, this._message, this._messageAlign, this._rateButton, this._noButton, this._laterButton, this._titlePadding, this._contentPadding, this._buttonTextStyle);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(
          _title,
          textAlign: _titleAlign,
        ),
        content: SingleChildScrollView(
          child: Text(
            _message,
            textAlign: _titleAlign,
          ),
        ),
        titlePadding: _titlePadding ?? EdgeInsets.fromLTRB(24.0, 24.0, 24.0, _message == null ? 20.0 : 0.0),
        contentPadding: _contentPadding ?? const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
        actions: [
          Wrap(
            alignment: WrapAlignment.end,
            children: [
              FlatButton(
                child: Text(_rateButton, style: _buttonTextStyle),
                onPressed: () {
                  _rateMyApp.doNotOpenAgain = true;
                  _rateMyApp.save().then((v) {
                    Navigator.pop(context);
                    _rateMyApp.launchStore();
                  });
                },
              ),
              FlatButton(
                child: Text(_laterButton, style: _buttonTextStyle),
                onPressed: () {
                  _rateMyApp.baseLaunchDate = _rateMyApp.baseLaunchDate.add(Duration(
                    days: _rateMyApp.remindDays,
                  ));
                  _rateMyApp.launches -= _rateMyApp.remindLaunches;
                  _rateMyApp.save().then((v) => Navigator.pop(context));
                },
              ),
              FlatButton(
                child: Text(_noButton, style: _buttonTextStyle),
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
  static Future<void> openDialog(
    BuildContext context,
    RateMyApp rateMyApp,
    String title,
    TextAlign titleAlign,
    String message,
    TextAlign messageAlign,
    String rateButton,
    String noButton,
    String laterButton,
    EdgeInsetsGeometry titlePadding,
    EdgeInsetsGeometry contentPadding,
    TextStyle buttonTextStyle,
  ) async =>
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => RateMyAppDialog(rateMyApp, title, titleAlign, message, messageAlign, rateButton, noButton, laterButton, titlePadding, contentPadding, buttonTextStyle),
      );
}

/// The rate my app star dialog.
class RateMyAppStarDialog extends StatefulWidget {
  /// The dialog's title.
  final String _title;

  /// The dialog's title alignment.
  final TextAlign _titleAlign;

  /// The dialog's message.
  final String _message;

  /// The dialog's message alignment.
  final TextAlign _messageAlign;

  /// The rating changed callback.
  final List<Widget> Function(double) _onRatingChanged;

  /// The smooth star rating style.
  final StarRatingOptions _starRatingOptions;

  /// Creates a new rate my app star dialog.
  RateMyAppStarDialog(this._title, this._titleAlign, this._message, this._messageAlign, this._onRatingChanged, this._starRatingOptions);

  @override
  State<StatefulWidget> createState() => RateMyAppStarDialogState();

  /// Opens the dialog.
  static Future<void> openDialog(
    BuildContext context,
    String title,
    TextAlign titleAlign,
    String message,
    TextAlign messageAlign,
    List<Widget> Function(double) onRatingChanged,
    StarRatingOptions starRatingOptions,
  ) async =>
      await showDialog(
        context: context,
        builder: (context) => RateMyAppStarDialog(title, titleAlign, message, messageAlign, onRatingChanged, starRatingOptions),
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
        title: Text(
          widget._title,
          textAlign: widget._titleAlign,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              child: Text(
                widget._message,
                textAlign: widget._messageAlign,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: SmoothStarRating(
                onRatingChanged: (rating) {
                  setState(() => _currentRating = rating);
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
