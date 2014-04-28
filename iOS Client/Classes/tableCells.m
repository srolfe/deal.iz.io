//
//  tableCells.m
//  deal.iz.io
//
//  Created by Steven Rolfe on 1/1/11.
//  Copyright 2011 Allintu. All rights reserved.
//

#import "tableCells.h"
#import <QuartzCore/QuartzCore.h>

@implementation tableCells
@synthesize textLabel;
@synthesize siteImage;
@synthesize thumb;
@synthesize borderView;
@synthesize timeStamp;
@synthesize favIcon;
@synthesize priceLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		favIcon.alpha=0;
		borderView.alpha=0;
    }
    return self;
}

- (void) drawRect:(CGRect)rect{
	[super drawRect:rect];
	
	self.layer.shadowPath=[UIBezierPath bezierPathWithRect:self.bounds].CGPath;
	[self.layer setShadowOpacity:0.2];
	[self.layer setShadowOffset:CGSizeMake(0, 0)];
	[self.layer setShadowColor:[UIColor blackColor].CGColor];
	[self.layer setShadowRadius:1.0];
}

-(void)setText:(NSString *)tx{
	textLabel.text=tx;
}

-(void)setFav:(BOOL)f{
	favIcon.alpha=f;
}

-(void)setSiteIcon:(UIImage *)im{
	siteImage.image=im;
}

-(void)setThumbnail:(UIImage *)im{
	thumb.image=im;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)dealloc {
	[textLabel release];
	[siteImage release];
	[thumb release];
	[borderView release];
	[timeStamp release];
	[favIcon release];
	[priceLabel release];
    [super dealloc];
}


@end
