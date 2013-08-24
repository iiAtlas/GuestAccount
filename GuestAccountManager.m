#import "GuestAccountManager.h"

@implementation GuestAccountManager

@synthesize guestModeEnabled;

-(id)init {
	if((self = [super init])) {

	}
	return self;
}

+(GuestAccountManager *)sharedManager {
	dispatch_once_t pred;
	static GuestAccountManager *sharedInstance = nil;
	dispatch_once(&pred, ^{
		sharedInstance = [[GuestAccountManager alloc] init];
	});
	return sharedInstance;
}

-(void)enableGuestMode {
	//Kill all (user) applications, makes sure apps reset data
    for (NSString *processName in [self runningProcesses]) {
        NSLog(@"\n\n processName:%@", processName);
        system([[NSString stringWithFormat:@"killall %@", processName] cStringUsingEncoding:NSASCIIStringEncoding]);
    }

    //Move applications
    [[NSFileManager defaultManager] moveItemAtPath:@"/var/mobile/Applications" toPath:@"/var/mobile/Applications.bak" error:nil];
    
    //Move contacts and contact images
    [[NSFileManager defaultManager] moveItemAtPath:@"/var/mobile/Library/AddressBook/AddressBook.sqlitedb" toPath:@"/var/mobile/Library/AddressBook/AddressBook.sqlitedb.bak" error:nil];
    [[NSFileManager defaultManager] moveItemAtPath:@"/var/mobile/Library/AddressBook/AddressBookImages.sqlitedb" toPath:@"/var/mobile/Library/AddressBook/AddressBookImages.sqlitedb.bak" error:nil];
    
    //Set springboard to do a soft respring
    NSString *filename = @"/var/mobile/Library/Preferences/com.apple.springboard.plist";
    NSMutableDictionary *prefs = [[[NSMutableDictionary alloc] initWithContentsOfFile:filename] autorelease];
    [prefs setValue:@"true" forKey:@"SBLanguageRestart"];
    [prefs writeToFile:filename atomically:YES];
    
    system("killall SpringBoard");

	[self setGuestModeEnabled:YES];
}

-(void)disableGuestMode {
	//Restore applications
    [[NSFileManager defaultManager] moveItemAtPath:@"/var/mobile/Applications.bak" toPath:@"/var/mobile/Applications" error:nil];
    
    //Restore contacts and contact images
    [[NSFileManager defaultManager] moveItemAtPath:@"/var/mobile/Library/AddressBook/AddressBook.sqlitedb.bak" toPath:@"/var/mobile/Library/AddressBook/AddressBook.sqlitedb" error:nil];
    [[NSFileManager defaultManager] moveItemAtPath:@"/var/mobile/Library/AddressBook/AddressBookImages.sqlitedb.bak" toPath:@"/var/mobile/Library/AddressBook/AddressBookImages.sqlitedb" error:nil];

    system("killall SpringBoard");

	[self setGuestModeEnabled:NO];
}

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

@end