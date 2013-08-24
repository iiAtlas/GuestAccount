#import <sys/sysctl.h>

@interface GuestAccountManager : NSObject

@property (nonatomic, assign) BOOL guestModeEnabled;

+(GuestAccountManager *)sharedManager;

-(void)enableGuestMode;
-(void)disableGuestMode;

-(NSArray *)runningProcesses;

@end