//
//  settings.m
//  deal.iz.io
//
//  Created by Steven Rolfe on 1/17/11.
//  Copyright 2011 Allintu. All rights reserved.
//

#import "settings.h"
#import "RSSFetch.h"
#import "TDBadgedCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UserVoice.h"


@implementation settings


#pragma mark -
#pragma mark Initialization

- (id)init{
	if ((self=[super initWithStyle:UITableViewStylePlain])){
		[self.tableView setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBack"]] autorelease]];
		// Setup RSSFetch
		self.title=@"Settings";
		rss=[[RSSFetch alloc] init];
		[rss setDelegate:self];
		
		sites=[[NSMutableArray alloc] init];
		
		NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
		if ([def arrayForKey:@"sites"]!=nil){
			sites=[[def arrayForKey:@"sites"] mutableCopy];
		}
		
		[self.tableView setSeparatorColor:[UIColor lightGrayColor]];
		
		self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Feedback" style:UIBarButtonItemStylePlain target:self action:@selector(launchUV)];
		
		[rss fetchRSS:1 withArguments:nil];
		loading=YES;
	}
	
	return self;
}

-(void)launchUV{
	[UserVoice presentUserVoiceModalViewControllerForParent:self.navigationController andSite:@"izio.uservoice.com" andKey:@"mkhHeDhJk397uTYjdhpSQ" andSecret:@"RpRLtxIreE5PRdK0h1J1TTlJFNrzmzg5LbEFaIc"];
}

- (void)dataReady:(NSMutableArray *)dat withType:(int)type{
	sites=dat;
	loading=NO;
	[self.tableView reloadData];
}
		
		

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	// We need one per site...
    if (loading){
		return 0;
	}else{
		return [sites count];
	}
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	if (section==0){
		UIView *secTop=[[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)] autorelease];
		UIImageView *back=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headBack"]];
		back.frame=secTop.frame;
		[secTop addSubview:back];
		[back release];
		UILabel	*secLabel=[[UILabel alloc] initWithFrame:CGRectMake(12, 7, 200, 20)];
		[secLabel setFont:[UIFont fontWithName:@"Helvetica Bold" size:14]];
		[secLabel setBackgroundColor:[UIColor clearColor]];
		[secLabel setText:@"Enabled Sites:"];
		
		[secTop addSubview:secLabel];
		[secLabel release];
		
		[secTop.layer setBorderColor:[UIColor lightGrayColor].CGColor];
		secTop.layer.borderWidth=1.0;
		
		secTop.layer.shadowPath=[UIBezierPath bezierPathWithRect:secTop.bounds].CGPath;
		[secTop.layer setShadowOpacity:0.2];
		[secTop.layer setShadowOffset:CGSizeMake(0, 0)];
		[secTop.layer setShadowColor:[UIColor blackColor].CGColor];
		[secTop.layer setShadowRadius:1.0];
		
		return secTop;
	}else{
		return nil;
	}
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	//if (section==0){
		return 30;
	//}else{
	//	return 20;
	//}
}


 - (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
	 UIView *secTop=[[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)] autorelease];
	 [secTop setBackgroundColor:[UIColor clearColor]];
	 UILabel	*secLabel=[[UILabel alloc] initWithFrame:CGRectMake(12, 4, 285, 28)];
	 [secLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
	 [secLabel setShadowColor:[UIColor whiteColor]];
	 [secLabel setShadowOffset:CGSizeMake(1, 1)];
	 secLabel.textAlignment=UITextAlignmentCenter;
	 secLabel.numberOfLines=2;
	 [secLabel setBackgroundColor:[UIColor clearColor]];
	 [secLabel setText:@"The default sites loaded by your main feed. NOTE: Filters ignore this list."];
	 [secTop addSubview:secLabel];
	 [secLabel release];
	 return secTop;
 }
 
 - (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	 return 30;
 }


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
    static NSString *CellIdentifier = @"Cell";
    /*
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }*/
	
	TDBadgedCell *cell = [[[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    // Configure the cell...
	cell.textLabel.font=[UIFont boldSystemFontOfSize:14];
	cell.textLabel.text=[[sites objectAtIndex:indexPath.row] objectForKey:@"title"];
	UISwitch *tmpSwitch=[[UISwitch alloc] initWithFrame:CGRectMake(cell.frame.origin.x+210, cell.bounds.origin.y+8, 0, 0)];
	[tmpSwitch setTag:[[[sites objectAtIndex:indexPath.row] objectForKey:@"siteId"] intValue]];
	NSLog(@"Got (%@)",[[sites objectAtIndex:indexPath.row] objectForKey:@"siteId"]);
	[tmpSwitch addTarget:self action:@selector(switched:) forControlEvents:UIControlEventValueChanged];
	
	if ([[[[sites objectAtIndex:indexPath.row] objectForKey:@"description"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"false"]){
		[tmpSwitch setOn:NO];
	}else{
		[tmpSwitch setOn:YES];
	}
	
	[cell addSubview:tmpSwitch];
	[tmpSwitch release];
    
    return cell;
}

- (void)switched:(UISwitch *)control{
	NSMutableString *tmp=[[NSMutableString alloc] initWithString:@"http://deal.iz.io/api/api.php?udid="];
	[tmp appendFormat:@"%@",[[UIDevice currentDevice] uniqueIdentifier]];
	
	if (control.on==NO){
		[tmp appendString:@"&req=disableSite&siteId="];
		[tmp appendFormat:@"%d",control.tag];
	}else{
		[tmp appendString:@"&req=enableSite&siteId="];
		[tmp appendFormat:@"%d",control.tag];
	}
	
	[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[tmp stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]] delegate:self];
	[tmp release];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


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
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

