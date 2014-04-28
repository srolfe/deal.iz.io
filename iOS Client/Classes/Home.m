//
//  Home.m
//  deal.iz.io
//
//  Created by Steven Rolfe on 12/31/10.
//  Copyright 2010 Allintu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Home.h"
#import "tableCells.h"
#import "details.h"

@implementation Home

#pragma mark -
#pragma mark View lifecycle

- (void)didLoadFilter:(int)filterId{
	filter=filterId;
}

- (void)viewWillDisappear:(BOOL)animated{
	[lazyImages removeQueue];
	//data=[[NSMutableArray alloc] init];
}

- (void) viewWillAppear:(BOOL)animated{
	[lazyImages resumeQueue];
	[self.tableView setSeparatorColor:[UIColor lightGrayColor]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	loadCell=YES;
	
	if (_refreshHeaderView == nil){
		EGORefreshTableHeaderView *view=[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate=self;
		[self.tableView addSubview:view];
		_refreshHeaderView=view;
		[view release];
	}
	
	[_refreshHeaderView refreshLastUpdatedDate];
	
	[self startLoadingScreen];

	UIImageView *background=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBack"]];
	[background setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	self.tableView.backgroundView=background;
	[background release];
}


// -- Loading Screen --

-(void) startLoadingScreen{
	loadScreen=YES;
	
	// Let's throw up a loading screen
	loadingView=[[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-100,(self.view.frame.size.height/2)-150,200,200)];
	loadingView.layer.cornerRadius=10;
	[loadingView setBackgroundColor:[UIColor blackColor]];
	
	UIActivityIndicatorView *active=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[active setFrame:CGRectMake((loadingView.frame.size.width/2)-25, (loadingView.frame.size.height/2)-50, 50, 50)];
	
	UILabel *loadingLabel=[[UILabel alloc] initWithFrame:CGRectMake((loadingView.frame.size.width/2)-100, 100, 200, 100)];
	[loadingLabel setBackgroundColor:[UIColor clearColor]];
	[loadingLabel setTextColor:[UIColor whiteColor]];
	[loadingLabel setFont:[UIFont boldSystemFontOfSize:22]];
	[loadingLabel setTextAlignment:UITextAlignmentCenter];
	loadingLabel.text=@"Loading Deals";
	
	[active startAnimating];
	[loadingView addSubview:active];
	[loadingView addSubview:loadingLabel];
	[self.view addSubview:loadingView];
	
	loadingView.layer.opacity=0;
	loadingView.transform=CGAffineTransformMakeScale(0.01, 0.01);
	
	// Fun animations
	[UIView beginAnimations:nil context:self];
	[UIView setAnimationDuration:0.3];
	loadingView.layer.opacity=0.8;
	loadingView.transform=CGAffineTransformMakeScale(1, 1);
	[UIView commitAnimations];
	
	[loadingLabel release];
	[active release];
}

-(void) removeLoadingScreen{
	[UIView beginAnimations:nil context:self];
	[UIView setAnimationDuration:0.3];
	loadingView.layer.opacity=0;
	loadingView.transform=CGAffineTransformMakeScale(0.01, 0.01);
	[UIView commitAnimations];
	
	[loadingView release];
	
	loadScreen=NO;
}

// -- Loading Screen --

#pragma mark -
#pragma mark Table view data source

- (id)init:(BOOL)fav andFilter:(int)fil{
	if ((self = [super init])){
		// Initialize our variables
		data=[[NSMutableArray alloc] init];
		
		// Set properties for ourself
		[self setTitle:@"Feed"];
		
		page=0;
		last=0;
		
		filtered=NO;
		filter=fil;
		favorite=NO;
		
		loadCell=YES;
		
		reachable=YES;
		
		loadScreen=NO;
		
		UIImageView *tmp=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchBar"]];
		tmp.frame=CGRectMake(0, 0, self.view.frame.size.width, 40);
		//[tmp.layer setGeometryFlipped:YES];
		tmp.layer.zPosition=-100;
		search=[[UISearchBar alloc] initWithFrame:CGRectMake(0, -40, self.view.frame.size.width, 40)];
		//[search setBarStyle:UIBarStyleBlack];
		[search setDelegate:self];
		
		[search setBackgroundColor:[UIColor clearColor]];
		[search setTintColor:[UIColor clearColor]];
		search.barStyle=UIBarStyleBlackTranslucent;
		[search addSubview:tmp];
		
		for (UIView *subview in search.subviews) {
			if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
				[subview removeFromSuperview];
				break;
			}
		}
		
		[tmp release];
		
		searchEnabled=NO;
		searchKeywords=[[NSMutableArray alloc] init];
		
		keywords=[[NSMutableArray alloc] init];
		
		// Setup our RSSFetcher class
		dealFetch=[[RSSFetch alloc] init];
		[dealFetch setDelegate:self];
		
		// Setup our lazy loader...
		lazyImages=[[lazyLoading alloc] init];
		[lazyImages setDelegate:self];
		
		self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-100);
		
		self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(enableSearch)];

		loading=YES;
		
		NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
		if (fav){
			[self setTitle:@"Favorites"];
			[dict setObject:@"true" forKey:@"favorite"];
			favorite=YES;
		}
		
		[dealFetch fetchRSS:1 withArguments:dict];
		[dict release];
	}
	return self;
}

-(void)reloadTableViewDataSource{
	// Refresh!
	//loading=NO;
	page=0;
	last=0;
	[lazyImages removeQueue];
	[dealFetch abort];
	
	NSMutableDictionary *arguments=[[NSMutableDictionary alloc] init];
	
	if (filtered){
		NSMutableArray *tmp=[[[NSMutableArray alloc] init] autorelease];
		
		if ([searchKeywords count]>0){
			keywords=searchKeywords;
		}
		
		BOOL omg=NO;
		for (NSMutableDictionary *site in sites){
			if ([[site objectForKey:@"enabled"] isEqualToString:@"true"]){
				[tmp addObject:[site objectForKey:@"siteId"]];
				omg=YES;
			}
		}
		
		if (omg){
			[arguments setObject:[NSMutableDictionary dictionaryWithObject:tmp forKey:@"sites"] forKey:@"filters"];
		}
		
		if ([keywords count]>0){
			if (omg){
				[[arguments objectForKey:@"filters"] setObject:keywords forKey:@"keywords"];
			}else{
				[arguments setObject:[NSMutableDictionary dictionaryWithObject:keywords forKey:@"keywords"] forKey:@"filters"];
			}
		}
	}
	
	if (filter>0){
		[arguments setObject:[NSString stringWithFormat:@"%d",filter] forKey:@"filterId"];
	}
	
	if (favorite){
		[arguments setObject:@"true" forKey:@"favorite"];
	}
		
	[dealFetch fetchRSS:0 withArguments:arguments];
	[arguments release];
}

-(void)removeFilter{
	filtered=NO;
	filter=0;
	[dealFetch abort];
	[lazyImages removeQueue];
	loading=YES;
	
	NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
	if (favorite){
		[dict setObject:@"true" forKey:@"favorite"];
	}
	
	[dealFetch fetchRSS:0 withArguments:dict];
	[dict release];
}

-(void)filterWith:(NSMutableArray *)siteList keywords:(NSMutableArray *)keywordList save:(BOOL)save name:(NSString *)name{
	sites=siteList;
	keywords=keywordList;
	filtered=YES;
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	[searchKeywords addObjectsFromArray:[searchBar.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	filtered=YES;
	searchBar.text=@"";
	[self reloadTableViewDataSource];
	[searchBar resignFirstResponder];
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	// Ok... It wants to display the cell...
	
	if (indexPath.row==([data count]-5) && indexPath.row!=last){
		page=page+1;
		[dealFetch abort];
		loading=YES;
		
		int ii=0;
		for (NSMutableDictionary *dat in data){
			if ((ii<indexPath.row && indexPath.row-ii>=20)){
				if ([dat objectForKey:@"thumb"]!=NULL && [[dat objectForKey:@"thumb"] isKindOfClass:[UIImage class]]){
					[dat setObject:@"" forKey:@"thumb"];
				}
			}
			
			ii++;
		}
		
		/*
		int ii=0;
		for (NSMutableDictionary *dat in data){
			if (ii<indexPath.row && indexPath.row-ii>=20){
				[dat setObject:@"" forKey:@"thumb"];
			}
			
			ii++;
		}*/
		
		NSMutableDictionary *arguments=[[[NSMutableDictionary alloc] init] autorelease];
		
		if (filtered){
			NSMutableArray *tmp=[[NSMutableArray alloc] init];
			
			BOOL omg=NO;
			for (NSMutableDictionary *site in sites){
				if ([[site objectForKey:@"enabled"] isEqualToString:@"true"]){
					[tmp addObject:[site objectForKey:@"siteId"]];
					omg=YES;
				}
			}
			
			if (omg){
				[arguments setObject:[NSMutableDictionary dictionaryWithObject:tmp forKey:@"sites"] forKey:@"filters"];
			}
			
			if ([keywords count]>0){
				if (omg){
					[[arguments objectForKey:@"filters"] setObject:keywords forKey:@"keywords"];
				}else{
					[arguments setObject:[NSMutableDictionary dictionaryWithObject:keywords forKey:@"keywords"] forKey:@"filters"];
				}
			}
			
			[tmp release];
		}
		
		[arguments setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
		
		if (favorite){
			[arguments setObject:@"true" forKey:@"favorite"];
		}
		
		if (filter>0){
			[arguments setObject:[NSString stringWithFormat:@"%d",filter] forKey:@"filterId"];
		}
		
		[dealFetch fetchRSS:0 withArguments:arguments];
		//[arguments release];
		
		last=indexPath.row;
	}
}

-(void)dataReady:(NSMutableArray *)dat withType:(int)type{
	loading=NO;
	
	if (([dat count]==0 || [dat count]<20) && type==0){
		loadCell=NO;
	}
	
	if (favorite){
		loadCell=NO;
	}
	
	if (type==0){
		// Datasource load/reload
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
		if (page>0){
			[data addObjectsFromArray:dat];
		}else{
			data=[[NSMutableArray alloc] initWithArray:dat];
		}
	
		int ii=0;
		for (NSMutableDictionary *tmp in data){
			if ([[tmp objectForKey:@"thumbnail"] isKindOfClass:[NSString class]] && [[tmp objectForKey:@"thumbnail"] length]>0 && [tmp objectForKey:@"thumb"]==nil){
				[lazyImages queueNextDownload:[tmp objectForKey:@"thumbnail"] withIndexPath:[NSIndexPath indexPathForRow:ii inSection:0] withType:0];
				[tmp setObject:[[UIImage alloc] init] forKey:@"thumb"];
			}
		
			if ([tmp objectForKey:@"fontColor"]==nil){
				[tmp setObject:[UIColor blackColor] forKey:@"fontColor"];
			}
		
			ii=ii+1;
		}

		if (loadScreen){
			[self removeLoadingScreen];
		}
		
		[self.tableView reloadData];
	}else if (type==1){
		// Here's a list of our sites... Let's load the icons from them and cache everything.
		sites=[[NSMutableArray alloc] initWithArray:dat];
		
		int ii=0;
		for (NSMutableDictionary *tmp in sites){
			// Throw all to the LazyLoader class...
			//NSMutableString *large=[tmp objectForKey:@"thumbnail"];
			if (![[tmp objectForKey:@"thumbnail"] isEqualToString:@""]){
				NSMutableString *small=[tmp objectForKey:@"thumbnail"];
				//[large appendString:@".png"];
				[small appendString:@"Mini.png"];
			
				//[lazyImages queueNextDownload:large withIndexPath:[NSIndexPath indexPathForRow:ii inSection:1] withType:1];
				[lazyImages queueNextDownload:small withIndexPath:[NSIndexPath indexPathForRow:ii inSection:1] withType:1];
				//[small release];
			}
			
			[tmp setObject:[[tmp objectForKey:@"description"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"enabled"];
			
			ii=ii+1;
		}
		
		NSMutableDictionary *arguments=[[[NSMutableDictionary alloc] init] autorelease];
		NSMutableArray *tmp=[[[NSMutableArray alloc] init] autorelease];
		
		if (filtered){
			BOOL omg=NO;
			for (NSMutableDictionary *site in sites){
				if ([[site objectForKey:@"enabled"] isEqualToString:@"true"]){
					[tmp addObject:[site objectForKey:@"siteId"]];
					omg=YES;
				}
			}
			
			if (omg){
				[arguments setObject:[NSMutableDictionary dictionaryWithObject:tmp forKey:@"sites"] forKey:@"filters"];
			}
			
			if ([keywords count]>0){
				if (omg){
					[[arguments objectForKey:@"filters"] setObject:keywords forKey:@"keywords"];
				}else{
					[arguments setObject:[NSMutableDictionary dictionaryWithObject:keywords forKey:@"keywords"] forKey:@"filters"];
				}
			}
			
			if (filterSave){
				[[arguments objectForKey:@"filters"] setObject:filterName forKey:@"name"];
				//[[arguments objectForKey:@"filters"] setObject:filterSave forKey:@"save"];
			}
			
			//[tmp release];
		}
		
		if (filter>0){
			[arguments setObject:[NSString stringWithFormat:@"%d",filter] forKey:@"filterId"];
		}
		
		if (favorite){
			[arguments setObject:@"true" forKey:@"favorite"];
		}
		
		[dealFetch fetchRSS:0 withArguments:arguments];
	}
}

// --[ EGORefreshView ]--

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	if (searchEnabled){
		return search;
	}else{
		return nil;
	}
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	if (searchEnabled){
		return 40;
	}else{
		return 0;
	}
}

-(void)enableSearch{
	if (searchEnabled){
		searchEnabled=NO;
		searchKeywords=[[NSMutableArray alloc] init];
		keywords=[[NSMutableArray alloc] init];
		self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(enableSearch)];
		[self reloadTableViewDataSource];
	}else{
		searchEnabled=YES;
		self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"X" style:UIBarButtonItemStylePlain target:self action:@selector(enableSearch)];
	}
	
	[self.tableView reloadData];
}
	

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view{
	[self reloadTableViewDataSource];
}

-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view{
	return loading;
}

-(NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view{
	return [NSDate date];
}

// --[ EGORefreshView ]--

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([data count]>0){
		if (loadCell){
			return [data count]+1;
		}else{
			return [data count];
		}
	}else{
		return 10;
	}
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 66;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"tableCells";
    
    tableCells *cell = (tableCells *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell==nil){
		NSArray *tlo=[[NSBundle mainBundle] loadNibNamed:@"tableCells" owner:nil options:nil];
		for (id currentObject in tlo){
			if ([currentObject isKindOfClass:[UITableViewCell class]]){
				cell=(tableCells *)currentObject;
				break;
			}
		}
	}
	
	if ([data count]>0){
		// More results
		if (indexPath.row==([data count]) && loadCell){
			cell.borderView.alpha=0;
			cell.textLabel.text=@"Loading deals...";
		}else{
			cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
			
			cell.borderView.alpha=0;
			int tmpIndex=indexPath.row;
			[cell setText:[[data objectAtIndex:tmpIndex] objectForKey:@"title"]];
			[cell.textLabel setTextColor:[[data objectAtIndex:tmpIndex] objectForKey:@"fontColor"]];
			
			[cell.textLabel setFont:[UIFont boldSystemFontOfSize:14]];
			
			[cell.priceLabel setText:[[data objectAtIndex:tmpIndex] objectForKey:@"price"]];
		
			if ([[[data objectAtIndex:tmpIndex] objectForKey:@"thumb"] isKindOfClass:[UIImage class]]){
				cell.borderView.alpha=1;
				[cell setThumbnail:[[data objectAtIndex:tmpIndex] objectForKey:@"thumb"]];
			}else if ([[[data objectAtIndex:tmpIndex] objectForKey:@"thumbnail"] isKindOfClass:[NSString class]] && [[[data objectAtIndex:tmpIndex] objectForKey:@"thumbnail"] length]>0){
				[lazyImages queueNextDownload:[[data objectAtIndex:tmpIndex] objectForKey:@"thumbnail"] withIndexPath:indexPath withType:0];
			}else{
				cell.borderView.alpha=0;
				[cell setThumbnail:[UIImage imageNamed:@"noThumb.png"]];
			}
			
			if ([[[data objectAtIndex:tmpIndex] objectForKey:@"favorite"] isEqualToString:@"true"]){
				[cell setFav:YES];
			}else{
				[cell setFav:NO];
			}
			
			
			NSDate *then=[[NSDate alloc] initWithTimeIntervalSince1970:[[[data objectAtIndex:tmpIndex] objectForKey:@"pubDate"] intValue]];
			NSDate *now=[[NSDate alloc] init];
			int tmp=[now timeIntervalSinceDate:then];
			
			NSMutableString *tmpFlag=[[NSMutableString alloc] initWithString:@"Seconds"];
			
			if (tmp>60){
				tmp/=60;
				if (tmp>1){
					tmpFlag=[NSMutableString stringWithString:@"Minutes"];
				}else{
					tmpFlag=[NSMutableString stringWithString:@"Minute"];
				}
				
				if (tmp>60){
					tmp/=60;
					if (tmp>1){
						tmpFlag=[NSMutableString stringWithString:@"Hours"];
					}else{
						tmpFlag=[NSMutableString stringWithString:@"Hour"];
					}
					
					if (tmp>24){
						tmp/=24;
						if (tmp>1){
							tmpFlag=[NSMutableString stringWithString:@"Days"];
						}else{
							tmpFlag=[NSMutableString stringWithString:@"Day"];
						}
					}
				}
			}
			
			
			cell.timeStamp.text=[NSString stringWithFormat:@"%d %@ Ago",tmp,tmpFlag];
			cell.timeStamp.textColor=[UIColor grayColor];
			
			[then release];
			[now release];
			//[tmpFlag release];
			
			for (NSDictionary *tmp in sites){
				if ([[tmp objectForKey:@"siteId"] isEqualToString:[[data objectAtIndex:tmpIndex] objectForKey:@"siteId"]]){
					if ([tmp objectForKey:@"thumb-small"]!=nil){
						[cell setSiteIcon:[tmp objectForKey:@"thumb-small"]];
					}
				}
			}
		}
	}
	
	return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
	UIView *secTop=[[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)] autorelease];
	[secTop setBackgroundColor:[UIColor clearColor]];
	return secTop;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	return 1;
}

-(void)appImageDidLoad:(UIImage *)im atIndex:(NSIndexPath *)indexPath withType:(int)type{
	if (type==0){
		if ([data count]>indexPath.row){
			tableCells *cell=(tableCells *)[self.tableView cellForRowAtIndexPath:indexPath];
			[cell setThumbnail:im];
			[[data objectAtIndex:indexPath.row] setObject:im forKey:@"thumb"];
			//cell.borderView.backgroundColor=[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
			cell.borderView.alpha=1;
		}
	}else{
		[[sites objectAtIndex:indexPath.row] setObject:im forKey:@"thumb-small"];
		[self.tableView reloadData];
	}
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row==[data count]){
	}else{
		BOOL tmp;
		
		if ([[[data objectAtIndex:indexPath.row] objectForKey:@"favorite"] isEqualToString:@"true"]){
			tmp=YES;
		}else{
			tmp=NO;
		}
		
		//NSArray *vcs=self.navigationController.viewControllers;
		[[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2] doClick];
		//[vcs release];
		
		details *desc=[[details alloc] initWithDeal:[[data objectAtIndex:indexPath.row] mutableCopy] forIndexPath:[indexPath copy] isFav:tmp];
		[desc setDelegate:self];
		[[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
		[[data objectAtIndex:indexPath.row] setObject:[UIColor grayColor] forKey:@"fontColor"];
		[[tableView cellForRowAtIndexPath:indexPath].textLabel setTextColor:[UIColor grayColor]];
		[self.navigationController pushViewController:desc animated:YES];
		[desc release];
	}
}

-(void)setFav:(BOOL)f forIndexPath:(NSIndexPath *)iPath{
	[[self.tableView cellForRowAtIndexPath:iPath] setFav:f];
	if (f){
		[[data objectAtIndex:iPath.row] setObject:@"true" forKey:@"favorite"];
	}else{
		[[data objectAtIndex:iPath.row] setObject:@"false" forKey:@"favorite"];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	
}


- (void)dealloc {
	[data release];
	[dealFetch setDelegate:nil];
	[lazyImages setDelegate:nil];
	[dealFetch release];
	[lazyImages release];
    [super dealloc];
}

@end

