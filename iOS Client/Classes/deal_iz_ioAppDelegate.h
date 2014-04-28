//
//  deal_iz_ioAppDelegate.h
//  deal.iz.io
//
//  Created by Steven Rolfe on 1/20/11.
//  Copyright 2011 Allintu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "Finch.h"
#import "Sound.h"

@interface deal_iz_ioAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UINavigationController *nav;
	
	Reachability *hostReach;
	UIView *reachView;
	
	BOOL reachable;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

