#import <SpringBoard/SpringBoard.h>
#import <UIKit/UIKit.h>
#include <notify.h>

#import "GuestAccountManager.h"

@interface SBAwayController (GuestAccount)
-(id)awayView;
-(void)swipeGuestIn;
-(void)swipeGuestOut;
-(void)tappedGuest;
@end

@interface SBAwayLockBar (GuestAccount)
-(void)knobDragged:(float)dragged;
@end

@interface SBSearchController (GuestAccount)
-(void)tappedExitGuest;
-(SBSearchView *)searchView;
@end

static char GUEST_BUTTON_KEY;
static char GUEST_LOGIN_LABEL_KEY;
static char MODIFIED_VIEW_KEY;

static char GUEST_BUTTON_SPOTLIGHT_KEY;
static char GUEST_LOGOUT_LABEL_KEY;

BOOL guestIsShown;
BOOL guestModeEnabled;

%hook SBAwayController

-(id)awayView {
    UIView *modifiedAwayView = %orig;

    //Load images
    NSBundle *bundle = [[[NSBundle alloc] initWithPath:@"/Library/MobileSubstrate/DynamicLibraries/GuestAccountResources.bundle"] autorelease];
    NSString *imagePath = [bundle pathForResource:@"guestCircle" ofType:@"png"];
    UIImage *buttonImage = [UIImage imageWithContentsOfFile:imagePath];

    UIButton *guestButton = [[[UIButton alloc] initWithFrame:CGRectMake(-100, 120, 100, 100)] autorelease];
    [guestButton setImage:buttonImage forState:UIControlStateNormal];
    [guestButton setAlpha:0];
    [guestButton addTarget:self action:@selector(tappedGuest) forControlEvents:UIControlEventTouchUpInside];

    UILabel *guestLoginLabel = [[[UILabel alloc] initWithFrame:CGRectMake(85, 200, 150, 30)] autorelease];
    [guestLoginLabel setText:@"Login Guest"];
    [guestLoginLabel setTextColor:[UIColor whiteColor]];
    [guestLoginLabel setBackgroundColor:[UIColor clearColor]];
    [guestLoginLabel setShadowColor:[UIColor colorWithWhite:0.5 alpha:0.3]];
    [guestLoginLabel setShadowOffset:CGSizeMake(-1, 1)];
    [guestLoginLabel setTextAlignment:UITextAlignmentCenter];
    [guestLoginLabel setAlpha:0];

    objc_setAssociatedObject(self, &GUEST_BUTTON_KEY, guestButton, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self, &GUEST_LOGIN_LABEL_KEY, guestLoginLabel, OBJC_ASSOCIATION_RETAIN);

    UIView *dontConflictWithSlider = [[[UIView alloc] initWithFrame:CGRectMake(0, 110, 360, 290)] autorelease];
    [modifiedAwayView addSubview:dontConflictWithSlider];
    [dontConflictWithSlider addSubview:guestButton];
    [dontConflictWithSlider addSubview:guestLoginLabel];

    //set swipe recognizers
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGuestIn)];
    [rightRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [dontConflictWithSlider addGestureRecognizer:rightRecognizer];
    [rightRecognizer release];

    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGuestOut)];
    [leftRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [dontConflictWithSlider addGestureRecognizer:leftRecognizer];
    [leftRecognizer release];

    objc_setAssociatedObject(self, &MODIFIED_VIEW_KEY, modifiedAwayView, OBJC_ASSOCIATION_RETAIN);
    return modifiedAwayView;
}

%new
//pull guestButton in
-(void)swipeGuestIn {
    if (!guestIsShown) {
        UIButton *guestButton = objc_getAssociatedObject(self, &GUEST_BUTTON_KEY);
        UILabel *guestLoginLabel = objc_getAssociatedObject(self, &GUEST_LOGIN_LABEL_KEY);

        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            guestButton.frame = CGRectMake(110, 100, 100, 100);
            [guestButton setAlpha:1];
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [guestLoginLabel setAlpha:1];
            } completion:nil];

            guestIsShown = YES;
        }];
    }
}

%new
//push guestButton to the side
-(void)swipeGuestOut {
    if (guestIsShown) {
        UIButton *guestButton = objc_getAssociatedObject(self, &GUEST_BUTTON_KEY);
        UILabel *guestLoginLabel = objc_getAssociatedObject(self, &GUEST_LOGIN_LABEL_KEY);

        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            guestButton.frame = CGRectMake(-100, 120, 100, 100);
            [guestButton setAlpha:0];
            [guestLoginLabel setAlpha:0];
        } completion:^(BOOL finished){
            guestIsShown = NO;
        }];
    }
}

%new
//tapped the guestButton
-(void)tappedGuest {
    if (guestIsShown) {
        UIButton *guestButton = objc_getAssociatedObject(self, &GUEST_BUTTON_KEY);
        UIView *modifiedAwayView = objc_getAssociatedObject(self, &MODIFIED_VIEW_KEY);

        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            guestButton.frame = CGRectMake(130, 110, 120, 120);
            [modifiedAwayView setUserInteractionEnabled:NO];
        } completion:^(BOOL finished){
            [[GuestAccountManager sharedManager] enableGuestMode];
        }];
    }
}

%end

%hook SBAwayLockBar
//move guestButton if they slide to unlock
-(void)knobDragged:(float)dragged {
    if (dragged == 1.0f) {
        if (guestIsShown) {
            UIButton *guestButton = objc_getAssociatedObject(self, &GUEST_BUTTON_KEY);

            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                guestButton.frame = CGRectMake(-100, 120, 100, 100);
                [guestButton setAlpha:0];
            } completion:^(BOOL finished){
                guestIsShown = NO;
            }];
        }
    }
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