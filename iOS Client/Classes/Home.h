//
//  Home.h
//  deal.iz.io
//
//  Created by Steven Rolfe on 12/31/10.
//  Copyright 2010 Allintu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSFetch.h"
#import "lazyLoading.h"
#import "EGORefreshTableHeaderView.h"

@interface Home : UITableViewController <lazyLoaderDelegate,EGORefreshTableHeaderDelegate,rssFetchDelegate,UISearchBarDelegate>{
	lazyLoading *lazyImages;
	EGORefreshTableHeaderView *_refreshHeaderView;
	RSSFetch *dealFetch;
	
	NSMutableArray *data; // Our deals
	NSMutableArray *sites; // Sites available in the feed (site images included)
	
	NSMutableArray *keywords;
	NSMutableArray *filteredSites;
	NSString *filterName;
	BOOL filterSave;
	
	UIView *loadingView;
	int loadScreen;
	
	BOOL loadCell;
	
	int page;
	int filter;
	int last;
	BOOL loading;
	BOOL filtered;
	BOOL favorite;
	
	BOOL searchEnabled;
	UISearchBar *search;
	NSMutableArray *searchKeywords;
	
	BOOL reachable;
	UIImageView *reachView;

}

- (void)startLoadingScreen;
- (void)removeLoadingScreen;
- (void)reloadTableViewDataSource;

- (id)init:(BOOL)fav andFilter:(int)fil;

@end
