//
//  detailsWebView.m
//  deal.iz.io
//
//  Created by Steven Rolfe on 1/26/11.
//  Copyright 2011 App.iz.io. All rights reserved.
//

#import "detailsWebView.h"


@implementation detailsWebView


-(id)init:(NSString *)link{
	if ((self=[super init])){
		UIWebView *web=[[UIWebView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-40)];
		[web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[link stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]]];
		web.scalesPageToFit=YES;
		[web setDelegate:self];
		[self.view addSubview:web];
		[web release];
		
		omg=link;
		
		UIActivityIndicatorView *active=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 5, 20, 20)];
		[active setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
		[active startAnimating];
		self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:active];
		[active release];
	}
	
	return self;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView{
	self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(activate)];
}

- (void) webViewDidStartLoad:(UIWebView *)webView{
	UIActivityIndicatorView *active=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 5, 20, 20)];
	[active setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
	[active startAnimating];
	self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:active];
	[active release];
}

- (void)activate{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[omg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
