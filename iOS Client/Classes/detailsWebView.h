//
//  detailsWebView.h
//  deal.iz.io
//
//  Created by Steven Rolfe on 1/26/11.
//  Copyright 2011 App.iz.io. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface detailsWebView : UIViewController <UIWebViewDelegate> {

	NSString *omg;
}

-(id)init:(NSString *)link;

@end
