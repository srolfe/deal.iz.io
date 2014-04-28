//
//  lazyLoading.h
//  deal.iz.io
//
//  Created by Steven Rolfe on 1/5/11.
//  Copyright 2011 Allintu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol lazyLoaderDelegate
-(void)appImageDidLoad:(UIImage *)im atIndex:(NSIndexPath *)indexPath withType:(int)type;
@end

@interface lazyLoading : NSObject {
	id <lazyLoaderDelegate> delegate;
	NSMutableArray *urls;
	NSMutableData *currDownload;
	NSURLConnection *conn;
	BOOL loading;
	NSMutableArray *siteImages;

}

@property (nonatomic,assign) id delegate;
@property (nonatomic,retain) NSMutableArray *urls;
@property (nonatomic,retain) NSMutableData *currDownload;
@property (nonatomic,retain) NSURLConnection *conn;
//@property (nonatomic,retain) BOOL loading;

-(void)queueNextDownload:(NSString *)url withIndexPath:(NSIndexPath *)indexPath withType:(int)type;
-(void)download;
-(void)removeQueue;
-(void)resumeQueue;

@end
