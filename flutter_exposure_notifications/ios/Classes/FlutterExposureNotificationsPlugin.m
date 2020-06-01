#import "FlutterExposureNotificationsPlugin.h"
#if __has_include(<flutter_exposure_notifications/flutter_exposure_notifications-Swift.h>)
#import <flutter_exposure_notifications/flutter_exposure_notifications-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_exposure_notifications-Swift.h"
#endif

@implementation FlutterExposureNotificationsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterExposureNotificationsPlugin registerWithRegistrar:registrar];
}
@end
