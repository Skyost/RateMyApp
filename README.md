<div align="center">
    <img src="https://github.com/Skyost/rate_my_app/raw/master/images/logo.svg" height="200">
</div>

# Rate my app !

This plugin allows to kindly ask users to rate your app if custom conditions are met (eg. install time, number of launches, etc...).
You can even add your own conditions.

_Rate my app_ is really inspired by [Android-Rate](https://github.com/hotchemi/Android-Rate/).

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

_Rate my app_ default constructor takes two main parameters (see _[Example](#example)_ for more info) :

* `minDays` Minimum elapsed days since the first app launch.
* `minLaunches` Minimum app launches count.

If everything above is verified, the method `shouldOpenDialog` will return `true` (`false` otherwise).
Then you should call `showRateDialog` which is going to show a native rating dialog on iOS ≥ _10.3_ and a custom rating prompt dialog on Android (and on older iOS versions).

If you prefer, you can call `showStarRateDialog` which will show a dialog containing a star rating bar that will allow you to take custom actions based on the rating
(for example if the user puts less than 3 stars then open your app bugs report page or something like this and if he puts more ask him to rate your app on the store page).
Still, you have to be careful with these practises (see [this paragraph](https://appradar.com/blog/ask-users-leave-review-in-app-stores#fraudulent-methods-to-gain-more-app-store-reviews) on App Radar).

## Screenshots

<details>
    <summary>On Android</summary>
    <img src="https://github.com/Skyost/rate_my_app/raw/master/images/android.png" height="500">
    <br><em><code>showRateDialog</code> method.</em>
</details>

<details>
    <summary>On iOS</summary>
    <img src="https://github.com/Skyost/rate_my_app/raw/master/images/ios_10_3.png" height="500">
    <br><em><code>showRateDialog</code> and <code>showStarRateDialog</code> methods with <code>ignoreIOS</code> set to <code>false</code>.</em>
</details>

## Example

```dart
// In this example, I'm giving a value to all parameters.
// Please note that not all are required (those that are required are marked with the @required annotation).

RateMyApp rateMyApp = RateMyApp(
  preferencesPrefix: 'rateMyApp_',
  minDays: 7,
  minLaunches: 10,
  remindDays: 7,
  remindLaunches: 10,
  googlePlayIdentifier: 'fr.skyost.example',
  appStoreIdentifier: '1491556149',
);

rateMyApp.init().then((_) {
  if (rateMyApp.shouldOpenDialog) {
    rateMyApp.showRateDialog(
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
      ignoreIOS: false, // Set to false if you want to show the Apple's native app rating dialog on iOS.
      dialogStyle: DialogStyle(), // Custom dialog styles.
      onDismissed: () => rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed), // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
      // contentBuilder: (context, defaultContent) => content, // This one allows you to change the default dialog content.
      // actionsBuilder: (context) => [], // This one allows you to use your own buttons. 
    );
    
    // Or if you prefer to show a star rating bar :
    
    rateMyApp.showStarRateDialog(
      context,
      title: 'Rate this app', // The dialog title.
      message: 'You like this app ? Then take a little bit of your time to leave a rating :', // The dialog message.
      // contentBuilder: (context, defaultContent) => content, // This one allows you to change the default dialog content.
      actionsBuilder: (context, stars) { // Triggered when the user updates the star rating.
        return [ // Return a list of actions (that will be shown at the bottom of the dialog).
          FlatButton(
            child: Text('OK'),
            onPressed: () async {
              print('Thanks for the ' + (stars == null ? '0' : stars.round().toString()) + ' star(s) !');
              // You can handle the result as you want (for instance if the user puts 1 star then open your contact page, if he puts more then open the store page, etc...).
              // This allows to mimic the behavior of the default "Rate" button. See "Advanced > Broadcasting events" for more information :
              await rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);
              Navigator.pop<RateMyAppDialogButton>(context, RateMyAppDialogButton.rate);
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
      starRatingOptions: StarRatingOptions(), // Custom star bar rating options.
      onDismissed: () => rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed), // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
    );
  }
});
```

If you want a more complete example, please check [this one](https://github.com/Skyost/rate_my_app/tree/master/example/) on Github.    
You can also follow [the tutorial of Marcus Ng](https://youtu.be/gOiaSwp984s) on YouTube
(for a replacement of `doNotOpenAgain`, see [Broadcasting events](#broadcasting-events)).

## Advanced

### Where to initialize _Rate My App_

You should be careful on where you initialize _Rate My App_ in your project.
But thankfully, there's a widget that helps you getting through all of this without any trouble : `RateMyAppBuilder`.
Here's an example :

```dart
// The builder should be initialized exactly one time during the app lifecycle.
// So place it where you want but it should respect that condition.

RateMyAppBuilder(
  builder: (context) => MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: const Text('Rate my app !'),
      ),
      body: Center(child: Text('This is my beautiful app !')),
    ),
  ),
  onInitialized: (context, rateMyApp) {
    // Called when Rate my app has been initialized.
    // See the example project on Github for more info.
  },
);
```

You can totally choose to not use it and to initialize _Rate my app_ in your `main()` method. This is up to you !

### Using custom identifiers

It's possible to use custom store identifiers ! Just pass the following parameters during the plugin initialization :

* `googlePlayIdentifier` Your Google Play identifier (usually a package name).
* `appStoreIdentifier` Your App Store identifier (usually numbers). **It's required if you're targeting an iOS version before iOS 10.3.**

### Using custom conditions

A condition is something required to be met in order for the `shouldOpenDialog` method to return `true`.
_Rate my app_ comes with three default conditions :

* `MinimumDaysCondition` Allows to set a minimum elapsed days since the first app launch before showing the dialog.
* `MinimumAppLaunchesCondition` Allows to set a minimum app launches count since the first app launch before showing the dialog.
* `DoNotOpenAgainCondition` Allows to prevent the dialog from being opened (when the user clicks on the _No_ button for example).

You can easily create your custom conditions ! All you have to do is to extend the `Condition` class. There are five methods to override :

* `readFromPreferences` You should read your condition values from the provided shared preferences here.
* `saveToPreferences` You should save your condition values to the provided shared preferences here.
* `reset` You should reset your condition values here.
* `isMet` Whether this condition is met.
* `onEventOccurred` When an event occurs in the plugin lifecycle. This is usually here that you can update your condition values.
Please note that you're not obligated to override this one (although this is recommended).

You can have an easy example of it by checking the source code of [`DoNotOpenAgainCondition`](https://github.com/Skyost/rate_my_app/tree/master/lib/src/conditions.dart#L169).

Then you can add your custom condition to _Rate my app_ by using the constructor `customConditions` (or by calling `rateMyApp.conditions.add` before initialization).

### Broadcasting events

As said in the previous section, the `shouldOpenDialog` method depends on conditions.

For example, when you click on the _No_ button,
[this event](https://github.com/Skyost/rate_my_app/tree/master/lib/src/core.dart#L237) will be triggered
and the condition `DoNotOpenAgainCondition` will react to it and will stop being met and thus the `shouldOpenDialog` will return `false`.

You may want to broadcast events in order to mimic the behaviour of the _No_ button for example.
This can be done either by using the `RateMyAppNoButton` or you can directly call `callEvent` from your current _RateMyApp_ instance in your button `onTap` callback.

Here are what events default conditions are listening to :

* `MinimumDaysCondition` : _Later_ button press.
* `MinimumAppLaunchesCondition` : _Rate my app_ initialization, _Later_ button press.
* `DoNotOpenAgainCondition` : _Rate_ button press, _No_ button press.

For example, starting from version 0.5.0, the getter/setter `doNotOpenAgain` has been removed.
You must trigger the `DoNotOpenAgainCondition` either by calling a _Rate_ button press event or a _No_ button press event (see [Example on Github](https://github.com/Skyost/RateMyApp/blob/master/example/lib/content.dart#L141)).

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
