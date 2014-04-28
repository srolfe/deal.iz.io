//
//  lazyLoading.m
//  deal.iz.io
//
//  Created by Steven Rolfe on 1/5/11.
//  Copyright 2011 Allintu. All rights reserved.
//

#import "lazyLoading.h"


@implementation lazyLoading
@synthesize urls;
@synthesize delegate;
@synthesize currDownload;
@synthesize conn;

-(id)init{
	if ((self==[super init])){
		urls=[[NSMutableArray alloc] init];
		loading=NO;
		siteImages=[[NSMutableArray alloc] init];
	}
	
	return self;
}

-(void)queueNextDownload:(NSString *)url withIndexPath:(NSIndexPath *)indexPath withType:(int)type{
	[urls addObject:[[[NSArray alloc] initWithObjects:url,indexPath,[NSString stringWithFormat:@"%d",type],NULL] autorelease]];
	[self download];
}

-(void)download{
	if ((loading==NO) && ([self.urls count]>0)){
		loading=YES;
		self.currDownload=[NSMutableData data];
		NSURLConnection *tmpCon = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[[[self.urls objectAtIndex:0] objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]] delegate:self];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		self.conn=tmpCon;
		[tmpCon release];
	}
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[self.currDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	self.currDownload=nil;
	self.conn=nil;
	loading=NO;
	[urls removeObjectAtIndex:0];
	[self download];
}

- (void)removeQueue{
	if ([conn respondsToSelector:@selector(cancel)]){
		[conn cancel];
	}
	
	//[urls release];
	currDownload=nil;
	conn=nil;
	loading=NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	//urls=[[NSMutableArray alloc] init];
}

- (void)resumeQueue{
	[self download];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    UIImage *image = [[[UIImage alloc] initWithData:self.currDownload] autorelease];
	if (image!=nil){
		if (image.size.width != 56 && image.size.height != 56 && [[urls objectAtIndex:0] objectAtIndex:2]==0)
		{
			CGSize itemSize = CGSizeMake(56, 56);
			UIGraphicsBeginImageContext(itemSize);
			CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
			[image drawInRect:imageRect];
			image = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
		}
	}else{
		image=[UIImage imageNamed:@"noThumb.png"];
	}
	
	[delegate appImageDidLoad:image atIndex:[[self.urls objectAtIndex:0] objectAtIndex:1] withType:[[[urls objectAtIndex:0] objectAtIndex:2] intValue]];
	//[image release];
	
	[urls removeObjectAtIndex:0];
	self.currDownload=nil;
	self.conn = nil;
	
	loading=NO;
	
	if ([self.urls count]>0){
		[self download];
	}
}



@end
