#import <UIKit/UIKit.h>

@interface GuestLockscreenViewController : UIViewController {
	UIButton *guestButton;
	UILabel *guestLabel;

	BOOL guestViewVisible;
}

-(void)tappedGuest;
-(void)swipeGuestIn;
-(void)swipeGuestOut;

@end