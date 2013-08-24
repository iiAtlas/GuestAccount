#import <SpringBoard/SpringBoard.h>
#import <UIKit/UIKit.h>
#include <notify.h>

#import "GuestAccountManager.h"
#import "GuestLockscreenViewController.h"

@interface SBAwayController (GuestAccount)
-(id)awayView;
@end

@interface SBAwayLockBar (GuestAccount)
-(void)knobDragged:(float)dragged;
@end

@interface SBSearchController (GuestAccount)
-(void)tappedExitGuest;
-(SBSearchView *)searchView;
@end

static char GUEST_BUTTON_SPOTLIGHT_KEY;
static char GUEST_LOGOUT_LABEL_KEY;

%hook SBAwayController

-(id)awayView {
    UIView *modifiedAwayView = %orig;

    GuestLockscreenViewController *guestVC = [[GuestLockscreenViewController alloc] init];
    [modifiedAwayView addSubview:[guestVC view]];

    return modifiedAwayView;
}

%end

%hook SBSearchController
-(id)init {
    SBSearchController *me = %orig;

    NSBundle *bundle = [[[NSBundle alloc] initWithPath:@"/Library/MobileSubstrate/DynamicLibraries/GuestAccountResources.bundle"] autorelease];
    NSString *imagePath = [bundle pathForResource:@"guestCircle" ofType:@"png"];
    UIImage *buttonImage = [UIImage imageWithContentsOfFile:imagePath];

    UIButton *guestButtonSpotlight = [[[UIButton alloc] initWithFrame:CGRectMake(110, 100, 100, 100)] autorelease];
    [guestButtonSpotlight setImage:buttonImage forState:UIControlStateNormal];
    [guestButtonSpotlight setAlpha:0];
    [guestButtonSpotlight addTarget:self action:@selector(tappedExitGuest) forControlEvents:UIControlEventTouchUpInside];

    UILabel *guestLogoutLabel = [[[UILabel alloc] initWithFrame:CGRectMake(85, 200, 150, 30)] autorelease];
    [guestLogoutLabel setText:@"Logout Guest"];
    [guestLogoutLabel setTextColor:[UIColor whiteColor]];
    [guestLogoutLabel setBackgroundColor:[UIColor clearColor]];
    [guestLogoutLabel setShadowColor:[UIColor colorWithWhite:0.5 alpha:0.3]];
    [guestLogoutLabel setShadowOffset:CGSizeMake(-1, 1)];
    [guestLogoutLabel setTextAlignment:UITextAlignmentCenter];
    [guestLogoutLabel setAlpha:0];

    objc_setAssociatedObject(self, &GUEST_BUTTON_SPOTLIGHT_KEY, guestButtonSpotlight, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self, &GUEST_LOGOUT_LABEL_KEY, guestLogoutLabel, OBJC_ASSOCIATION_RETAIN);

    return me;
}

-(void)controllerWasActivated {
    UIButton *b = objc_getAssociatedObject(self, &GUEST_BUTTON_SPOTLIGHT_KEY);
    UILabel *l = objc_getAssociatedObject(self, &GUEST_LOGOUT_LABEL_KEY);

    [[self searchView] addSubview:b];
    [[self searchView] addSubview:l];

    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [b setAlpha:1];
        [l setAlpha:1];
    } completion:nil];
}

-(void)controllerWasDeactivated {
    UIButton *b = objc_getAssociatedObject(self, &GUEST_BUTTON_SPOTLIGHT_KEY);
    UILabel *l = objc_getAssociatedObject(self, &GUEST_LOGOUT_LABEL_KEY);

    [b setAlpha:0];
    [l setAlpha:0];

    [b removeFromSuperview];
    [l removeFromSuperview];

    %orig;
}

%new
-(void)tappedExitGuest {
    
}
%end