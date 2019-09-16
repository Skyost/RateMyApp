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
2. `minLaunches` Minimum launches.

If everything above is verified, the method `shouldOpenDialog` will return `true` (`false` otherwise).
Then you should call `showRateDialog` which is going to show a native rating dialog on iOS >= _10.3_ and a custom rating prompt dialog on Android (and on older iOS versions).

If you prefer, you can call `showStarRateDialog` which will show a dialog containing a star rating bar that will allow you to take custom actions based on the rating
(for example if the user puts less than 3 stars then open your app bugs report page or something like this and if he puts more ask him to rate your app on the store page).

### Using custom identifiers

It's possible to use custom identifiers ! Just pass the following parameters during the plugin initialization :

1. `googlePlayIdentifier` Your Google Play identifier (usually a package name).
2. `appStoreIdentifier` Your App Store identifier (usually numbers). **It's required if you're targeting an iOS version before iOS 10.3.**

## Screenshots

### On Android

<img src="https://github.com/Skyost/rate_my_app/raw/master/screenshots/android.png" height="500">

_`showRateDialog` method._


### On iOS

#### iOS < 10.3

No screenshot for the moment. If you have one, please don't hesitate to submit it !

#### iOS >= 10.3

<img src="https://github.com/Skyost/rate_my_app/raw/master/screenshots/ios_10_3.png" height="500">

_`showRateDialog` and `showStarRateDialog` method with `ignoreIOS` set to `false`._

## Example

```dart
RateMyApp rateMyApp = RateMyApp(
  preferencesPrefix: 'rateMyApp_',
  minDays: 7,
  minLaunches: 10,
  remindDays: 7,
  remindLaunches: 10,
);

_rateMyApp.init().then((_) {
  if (_rateMyApp.shouldOpenDialog) {
    _rateMyApp.showRateDialog(
      context,
      title: 'Rate this app',
      message: 'If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute.',
      rateButton: 'RATE',
      noButton: 'NO THANKS',
      laterButton: 'MAYBE LATER',
      ignoreIOS: false,
      dialogStyle: DialogStyle(),
    );
    
    // Or if you prefer to show a star rating bar :
    
    _rateMyApp.showStarRateDialog(
      context,
      title: 'Rate this app',
      message: 'You like this app ? Then take a little bit of your time to leave a rating :',
      onRatingChanged: (stars) {
        return [
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              print('Thanks for the ' + (stars == null ? '0' : stars.round().toString()) + ' star(s) !');
              // You can handle the result as you want (for instance if the user puts 1 star then open your contact page, if he puts more then open the store page, etc...).
              _rateMyApp.doNotOpenAgain = true;
              _rateMyApp.save().then((v) => Navigator.pop(context));
            },
          ),
        ];
      },
      ignoreIOS: false,
      dialogStyle: DialogStyle(
        titleAlign: TextAlign.center,
        messageAlign: TextAlign.center,
        messagePadding: EdgeInsets.only(bottom: 20),
      ),
      starRatingOptions: StarRatingOptions(),
    );
  }
});
```

## Contributions

You have a lot of options to contribute to this project ! You can :

* [Fork it](https://github.com/Skyost/rate_my_app/fork) on Github.
* [Submit](https://github.com/Skyost/rate_my_app/issues/new/choose) a feature request or a bug report.
* [Donate](https://paypal.me/Skyost) to the developer.

## Dependencies

This library depends on some other libraries :

* [shared_preferences](https://pub.dev/packages/shared_preferences)
* [smooth_star_rating](https://pub.dev/packages/smooth_star_rating)
