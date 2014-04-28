//
//  mainScreen.h
//  deal.iz.io
//
//  Created by Steven Rolfe on 1/20/11.
//  Copyright 2011 Allintu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSFetch.h"
#import "Home.h"
#import "filters2.h"
#import "Finch.h"
#import "Sound.h"


@interface mainScreen : UITableViewController <rssFetchDelegate> {
	RSSFetch *rss;
	NSMutableArray *filters;
	
	BOOL load;
	NSMutableArray *sites;
	
	filters2 *fit;
	
	Finch *soundEngine;
	Sound *click;
	
	BOOL createButton;
	BOOL loadButton;
	
	BOOL reachable;
	UIImageView *reachView;
	
	UIActivityIndicatorView *filterLoader;
	UIButton *filterEdit;
}

- (void)settings;
- (void)addFilter;
- (void)doClick;

@end
