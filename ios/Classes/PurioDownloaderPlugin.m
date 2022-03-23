#import "PurioDownloaderPlugin.h"
#if __has_include(<purio_downloader/purio_downloader-Swift.h>)
#import <purio_downloader/purio_downloader-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "purio_downloader-Swift.h"
#endif

@implementation PurioDownloaderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPurioDownloaderPlugin registerWithRegistrar:registrar];
}
@end
