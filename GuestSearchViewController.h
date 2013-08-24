#import <UIKit/UIKit.h>

@interface GuestSearchViewController : UIViewController {
	UIButton *guestButton;
	UILabel *guestLabel;
}

-(void)tappedExitGuest;
-(void)showGuestButton;
-(void)hideGuestButton;

@end