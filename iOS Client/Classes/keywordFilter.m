//
//  keywordFilter.m
//  deal.iz.io
//
//  Created by Steven Rolfe on 1/18/11.
//  Copyright 2011 Allintu. All rights reserved.
//

#import "keywordFilter.h"


@implementation keywordFilter
@synthesize delegate;


#pragma mark -
#pragma mark Initialization

- (id)init{
	if ((self=[super initWithStyle:UITableViewStyleGrouped])){
		[self.tableView setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBack"]] autorelease]];
		keys=[[NSMutableArray alloc] init];
		
		[self setTitle:@"Keywords"];
	}
	
	return self;
}

- (void)setKeywords:(NSMutableArray *)keywords{
	keys=[keywords mutableCopy];
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
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section==0){
		return 1;
	}else{
		return [keys count];
	}
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	if (section==0){
		UIView *secTop=[[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)] autorelease];
		[secTop setBackgroundColor:[UIColor clearColor]];
		UILabel	*secLabel=[[UILabel alloc] initWithFrame:CGRectMake(12, 17, 200, 20)];
		[secLabel setFont:[UIFont fontWithName:@"Helvetica Bold" size:14]];
		[secLabel setShadowColor:[UIColor whiteColor]];
		[secLabel setShadowOffset:CGSizeMake(1, 1)];
		[secLabel setBackgroundColor:[UIColor clearColor]];
		[secLabel setText:@"Enter Keywords:"];
	
		[secTop addSubview:secLabel];
		[secLabel release];
	
		return secTop;
	}else{
		return nil;
	}
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	if (section==0){
		return 40;
	}else{
		return 20;
	}
}

/*
- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
	UIView *secTop=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 82)];
	[secTop setBackgroundColor:[UIColor clearColor]];
	UILabel	*secLabel=[[UILabel alloc] initWithFrame:CGRectMake(17, 0, 285, 80)];
	[secLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
	[secLabel setShadowColor:[UIColor whiteColor]];
	[secLabel setShadowOffset:CGSizeMake(1, 1)];
	secLabel.textAlignment=UITextAlignmentCenter;
	secLabel.numberOfLines=4;
	[secLabel setBackgroundColor:[UIColor clearColor]];
	[secLabel setText:@"Filters have three different components: your filter's name, keywords to search for, and sites to search with. You can use any combination of sites and keywords, but the name is required."];
	[secTop addSubview:secLabel];
	return secTop;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	return 82;
}
 */


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	[cell setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0.93 alpha:1]];
	cell.textLabel.font = [UIFont systemFontOfSize:14];
	
	if (indexPath.section==0 && indexPath.row==0){
		if (texty==nil){
			texty=[[[UITextField alloc] initWithFrame:CGRectMake(cell.frame.origin.x+10, cell.frame.origin.y+10, cell.frame.size.width-40, cell.frame.size.height-20)] autorelease];
			[texty setBorderStyle:UITextBorderStyleBezel];
			texty.returnKeyType=UIReturnKeyDone;
			//[texty setKeyboardType:UIKeyboardTypeAlphabet];
			[texty setDelegate:self];
			[cell.contentView addSubview:texty];
		}
	}else{
		cell.textLabel.text=[keys objectAtIndex:indexPath.row];
	}
    
    return cell;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	if (![textField.text isEqualToString:@""]){
		//[keys addObject:textField.text];
		//[textField.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		[keys addObjectsFromArray:[textField.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
		textField.text=@"";
		[self.tableView reloadData];
	}
	
	[delegate didFilterKeys:keys];
	
	//self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(filter)];
	return NO;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [keys removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
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

