#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBAwayBulletinListController.h>
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
static char GUEST_LOCK_VC_KEY;

%hook SBAwayController
-(void)activate {
    GuestLockscreenViewController *guestLockVC = [[GuestLockscreenViewController alloc] init];
    [[self awayView] addSubview:[guestLockVC view]];

    objc_setAssociatedObject(self, &GUEST_LOCK_VC_KEY, guestLockVC, OBJC_ASSOCIATION_RETAIN);

    %orig;
}

-(void)undimScreen:(BOOL)arg1 {
    GuestLockscreenViewController *guestLockVC = objc_getAssociatedObject(self, &GUEST_LOCK_VC_KEY);
    SBAwayBulletinListController *bulletinController = [self activeOrPendingBulletinController];

    //Check for messages, hide login head if found
    if([[bulletinController listItems] count] > 0) [guestLockVC setAllowsGestures:NO];
    else [guestLockVC setAllowsGestures:YES];

    %orig;
}
%end

%hook SBSearchController
-(id)init {
    SBSearchController *me = %orig;

    GuestSearchViewController *guestSearchVC = [[GuestSearchViewController alloc] init];
    objc_setAssociatedObject(self, &GUEST_SEARCH_VC_KEY, guestSearchVC, OBJC_ASSOCIATION_RETAIN);

    return me;
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
%end

%hook SBAwayLockBar
-(void)knobDragged:(float)dragged {
    if (dragged == 1.0f) {
        //we need to move the guest view out here incase the user has a password
    }
    %orig;
}
%end