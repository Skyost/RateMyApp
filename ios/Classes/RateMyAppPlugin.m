#import "RateMyAppPlugin.h"
#if __has_include(<rate_my_app/rate_my_app-Swift.h>)
#import <rate_my_app/rate_my_app-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "rate_my_app-Swift.h"
#endif

@implementation RateMyAppPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftRateMyAppPlugin registerWithRegistrar:registrar];
}
@end
