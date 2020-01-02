# Rate my app !

This plugin allows to kindly ask users to rate your app if custom conditions are met (eg. install time, number of launches, etc...).

Rate my app is really inspired by [Android-Rate](https://github.com/hotchemi/Android-Rate/).

## How to use

### Installation

To target an iOS version before _10.3_, add this in your `Info.plist` :

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>itms</string>
</array>
```

By the way, it's important to note that your bundle identifier (in your `Info.plist`) must match the App ID on iTunes Connect and the package identifier (in your `build.gradle`) must match your App ID on Google Play.

If for any reason it doesn't match please go to the _[Using custom identifiers](#using-custom-identifiers)_ section.

### How it works

_Rate my app_ takes two parameters :

1. `minDays` Minimum elapsed days since the first app launch.
2. `minLaunches` Minimum app launches count.

If everything above is verified, the method `shouldOpenDialog` will return `true` (`false` otherwise).
Then you should call `showRateDialog` which is going to show a native rating dialog on iOS >= _10.3_ and a custom rating prompt dialog on Android (and on older iOS versions).

If you prefer, you can call `showStarRateDialog` which will show a dialog containing a star rating bar that will allow you to take custom actions based on the rating
(for example if the user puts less than 3 stars then open your app bugs report page or something like this and if he puts more ask him to rate your app on the store page).

### Using custom identifiers

It's possible to use custom identifiers ! Just pass the following parameters during the plugin initialization :

1. `googlePlayIdentifier` Your Google Play identifier (usually a package name).
2. `appStoreIdentifier` Your App Store identifier (usually numbers). **It's required if you're targeting an iOS version before iOS 10.3.**

### Using custom conditions

A condition is something required to be met in order for the dialog to open.
Rate my app comes with three default conditions :

1. `MinimumDaysCondition` Allows to set a minimum elapsed days since the first app launch before showing the dialog.
2. `MinimumAppLaunchesCondition` Allows to set a minimum app launches count since the first app launch before showing the dialog.
3. `DoNotOpenAgainCondition` Allows to block the dialog from being opened.

You can easily add custom conditions to the plugin. All you have to do is to extend the `Condition` class. There are five methods to override :

1. `readFromPreferences` You should read your condition state from the provided shared preferences here.
2. `saveToPreferences` You should save your condition state to the provided shared preferences here.
3. `reset` You should reset your condition state here.
4. `isMet` Whether this condition is met.
5. `onEventOccurred` When an event occurs in the plugin lifecycle. This is usually here that you can change your condition values.

You can have an easy example by checking the source code of [`DoNotOpenAgainCondition`](https://github.com/Skyost/rate_my_app/tree/master/lib/src/conditions.dart#L163).

## Screenshots

### On Android

<img src="https://github.com/Skyost/rate_my_app/raw/master/screenshots/android.png" height="500">

_`showRateDialog` method._

### On iOS

<img src="https://github.com/Skyost/rate_my_app/raw/master/screenshots/ios_10_3.png" height="500">

_`showRateDialog` and `showStarRateDialog` method with `ignoreIOS` set to `false`._

## Example

```dart
// In this example, I'm giving a value to all parameters.
// Please note that not everyone are required (those that are required are marked with the @required annotation).

RateMyApp rateMyApp = RateMyApp(
  preferencesPrefix: 'rateMyApp_',
  minDays: 7,
  minLaunches: 10,
  remindDays: 7,
  remindLaunches: 10,
  googlePlayIdentifier: 'fr.skyost.example',
  appStoreIdentifier: '1491556149',
);

_rateMyApp.init().then((_) {
  if (_rateMyApp.shouldOpenDialog) {
    _rateMyApp.showRateDialog(
      context,
      title: 'Rate this app', // The dialog title.
      message: 'If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute.', // The dialog message.
      rateButton: 'RATE', // The dialog "rate" button text.
      noButton: 'NO THANKS', // The dialog "no" button text.
      laterButton: 'MAYBE LATER', // The dialog "later" button text.
      listener: (button) { // The button click listener (useful if you want to cancel the click event).
        switch(button) {
          case RateMyAppDialogButton.rate:
            print('Clicked on "Rate".');
            break;
          case RateMyAppDialogButton.later:
            print('Clicked on "Later".');
            break;
          case RateMyAppDialogButton.no:
            print('Clicked on "No".');
            break;
        }
        
        return true; // Return false if you want to cancel the click event.
      },
      ignoreIOS: false, // Set to false if you want to show the native Apple app rating dialog on iOS.
      dialogStyle: DialogStyle(), // Custom dialog styles.
    );
    
    // Or if you prefer to show a star rating bar :
    
    _rateMyApp.showStarRateDialog(
      context,
      title: 'Rate this app', // The dialog title.
      message: 'You like this app ? Then take a little bit of your time to leave a rating :', // The dialog message.
      onRatingChanged: (stars) { // Triggered when the user updates the star rating.
        return [ // Return a list of actions (that will be shown at the bottom of the dialog).
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              print('Thanks for the ' + (stars == null ? '0' : stars.round().toString()) + ' star(s) !');
              // You can handle the result as you want (for instance if the user puts 1 star then open your contact page, if he puts more then open the store page, etc...).
              _rateMyApp.doNotOpenAgain = true;
              _rateMyApp.save().then((_) => Navigator.pop(context));
            },
          ),
        ];
      },
      ignoreIOS: false, // Set to false if you want to show the native Apple app rating dialog on iOS.
      dialogStyle: DialogStyle( // Custom dialog styles.
        titleAlign: TextAlign.center,
        messageAlign: TextAlign.center,
        messagePadding: EdgeInsets.only(bottom: 20),
      ),
      starRatingOptions: StarRatingOptions(), // Custom star rating options.
    );
  }
});
```

## Contributions

You have a lot of options to contribute to this project ! You can :

* [Fork it](https://github.com/Skyost/rate_my_app/fork) on Github.
* [Submit](https://github.com/Skyost/rate_my_app/issues/new/choose) a feature request or a bug report.
* [Donate](https://paypal.me/Skyost) to the developer.
* [Watch a little ad](https://utip.io/skyost) on uTip.

## Dependencies

This library depends on some other libraries :

* [shared_preferences](https://pub.dev/packages/shared_preferences)
* [smooth_star_rating](https://pub.dev/packages/smooth_star_rating)
