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
#import "DSFSurreyEstablishment.h"

@interface DSFRootTableViewController () <CLLocationManagerDelegate, UISearchBarDelegate>
@property (nonatomic, strong) NSMutableArray *establishments;
@property (nonatomic, strong) DSFEstablishment *_currentEstablishment;
@property (nonatomic) NSInteger _currentPage;
@property (nonatomic) NSInteger _totalPages;
@property (nonatomic) BOOL _noResultsFound;
@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) UIView *disableViewOverlay;
@property (nonatomic, strong) SSPullToRefreshView *pullToRefreshView;
@property (nonatomic, strong) NSMutableDictionary *surreyParameters;
@property (nonatomic, strong) NSMutableArray *objectIds;
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
//    self.extendedLayoutIncludesOpaqueBars = YES;
    
//    self.navigationController.navigationBar.translucent = NO;
    
    self.currentLocation = nil;
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self startUpdatingLocation];
    
    self.pullToRefreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView
                                                                    delegate:self];
    self.pullToRefreshView.contentView = [[DSFPullToRefreshView alloc] init];

//    [self resetEstablishmentsAndShowLoadingCell:YES];     called from location manager

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
        [self fetchEstablishments];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1; // Everything in one section for now
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // DINE SURREY - temporary until handling paging
    if (DINE_SURREY) {
        return [self.establishments count];
    }
    
    // Loading cell only
    if (self._currentPage == 0) {
        return 1;
    }
    
    // "No Results Found" Cell Only
    if (self._noResultsFound) {
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

    if (DINE_SURREY) {

        // We need to calculate distance, since it's not provided by Surrey.
        DSFSurreyEstablishment *establishment = [self.establishments objectAtIndex:[indexPath row]];
        
        CLLocation *estLocation =  [[CLLocation alloc] initWithLatitude:establishment.location.latitude longitude:establishment.location.longitude];
        establishment.distance = [self.currentLocation distanceFromLocation:estLocation] / 1000;
        
        DSFSurreyEstablishmentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        [cell setEstablishment:establishment];
        [cell updateCellContent];
        
        return cell;
        
    } else {
        DSFEstablishmentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        DSFEstablishment *establishment = [self.establishments objectAtIndex:[indexPath row]];
        [cell setEstablishment: establishment];
        [cell updateCellContent];
        
        return cell;

    }
    
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
    if (cell.tag == kLoadingCellTag) {
        self._currentPage++;
        // Update establishments if we're not on the first row (i.e. first load, since first load will be done by location callback)
        if (indexPath.row > 0) {
            [self fetchEstablishments];
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
    NSLog(@"Distance: %f", distance);
    if (self.currentLocation == nil || distance > 1) {
        self.currentLocation = newLocation;
        [self fetchEstablishmentsWithReset:YES];
    }
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    if (error.code == kCLErrorDenied) {
        // User Denied access to current location
        NSLog(@"locationManager didFailWithError (kCLErrorDenied) %@", error);
        [self.locationManager stopUpdatingLocation];
        [self fetchEstablishments];
    }
}

#pragma mark - fetching data

// reset establishments called on view load, before executing a search, and will be called on pull to refresh
- (void)resetEstablishments {
    // By default, don't show loading cell (this will keep the old data in view until update, which is a desired behavior at times)
    [self resetEstablishmentsAndShowLoadingCell:NO];
}

- (void)resetEstablishmentsAndShowLoadingCell:(BOOL)showLoadingCell {
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

- (void)fetchEstablishments {
    [self fetchEstablishmentsWithReset:NO];
}

- (void)fetchSurreyObjectIds {
    if (self.objectIds == nil) {
        self.objectIds = [NSMutableArray array];
    } else {
        [self.objectIds removeAllObjects];
    }

    self.surreyParameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                             // Object, Key
                             @"NAME like '%%'", @"where",
                             @"json", @"f",
                             @"*", @"outfields",
                             @"false", @"returnGeometry",
                             nil];
    NSLog(@"surreyParameters: %@", self.surreyParameters);

    [[DSFApiClient sharedInstance] getPath:@"query" parameters:self.surreyParameters
    success:
     ^(AFHTTPRequestOperation *operation, id response) {
         
         // Reset objectIds and load array
         if (self.objectIds == nil) {
             self.objectIds = [NSMutableArray array];
         } else {
             [self.objectIds removeAllObjects];
         }
         
         for (id establishmentDictionary in response[@"features"]) {
             NSString *objectId = establishmentDictionary[@"attributes"][@"OBJECTID"];
             
             [self.objectIds addObject:objectId];
         }
         NSLog(@"Retrieved %d objectIds", [self.objectIds count]);
     }
    failure:
     ^(AFHTTPRequestOperation *operation, NSError *error) {
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
        
    }];
}

- (void)fetchEstablishmentsWithReset:(BOOL)reset {
    
    if (reset) {
        // Need to set current page to 1 before the API request if resetting.
        self._currentPage = 1;
    }
    
    NSMutableDictionary *parameters;
    NSString *path;

    // TODO: sort not working
    // @"where=NAME like '%%'&f=json&outfields=*&returnGeometry=false&orderByFields=NAME ASC";
    
    if (DINE_SURREY) {
        
        if ([self.objectIds count] == 0) {
            // ArcGIS - Surrey straight query

            parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        // Object,          Key
                                        @"NAME like '%%'",  @"where",
                                        @"json",            @"f",
                                        @"*",               @"outfields",
                                        @"false",           @"returnGeometry",
                                        nil];
            // Prepare for establishment record query
            path = @"query";
        } else {

            // ArcGIS - Surrey related query - TODO: refactor
            self.surreyParameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     // Object,         Key
                                     @"NAME like '%%'", @"where",
                                     @"json",           @"f",
                                     @"*",              @"outfields",
                                     @"false",          @"returnGeometry",
                                     @"0",              @"relationshipId",
                                     @"",               @"objectIds",
                                     nil];
            
            // Get 10 objectIds to test and add to surreyParameters - TODO: provide paging function.
            int start=0, end=9;
            NSString *ids;
            for (int i=start; i<end; i++) {
                NSString *objectId = [[self.objectIds objectAtIndex:i] stringValue];
                if (ids == nil) {
                    ids = objectId;
                } else {
                    ids = [NSString stringWithFormat:@"%@, %@", ids, objectId];
                }

            }
            
            [self.surreyParameters setObject:ids forKey:@"objectIds"];
            NSLog(@"surreyParameters: %@", self.surreyParameters);
            
            // Prepare for related record query
            path = @"queryRelatedRecords";
            
            parameters = self.surreyParameters;
        }
        
        
    } else {
        path = @"establishments.json";
        parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      [NSString stringWithFormat:@"%ld", (long)self._currentPage], @"page", nil];
        
        if (self.currentLocation != nil) {
            parameters[@"near"] = [NSString stringWithFormat:@"%f,%f",
                                   self.currentLocation.coordinate.latitude,
                                   self.currentLocation.coordinate.longitude];
        }
        
        if (self.searchText != nil) {
            parameters[@"search"] = self.searchText;
        }

    }
    
    NSLog(@"parameters: %@", parameters);
    
    [[DSFApiClient sharedInstance] getPath:path parameters:parameters success:
     ^(AFHTTPRequestOperation *operation, id response) {
         
         if (reset) {
             NSLog(@"Resetting establishments");
             [self resetEstablishments];
         }
         
         NSLog(@"Response: %@", response);
         self._totalPages = [response[@"paging"][@"total_pages"] intValue];
         
         if (self._totalPages == 0) {
             self._noResultsFound = YES;
         } else {
             self._noResultsFound = NO;
         }
         
         
         if (DINE_SURREY) {
             for (id establishmentDictionary in response[@"features"]) {
                 DSFSurreyEstablishment *establishment = [[DSFSurreyEstablishment alloc] initWithDictionary:establishmentDictionary[@"attributes"]];
                 [self.establishments addObject:establishment];
             }
         } else {
             for (id establishmentDictionary in response[@"data"]) {
                 DSFEstablishment *establishment = [[DSFEstablishment alloc] initWithDictionary:establishmentDictionary];
                 [self.establishments addObject:establishment];
             }
             
         }
         
         [self.pullToRefreshView finishLoading];
         [self.tableView reloadData];
         
     }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
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
