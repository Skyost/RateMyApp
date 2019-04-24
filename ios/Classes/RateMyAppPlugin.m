#import "RateMyAppPlugin.h"
#import <StoreKit/StoreKit.h>

@implementation RateMyAppPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"rate_my_app"
            binaryMessenger:[registrar messenger]];
  RateMyAppPlugin* instance = [[RateMyAppPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"requestReview"]) {
    [SKStoreReviewController requestReview];
    result(nil);
  }
  else if([call.method isEqualToString:@"canRequestReview"]) {
    if (@available(iOS 10.3, *)) {
      result([NSNumber numberWithBool:YES]);
    }
    else {
      result([NSNumber numberWithBool:NO]);
    }
  }
  else if([call.method isEqualToString:@"launchStore"]) {
    NSString *appId = call.arguments[@"appId"];

    if (appId == (NSString *)[NSNull null]) {
        result([FlutterError errorWithCode:@"ERROR" message:@"App id cannot be null" details:nil]);
    }
    else if ([appId length] == 0) {
        result([FlutterError errorWithCode:@"ERROR" message:@"Empty app id" details:nil]);
    }
    else {
      NSString *iTunesLink = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review", appId];
      NSURL* itunesURL = [NSURL URLWithString:iTunesLink];
      if ([[UIApplication sharedApplication] canOpenURL:itunesURL]) {
        [[UIApplication sharedApplication] openURL:itunesURL];
      }
    }

    result(nil);
  }
  else {
    result(FlutterMethodNotImplemented);
  }
}

@end
