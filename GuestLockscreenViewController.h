#import <UIKit/UIKit.h>

@interface GuestLockscreenViewController : UIViewController {
	UIButton *guestButton;
	UILabel *guestLabel;

	BOOL guestViewVisible, loggingIn;

	CGFloat W, H;
}

@property (nonatomic, assign) BOOL allowsGestures;

-(void)tappedGuest;
-(void)swipeGuestFromLeft;
-(void)swipeGuestFromRight;
-(void)fadeOut:(BOOL)immediate;

@end