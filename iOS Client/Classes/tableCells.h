//
//  tableCells.h
//  deal.iz.io
//
//  Created by Steven Rolfe on 1/1/11.
//  Copyright 2011 Allintu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface tableCells : UITableViewCell {
	IBOutlet UILabel *textLabel;
	IBOutlet UIImageView *siteImage;
	IBOutlet UIImageView *thumb;
	IBOutlet UIImageView *borderView;
	IBOutlet UILabel *timeStamp;
	IBOutlet UIImageView *favIcon;
	IBOutlet UILabel *priceLabel;
	//UIActivityIndicatorView *active;
}

@property (nonatomic,retain) IBOutlet UILabel *textLabel;
@property (nonatomic,retain) IBOutlet UIImageView *siteImage;
@property (nonatomic,retain) IBOutlet UIImageView *thumb;
@property (nonatomic,retain) IBOutlet UIImageView *borderView;
@property (nonatomic,retain) IBOutlet UILabel *timeStamp;
@property (nonatomic,retain) IBOutlet UIImageView *favIcon;
@property (nonatomic,retain) IBOutlet UILabel *priceLabel;

-(void)setText:(NSString *)tx;
-(void)setSiteIcon:(UIImage *)im;
-(void)setThumbnail:(UIImage *)im;
-(void)setFav:(BOOL)f;

@end
