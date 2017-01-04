#import "headers.h"
#import "ZYBackgrounder.h"
#include <execinfo.h>
#include <stdio.h>
#include <stdlib.h>

@interface FBApplicationInfo : NSObject
@property (nonatomic, copy) NSString *bundleIdentifier;
- (BOOL)isExitsOnSuspend;
@end

%hook FBApplicationInfo
- (BOOL)supportsBackgroundMode:(__unsafe_unretained NSString *)mode {
	NSInteger override = [ZYBackgrounder.sharedInstance application:self.bundleIdentifier overrideBackgroundMode:mode];
    if (override == -1) {
      return %orig;
    }
	return override;
}
%end

%hook BKSProcessAssertion
- (id)initWithPID:(NSInteger)arg1 flags:(NSUInteger)arg2 reason:(NSUInteger)arg3 name:(unsafe_id)arg4 withHandler:(unsafe_id)arg5 {
    if ((arg3 == kProcessAssertionReasonViewServices) == NO && // whitelist this to allow share menu to work
        [arg4 isEqualToString:@"Called by iOS6_iCleaner, from unknown method"] == NO && // whitelist iCleaner to prevent crash on open
        [arg4 isEqualToString:@"Called by Filza_main, from -[AppDelegate applicationDidEnterBackground:]"] == NO && // Whitelist filza to prevent iOS hang (?!)
        IS_SPRINGBOARD == NO) // FIXME: this is a hack that prevents SpringBoard from not starting
    {
        NSString *identifier = NSBundle.mainBundle.bundleIdentifier;

        if (!identifier) {
          goto ORIGINAL;
        }

        if ([ZYBackgrounder.sharedInstance shouldSuspendImmediately:identifier]) {

            if ((arg3 >= kProcessAssertionReasonAudio && arg3 <= kProcessAssertionReasonVOiP)) {
                //HBLogDebug(@"[ReachApp] blocking BKSProcessAssertion");
								//I think this part may be causing potential audio issues, need reports to confirm
                return nil;
            }
        }
    }
ORIGINAL:
    return %orig(arg1, arg2, arg3, arg4, arg5);
}
%end
