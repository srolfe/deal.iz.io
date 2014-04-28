//
//  RSSFetch2.m
//  deal.iz.io
//
//  Created by Steven Rolfe on 1/11/11.
//  Copyright 2011 Allintu. All rights reserved.
//

#import "RSSFetch.h"
#import "Reachability.h"


@implementation RSSFetch
@synthesize delegate;

- (id)init{
	if ((self=[super init])){
		data=[[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)fetchRSS:(int)type withArguments:(NSMutableDictionary *)args{
	// Reset our NSURL objects
	xmlFile=[[NSMutableData alloc] init];
	item=[[NSMutableDictionary alloc] init];
	
	// Save our type
	typeId=type;
	
	// Build our URL
	NSMutableString *rssURL=[[NSMutableString alloc] initWithString:@"http://deal.iz.io/api/api.php?"];
	switch (type) {
		case 0:{
			// Our standard feed. Append the feed tag
			[rssURL appendString:@"req=feed"];
		}break;
		case 1:{
			// Fetch a list of sites available
			[rssURL appendString:@"req=siteFetch"];
		}break;
		case 2:{
			// Fetch a list of sites available
			[rssURL appendString:@"req=filterFetch"];
		}break;
	}
	
	// Check our arguments out
	// Start with filters
	if ([args objectForKey:@"filters"]!=nil){
		[rssURL appendString:@"&filtered=yes"];
		
		// Check the keywords first
		if ([[args objectForKey:@"filters"] objectForKey:@"keywords"]!=nil){
			[rssURL appendString:@"&keys="];
			for (NSString *filter in [[args objectForKey:@"filters"] objectForKey:@"keywords"]){
				[rssURL appendString:filter];
				[rssURL appendString:@"|"];
			}
		}
		
		// Check the sites next
		if ([[args objectForKey:@"filters"] objectForKey:@"sites"]!=nil){
			[rssURL appendString:@"&sites="];
			for (NSString *filter in [[args objectForKey:@"filters"] objectForKey:@"sites"]){
				[rssURL appendString:filter];
				[rssURL appendString:@"|"];
			}
		}
		
		// Lastly, are we saving this filter?
		if ([[args objectForKey:@"filters"] objectForKey:@"save"]!=nil){
			[rssURL appendString:@"&save=true&name="];
			[rssURL appendString:[[args objectForKey:@"name"] objectForKey:@"save"]];
		}
	}
	
	if ([args objectForKey:@"filterId"]!=nil){
		[rssURL appendString:@"&filtered=yes"];
		[rssURL appendFormat:@"&filterId=%@",[args objectForKey:@"filterId"]];
	}
	
	// Next argument: pages
	if ([args objectForKey:@"page"]!=nil){
		[rssURL appendFormat:@"&p=%@",[args objectForKey:@"page"]];
	}
	
	// Next argument: favorites
	if ([args objectForKey:@"favorite"]!=nil){
		[rssURL appendString:@"&fav=true"];
	}
	
	// Finish up with a UDID
	[rssURL appendFormat:@"&udid=%@",[UIDevice currentDevice].uniqueIdentifier];
	
	// That's all for now. Let's begin...
	connection=[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[rssURL stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]] delegate:self];
	[rssURL release];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	NSLog(@"%@",error);
}

// ---[ NSURL Delegate Functions ]---
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)dat{
	[xmlFile appendData:dat];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	// Initalize the parser
	parser=[[NSXMLParser alloc] initWithData:xmlFile];
	[parser setDelegate:self];
	
	// Setup some additional options
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	
	// Turn on our network activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
	
	// Parse the document
	data=[[NSMutableArray alloc] init];
	[parser parse];
}

// ---[ NSXML Delegate Functions ]---
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
	// Save our current element's name
	currentElement=[elementName copy];
	
	// Are we inside an item?
	if ([elementName isEqualToString:@"item"]){
		// Clear all our temporary bits
		item=[[NSMutableDictionary alloc] init];
		itemTitle=[[NSMutableString alloc] init];
		itemDescription=[[NSMutableString alloc] init];
		itemLink=[[NSMutableString alloc] init];
		itemPubDate=[[NSMutableString alloc] init];
		itemGuid=[[NSMutableString alloc] init];
		itemSiteGuid=[[NSMutableString alloc] init];
		itemSiteId=[[NSMutableString alloc] init];
		itemThumbnail=[[NSMutableString alloc] init];
		itemIsFavorite=[[NSMutableString alloc] init];
		itemPrice=[[NSMutableString alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	// Save the bits we find
	if ([currentElement isEqualToString:@"title"]){
		[itemTitle appendString:string];
	}else if ([currentElement isEqualToString:@"description"]){
		[itemDescription appendString:string];
	}else if ([currentElement isEqualToString:@"link"]){
		[itemLink appendString:string];
	}else if ([currentElement isEqualToString:@"pubDate"]){
		[itemPubDate appendString:string];
	}else if ([currentElement isEqualToString:@"guid"]){
		[itemGuid appendString:string];
	}else if ([currentElement isEqualToString:@"siteguid"]){
		[itemSiteGuid appendString:string];
	}else if ([currentElement isEqualToString:@"siteid"]){
		[itemSiteId	appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	}else if ([currentElement isEqualToString:@"thumbnail"]){
		[itemThumbnail appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	}else if ([currentElement isEqualToString:@"favorite"]){
		[itemIsFavorite appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	}else if ([currentElement isEqualToString:@"price"]){
		[itemPrice appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	// Save all our bits to the master array
	if ([elementName isEqualToString:@"item"]){
		[item setObject:itemTitle forKey:@"title"];
		[item setObject:itemDescription forKey:@"description"];
		[item setObject:itemLink forKey:@"link"];
		[item setObject:itemPubDate forKey:@"pubDate"];
		[item setObject:itemGuid forKey:@"guid"];
		[item setObject:itemSiteGuid forKey:@"siteGuid"];
		[item setObject:itemSiteId forKey:@"siteId"];
		[item setObject:itemThumbnail forKey:@"thumbnail"];
		[item setObject:itemIsFavorite forKey:@"favorite"];
		[item setObject:itemPrice forKey:@"price"];
		
		[data addObject:item];
		[item release];
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parse{
	// Stop network activity indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
	
	// Call our delegate
	[[self delegate] dataReady:[data mutableCopy] withType:typeId];
	[data release];
}

- (void)abort{
	if (parser!=nil){
		[parser abortParsing];
		[parser release];
	}
}

@end
