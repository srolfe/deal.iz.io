//
//  deal_iz_ioAppDelegate.m
//  deal.iz.io
//
//  Created by Steven Rolfe on 1/20/11.
//  Copyright 2011 Allintu. All rights reserved.
//

#import "deal_iz_ioAppDelegate.h"
#import "mainScreen.h"
#import "Reachability.h"

@implementation UINavigationBar (nav)

- (void) drawRect:(CGRect)rect{
	//[super drawRect:rect];
	UIImage *img=[UIImage imageNamed:@"navBar"];
	[img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	self.tintColor=[UIColor colorWithRed:72.0/255.0 green:72.0/255.0 blue:72.0/255.0 alpha:1];
}

@end



@implementation deal_iz_ioAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	nav=[[UINavigationController alloc] init];
	
	mainScreen *ms=[[mainScreen alloc] init];
	
	[nav pushViewController:ms animated:NO];
	
	reachable=YES;
	
    [self.window addSubview:nav.view];
    [self.window makeKeyAndVisible];
	
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
	
	hostReach = [[Reachability reachabilityWithHostName:@"deal.iz.io"] retain];
	[hostReach startNotifier];
    
    return YES;
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
	
	const char* data = [deviceToken bytes];
	NSMutableString* token = [NSMutableString string];
	
	for (int i = 0; i < [deviceToken length]; i++) {
		[token appendFormat:@"%02.2hhX", data[i]];
	}
	
	NSMutableString *url=[[NSMutableString alloc] init];
	[url appendFormat:@"http://deal.iz.io/api/api.php?udid=%@",[UIDevice currentDevice].uniqueIdentifier];
	[url appendFormat:@"&req=addPushToken&token=%@",token];
	[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]] delegate:self];
	[url release];
}

- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
	NSLog(@"Error in registration. Error: %@", error);
}

- (void)reach:(Reachability *)reach{
	NetworkStatus internetStatus = [reach currentReachabilityStatus];
	if (internetStatus==NotReachable && reachable){
		reachable=NO;
		reachView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBack"]];
		reachView.frame=CGRectMake(0,self.window.frame.size.height,self.window.frame.size.width,self.window.frame.size.height);
		reachView.layer.zPosition=100;
		
		UIImageView *mIcon=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moneyFade"]];
		mIcon.frame=CGRectMake(self.window.frame.size.width/2-50, self.window.frame.size.height/2-25-60, 100, 100);
		[reachView addSubview:mIcon];
		[mIcon release];
		
		UILabel *tmp=[[UILabel alloc] initWithFrame:CGRectMake(self.window.frame.size.width/2-100, self.window.frame.size.height/2-25, 200, 50)];
		[tmp setText:@"Network Unavailable"];
		[tmp setTextColor:[UIColor grayColor]];
		[tmp setTextAlignment:UITextAlignmentCenter];
		[tmp setBackgroundColor:[UIColor clearColor]];
		[tmp setShadowColor:[UIColor lightGrayColor]];
		[tmp setShadowOffset:CGSizeMake(1, 1)];
		[reachView addSubview:tmp];
		[tmp release];
		
		[self.window addSubview:reachView];;
		
		[UIView beginAnimations:@"noService" context:self];
		[UIView setAnimationDuration:1];
		CGRect oldFrame=reachView.frame;
		oldFrame.origin.y=0;
		[reachView setFrame:oldFrame];
		[UIView commitAnimations];
	}else{
		if (reachView!=nil && !reachable){
			reachable=YES;
			[UIView beginAnimations:@"yesService" context:self];
			[UIView setAnimationDuration:1];
			CGRect oldFrame=reachView.frame;
			oldFrame.origin.y+=self.window.frame.size.height;
			[reachView setFrame:oldFrame];
			[UIView commitAnimations];
		
			[reachView performSelector:@selector(removeFromSuperview) withObject:reachView afterDelay:1];
			[reachView performSelector:@selector(release) withObject:reachView afterDelay:1.05];
		}
	}
}

- (void)reachabilityChanged:(NSNotification *)note{
	NSLog(@"Was notified");
	Reachability* curReach=[note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self reach:curReach];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
