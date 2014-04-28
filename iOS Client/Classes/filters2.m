//
//  filters2.m
//  deal.iz.io
//
//  Created by Steven Rolfe on 1/12/11.
//  Copyright 2011 Allintu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "filters2.h"
#import "sitesFilter.h"
#import "keywordFilter.h"
#import "TDBadgedCell.h"


@implementation filters2
@synthesize delegate;


#pragma mark -
#pragma mark Initialization


- (id)init{
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
		[self.tableView setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBack"]] autorelease]];
		omgcats=0;
		rss=[[RSSFetch alloc] init];
		[rss setDelegate:self];
		[rss fetchRSS:1 withArguments:nil];
		
		[self.tableView setSeparatorColor:[UIColor lightGrayColor]];
		
		kChange=NO;
		sChange=NO;
		
		reachable=YES;
		
		[self setTitle:@"New Filter"];
		
		sites=[[NSMutableArray alloc] init];
		
		NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
		if ([def arrayForKey:@"sites"]!=nil){
			sites=[[def arrayForKey:@"sites"] mutableCopy];
			for (NSMutableDictionary *site in sites){
				[site setObject:[[site objectForKey:@"description"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"enabled"];
			}
		}
		
		keywords=[[NSMutableArray alloc] init];
    }
    return self;
}

/*
- (void) viewWillAppear:(BOOL)animated{
	NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
	if ([def arrayForKey:@"sites"]!=nil){
		sites=[[def arrayForKey:@"sites"] mutableCopy];
		int ii=0;
		for (NSMutableDictionary *site in sites){
			sites
			[site setObject:[[site objectForKey:@"description"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"enabled"];
			ii++;
		}
	}
}*/

- (void)dataReady:(NSMutableArray *)dat withType:(int)type{
	sites=dat;
	//NSLog(@"Got 'em");
	
	NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
	[def setObject:dat forKey:@"sites"];
	
	for (NSMutableDictionary *site in sites){
		[site setObject:[[site objectForKey:@"description"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"enabled"];
	}
	
	[self.tableView reloadData];
}

- (void)setSites:(NSMutableArray *)siteList{
	//sites=siteList;
}


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.tableView reloadData];
	
	self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(filter)];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)filter{
	//[delegate filterWith:sites keywords:keywords save:switchy.on name:texty.text];
	kChange=NO;
	sChange=NO;
	
	if (texty.text!=nil){
		
		BOOL site=YES;
		for (NSMutableDictionary *si in sites){
			if (![[si objectForKey:@"enabled"] isEqualToString:[[si objectForKey:@"description"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]){
				site=NO;
			}
		}
		
		if ([keywords count]==0 && site){
			[keywords addObjectsFromArray:[texty.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
		}
		
		NSMutableString *siteList=[[NSMutableString alloc] init];
		for (NSMutableDictionary *tmp in sites){
			if ([[tmp objectForKey:@"enabled"] isEqualToString:@"true"]){
				[siteList appendString:[tmp objectForKey:@"siteId"]];
				[siteList appendString:@"|"];
			}
		}
		
		NSMutableString *keywordList=[[NSMutableString alloc] init];
		for (NSMutableString *tmp2 in keywords){
			[keywordList appendFormat:@"%@|",tmp2];
		}
		
		
		NSMutableString *url=[[NSMutableString alloc] init];
		[url appendFormat:@"http://deal.iz.io/api/api.php?udid=%@",[UIDevice currentDevice].uniqueIdentifier];
		[url appendFormat:@"&req=saveFilter&name=%@&sites=%@&keywords=%@",texty.text,siteList,keywordList];
		[siteList release];
		[keywordList release];
		
		if (switchy.on){
			[url appendFormat:@"&push=true"];
		}
		
		[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]] delegate:self];
		[url release];
		
		keywords=[[NSMutableArray alloc] init];
		[self.tableView reloadData];
		texty.text=nil;
		
		[self.navigationController popViewControllerAnimated:YES];
	}else{
		keywords=[[NSMutableArray alloc] init];
		[self.tableView reloadData];
		texty.text=nil;
		[self.navigationController popViewControllerAnimated:YES];
	}
}


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
	NSLog(@"bye bye");
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
	if ([sites count]>0){
		return 4;
	}else{
		return 0;
	}
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	UIView *secTop=[[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)] autorelease];
	UIImageView *back=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headBack"]];
	back.frame=secTop.frame;
	[secTop addSubview:back];
	[back release];
	UILabel	*secLabel=[[UILabel alloc] initWithFrame:CGRectMake(12, 7, 200, 20)];
	[secLabel setFont:[UIFont fontWithName:@"Helvetica Bold" size:14]];
	[secLabel setBackgroundColor:[UIColor clearColor]];
	[secLabel setText:@"Create Filter:"];
		
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
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 30;
}


- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
	UIView *secTop=[[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)] autorelease];
	[secTop setBackgroundColor:[UIColor clearColor]];
	/*UILabel	*secLabel=[[UILabel alloc] initWithFrame:CGRectMake(17, 0, 285, 80)];
	[secLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
	[secLabel setShadowColor:[UIColor whiteColor]];
	[secLabel setShadowOffset:CGSizeMake(1, 1)];
	secLabel.textAlignment=UITextAlignmentCenter;
	secLabel.numberOfLines=4;
	[secLabel setBackgroundColor:[UIColor clearColor]];
	[secLabel setText:@"Filters have three different components: your filter's name, keywords to search for, and sites to search with. You can use any combination of sites and keywords, but the name is required."];
	[secTop addSubview:secLabel];*/
	return secTop;
}

 
- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    /*UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }*/
	
	TDBadgedCell *cell = [[[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	
	//[cell setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0.93 alpha:1]];
	cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    // Configure the cell...
		switch (indexPath.row){
			case 0:{
				// Filter's name
				[cell.textLabel setText:@"Name"];
				if (nameCell==nil){
					NSLog(@"Creating...");
					texty=[[UITextField alloc] initWithFrame:CGRectMake(cell.frame.origin.x+80, cell.frame.origin.y+8, cell.frame.size.width-98, cell.frame.size.height-15)];
					[texty setBorderStyle:UITextBorderStyleBezel];
					//texty.layer.masksToBounds=YES;
					//[texty.layer setCornerRadius:6.0];
					//[texty.layer setBorderWidth:2.0];
					//[texty.layer setBorderColor:[UIColor lightGrayColor].CGColor];
					[texty setReturnKeyType:UIReturnKeyDone];
					[texty setDelegate:self];
					[cell addSubview:texty];
					nameCell=cell;
				}else{
					return nameCell;
				}
			}break;
			case 1:{
				// Keywords List
				cell.textLabel.text=@"Keywords";
				cell.badgeString=[NSString stringWithFormat:@"%d",[keywords count]];
				
				if (kChange){
					cell.badgeColor=[UIColor colorWithRed:1.000 green:0.397 blue:0.419 alpha:1.000];
				}
				
				cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
			}break;
			case 2:{
				// Sites List
				int ii=0;
				for (NSMutableDictionary *tmp in sites){
					if ([[tmp objectForKey:@"enabled"] isEqualToString:@"true"]){
						ii++;
					}
				}
				
				if (sChange){
					cell.badgeColor=[UIColor colorWithRed:1.000 green:0.397 blue:0.419 alpha:1.000];
				}
		
				cell.textLabel.text=@"Sites";
				cell.badgeString=[NSString stringWithFormat:@"%d",ii];
				NSLog(@"%d",ii);
				cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
			}break;
			case 3:{
				// Push Notifications
				[cell.textLabel setText:@"Push Notifications?"];
				if (switchy==nil){
					switchy=[[UISwitch alloc] initWithFrame:CGRectMake(cell.frame.size.width-113, cell.frame.origin.y+8, 100, cell.frame.size.height-8)];
					[switchy addTarget:self action:@selector(switchMe) forControlEvents:UIControlEventValueChanged];
				}
				
				[cell addSubview:switchy];
			}break;
			/*case 2:{
				// Save Toggle
				[cell.textLabel setText:@"Save Filter"];
				if (switchy==nil){
					switchy=[[UISwitch alloc] initWithFrame:CGRectMake(cell.frame.size.width-113, cell.frame.origin.y+8, 100, cell.frame.size.height-8)];
					[switchy addTarget:self action:@selector(switchMe) forControlEvents:UIControlEventValueChanged];
					[cell addSubview:switchy];
				}
			}break;*/
		}

    return cell;
}

- (void)switchMe{
	[self.tableView reloadData];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
	[texty resignFirstResponder];
	return NO;
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
    if (indexPath.section==0 && indexPath.row==2){
		sitesFilter *sf=[[sitesFilter alloc] initWithSites:sites];
		[sf setDelegate:self];
		[self.navigationController pushViewController:sf animated:YES];
	}else if (indexPath.section==0 && indexPath.row==1){
		keywordFilter *kf=[[keywordFilter alloc] init];
		
		if ([keywords count]>0){
			[kf setKeywords:keywords];
		}
		
		[kf setDelegate:self];
		[self.navigationController pushViewController:kf animated:YES];
	}
	
	[self.tableView cellForRowAtIndexPath:indexPath].selected=NO;
}

- (void)didFilterSites:(NSMutableArray *)siteList{
	sites=siteList;
	
	int ii=0;
	for (NSMutableDictionary *tmp in sites){
		if ([[tmp objectForKey:@"enabled"] isEqualToString:@"true"]){
			ii++;
		}
	}
	
	sChange=YES;
	
	TDBadgedCell *cell=(TDBadgedCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]];
	cell.badgeString=[NSString stringWithFormat:@"%d",ii];
	cell.badgeColor=[UIColor colorWithRed:1.000 green:0.397 blue:0.419 alpha:1.000];
	
	[self.tableView reloadData];
	
}

- (void)didFilterKeys:(NSMutableArray *)keyList{
	keywords=keyList;
	
	kChange=YES;
	
	TDBadgedCell *cell=(TDBadgedCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
	cell.badgeString=[NSString stringWithFormat:@"%d",[keywords count]];
	cell.badgeColor=[UIColor colorWithRed:1.000 green:0.397 blue:0.419 alpha:1.000];
	
	[self.tableView reloadData];
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

