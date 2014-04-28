//
//  mainScreen.m
//  deal.iz.io
//
//  Created by Steven Rolfe on 1/20/11.
//  Copyright 2011 Allintu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "mainScreen.h"
#import "RSSFetch.h"
#import "TDBadgedCell.h"
#import "Home.h"
#import "filters2.h"
#import "settings.h"
#import "Finch.h"
#import "Sound.h"


@implementation mainScreen


#pragma mark -
#pragma mark Initialization

- (id)init{
	if ((self=[super initWithStyle:UITableViewStylePlain])){
		createButton=NO;
		loadButton=YES;
		
		UISwipeGestureRecognizer *swipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
		[swipe setDirection:UISwipeGestureRecognizerDirectionRight];
		[self.view addGestureRecognizer:swipe];
		
		soundEngine=[[Finch alloc] init];
		click=[[Sound alloc] initWithFile:[[NSBundle mainBundle] URLForResource:@"click" withExtension:@"wav"]];
		
		// Load our RSS class
		[self.tableView setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBack"]] autorelease]];
		[self.tableView setSeparatorColor:[UIColor lightGrayColor]];
		
		rss=[[RSSFetch alloc] init];
		[rss setDelegate:self];
		
		[self setTitle:@"deal.iz.io"];
		
		filters=[[NSMutableArray alloc] init];
		
		NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
		if ([def arrayForKey:@"filters"]!=nil){
			filters=[[def arrayForKey:@"filters"] mutableCopy];
			loadButton=NO;
		}
		
		sites=[[NSMutableArray alloc] init];
		
		load=YES;
		
		fit=[[filters2 alloc] init];
		
		reachable=YES;
		
		[rss fetchRSS:2 withArguments:nil];
		
		self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settings)];
		self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Add Filter" style:UIBarButtonItemStylePlain target:self action:@selector(addFilter)];
	}
	
	return self;
}

- (void)swiped:(UIGestureRecognizer *)swipe{
	// We got a swipe. Let's locate it...
	NSIndexPath *cellPath=[self.tableView indexPathForRowAtPoint:[swipe locationInView:self.view]];
	
	[self removePopOvers];
	
	if (cellPath.section==2){
		// Get our frame
		CGRect frame=[self.tableView rectForRowAtIndexPath:cellPath];
		CGPoint yOffset=self.tableView.contentOffset;
		
		// Animation + Regular frames
		CGRect prevFrame=CGRectMake(0-frame.size.width, (frame.origin.y - yOffset.y), frame.size.width, frame.size.height);
		CGRect cellFrame=CGRectMake(frame.origin.x, (frame.origin.y - yOffset.y), frame.size.width, frame.size.height);
		
		// Create popOverFrame
		UIView *popOverFrame=[[UIView alloc] initWithFrame:prevFrame];
		[popOverFrame setTag:1337];
		[popOverFrame setBackgroundColor:[UIColor clearColor]];
		
		// Delete button
		UIButton *deleteButton=[[UIButton alloc] initWithFrame:CGRectMake(popOverFrame.frame.size.width-95, 5, 90, popOverFrame.frame.size.height-10)];
		[deleteButton addTarget:self action:@selector(deleteRow:) forControlEvents:UIControlEventTouchUpInside];
		[deleteButton setTag:cellPath.row];
		[deleteButton setBackgroundColor:[UIColor colorWithRed:191.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1]];
		[deleteButton setTitle:@"remove" forState:UIControlStateNormal];
		[deleteButton.layer setCornerRadius:3.0];
		
		// Edit button
		UIButton *editButton=[[UIButton alloc] initWithFrame:CGRectMake(popOverFrame.frame.size.width-95-95, 5, 90, popOverFrame.frame.size.height-10)];
		[editButton setBackgroundColor:[UIColor colorWithRed:157.0/255.0 green:191.0/255.0 blue:160.0/255.0 alpha:1]];
		[editButton setTitle:@"edit" forState:UIControlStateNormal];
		[editButton.layer setCornerRadius:3.0];
		
		// Add buttons to popOverFrame
		[popOverFrame addSubview:deleteButton];
		[popOverFrame addSubview:editButton];
		
		// Deallocate resources
		[editButton release];
		[deleteButton release];
		
		[self.view addSubview:popOverFrame];
		
		[popOverFrame release];
		
		// Animate it's entry
		[UIView beginAnimations:@"popOver" context:self];
		[UIView setAnimationDuration:0.2];
		[popOverFrame setFrame:cellFrame];
		[UIView commitAnimations];
		
	}
}

- (void)editFilter:(UIButton *)sender{
	[fit 

- (void)deleteRow:(UIButton *)sender{
	[self removePopOvers];
	NSIndexPath *path=[NSIndexPath indexPathForRow:sender.tag inSection:2];
	
	[self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:path];
}

- (void)removePopOvers{
	for (UIView *tmp in self.view.subviews) {
		if (tmp.tag==1337){
			[tmp removeFromSuperview];
		}
	}
}

- (void)doClick{
	[click play];
}

- (void)settings{
	settings *set=[[settings alloc] init];
	[click play];
	
	if (reachable){
		[self.navigationController pushViewController:set animated:YES];
	}
	
	[set release];
}

- (void)addFilter{
	[click play];
	
	if (reachable){
		[self.navigationController pushViewController:fit animated:YES];
	}
}

- (void)dataReady:(NSMutableArray *)dat withType:(int)type{
	load=NO;
	
	[filterLoader stopAnimating];
	[filterLoader setAlpha:0];
	
	NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
	
	if (loadButton){
		loadButton=NO;
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationLeft];
	}
	
	if (type==2){
		if ([dat count]>0){
			if (createButton){
				createButton=NO;
				[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationLeft];
				filters=dat;
				[def setObject:dat forKey:@"filters"];
				[self performSelector:@selector(refreshIt) withObject:self afterDelay:0];
			}else{
				filters=dat;
				[def setObject:dat forKey:@"filters"];
				[self.tableView reloadData];
			}
		}else{
			createButton=YES;
			filters=nil;
			[def removeObjectForKey:@"filters"];
			[self.tableView reloadData];
		}
		
		[rss fetchRSS:1 withArguments:nil];
	}else if (type==1){
		sites=dat;
		[def setObject:sites forKey:@"sites"];
	}
	
	[def synchronize];
}

- (void)refreshIt{
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark View lifecycle


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.tableView reloadData];
	
	if (load==NO){
		[filterLoader startAnimating];
		[filterLoader setAlpha:1];
		load=YES;
		[rss abort];
		[self performSelector:@selector(revamp) withObject:self afterDelay:0.3];
	}
}

- (void)revamp{
	[rss fetchRSS:2 withArguments:nil];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section){
		case 0:{
			return 1;
		}break;
		case 1:{
			return 1;
		}break;
		default:{
			if (createButton || loadButton){
				return 1;
			}else{
				return [filters count];
			}
		}break;
	}
}

-(void)editIt{
	if (self.tableView.editing==NO){
		[UIView beginAnimations:@"editBut" context:self];
		[UIView setAnimationDuration:0.2];
		[self.tableView setEditing:YES];
		[UIView commitAnimations];
	}else{
		[UIView beginAnimations:@"editBut" context:self];
		[UIView setAnimationDuration:0.2];
		[self.tableView setEditing:NO];
		[UIView commitAnimations];
	}
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	if (section==2){
		UIView *secTop=[[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)] autorelease];
		//[secTop setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.2]];
		UIImageView *back=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headBack"]];
		back.frame=secTop.frame;
		[secTop addSubview:back];
		[back release];
		UILabel	*secLabel=[[UILabel alloc] initWithFrame:CGRectMake(12, 7, 200, 20)];
		[secLabel setFont:[UIFont fontWithName:@"Helvetica Bold" size:14]];
		//[secLabel setShadowColor:[UIColor whiteColor]];
		//[secLabel setShadowOffset:CGSizeMake(1, 1)];
		[secLabel setBackgroundColor:[UIColor clearColor]];
		[secLabel setText:@"Filters:"];
		
		if (filterLoader==nil){
			filterLoader=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(70, 10, 16, 16)];
			filterLoader.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
			[filterLoader startAnimating];
		}
		
		/*if (filterEdit==nil){
			filterEdit=[[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50, 7, 50, 20)];
			[filterEdit setBackgroundColor:[UIColor clearColor]];
			[filterEdit setTitle:@"Edit" forState:UIControlStateNormal];
			[filterEdit.titleLabel setTextColor:[UIColor blackColor]];
			[filterEdit.titleLabel setFont:[UIFont fontWithName:@"Helvetica Bold" size:14]];
			//[filterEdit.titleLabel setTextColor:[UIColor whiteColor]];
			//[filterEdit.titleLabel setFont:[UIFont systemFontOfSize:6]];
			
			[filterEdit addTarget:self action:@selector(editIt) forControlEvents:UIControlEventTouchUpInside];
		}*/
		
		[secTop.layer setBorderColor:[UIColor lightGrayColor].CGColor];
		secTop.layer.borderWidth=1.0;
		
		secTop.layer.shadowPath=[UIBezierPath bezierPathWithRect:secTop.bounds].CGPath;
		[secTop.layer setShadowOpacity:0.2];
		[secTop.layer setShadowOffset:CGSizeMake(0, 0)];
		[secTop.layer setShadowColor:[UIColor blackColor].CGColor];
		[secTop.layer setShadowRadius:1.0];
		
		[secTop addSubview:secLabel];
		[secLabel release];
		[secTop	addSubview:filterLoader];
		//[secTop	addSubview:filterEdit];
		return secTop;
	}else{
		return nil;
	}
}


- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
	if (section==2){
		UIView *secTop=[[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)] autorelease];
		[secTop setBackgroundColor:[UIColor clearColor]];
		return secTop;
	}else{
		return nil;
	}
}

 
- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	if (section==2){
		return 1;
	}else{
		return 10;
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	if (section==2){
		return 30;
	}else{
		return 10;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
	TDBadgedCell *cell = [[[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	
	if (indexPath.section==0){
		cell.textLabel.text=@"      All Deals";
		cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
	
		UIImageView *all=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainFeed"]];
		all.frame=CGRectMake(cell.frame.origin.x+10, cell.frame.origin.y+12, 20, 20);
		[cell addSubview:all];
		[all release];
	}
	
	if (indexPath.section==1){
		cell.textLabel.text=@"      Favorites";
		cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
		
		UIImageView *fav=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainFav"]];
		fav.frame=CGRectMake(cell.frame.origin.x+10, cell.frame.origin.y+12, 20, 20);
		[cell addSubview:fav];
		[fav release];
	}
		
	if (indexPath.section==2){
		if (createButton){
			cell.textLabel.text=@"      Create Filter";
			cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
			
			UIImageView *filter=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addFilter"]];
			filter.frame=CGRectMake(cell.frame.origin.x+5, cell.frame.origin.y+6, 30, 30);
			[cell addSubview:filter];
			[filter release];
		}else if (loadButton){
			cell.textLabel.text=@"          Loading...";
			cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
			
			UIActivityIndicatorView *active=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(cell.frame.origin.x+15+10, cell.frame.origin.y+3+10, 20, 20)];
			[active setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
			[active startAnimating];
			[cell addSubview:active];
			[active release];
		}else{
			cell.textLabel.text = [[filters objectAtIndex:indexPath.row] objectForKey:@"title"];
			cell.textLabel.font = [UIFont systemFontOfSize:14];

			NSString *bString=[[[filters objectAtIndex:indexPath.row] objectForKey:@"pubDate"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			cell.badgeString = [bString copy];
	
			if ([bString intValue]==0){
				cell.badgeColor = [UIColor colorWithWhite:0.783 alpha:1.000];
			}
		}
	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==2){
		if (!createButton){
			return YES;
		}else{
			return NO;
		}
	}else{
		return NO;
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
		NSMutableString *url=[[NSMutableString alloc] init];
		[url appendFormat:@"http://deal.iz.io/api/api.php?udid=%@&req=removeFilter&filterId=%@",[UIDevice currentDevice].uniqueIdentifier,[[filters objectAtIndex:indexPath.row] objectForKey:@"guid"]];
		[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]] delegate:self];
		[url release];
        [filters removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
		
		if ([filters count]==0){
			createButton=YES;
			[self.tableView reloadData];
		}
    }
}



/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[click play];
	
    if (indexPath.section==0){
		Home *hvc=[[Home alloc] init:NO andFilter:0];
		[self.navigationController pushViewController:hvc animated:YES];
		[hvc release];
	}else if (indexPath.section==1){
		Home *hvc=[[Home alloc] init:YES andFilter:0];
		[self.navigationController pushViewController:hvc animated:YES];
		[hvc release];
	}else if (indexPath.section==2){
		if (createButton){
			[self.navigationController pushViewController:fit animated:YES];
		}else{
			Home *hvc=[[Home alloc] init:NO andFilter:[[[filters objectAtIndex:indexPath.row] objectForKey:@"guid"] intValue]];
			[self.navigationController pushViewController:hvc animated:YES];
			[hvc release];
		}
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

