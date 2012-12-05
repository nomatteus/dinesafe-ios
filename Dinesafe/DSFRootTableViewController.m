//
//  DinesafeRootTableViewController.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-20.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DSFRootTableViewController.h"

@interface DSFRootTableViewController () <CLLocationManagerDelegate, UISearchBarDelegate>
@property (nonatomic, strong) NSMutableArray *establishments;
@property (nonatomic, strong) DSFEstablishment *_currentEstablishment;
@property (nonatomic) NSInteger _currentPage;
@property (nonatomic) NSInteger _totalPages;
@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) UIView *disableViewOverlay;
- (void)fetchEstablishments;
- (void)resetEstablishments;
@end

@implementation DSFRootTableViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupSearchBar];

    self.currentLocation = nil;
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager startUpdatingLocation];
    
    [self resetEstablishments];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search

- (void)setupSearchBar {
    // Scroll table view so search bar is just out of sight
    CGPoint offset = CGPointMake(0, self.searchBar.frame.size.height);
    self.tableView.contentOffset = offset;
}

// Search begins, keyboard appears
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.tableView.allowsSelection = NO;
    self.tableView.scrollEnabled = NO;
    
    // Add Disabled View Overlay
    self.disableViewOverlay.alpha = 0;
    [self.view addSubview:self.disableViewOverlay];
    
    [UIView beginAnimations:@"FadeIn" context:nil];
    [UIView setAnimationDuration:0.3];
    self.disableViewOverlay.alpha = 0.7;
    [UIView commitAnimations];
}

// Search finished (clicked "Search" button)
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;
    
    [self.disableViewOverlay removeFromSuperview];
    
    self.searchText = [searchBar text];
    [self.searchBar resignFirstResponder]; // hides keyboard
    [self resetEstablishments];
    [self fetchEstablishments];
}

- (UIView *)disableViewOverlay {
    if (_disableViewOverlay == nil) {
//        CGRect frame = CGRectMake(0.0f,44.0f,320.0f,416.0f);
        CGRect frame = [[UIScreen mainScreen] bounds];
        frame.origin.y = self.searchBar.frame.size.height;
        _disableViewOverlay = [[UIView alloc] initWithFrame:frame];
        _disableViewOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _disableViewOverlay.backgroundColor = [UIColor blackColor];
        _disableViewOverlay.alpha = 0;
    }
    return _disableViewOverlay;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1; // Everything in one section for now
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Loading cell only
    if (self._currentPage == 0) {
        return 1;
    }
    
    // Establishments + loading cell at bottom
    if (self._currentPage < self._totalPages) {
        return self.establishments.count + 1;
    }
    
    // On last page, so no loading cell
    return [self.establishments count];
}

- (UITableViewCell *)establishmentCellForIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"EstablishmentCell";
    DSFEstablishmentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    DSFEstablishment *establishment = [self.establishments objectAtIndex:[indexPath row]];
    [cell setEstablishment: establishment];
    
    [cell updateCellContent];
    
    return cell;
}

- (UITableViewCell *)loadingCell {
    DSFLoadingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
    return cell;
}

// Use this if need different heights for different cells
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Keep this in sync with changes in storyboard. Apparently there's bug that won't pick up row height changes in storyboard...
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.establishments.count) {
        return [self establishmentCellForIndexPath:indexPath];
    } else {
        return [self loadingCell];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.tag == kLoadingCellTag) {
        self._currentPage++;
        // Update establishments if we're not on the first row (i.e. first load, since first load will be done by location callback)
        if (indexPath.row > 0) {
            [self fetchEstablishments];
        }
    }
}

#pragma mark - location update

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {

    if (self.currentLocation == nil) {
        self.currentLocation = newLocation;
        [self fetchEstablishments];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError %@", error);
}

#pragma mark - fetching data

// reset establishments called on view load, before executing a search, and will be called on pull to refresh
- (void)resetEstablishments {
    if (self.establishments == nil) {
        self.establishments = [NSMutableArray array];
    } else {
        [self.establishments removeAllObjects];
    }
    self._currentPage = 0; // no pages means we'll show single cell activity indicator
    [self.tableView reloadData];
}

- (void)fetchEstablishments {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%d", self._currentPage], @"page",
                                       nil];
    if (self.currentLocation != nil) {
        parameters[@"near"] = [NSString stringWithFormat:@"%f,%f",
                               self.currentLocation.coordinate.latitude,
                               self.currentLocation.coordinate.longitude];
    }
    if (self.searchText != nil) {
        parameters[@"search"] = self.searchText;
    }
    NSLog(@"parameters: %@", parameters);
    [[DSFApiClient sharedInstance] getPath:@"establishments.json" parameters:parameters success:
     ^(AFHTTPRequestOperation *operation, id response) {
         
         //NSLog(@"Response: %@", response);
         self._totalPages = [response[@"paging"][@"total_pages"] intValue];
         
         for (id establishmentDictionary in response[@"data"]) {
             DSFEstablishment *establishment = [[DSFEstablishment alloc] initWithDictionary:establishmentDictionary];
             [self.establishments addObject:establishment];
         }
         
         [self.tableView reloadData];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         [[[UIAlertView alloc] initWithTitle:@"Error Fetching Data"
                                     message:@"Please try again later."
                                    delegate:nil
                           cancelButtonTitle:@"Close"
                           otherButtonTitles: nil] show];
         
         NSLog(@"%@", error);
         
     }];
    
}
     
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self._currentEstablishment = self.establishments[indexPath.row];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (([[segue identifier] isEqualToString:@"EstablishmentListToDetailView"])) {
        DSFInspectionTableViewController *detailView = [segue destinationViewController];
        detailView.establishment = [sender establishment];
        detailView.currentLocation = self.currentLocation;
    }
}

@end
