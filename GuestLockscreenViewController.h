#import <UIKit/UIKit.h>

@interface GuestLockscreenViewController : UIViewController {
	UIButton *guestButton;
	UILabel *guestLabel;

	BOOL guestViewVisible;

	CGFloat W, H;
}

-(void)tappedGuest;
-(void)swipeGuestFromLeft;
-(void)swipeGuestFromRight;

@end