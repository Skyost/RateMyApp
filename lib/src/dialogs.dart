import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:rate_my_app/src/core.dart';
import 'package:rate_my_app/src/style.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

/// A simple dialog button click listener.
typedef RateMyAppDialogButtonClickListener = bool Function(
    RateMyAppDialogButton button);

/// Validates a state when called in a function.
typedef Validator = bool Function();

/// Allows to dynamically build actions.
typedef DialogActionsBuilder = List<Widget> Function(BuildContext context);

/// Allows to dynamically build actions according to the specified rating.
typedef StarDialogActionsBuilder = List<Widget> Function(
    BuildContext context, double stars);

/// A validator that always returns true.
bool validatorTrue() => true;

/// A validator that always returns false.
bool validatorFalse() => true;

/// The Android Rate my app dialog.
class RateMyAppDialog extends StatelessWidget {
  /// The Rate my app instance.
  final RateMyApp rateMyApp;

  /// The dialog's title.
  final String title;

  /// The dialog's message.
  final String message;

  /// The actions builder.
  final DialogActionsBuilder actionsBuilder;

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

  /// Creates a new Rate my app dialog.
  const RateMyAppDialog(
    this.rateMyApp, {
    @required this.title,
    @required this.message,
    this.actionsBuilder,
    @required this.rateButton,
    @required this.noButton,
    @required this.laterButton,
    this.listener,
    @required this.dialogStyle,
  })  : assert(title != null),
        assert(message != null),
        assert(rateButton != null),
        assert(noButton != null),
        assert(laterButton != null),
        assert(dialogStyle != null);

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
        contentPadding: dialogStyle.contentPadding,
        shape: dialogStyle.dialogShape,
        actions: (actionsBuilder ?? _defaultActionsBuilder)(context),
      );

  /// Opens the dialog.
  static Future<void> openDialog(
    BuildContext context,
    RateMyApp rateMyApp, {
    @required String title,
    @required String message,
    @required String rateButton,
    @required String noButton,
    @required String laterButton,
    RateMyAppDialogButtonClickListener listener,
    @required DialogStyle dialogStyle,
    DialogActionsBuilder actionsBuilder,
    VoidCallback onDismissed,
  }) async {
    RateMyAppDialogButton clickedButton =
        await showDialog<RateMyAppDialogButton>(
      context: context,
      builder: (context) => RateMyAppDialog(
        rateMyApp,
        title: title,
        message: message,
        actionsBuilder: actionsBuilder,
        rateButton: rateButton,
        noButton: noButton,
        laterButton: laterButton,
        listener: listener,
        dialogStyle: dialogStyle,
      ),
    );

    if (clickedButton == null && onDismissed != null) {
      onDismissed();
    }
  }

  List<Widget> _defaultActionsBuilder(BuildContext context) => [
        Wrap(
          alignment: WrapAlignment.end,
          children: [
            RateMyAppRateButton(
              rateMyApp,
              text: rateButton,
              validator: () =>
                  listener == null || listener(RateMyAppDialogButton.rate),
            ),
            RateMyAppLaterButton(
              rateMyApp,
              text: laterButton,
              validator: () =>
                  listener == null || listener(RateMyAppDialogButton.later),
            ),
            RateMyAppNoButton(
              rateMyApp,
              text: noButton,
              validator: () =>
                  listener == null || listener(RateMyAppDialogButton.no),
            ),
          ],
        ),
      ];
}

/// The Rate my app star dialog.
class RateMyAppStarDialog extends StatefulWidget {
  /// The Rate my app instance.
  final RateMyApp rateMyApp;

  /// The dialog's title.
  final String title;

  /// The dialog's header.
  final Widget header;

  /// The rating changed callback.
  final StarDialogActionsBuilder actionsBuilder;

  /// The dialog's style.
  final DialogStyle dialogStyle;

  /// The smooth star rating style.
  final StarRatingOptions starRatingOptions;

  /// Creates a new Rate my app star dialog.
  const RateMyAppStarDialog(
    this.rateMyApp, {
    @required this.title,
    @required this.header,
    this.actionsBuilder,
    @required this.dialogStyle,
    @required this.starRatingOptions,
  })  : assert(title != null),
        assert(header != null),
        assert(dialogStyle != null),
        assert(starRatingOptions != null);

  @override
  State<StatefulWidget> createState() => RateMyAppStarDialogState();

  /// Opens the dialog.
  static Future<void> openDialog(
    BuildContext context,
    RateMyApp rateMyApp, {
    @required String title,
    TextAlign titleAlign,
    @required Widget header,
    TextAlign messageAlign,
    StarDialogActionsBuilder actionsBuilder,
    @required DialogStyle dialogStyle,
    @required StarRatingOptions starRatingOptions,
    VoidCallback onDismissed,
  }) async {
    RateMyAppDialogButton clickedButton = await showDialog(
      context: context,
      builder: (context) => RateMyAppStarDialog(
        rateMyApp,
        title: title,
        header: header,
        actionsBuilder: actionsBuilder,
        dialogStyle: dialogStyle,
        starRatingOptions: starRatingOptions,
      ),
    );

    if (clickedButton == null && onDismissed != null) {
      onDismissed();
    }
  }

  /// Used when there is no onRatingChanged callback.
  List<Widget> _defaultOnRatingChanged(BuildContext context, double rating) => [
        RateMyAppRateButton(
          rateMyApp,
          text: 'RATE',
        ),
        RateMyAppLaterButton(
          rateMyApp,
          text: 'MAYBE LATER',
        ),
        RateMyAppNoButton(
          rateMyApp,
          text: 'NO',
        ),
      ];
}

/// The Rate my app star dialog state.
class RateMyAppStarDialogState extends State<RateMyAppStarDialog> {
  /// The current rating.
  double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.starRatingOptions.initialRating;
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
                child: widget.header,
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
                halfFilledIconData: widget.starRatingOptions.halfFilledIconData,
                filledIconData: widget.starRatingOptions.filledIconData,
                rating:
                    _currentRating == null ? 0.0 : _currentRating.toDouble(),
              ),
            ],
          ),
        ),
        contentPadding: widget.dialogStyle.contentPadding,
        shape: widget.dialogStyle.dialogShape,
        actions: (widget.actionsBuilder ?? widget._defaultOnRatingChanged)(
            context, _currentRating),
      );
}

/// A Rate my app dialog button with a text, a validator and a callback.
abstract class _RateMyAppDialogButton extends StatelessWidget {
  /// The Rate my app instance.
  final RateMyApp rateMyApp;

  /// The button text.
  final String text;

  /// The state validator (whether this button should have an effect).
  final Validator validator;

  /// Called when the action has been executed.
  final VoidCallback callback;

  /// Creates a new Rate my app button widget instance.
  const _RateMyAppDialogButton(
    this.rateMyApp, {
    @required this.text,
    this.validator = validatorTrue,
    this.callback,
  }) : assert(text != null);

  @override
  Widget build(BuildContext context) => FlatButton(
        child: Text(text),
        onPressed: () async {
          if (validator != null && !validator()) {
            return;
          }

          await onButtonClicked(context);

          if (callback != null) {
            callback();
          }
        },
      );

  Future<void> onButtonClicked(BuildContext context);
}

/// The Rate my app "rate" button widget.
class RateMyAppRateButton extends _RateMyAppDialogButton {
  /// Creates a new Rate my app "rate" button widget instance.
  const RateMyAppRateButton(
    RateMyApp rateMyApp, {
    @required String text,
    Validator validator,
    VoidCallback callback,
  }) : super(
          rateMyApp,
          text: text,
          validator: validator,
          callback: callback,
        );

  @override
  Future<void> onButtonClicked(BuildContext context) {
    return rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed).then((_) {
      Navigator.pop<RateMyAppDialogButton>(context, RateMyAppDialogButton.rate);
      rateMyApp.launchStore();
    });
  }
}

/// The Rate my app "later" button widget.
class RateMyAppLaterButton extends _RateMyAppDialogButton {
  /// Creates a new Rate my app "later" button widget instance.
  const RateMyAppLaterButton(
    RateMyApp rateMyApp, {
    @required String text,
    Validator validator,
    VoidCallback callback,
  }) : super(
          rateMyApp,
          text: text,
          validator: validator,
          callback: callback,
        );

  @override
  Future<void> onButtonClicked(BuildContext context) =>
      rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed).then((_) {
        Navigator.pop<RateMyAppDialogButton>(
            context, RateMyAppDialogButton.later);
      });
}

/// The Rate my app "no" button widget.
class RateMyAppNoButton extends _RateMyAppDialogButton {
  /// Creates a new Rate my app "no" button widget instance.
  const RateMyAppNoButton(
    RateMyApp rateMyApp, {
    @required String text,
    Validator validator,
    VoidCallback callback,
  }) : super(
          rateMyApp,
          text: text,
          validator: validator,
          callback: callback,
        );

  @override
  Future<void> onButtonClicked(BuildContext context) =>
      rateMyApp.callEvent(RateMyAppEventType.noButtonPressed).then((_) {
        Navigator.pop<RateMyAppDialogButton>(context, RateMyAppDialogButton.no);
      });
}

/// Represents a Rate my app dialog button.
enum RateMyAppDialogButton {
  /// The "rate" button.
  rate,

  /// The "later" button.
  later,

  /// The "no" button.
  no,
}
