#import "ZYSpringBoardKeyboardActivation.h"
#import "headers.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "ZYMessaging.h"
#import "ZYMessagingClient.h"
#import "ZYKeyboardWindow.h"
#import "ZYRemoteKeyboardView.h"

extern BOOL overrideDisableForStatusBar;
ZYKeyboardWindow *keyboardWindow;

@implementation ZYSpringBoardKeyboardActivation
+ (instancetype)sharedInstance {
    SHARED_INSTANCE2(ZYSpringBoardKeyboardActivation,
        [ZYRunningAppsProvider.sharedInstance addTarget:self]
    );
}

- (void)showKeyboardForAppWithIdentifier:(NSString*)identifier {
    if (keyboardWindow) {
        [self hideKeyboard];
        //HBLogDebug(@"[ReachApp] springboard cancelling - keyboardWindow exists");
        //return;
    }

    HBLogDebug(@"[ReachApp] showing kb window %@", identifier);
    keyboardWindow = [[ZYKeyboardWindow alloc] init];
    overrideDisableForStatusBar = YES;
    [keyboardWindow setupForKeyboardAndShow:identifier];
    overrideDisableForStatusBar = NO;
    _currentIdentifier = identifier;
}

- (void)hideKeyboard {
    HBLogDebug(@"[ReachApp] remove kb window (%@)", _currentIdentifier);
    keyboardWindow.hidden = YES;
    [keyboardWindow removeKeyboard];
    keyboardWindow = nil;
    _currentIdentifier = nil;
}

- (void)appDidDie:(SBApplication*)app {
    if ([_currentIdentifier isEqual:app.bundleIdentifier]) {
      [self hideKeyboard];
    }
}

- (UIWindow*)keyboardWindow {
    return keyboardWindow;
}
@end
