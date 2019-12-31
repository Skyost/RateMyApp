import 'package:flutter/material.dart';
import 'package:rate_my_app/src/core.dart';
import 'package:rate_my_app/src/style.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

/// A simple dialog button click listener.
typedef bool RateMyAppDialogButtonClickListener(RateMyAppDialogButton button);

/// The Android rate my app dialog.
class RateMyAppDialog extends StatelessWidget {
  /// The rate my app instance.
  final RateMyApp _rateMyApp;

  /// The dialog's title.
  final String title;

  /// The dialog's message.
  final String message;

  /// The dialog's rate button.
  final String rateButton;

  /// The dialog's no button.
  final String noButton;

  /// The dialog's later button.
  final String laterButton;

  /// The buttons listener.
  final RateMyAppDialogButtonClickListener listener;

  /// The dialog's style.
  final DialogStyle dialogStyle;

  /// Creates a new rate my app dialog.
  const RateMyAppDialog(
    this._rateMyApp, {
    this.title,
    this.message,
    this.rateButton,
    this.noButton,
    this.laterButton,
    this.listener,
    this.dialogStyle,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Padding(
          padding: dialogStyle.titlePadding,
          child: Text(
            title,
            style: dialogStyle.titleStyle,
            textAlign: dialogStyle.titleAlign,
          ),
        ),
        content: SingleChildScrollView(
          child: Padding(
            padding: dialogStyle.messagePadding,
            child: Text(
              message,
              style: dialogStyle.messageStyle,
              textAlign: dialogStyle.messageAlign,
            ),
          ),
        ),
        actions: [
          Wrap(
            alignment: WrapAlignment.end,
            children: [
              _createRateButton(context),
              _createLaterButton(context),
              _createNoButton(context),
            ],
          ),
        ],
      );

  /// Creates the rate button.
  Widget _createRateButton(BuildContext context) => FlatButton(
        child: Text(rateButton),
        onPressed: () {
          if (listener != null && !listener(RateMyAppDialogButton.rate)) {
            return;
          }

          _rateMyApp.doNotOpenAgain = true;
          _rateMyApp.save().then((v) {
            Navigator.pop(context);
            _rateMyApp.launchStore();
          });
        },
      );

  /// Creates the later button.
  Widget _createLaterButton(BuildContext context) => FlatButton(
        child: Text(laterButton),
        onPressed: () {
          if (listener != null && !listener(RateMyAppDialogButton.later)) {
            return;
          }

          _rateMyApp.baseLaunchDate = _rateMyApp.baseLaunchDate.add(Duration(
            days: _rateMyApp.remindDays,
          ));
          _rateMyApp.launches -= _rateMyApp.remindLaunches;
          _rateMyApp.save().then((v) => Navigator.pop(context));
        },
      );

  /// Creates the no button.
  Widget _createNoButton(BuildContext context) => FlatButton(
        child: Text(noButton),
        onPressed: () {
          if (listener != null && !listener(RateMyAppDialogButton.no)) {
            return;
          }

          _rateMyApp.doNotOpenAgain = true;
          _rateMyApp.save().then((v) => Navigator.pop(context));
        },
      );

  /// Opens the dialog.
  static Future<void> openDialog(
    BuildContext context,
    RateMyApp rateMyApp, {
    String title,
    String message,
    String rateButton,
    String noButton,
    String laterButton,
    RateMyAppDialogButtonClickListener listener,
    DialogStyle dialogStyle,
  }) =>
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => RateMyAppDialog(
          rateMyApp,
          title: title,
          message: message,
          rateButton: rateButton,
          noButton: noButton,
          laterButton: laterButton,
          listener: listener,
          dialogStyle: dialogStyle,
        ),
      );
}

/// Represents a rate my app dialog button.
enum RateMyAppDialogButton {
  /// The "rate" button.
  rate,

  /// The "later" button.
  later,

  /// The "no" button.
  no,
}

/// The rate my app star dialog.
class RateMyAppStarDialog extends StatefulWidget {
  /// The dialog's title.
  final String title;

  /// The dialog's message.
  final String message;

  /// The rating changed callback.
  final List<Widget> Function(double) onRatingChanged;

  /// The dialog's style.
  final DialogStyle dialogStyle;

  /// The smooth star rating style.
  final StarRatingOptions starRatingOptions;

  /// Creates a new rate my app star dialog.
  const RateMyAppStarDialog({
    this.title,
    this.message,
    this.onRatingChanged,
    this.dialogStyle,
    this.starRatingOptions,
  });

  @override
  State<StatefulWidget> createState() => RateMyAppStarDialogState();

  /// Opens the dialog.
  static Future<void> openDialog(
    BuildContext context, {
    String title,
    TextAlign titleAlign,
    String message,
    TextAlign messageAlign,
    List<Widget> Function(double) onRatingChanged,
    DialogStyle dialogStyle,
    StarRatingOptions starRatingOptions,
  }) =>
      showDialog(
        context: context,
        builder: (context) => RateMyAppStarDialog(
          title: title,
          message: message,
          onRatingChanged: onRatingChanged,
          dialogStyle: dialogStyle,
          starRatingOptions: starRatingOptions,
        ),
      );
}

/// The rate my app star dialog state.
class RateMyAppStarDialogState extends State<RateMyAppStarDialog> {
  /// The current rating.
  double _currentRating;

  @override
  void initState() {
    _currentRating = widget.starRatingOptions.initialRating;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Padding(
          padding: widget.dialogStyle.titlePadding,
          child: Text(
            widget.title,
            style: widget.dialogStyle.titleStyle,
            textAlign: widget.dialogStyle.titleAlign,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: widget.dialogStyle.messagePadding,
                child: Text(
                  widget.message,
                  style: widget.dialogStyle.messageStyle,
                  textAlign: widget.dialogStyle.messageAlign,
                ),
              ),
              SmoothStarRating(
                onRatingChanged: (rating) {
                  setState(() => _currentRating = rating);
                },
                color: widget.starRatingOptions.starsFillColor,
                borderColor: widget.starRatingOptions.starsBorderColor,
                spacing: widget.starRatingOptions.starsSpacing,
                size: widget.starRatingOptions.starsSize,
                allowHalfRating: widget.starRatingOptions.allowHalfRating,
                rating: _currentRating == null ? 0 : _currentRating.toDouble(),
              ),
            ],
          ),
        ),
        actions: widget.onRatingChanged(_currentRating),
      );
}
