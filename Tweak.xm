#import <UIKit/UIKit.h>
#include <notify.h>
#import <sys/sysctl.h>

#import <SpringBoard/SBSearchView.h>

@interface XXUnknownSuperclass
@end

@interface SBDisplay : XXUnknownSuperclass
@end

@interface SBAlert : SBDisplay
@end

@interface SBAwayController : SBAlert
-(id)awayView;
-(void)swipeGuestIn;
-(void)swipeGuestOut;
-(void)tappedGuest;
-(void)setGuestMode;
-(void)endGuestMode;
-(NSArray *)runningProcesses;
@end

@interface SBAwayLockBar : UIView
-(void)knobDragged:(float)dragged;
@end

@interface SBUIFullScreenAlertAdapter : SBAlert
-(BOOL)handleLockButtonPressed;
@end

@interface SBSearchController
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
            [self setGuestMode];
        }];
    }
}

%new
//does all the file modification stuff and soft resprings
-(void)setGuestMode {    
    //kill all (user) applications, makes sure apps reset data
    for (NSString *processName in [self runningProcesses]) {
        NSLog(@"\n\n processName:%@", processName);
        system([[NSString stringWithFormat:@"killall %@", processName] cStringUsingEncoding:NSASCIIStringEncoding]);
    }
    //move applications
    [[NSFileManager defaultManager] moveItemAtPath:@"/var/mobile/Applications" toPath:@"/var/mobile/Applications.bak" error:nil];
    
    //move contacts and contact images
    [[NSFileManager defaultManager] moveItemAtPath:@"/var/mobile/Library/AddressBook/AddressBook.sqlitedb" toPath:@"/var/mobile/Library/AddressBook/AddressBook.sqlitedb.bak" error:nil];
    [[NSFileManager defaultManager] moveItemAtPath:@"/var/mobile/Library/AddressBook/AddressBookImages.sqlitedb" toPath:@"/var/mobile/Library/AddressBook/AddressBookImages.sqlitedb.bak" error:nil];
    
    //set springboard to do a soft respring
    NSString *filename = @"/var/mobile/Library/Preferences/com.apple.springboard.plist";
    NSMutableDictionary *prefs = [[[NSMutableDictionary alloc] initWithContentsOfFile:filename] autorelease];
    [prefs setValue:@"true" forKey:@"SBLanguageRestart"];
    [prefs writeToFile:filename atomically:YES];
    
    //send respring command
    system("killall SpringBoard");
}

%new
//restore all files 
-(void)endGuestMode {
    //restore applications
    [[NSFileManager defaultManager] moveItemAtPath:@"/var/mobile/Applications.bak" toPath:@"/var/mobile/Applications" error:nil];
    //restore contacts and contact images
    [[NSFileManager defaultManager] moveItemAtPath:@"/var/mobile/Library/AddressBook/AddressBook.sqlitedb.bak" toPath:@"/var/mobile/Library/AddressBook/AddressBook.sqlitedb" error:nil];
    [[NSFileManager defaultManager] moveItemAtPath:@"/var/mobile/Library/AddressBook/AddressBookImages.sqlitedb.bak" toPath:@"/var/mobile/Library/AddressBook/AddressBookImages.sqlitedb" error:nil];

    //full respring, passcode will be required if one is set
    system("killall SpringBoard");
}

%new
//make array of running processes
-(NSArray *)runningProcesses {
    NSString *appleProcesses = @"kernel_task, launchd, UserEventAgent, wifid, timed, syslogd, powerd, lockdownd, installd, deleted, mediaserverd, mDNSResponder, locationd, imagent, iaptransportd, fseventsd, fairplayd.J1, AppleIDAuthAgent, configd, backboardd, kbd, BTServer, notifyd, itunesstored, SpringBoard, aggregated, networkd, networkd_privile, CommCenterClassi, apsd, gamed, dataaccessd, aosnotifyd, accountsd, lsd, distnoted, assetsd, tccd, softwareupdatese, MobilePhone, MobileMail, xpcd, geod, BlueTool, SCHelper, filecoordination, coresymbolicatio, absinthed.J1, notification_pro, afcd, MobileSMS, ptpd, syslog_relay, DTMobileIS, springboardservi, librariand, ubd, syncdefaultsd, lockbot, amfid, assistantd, assistant_servic, securityd, sandboxd, debugserver, appkick distro, CFNetworkAgent, awdd, pasteboardd";
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t miblen = 4;
    size_t size;
    int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
    struct kinfo_proc *process = NULL;
    struct kinfo_proc *newprocess = NULL;
    do {
        size += size / 10;
        newprocess = (struct kinfo_proc *)realloc(process, size);
        if (!newprocess){
            if (process){
                free(process);
            }
            return nil;
        }
        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);
    } while (st == -1 && errno == ENOMEM);
    if (st == 0){
        if (size % sizeof(struct kinfo_proc) == 0){
            int nprocess = size / sizeof(struct kinfo_proc);
            if (nprocess){
               NSMutableArray *array = [[NSMutableArray alloc] init];
                for (int i = nprocess -1; i >= 0; i--){
                    NSString *processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                    //if its a user application, add it to returned array
                    NSLog(@"%@", processName);
                    if([appleProcesses rangeOfString:processName].location == NSNotFound) {
                        [array addObject:processName];
                    }
                    [processName release];
                }
                free(process);
                return [array autorelease];
            }
        }
    }

    return nil;
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