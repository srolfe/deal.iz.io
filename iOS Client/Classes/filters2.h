//
//  filters2.h
//  deal.iz.io
//
//  Created by Steven Rolfe on 1/12/11.
//  Copyright 2011 Allintu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sitesFilter.h"
#import "keywordFilter.h"
#import "RSSFetch.h"
#import "TDBadgedCell.h"

@protocol filterDelegate
- (void)filterWith:(NSMutableArray *)siteList keywords:(NSMutableArray *)keywordList save:(BOOL)save name:(NSString *)name;
- (void)didLoadFilter:(int)filterId;
@end

@interface filters2 : UITableViewController <rssFetchDelegate,sitesFilterDelegate,keysFilterDelegate,UITextFieldDelegate> {
	id <filterDelegate> delegate;
	RSSFetch *rss;
	
	NSMutableArray *keywords;
	NSMutableArray *sites;
	NSMutableString *name;
	
	UITextField *texty;
	UISwitch *switchy;
	BOOL save;
	
	int omgcats;
	
	BOOL sChange;
	BOOL kChange;
	
	TDBadgedCell *nameCell;
	
	UIImageView *reachView;
	BOOL reachable;
}

@property (nonatomic,assign) id delegate;

@end
