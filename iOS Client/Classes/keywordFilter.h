//
//  keywordFilter.h
//  deal.iz.io
//
//  Created by Steven Rolfe on 1/18/11.
//  Copyright 2011 Allintu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol keysFilterDelegate
-(void)didFilterKeys:(NSMutableArray *)keyList;
@end

@interface keywordFilter : UITableViewController <UITextFieldDelegate> {
	id <keysFilterDelegate> delegate;
	NSMutableArray *keys;
	UITextField *texty;
}

@property (nonatomic,assign) id delegate;

@end
