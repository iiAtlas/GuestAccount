#import "GuestSearchViewController.h"
#import "GuestAccountManager.h"

@implementation GuestSearchViewController

-(id)init {
	if((self = [super init])) {
		NSBundle *bundle = [[[NSBundle alloc] initWithPath:@"/Library/MobileSubstrate/DynamicLibraries/GuestAccountResources.bundle"] autorelease];
		UIImage *buttonImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"guestCircle" ofType:@"png"]];

		guestButton = [[[UIButton alloc] initWithFrame:CGRectMake(110, 100, 100, 100)] autorelease];
		[guestButton setImage:buttonImage forState:UIControlStateNormal];
		[guestButton setAlpha:0];
		[guestButton addTarget:self action:@selector(tappedExitGuest) forControlEvents:UIControlEventTouchUpInside];

		guestLabel = [[[UILabel alloc] initWithFrame:CGRectMake(85, 200, 150, 30)] autorelease];
		[guestLabel setText:@"Logout Guest"];
		[guestLabel setTextColor:[UIColor whiteColor]];
		[guestLabel setBackgroundColor:[UIColor clearColor]];
		[guestLabel setShadowColor:[UIColor colorWithWhite:0.5 alpha:0.3]];
		[guestLabel setShadowOffset:CGSizeMake(-1, 1)];
		[guestLabel setTextAlignment:UITextAlignmentCenter];
		[guestLabel setAlpha:0];

		[[self view] addSubview:guestButton];
		[[self view] addSubview:guestLabel];
	}
	return self;
}

-(void)showGuestButton {
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [guestButton setAlpha:1];
        [guestLabel setAlpha:1];
    } completion:nil];
}

-(void)hideGuestButton {
	[guestButton setAlpha:0];
    [guestLabel setAlpha:0];
}

-(void)tappedExitGuest {
	[[GuestAccountManager sharedManager] disableGuestMode];
}

@end