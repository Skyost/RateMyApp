import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

/// Allows to tweak the plugin dialogs.
class DialogStyle {
  /// The title padding.
  final EdgeInsetsGeometry titlePadding;

  /// The content padding.
  final EdgeInsetsGeometry contentPadding;

  /// The title text align.
  final TextAlign? titleAlign;

  /// The title text style.
  final TextStyle? titleStyle;

  /// The message padding.
  final EdgeInsetsGeometry messagePadding;

  /// The message text align.
  final TextAlign? messageAlign;

  /// The message padding.
  final TextStyle? messageStyle;

  /// The dialog shape.
  final ShapeBorder? dialogShape;

  /// Creates a new dialog style instance.
  const DialogStyle({
    this.titlePadding = const EdgeInsets.all(0),
    this.contentPadding = const EdgeInsets.all(24),
    this.titleAlign,
    this.titleStyle,
    this.messagePadding = const EdgeInsets.all(0),
    this.messageAlign,
    this.messageStyle,
    this.dialogShape,
  });
}

// In order to allow the user to use this rating widget class, we have to expose it through our package
class RatingWidgetLocal extends RatingWidget {
  RatingWidgetLocal({
    required Widget full,
    required Widget half,
    required Widget empty,
  }) : super(empty: empty, full: full, half: half);
}

/// Just a little class that allows to customize some rating bar options.
class StarRatingOptions {
  /// The rating widget.
  final RatingWidgetLocal? ratingWidget;

  /// The item builder.
  /// Will override the [ratingWidget] setting if specified.
  final IndexedWidgetBuilder? itemBuilder;

  /// The initial rating.
  final double initialRating;

  /// The minimum rating.
  final double minRating;

  /// Whether we allow half-stars ratings.
  final bool allowHalfRating;

  /// The items padding.
  final EdgeInsetsGeometry itemPadding;

  /// The items size.
  final double itemSize;

  /// The item count.
  final int itemCount;

  // Item Color
  final Color itemColor;

  // Border color of the default Rating Widget. If not specified, defaults to itemColor
  final Color? borderColor;

  /// Whether the items should glow.
  final bool glow;

  /// The items glow radius.
  final double glowRadius;

  /// The items glow color.
  final Color glowColor;

  /// The direction.
  final Axis direction;

  /// If set to `true`, this will disable the drag feature (and also the half rating feature).
  final bool tapOnlyMode;

  /// How items should be disposed in the main axis.
  final WrapAlignment wrapAlignment;

  /// Creates a new star rating options instance.
  const StarRatingOptions({
    this.ratingWidget,
    this.itemBuilder,
    this.initialRating = 0,
    this.minRating = 0,
    this.allowHalfRating = false,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 2),
    this.itemSize = 40,
    this.itemCount = 5,
    this.itemColor = Colors.orangeAccent,
    this.borderColor,
    this.glow = false,
    this.glowRadius = 2,
    this.glowColor = Colors.orangeAccent,
    this.direction = Axis.horizontal,
    this.tapOnlyMode = false,
    this.wrapAlignment = WrapAlignment.start,
  });
}
