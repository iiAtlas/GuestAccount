#import <SpringBoard/SpringBoard.h>
#import <UIKit/UIKit.h>

#import "GuestAccountManager.h"
#import "GuestLockscreenViewController.h"
#import "GuestSearchViewController.h"

@interface SBAwayController (GuestAccount)
-(id)awayView;
@end

@interface SBSearchController (GuestAccount)
-(SBSearchView *)searchView;
@end

static char GUEST_SEARCH_VC_KEY;

%hook SBAwayController
-(id)awayView {
    UIView *modifiedAwayView = %orig;

    GuestLockscreenViewController *guestLockVC = [[GuestLockscreenViewController alloc] init];
    [modifiedAwayView addSubview:[guestLockVC view]];

    return modifiedAwayView;
}
%end

%hook SBSearchController
-(id)init {
    GuestSearchViewController *guestSearchVC = [[GuestSearchViewController alloc] init];
    objc_setAssociatedObject(self, &GUEST_SEARCH_VC_KEY, guestSearchVC, OBJC_ASSOCIATION_RETAIN);

    return %orig;
}

-(void)controllerWasActivated {
    GuestSearchViewController *vc = objc_getAssociatedObject(self, &GUEST_SEARCH_VC_KEY);
    [[self searchView] addSubview:[vc view]];
    [vc showGuestButton];

    %orig;
}

-(void)controllerWasDeactivated {
    GuestSearchViewController *vc = objc_getAssociatedObject(self, &GUEST_SEARCH_VC_KEY);
    [[vc view] removeFromSuperview];

    [vc hideGuestButton];

    %orig;  
}

-(int)tableView:(UITableView *)arg1 numberOfRowsInSection:(int)arg2 {
    if (arg2 > 0) {
        GuestSearchViewController *vc = objc_getAssociatedObject(self, &GUEST_SEARCH_VC_KEY);
        [[vc view] removeFromSuperview];

        [vc hideGuestButton];
    }

    return %orig;
}
%end

%hook SBAwayLockBar
-(void)knobDragged:(float)dragged {
    if (dragged == 1.0f) {
        //we need to move the guest view out here incase the user has a password
    }
    %orig;
}
%end