//
//  DinesafeRootTableViewController.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-20.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DSFRootTableViewController.h"
#import "DSFPullToRefreshView.h"
#import "Flurry.h"
#import "DSFApiClient.h"

@interface DSFRootTableViewController () <CLLocationManagerDelegate, UISearchBarDelegate>
@property (nonatomic, strong) NSMutableArray *establishments;       // page
@property (nonatomic, strong) NSMutableArray *allEstablishments;    // loaded for paging
@property (nonatomic, strong) DSFEstablishment *_currentEstablishment;
@property (nonatomic) NSInteger _currentPage;
@property (nonatomic) NSInteger _totalPages;
@property (nonatomic) BOOL _noResultsFound;
@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) UIView *disableViewOverlay;
@property (nonatomic, strong) SSPullToRefreshView *pullToRefreshView;
@property (nonatomic, strong) NSMutableDictionary *surreyParameters;    // TODO - remove
@property (nonatomic, strong) NSMutableArray *objectIds;
@property (nonatomic, strong) NSString *ringDistance;
- (void)fetchEstablishments;
- (void)fetchEstablishmentsWithReset:(BOOL)reset;
- (void)resetEstablishments;
- (void)resetEstablishmentsAndShowLoadingCell:(BOOL)showLoadingCell;
- (BOOL)startUpdatingLocation;
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

//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.extendedLayoutIncludesOpaqueBars = YES;cellForRowAtIndexPath
    
//    self.navigationController.navigationBar.translucent = NO;
    
    self.currentLocation = nil;
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self startUpdatingLocation];
    
    self.pullToRefreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView
                                                                    delegate:self];
    self.pullToRefreshView.contentView = [[DSFPullToRefreshView alloc] init];

    [self resetEstablishmentsAndShowLoadingCell:YES];     // called from location manager

    [Flurry logAllPageViews:self.navigationController];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search


- (void)showSearch:(UISearchBar *)searchBar {
    self.tableView.allowsSelection = NO;
    self.tableView.scrollEnabled = NO;
    
    [self.searchBar setShowsCancelButton:YES animated:YES];
    
    // Add Disabled View Overlay
    self.disableViewOverlay.alpha = 0;
    [self.view addSubview:self.disableViewOverlay];
    
    [UIView beginAnimations:@"FadeIn" context:nil];
    [UIView setAnimationDuration:0.3];
    self.disableViewOverlay.alpha = 0.7;
    [UIView commitAnimations];
}

- (void)hideSearch:(UISearchBar *)searchBar andPerformSearch:(BOOL)performSearch {
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;
    
    [self.searchBar setShowsCancelButton:NO animated:YES];
    
    [self.disableViewOverlay removeFromSuperview];
    
    [self.searchBar resignFirstResponder]; // hides keyboard
    
    // See if new search text is different from previous search text
    BOOL searchTextChanged;
    NSString *searchBarText = [searchBar text];
    NSLog(@"searchBarText = %@", [searchBar text]);
    
    if ((self.searchText == nil && [searchBarText isEqualToString:@""]) || [self.searchText isEqualToString:searchBarText]) {
        searchTextChanged = NO;
    } else {
        searchTextChanged = YES;
        self.searchText = searchBarText;
    }
    
    // Perform search if performSearch set to YES, or if search text is changed and equal to empty string
    // This allows for "clearing" of search, while avoiding refreshing when not necessary
    if (performSearch || (searchTextChanged && [self.searchText isEqualToString:@""])) {
        [self.locationManager startUpdatingLocation]; // Check for updated location
        [self resetEstablishmentsAndShowLoadingCell:YES];
        [self fetchEstablishmentsWithReset:NO];
        [Flurry logEvent:@"Perform Search"
          withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                          self.searchText, @"Search Text",
                          nil]];
    }
}

// Search begins, keyboard appears
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self showSearch:searchBar];
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self hideSearch:searchBar andPerformSearch:NO];
}

// Search finished (clicked "Search" button)
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self hideSearch:searchBar andPerformSearch:YES];
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
        // Recognize a tap on overlay view to dismiss search view
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTaps:)];
        tapGestureRecognizer.numberOfTouchesRequired = 1;
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [_disableViewOverlay addGestureRecognizer:tapGestureRecognizer];
    }
    return _disableViewOverlay;
}

- (void)handleTaps:(UIGestureRecognizer*)paramSender {
    [self hideSearch:self.searchBar andPerformSearch:NO];
}

#pragma mark - Pull to Refresh Delegate

- (BOOL)pullToRefreshViewShouldStartLoading:(SSPullToRefreshView *)view {
    return YES;
}

/**
 The pull to refresh view started loading. You should kick off whatever you need to load when this is called.
 */
- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view {
    NSLog(@"pullToRefreshViewDidStartLoading");
    [self.locationManager startUpdatingLocation];
    [self fetchEstablishmentsWithReset:YES];
    [Flurry logEvent:@"Pull to Refresh" timed:YES];
}

/**
 The pull to refresh view finished loading. This will get called when it receives `finishLoading`.
 */
- (void)pullToRefreshViewDidFinishLoading:(SSPullToRefreshView *)view {
    [Flurry endTimedEvent:@"Pull to Refresh" withParameters:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1; // Everything in one section for now
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberOfRowsInSection %lu", (unsigned long)[self.establishments count]);
    
    // Loading cell only
    if (self._currentPage == 0) {
        NSLog(@"Loading cell only");
        return 1;
    }
    
    // "No Results Found" Cell Only
    if (self._noResultsFound) {
        NSLog(@"\"No Results Found\" Cell Only");
        return 1;
    }
    
    // Establishments + loading cell at bottom
    if (self._currentPage < self._totalPages) {
        NSLog(@"Establishments + loading cell at bottom");
        return self.establishments.count + 1;
    }
    
    // On last page, so no loading cell
    NSLog(@"On last page, so no loading cell");
    return [self.establishments count];
}

- (UITableViewCell *)establishmentCellForIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"establishmentCellForIndexPath %ld", (long)[indexPath row]);
    
    static NSString *CellIdentifier = @"EstablishmentCell";

    DSFEstablishment *establishment = [self.establishments objectAtIndex:[indexPath row]];
    
    DSFEstablishmentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [cell setEstablishment:establishment];
    [cell updateCellContent];
    
    return cell;
}

- (UITableViewCell *)loadingCell {
    DSFLoadingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
    return cell;
}

- (UITableViewCell *)noResultsCell {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"NoResultsCell"];
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
    } else if (self._noResultsFound) {
        return [self noResultsCell];
    } else {
        return [self loadingCell];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"willDisplayCell %li (currentPage = %li) (totalPages = %li)", (long)indexPath.row, (long)self._currentPage, (long)self._totalPages);
    
    if (cell.tag == kLoadingCellTag) {
        self._currentPage++;
        // Update establishments if we're not on the first row (i.e. first load, since first load will be done by location callback)
        if (indexPath.row > 0) {
            [self fetchRelatedInspections];
            [Flurry logEvent:@"Loading Cell Viewed (Load Next Page)"];
        }
    }
}

#pragma mark - location update

- (BOOL)startUpdatingLocation {
    // Proxy to CLLocationManager startUpdatingLocation method
    // allows us to respond to changes to location services enabled/disabled
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"locationServicesEnabled true");
        [self.locationManager startUpdatingLocation];
        return YES;
    } else {
        NSLog(@"locationServicesEnabled false");
        self.currentLocation = nil;
        [self fetchEstablishmentsWithReset:YES];
        return NO;
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {

    CLLocationDistance distance = [newLocation distanceFromLocation:oldLocation];
    if (self.currentLocation == nil || distance > 1) {
        self.currentLocation = newLocation;
        NSLog(@"Moved to new location");
        [self fetchEstablishmentsWithReset:YES];
    }
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    if (error.code == kCLErrorDenied) {
        // User Denied access to current location
        [self.locationManager stopUpdatingLocation];
//        [self fetchEstablishments];
        // No need to reset - already done.
        [self fetchEstablishmentsWithReset:NO];
    }
}

#pragma mark - fetching data

// reset establishments called on view load, before executing a search, and will be called on pull to refresh
- (void)resetEstablishments {
    // By default, don't show loading cell (this will keep the old data in view until update, which is a desired behavior at times)
    [self resetEstablishmentsAndShowLoadingCell:NO];
}

- (void)resetEstablishmentsAndShowLoadingCell:(BOOL)showLoadingCell {
//    NSLog(@"resetEstablishmentsAndShowLoadingCell:%hhd", showLoadingCell);
    
    // initialize or reset establishments in view
    if (self.establishments == nil) {
        self.establishments = [NSMutableArray array];
    } else {
        [self.establishments removeAllObjects];
    }
    
    if (showLoadingCell) {
        self._currentPage = 0; // no pages means we'll show single cell activity indicator
    } else {
        self._currentPage = 1;
    }
    // Reset no results found flag
    self._noResultsFound = NO;
    
    [self.tableView reloadData];
}

// Not using. TODO: remove
- (void)fetchEstablishments {
    NSLog(@"fetchEstablishments");

    [self fetchEstablishmentsWithReset:NO];
}

- (void)fetchRelatedInspections {
    NSLog(@"2) fetchRelatedInspections (currentPage = %li)", (long)self._currentPage);
    
    /**
     Send a page of object ids (10) to fetch related inspections
     
     - get a page (10) of object ids from self.establishments
     - fetch related inspections
     - move page counter ahead
     - reload table with results
     
     - return here for the next set when table is at last cell
     
     */
    
    
    NSString *objectIds = nil;
    
    //TODO - refactor as get page from all establishments
    int idx = (int)(self._currentPage - 1) * kPageSize;
    int limit = idx + kPageSize;

    if (limit > [self.allEstablishments count]) {
        limit =  (int)[self.allEstablishments count];
    }
    
//    NSLog(@"get objectIds in range %i to %i", idx, limit - 1);
    
    for (; idx < limit; idx++) {
        NSLog(@"idx = %i", idx);
        DSFEstablishment *establishmentDictionary = [self.allEstablishments objectAtIndex:idx];
        
        if (objectIds == nil) {
            objectIds = [NSString stringWithFormat:@"%lu", (unsigned long)establishmentDictionary.establishmentId];
        } else {
            objectIds = [NSString stringWithFormat:@"%@, %lu", objectIds, (long unsigned)establishmentDictionary.establishmentId];
        }
    }

    NSMutableDictionary *parameters;
    parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                  //Object,                  Key
                  @"json",                   @"f",
                  @"",                       @"maxAllowableOffset",
                  objectIds,                 @"objectIds",
                  @"*",                      @"outFields",
                  @"",                       @"outSR",
                  @"0",                      @"relationshipId",
                  @"false",                  @"returnGeometry",
                  nil];
    
    NSLog(@"parameters = %@", parameters);
    
    [[DSFApiClient sharedInstanceRelatedRecords] postPath:@"queryRelatedRecords" parameters:parameters
    success:^(AFHTTPRequestOperation *operation, id response) {
//        NSLog(@"response = %@", response);
        
        DSFEstablishment *establishment;
        for (id establishmentDictionary in response[@"relatedRecordGroups"]) {
            
            NSString *objectId = [NSString stringWithFormat:@"%@", establishmentDictionary[@"objectId"]];
            NSLog(@"objectId = %@", objectId);
            
            NSArray *relatedRecords = establishmentDictionary[@"relatedRecords"];
            
            int index = [self findEstablishment:objectId];
            
            establishment = [self.allEstablishments objectAtIndex:index];

            [establishment updateWithInspections:relatedRecords];
            
            [self.establishments addObject:establishment];
  
        }
        // Sort inspections by date.
        for (DSFEstablishment *establishment in self.establishments) {

//            NSLog(@"objectId = %lu", (unsigned long)establishment.establishmentId);
            
            [establishment.inspections sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                DSFInspection *inspect1 = obj1;
                DSFInspection *inspect2 = obj2;
                
                if ([inspect1.date compare:inspect2.date] == NSOrderedDescending) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                
                if ([inspect1.date compare:inspect2.date] == NSOrderedAscending) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                
                return (NSComparisonResult)NSOrderedSame;
            }];
        }
        
        // Sort by distance -- Re-sort.
        [self.establishments sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            DSFEstablishment *est1 = obj1;
            DSFEstablishment *est2 = obj2;
            
            if (est1.distance > est2.distance) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if (est1.distance < est2.distance) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        /* Begin loading table view */
        [self.pullToRefreshView finishLoading];
        [self.tableView reloadData];


    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self reportError:error];
    }];
}

- (void)setTotalPages {
    self._totalPages = [self.allEstablishments count] / kPageSize;
    if ([self.allEstablishments count] == 0) {
        self._noResultsFound = YES;
    } else {
        self._noResultsFound = NO;
    }
}

/**
 * fetch all establishments into paging array allEstablishments
 * Called by pullToRefreshViewDidStartLoading and will reload entire set of establishments. Wasteful. 
 * TODO: Call on load or reset only.
 */
- (void)fetchAllEstablishments {
    NSLog(@"fetchAllEstablishments");
    
    NSMutableDictionary *parameters;
    parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                  //                Object,                    Key
                  @"json",                   @"f",
                  @"*",                      @"outFields",
                  @"false",                  @"returnCountOnly",
                  @"false",                  @"returnGeometry",
                  @"false",                  @"returnIdsOnly",
                  @"%",                      @"text",
                  @"",                       @"time",
                  @"",                       @"where",
                  
                  nil];
    
    if (self.searchText != nil && ![self.searchText isEqualToString:@""]) {
        parameters[@"text"] = self.searchText;
    }
    
    NSLog(@"parameters: %@", parameters);
    
    [[DSFApiClient sharedInstance] postPath:@"query" parameters:parameters
    success: ^(AFHTTPRequestOperation *operation, id response) {

        NSLog(@"Resetting all establishments");
        
        if (self.objectIds == nil) {
            self.objectIds = [NSMutableArray array];
        } else {
            [self.objectIds removeAllObjects];
        }
        
        if (self.allEstablishments == nil) {
            self.allEstablishments = [NSMutableArray array];
        } else {
            NSLog(@"removeAllObjects");
            [self.allEstablishments removeAllObjects];
            [self.establishments removeAllObjects];
        }

        for (id establishmentDictionary in response[@"features"]) {
            
            NSString *objectId = establishmentDictionary[@"attributes"][@"OBJECTID"];
            [self.objectIds addObject:objectId];
            
            DSFEstablishment *establishment = [[DSFEstablishment alloc] initWithDictionary:establishmentDictionary[@"attributes"]];
            
            // Calculate distance from current location
            CLLocation *estLocation =  [[CLLocation alloc] initWithLatitude:establishment.location.latitude longitude:establishment.location.longitude];
            establishment.distance = [self.currentLocation distanceFromLocation:estLocation] / 1000;

            [self.allEstablishments addObject:establishment];
        }
        NSLog(@"1) Retrieved all %lu establishments", (unsigned long)[self.allEstablishments count]);

        [self setTotalPages];   // also sets resultsFound = YES|NO

        // Sort by distance
        [self.allEstablishments sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            DSFEstablishment *est1 = obj1;
            DSFEstablishment *est2 = obj2;
            
            if (est1.distance > est2.distance) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if (est1.distance < est2.distance) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        // Get inspections and load table
        [self fetchRelatedInspections];
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self reportError:error];
    }];
}

- (void)fetchEstablishmentsWithReset:(BOOL)reset {
//    NSLog(@"fetchEstablishmentsWithReset reset = %hhd", reset);
    
    if (reset) {
        // Need to set current page to 1 before the API request if resetting.
        self._currentPage = 1;
    }
    
    [self fetchAllEstablishments];
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
        
        NSLog(@"establishment (%lu) - %@", (unsigned long)detailView.establishment.establishmentId, detailView.establishment.latestName);

    }
}

#pragma mark - Utils

- (int)findEstablishment:(NSString *)searchID{
    //TODO - refactor
    int i=0;
    for (DSFEstablishment *establishment in self.allEstablishments) {
        NSString *idStr = [NSString stringWithFormat:@"%zd", establishment.establishmentId];
        if([idStr isEqualToString: searchID]) {
            break;
        } else {
            i++;
        }
    }
    return i;
}

- (void)reportError:(NSError *)error {
    NSString *errorTitle;
    NSString *errorMsg;
    if (error.code == -1011) {
        // -1011 is application error: 404 or 500, or similar
        errorTitle = @"Error Fetching Data";
        errorMsg = @"Please try again.";
    } else {
        // -1003 is hostname not accessible. For that and others, display "network?" message
        errorTitle = @"Could Not Connect";
        errorMsg = @"Please check that you have an active internet connection, and try again.";
    }
    [[[UIAlertView alloc] initWithTitle:errorTitle
                                message:errorMsg
                               delegate:nil
                      cancelButtonTitle:@"Close"
                      otherButtonTitles: nil] show];
    
    // Reset pull to refresh view so it's available for user to "pull and try again".
    [self.pullToRefreshView finishLoading];
    
    NSLog(@"%@", error);
}

@end
