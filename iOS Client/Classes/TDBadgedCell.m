//
//  TDBadgedCell.m
//  TDBadgedTableCell
//	TDBageView
//
//	Any rereleasing of this code is prohibited.
//	Please attribute use of this code within your application
//
//	Any Queries should be directed to hi@tmdvs.me | http://www.tmdvs.me
//	
//  Created by Tim on [Dec 30].
//  Copyright 2009 Tim Davies. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TDBadgedCell.h"

@interface TDBadgeView ()

@property (nonatomic, retain) UIFont *font;
@property (nonatomic, assign) NSUInteger width;

@end

@implementation TDBadgeView

@synthesize width, badgeString, parent, badgeColor, badgeColorHighlighted;
// from private
@synthesize font;

- (id) initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		font = [[UIFont boldSystemFontOfSize: 14] retain];
		
		self.backgroundColor = [UIColor clearColor];
	}
	
	return self;	
}

- (void) drawRect:(CGRect)rect
{	
	NSString *countString = self.badgeString;
	
	CGSize numberSize = [countString sizeWithFont: font];
	
	self.width = numberSize.width + 16;
	
	CGRect bounds = CGRectMake(0 , 0, numberSize.width + 16 , 18);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	float radius = bounds.size.height / 2.0;
	
	CGContextSaveGState(context);
	
	UIColor *col;
	if (parent.highlighted || parent.selected) {
		if (self.badgeColorHighlighted) {
			col = self.badgeColorHighlighted;
		} else {
			col = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.000];
		}
	} else {
		if (self.badgeColor) {
			col = self.badgeColor;
		} else {
			col = [UIColor colorWithRed:0.530 green:0.600 blue:0.738 alpha:1.000];
		}
	}

	CGContextSetFillColorWithColor(context, [col CGColor]);
	
	CGContextBeginPath(context);
	CGContextAddArc(context, radius, radius, radius, M_PI / 2 , 3 * M_PI / 2, NO);
	CGContextAddArc(context, bounds.size.width - radius, radius, radius, 3 * M_PI / 2, M_PI / 2, NO);
	CGContextClosePath(context);
	CGContextFillPath(context);
	CGContextRestoreGState(context);
	
	bounds.origin.x = (bounds.size.width - numberSize.width) / 2 +0.5;
	
	CGContextSetBlendMode(context, kCGBlendModeClear);
	
	[countString drawInRect:bounds withFont:self.font];
}

- (void) dealloc
{
	parent = nil;
	
	[font release];
	[badgeColor release];
	[badgeColorHighlighted release];
	
	[super dealloc];
}

@end


@implementation TDBadgedCell

@synthesize badgeString, badge, badgeColor, badgeColorHighlighted;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		badge = [[TDBadgeView alloc] initWithFrame:CGRectZero];
		badge.parent = self;
		
		//[self setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0.93 alpha:1]];
		//backImage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"betterCell"]];
		//[backImage setFrame:self.frame];
		//self.layer.masksToBounds=YES
		//self.layer.superlayer.
		//[self.layer setBorderWidth:2];
		
		//redraw cells in accordance to accessory
		float version = [[[UIDevice currentDevice] systemVersion] floatValue];
		
		if (version <= 3.0)
			[self addSubview:self.badge];
		else 
			[self.contentView addSubview:self.badge];
		
		[self.badge setNeedsDisplay];
    }
    return self;
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	
	UIImageView *backImage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"betterCell"]];
	[backImage setFrame:self.bounds];
	
	self.layer.shadowPath=[UIBezierPath bezierPathWithRect:self.bounds].CGPath;
	[self.layer setShadowOpacity:0.2];
	[self.layer setShadowOffset:CGSizeMake(0, 0)];
	[self.layer setShadowColor:[UIColor blackColor].CGColor];
	[self.layer setShadowRadius:1.0];
	
	//[self.layer setShouldRasterize:YES];
	 
	
	[self setBackgroundView:backImage];
	[backImage release];
	
	 
	if(self.badgeString)
	{
		//force badges to hide on edit.
		if(self.editing)
			[self.badge setHidden:YES];
		else
			[self.badge setHidden:NO];
		
		
		CGSize badgeSize = [self.badgeString sizeWithFont:[UIFont boldSystemFontOfSize: 14]];
		
		float version = [[[UIDevice currentDevice] systemVersion] floatValue];
		
		CGRect badgeframe;
		
		if (version <= 3.0)
		{
			badgeframe = CGRectMake(self.contentView.frame.size.width - (badgeSize.width+16), round((self.contentView.frame.size.height - 18) / 2), badgeSize.width+16, 18);
		}
		else
		{
			badgeframe = CGRectMake(self.contentView.frame.size.width - (badgeSize.width+16) - 10, round((self.contentView.frame.size.height - 18) / 2), badgeSize.width+16, 18);
		}
		
		[self.badge setFrame:badgeframe];
		[badge setBadgeString:self.badgeString];
		[badge setParent:self];
		
		if ((self.textLabel.frame.origin.x + self.textLabel.frame.size.width) >= badgeframe.origin.x)
		{
			CGFloat badgeWidth = self.textLabel.frame.size.width - badgeframe.size.width - 10.0;
			
			self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y, badgeWidth, self.textLabel.frame.size.height);
		}
		
		if ((self.detailTextLabel.frame.origin.x + self.detailTextLabel.frame.size.width) >= badgeframe.origin.x)
		{
			CGFloat badgeWidth = self.detailTextLabel.frame.size.width - badgeframe.size.width - 10.0;
			
			self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x, self.detailTextLabel.frame.origin.y, badgeWidth, self.detailTextLabel.frame.size.height);
		}
		//set badge highlighted colours or use defaults
		if(self.badgeColorHighlighted)
			badge.badgeColorHighlighted = self.badgeColorHighlighted;
		else 
			badge.badgeColorHighlighted = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.000];
		
		//set badge colours or impose defaults
		if(self.badgeColor)
			badge.badgeColor = self.badgeColor;
		else
			badge.badgeColor = [UIColor colorWithRed:0.530 green:0.600 blue:0.738 alpha:1.000];
	}
	else
	{
		[self.badge setHidden:YES];
	}
	
}

/*
- (void)drawRect:(CGRect)rect{
	[super drawRect:rect];
	
	CGRect oldFrame=self.frame;
	CGRect newFrame=self.frame;
	newFrame.origin.x-=500;
	
	[self setFrame:newFrame];
	
	[UIView beginAnimations:@"tmp" context:self];
	[UIView setAnimationDuration:0.3];
	[self setFrame:oldFrame];
	[UIView commitAnimations];
}
 */
	

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	[super setHighlighted:highlighted animated:animated];
	[badge setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	[badge setNeedsDisplay];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	
	if (editing) {
		badge.hidden = YES;
		[badge setNeedsDisplay];
		[self setNeedsDisplay];
		
		//[self addEditButton];
	}
	else 
	{
		badge.hidden = NO;
		[badge setNeedsDisplay];
		[self setNeedsDisplay];
		
		//[self removeEditButton];
	}
}

/*
-(void)addEditButton{
	editBut=[[UIButton alloc] initWithFrame:CGRectMake(195, 7, 50, 30)];
	[editBut setBackgroundColor:[UIColor grayColor]];
	[editBut setTitle:@"Edit" forState:UIControlStateNormal];
	
	[editBut actionsForTarget:@selector(editMe) forControlEvent:UIControlEventTouchUpInside];
	
	editBut.layer.masksToBounds=YES;
	[editBut.layer setCornerRadius:3.0];
	
	[self addSubview:editBut];
}

-(void)editMe{
	NSLog(@"Editing...");
}

-(void)removeEditButton{
	[editBut removeFromSuperview];
	[editBut release];
}
 */

- (void)dealloc {
	[badge release];
	[badgeColor release];
	[badgeString release];
	[badgeColorHighlighted release];
	
    [super dealloc];
}


@end