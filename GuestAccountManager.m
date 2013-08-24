#import "GuestAccountManager"

@implementation GuestAccountManager

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

@end