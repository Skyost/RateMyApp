import 'package:flutter/material.dart';

class DialogStyle {
  final EdgeInsetsGeometry titlePadding;
  final TextAlign titleAlign;
  final TextStyle titleStyle;
  final EdgeInsetsGeometry messagePadding;
  final TextAlign messageAlign;
  final TextStyle messageStyle;

  const DialogStyle({
    this.titlePadding = const EdgeInsets.all(0),
    this.titleAlign = TextAlign.left,
    this.titleStyle,
    this.messagePadding = const EdgeInsets.all(0),
    this.messageAlign = TextAlign.left,
    this.messageStyle,
  });
}

/// Just a little class that allows to customize some rating bar options.
class StarRatingOptions {
  /// The fill color of the stars.
  final Color starsFillColor;

  /// The border color for the stars.
  final Color starsBorderColor;

  /// The stars size.
  final double starsSize;

  /// The space between two stars.
  final double starsSpacing;

  /// The initial rating.
  final double initialRating;

  /// Whether we allow half-stars ratings.
  final bool allowHalfRating;

  /// Creates a new star rating options instance.
  const StarRatingOptions({
    this.starsFillColor = Colors.orangeAccent,
    this.starsBorderColor = Colors.orangeAccent,
    this.starsSize = 40,
    this.starsSpacing = 0,
    this.initialRating,
    this.allowHalfRating = false,
  });
}