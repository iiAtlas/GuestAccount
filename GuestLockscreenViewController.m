#import "GuestLockscreenViewController.h"
#import "GuestAccountManager.h"

@implementation GuestLockscreenViewController

-(id)init {
	if((self = [super init])) {
		W = [[UIScreen mainScreen] bounds].size.width;
		H = [[UIScreen mainScreen] bounds].size.height;

		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 117, W, H - 213)];
		[self setView:view];
		[view release];

		//Load images
		NSBundle *bundle = [[[NSBundle alloc] initWithPath:@"/Library/MobileSubstrate/DynamicLibraries/GuestAccountResources.bundle"] autorelease];
		UIImage *buttonImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"guestCircle" ofType:@"png"]];

		guestButton = [[[UIButton alloc] initWithFrame:CGRectMake(-100, 120, 100, 100)] autorelease];
		[guestButton setImage:buttonImage forState:UIControlStateNormal];
		[guestButton setAlpha:0];
		[guestButton addTarget:self action:@selector(tappedGuest) forControlEvents:UIControlEventTouchUpInside];

		guestLabel = [[[UILabel alloc] initWithFrame:CGRectMake((W - 150) / 2, 200, 150, 30)] autorelease];
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
		UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGuestFromLeft)];
		[rightRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
		[[self view] addGestureRecognizer:rightRecognizer];
		[rightRecognizer release];

		UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGuestFromRight)];
		[leftRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
		[[self view] addGestureRecognizer:leftRecognizer];
		[leftRecognizer release];
	}
	return self;
}

-(void)swipeGuestFromLeft {
	if(!loggingIn) {
		if(!guestViewVisible) { //Swipe in from left
			[guestButton setFrame:CGRectMake(-100, 120, 100, 100)];
			[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
				[guestButton setFrame:CGRectMake((W - 100) / 2, 100, 100, 100)];
				[guestButton setAlpha:1];
			} completion:^(BOOL finished){
				[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
					[guestLabel setAlpha:1];
			} completion:nil];
				guestViewVisible = YES;
			}];
		}else { //Swipe out to right
			[guestButton setFrame:CGRectMake((W - 100) / 2, 100, 100, 100)];
			[UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
				[guestLabel setAlpha:0];
			} completion:^(BOOL finished){
				[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
					[guestButton setFrame:CGRectMake(W, 120, 100, 100)];
					[guestButton setAlpha:0];
				} completion:^(BOOL finished){
					guestViewVisible = NO;
				}];
			}];
		}
	}
}

-(void)swipeGuestFromRight {
	if(!loggingIn) {
		if(!guestViewVisible) { //Swipe in from right
			[guestButton setFrame:CGRectMake(W, 120, 100, 100)];
			[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
				[guestButton setFrame:CGRectMake((W - 100) / 2, 100, 100, 100)];
				[guestButton setAlpha:1];
			} completion:^(BOOL finished){
				[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
					[guestLabel setAlpha:1];
			} completion:nil];
				guestViewVisible = YES;
			}];
		}else { //Swipe out to left
			[guestButton setFrame:CGRectMake((W - 100) / 2, 100, 100, 100)];
			[UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
				[guestLabel setAlpha:0];
			} completion:^(BOOL finished){
				[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
					[guestButton setFrame:CGRectMake(-100, 120, 100, 100)];
					[guestButton setAlpha:0];
				} completion:^(BOOL finished){
					guestViewVisible = NO;
				}];
			}];
		}
	}
}

-(void)fadeOut {
	[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		[guestButton setFrame:CGRectMake(-100, 120, 100, 100)];
		[guestButton setAlpha:0];
		[guestLabel setAlpha:0];
	} completion:^(BOOL finished){
		guestViewVisible = NO;
	}];
}

-(void)tappedGuest {
	if(guestViewVisible && !loggingIn) {
		loggingIn = YES; //Warning: never set to no (for now)
		[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
			[guestButton setFrame:CGRectMake((W - 120) / 2, 90, 120, 120)];
			[guestLabel setFrame:CGRectMake((W - 150) / 2, 210, 150, 30)];
			[guestLabel setText:@"Logging in"];
		} completion:^(BOOL finished){
			[[GuestAccountManager sharedManager] enableGuestMode];
		}];
	}
}

@end