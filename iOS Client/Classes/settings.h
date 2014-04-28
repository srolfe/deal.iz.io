//
//  settings.h
//  deal.iz.io
//
//  Created by Steven Rolfe on 1/17/11.
//  Copyright 2011 Allintu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSFetch.h"


@interface settings : UITableViewController <rssFetchDelegate> {
	RSSFetch *rss;
	NSMutableArray *sites;
	bool loading;
}

@end
