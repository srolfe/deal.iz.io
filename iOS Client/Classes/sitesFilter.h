//
//  sitesFilter.h
//  deal.iz.io
//
//  Created by Steven Rolfe on 1/18/11.
//  Copyright 2011 Allintu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol sitesFilterDelegate
-(void)didFilterSites:(NSMutableArray *)siteList;
@end

@interface sitesFilter : UITableViewController {
	id <sitesFilterDelegate> delegate;
	NSMutableArray *sites;
}

@property (nonatomic,assign) id delegate;

- (id)initWithSites:(NSMutableArray *)siteList;

@end
