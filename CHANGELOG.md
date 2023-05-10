## 2.0.0
* Added support of namespace property to support Android Gradle Plugin (AGP) 8. Projects with AGP < 4.2 are not supported anymore. It is highly recommended to update at least to AGP 7.0 or newer.

## 1.1.4
* Migrated from `PlayCore` to  `PlayReview`.

## 1.1.3
* Various updates for Flutter 3 (thanks [daadu](https://github.com/daadu) and [lohanbodevan](https://github.com/lohanbodevan)).

## 1.1.2
* Upgraded Kotlin version to 1.6.10.

## 1.1.1+1
* Switched from `pedantic` to `flutter_lints`.

## 1.1.1
* Added support for dialogs transitions (thanks [Sadeesha-Sath](https://github.com/Sadeesha-Sath)).
* Added custom item and item color customization for rate dialogs (thanks [Sadeesha-Sath](https://github.com/Sadeesha-Sath)). 

## 1.1.0+1
* Fixed bugs with some `invokeMethod` calls.

## 1.1.0
* Added support for `flutter_rating_bar`.

## 1.0.0+2
* Fixed some problems with the Dart analyzer.

## 1.0.0+1
* Fixed some problems with the `pubspec.yaml` file.

## 1.0.0
* Null safety migration.
* Updated for Flutter v2.0.0.

## 0.7.2

* Changed how the plugin handles store openings.
* Various fixes and updates.

## 0.7.1+1

* Various fixes.

## 0.7.1

* Disabled Android native review dialog by default.
* Various fixes on Android platforms (thanks [in_app_review](https://github.com/britannio/in_app_review)).

## 0.7.0+1

* Added some extra debugging info on Android.
* Improved README (thanks [farazk86](https://github.com/Skyost/RateMyApp/pull/68)).

## 0.7.0

* Added support for the new [Google Play In-App Review API](https://developer.android.com/guide/playcore/in-app-review/).
* Various useful methods and getters added (like `isNativeReviewDialogSupported` or `launchNativeReviewDialog()`).

## 0.6.1+7

* Updated README and ran `dartfmt` on the _lib_ folder.

## 0.6.1+6

* Removed a debug message.

## 0.6.1+5

* Fixed a bug with the builder.

## 0.6.1+4

* Fixed an issue regarding `MinimumDaysCondition` (see #57).
* Fixed an issue with the iOS native dialog (see #56).

## 0.6.1+3

* Preparing for `1.0.0` release of `shared_preferences` (see https://github.com/flutter/flutter/wiki/Package-migration-to-1.0.0).

## 0.6.1+2

* Updated README.

## 0.6.1+1

* Various improvements.
* Updated Dart & Flutter requirements.

## 0.6.1

* Added the ability to change the dialog default content.
* Added a `RateMyAppBuilder`.
* Improved example project.

## 0.6.0+3

* Fixed a bug with `smooth_star_rating`.

## 0.6.0+2

* Fixed another problem with `pedantic`.

## 0.6.0+1

* Fixed a problem with `pedantic`.

## 0.6.0

* Added some styling options.
* Now exposing the `BuildContext` in stars dialog.
* Updated repository link.

## 0.5.0+4

* Added the ability to run code when the dialog has been dismissed.
* Added a dialog style that allows to change the content padding.

## 0.5.0+3

* Updated README and added a link to Marcus Ng video on YouTube.

## 0.5.0+2

* Updated README and added more details about what has been deleted.

## 0.5.0+1

* Updated example and README.

## 0.5.0

* Added a more modular condition system.
* Updated `smooth_star_rating` (and thus allowing further star rating bar customizations).
* Improved the README.md.
* Now using AndroidX.

## 0.4.1+1

* A little bug fixed when using a button listener.

## 0.4.1

* Added the ability to attach a listener to the `RateMyAppDialog` buttons.

## 0.4.0

* Moved some files to the `src` folder.
* Added some options that allow you to tweak the dialogs look.

## 0.3.0+4

* Updated README.

## 0.3.0+3

* Changed the default stars border color.

## 0.3.0+2

* Added an option to change the `showStarRateDialog` style.

## 0.3.0+1

* Updated README.

## 0.3.0

* Added an option to ignore iOS checks (when showing a dialog).
* Added a `showStarRateDialog` method that allows to show a dialog with stars rating.

## 0.2.0+4

* `preferencesPrefix` was not used. As it changes preference keys, this release resets Rate my app user preferences.
* `baseLaunchDate` not affected by the _Maybe Later_ button.

## 0.2.0+3

* Fixed `remindLaunches` constantly triggering.

## 0.2.0+2

* Updated README and examples.

## 0.2.0+1

* Updated minimum SDK version.

## 0.2.0

* Added the ability to use custom identifiers.
* Removed a dependency.
* Fixed a bug where the dialog was not closing after the user successfully clicked on "Rate".

## 0.1.0

* First published release.
