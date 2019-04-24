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

### Using custom identifiers

It's possible to use custom identifiers ! Just pass the following parameters during the plugin initialization :

1. `googlePlayIdentifier` Your Google Play identifier (usually a package name).
2. `appStoreIdentifier` Your App Store identifier (usually numbers). **It's required if you're targeting an iOS version before iOS 10.3.**

## Screenshots

### On Android

![Android screenshot](https://github.com/Skyost/rate_my_app/blob/master/screenshots/android.png)

### On iOS

#### iOS < 10.3

No screenshot for the moment. If you have one, please don't hesitate to submit it !

#### iOS >= 10.3

![iOS 10.3 screenshot](https://github.com/Skyost/rate_my_app/blob/master/screenshots/ios_10_3.png)

## Example

```dart
RateMyApp rateMyApp = RateMyApp(
  minDays: 7,
  minLaunches: 10,
  remindDays: 7,
  remindLaunches: 10,
);
rateMyApp.init();

if(rateMyApp.shouldOpenDialog) {
  rateMyApp.showRateDialog(
    context,
      title: 'Rate this app',
      message: 'If you like this app, please take a little bit of your time to review it !\nIt really helps us and it shouldn\'t take you more than one minute.',
      rateButton: 'RATE',
      noButton: 'NO THANKS',
      laterButton: 'MAYBE LATER',
  );
}
```

## Dependencies

This library depends on some other libraries :

* [shared_preferences](https://pub.dartlang.org/packages/shared_preferences)
