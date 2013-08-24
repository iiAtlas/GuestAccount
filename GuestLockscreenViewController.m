#import "GuestLockscreenViewController.h"
#import "GuestAccountManager.h"

@implementation GuestLockscreenViewController

-(id)init {
	if((self = [super init])) {
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 110, 360, 290)];
		[self setView:view];
		[view release];

		//Load images
		NSBundle *bundle = [[[NSBundle alloc] initWithPath:@"/Library/MobileSubstrate/DynamicLibraries/GuestAccountResources.bundle"] autorelease];
		UIImage *buttonImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"guestCircle" ofType:@"png"]];

		guestButton = [[[UIButton alloc] initWithFrame:CGRectMake(-100, 87, 100, 100)] autorelease];
		[guestButton setImage:buttonImage forState:UIControlStateNormal];
		[guestButton setAlpha:0];
		[guestButton addTarget:self action:@selector(tappedGuest) forControlEvents:UIControlEventTouchUpInside];

		guestLabel = [[[UILabel alloc] initWithFrame:CGRectMake(85, 180, 150, 30)] autorelease];
		[guestLabel setText:@"Login Guest"];
		[guestLabel setTextColor:[UIColor whiteColor]];
		[guestLabel setTextAlignment:UITextAlignmentCenter];
		[guestLabel setBackgroundColor:[UIColor clearColor]];
		[guestLabel setShadowColor:[UIColor colorWithWhite:0.5 alpha:0.3]];
		[guestLabel setShadowOffset:CGSizeMake(-1, 1)];
		[guestLabel setAlpha:0];

		[[self view] addSubview:guestButton];
		[[self view] addSubview:guestLabel];

		//Swipe recognizers
		UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGuestIn)];
		[rightRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
		[[self view] addGestureRecognizer:rightRecognizer];
		[rightRecognizer release];

		UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGuestOut)];
		[leftRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
		[[self view] addGestureRecognizer:leftRecognizer];
		[leftRecognizer release];
	}
	return self;
}

-(void)swipeGuestIn {
	if(!guestViewVisible) {
		[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
			[guestButton setFrame:CGRectMake(110, 87, 100, 100)];
			[guestButton setAlpha:1];
		} completion:^(BOOL finished){
			[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
				[guestLabel setAlpha:1];
		} completion:nil];
			guestViewVisible = YES;
		}];
	}
}

-(void)swipeGuestOut {
	if(guestViewVisible) {
		[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			[guestButton setFrame:CGRectMake(-100, 87, 100, 100)];
			[guestButton setAlpha:0];
			[guestLabel setAlpha:0];
		} completion:^(BOOL finished){
			guestViewVisible = NO;
		}];
	}
}

-(void)tappedGuest {
	if(guestViewVisible) {
		[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
			[guestButton setFrame:CGRectMake(105, 77, 110, 110)];
		} completion:^(BOOL finished){
		//	[[GuestAccountManager sharedManager] enableGuestMode];
		}];
	}
}

@end