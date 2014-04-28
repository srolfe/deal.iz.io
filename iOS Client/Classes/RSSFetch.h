//
//  RSSFetch2.h
//  deal.iz.io
//
//  Created by Steven Rolfe on 1/11/11.
//  Copyright 2011 Allintu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol rssFetchDelegate
- (void)dataReady:(NSMutableArray *)dat withType:(int)type;
@end

@interface RSSFetch : NSObject <NSXMLParserDelegate>{
	id <rssFetchDelegate> delegate; // Our delegate
	int typeId;
	
	// NSURL Connection Objects
	NSMutableData *xmlFile;
	NSURLConnection *connection;
	
	// NSXML Objects
	NSXMLParser *parser;
	NSMutableArray *data;
	
	// Filter Specific
	NSMutableArray *siteFilters;
	NSMutableArray *keywordFilters;
	
	// XML Temporary Objects
	NSMutableDictionary *item;
	NSString *currentElement;
	NSMutableString *itemSiteId;
	NSMutableString *itemTitle;
	NSMutableString *itemDescription;
	NSMutableString *itemLink;
	NSMutableString *itemPubDate;
	NSMutableString *itemGuid;
	NSMutableString *itemSiteGuid;
	NSMutableString *itemThumbnail;
	NSMutableString *itemIsFavorite;
	NSMutableString *itemPrice;
}

@property (nonatomic,assign) id delegate;

- (void)fetchRSS:(int)type withArguments:(NSMutableDictionary *)args;
- (void)abort;

@end
