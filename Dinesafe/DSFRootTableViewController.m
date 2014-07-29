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

//    [self resetEstablishmentsAndShowLoadingCell:YES];     // called from location manager

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
    NSLog(@"numberOfSectionsInTableView");
    
    // Return the number of sections.
    return 1; // Everything in one section for now
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberOfRowsInSection %lu", (unsigned long)[self.establishments count]);
    
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
    NSLog(@"establishmentCellForIndexPath");
    
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
    NSLog(@"cellForRowAtIndexPath");
    
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
    NSLog(@"resetEstablishmentsAndShowLoadingCell");
    
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

- (void)fetchSurroundingGeometries:(NSString *)inMeters {
    /**
     TODO:
     - handle when no points are returned
     */
    
    NSMutableDictionary *parameters;

    // Current Location
    NSString *location = [NSString stringWithFormat:@"%f, %f", self.currentLocation.coordinate.longitude, self.currentLocation.coordinate.latitude];
    
    // City of Surrey
//    location = @"-122.80816,49.11268";
    
    parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
//                Object,           Key
                  @"26910",         @"bufferSR",
                  inMeters,           @"distances",
                  location,         @"geometries",
                  @"4326",          @"inSR",
                  @"4326",          @"outSR",
                  @"unionResults",	@"false",
                  @"json",          @"f",
                  nil];
    
    NSLog(@"parameters: %@", parameters);
    [[DSFApiClient sharedInstanceWithGeometries] getPath:@"buffer" parameters:parameters
    success:
     ^(AFHTTPRequestOperation *operation, id response) {
         NSDictionary *jsonDict = response[@"geometries"][0];
         NSError *error;
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONReadingAllowFragments error:&error];
         NSString *rings = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
//         NSLog(@"rings = %@", rings);
         
         if (rings != nil) {
             [self fetchSurreyObjectIds:rings];
         } else {
             // TODO - Handle with some alternative to user
             NSLog(@"Geometries not found");
         }

     }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [self reportError:error];
     }];
    
}

- (void)fetchSurreyObjectIds:(NSString *)surroundingRings {
    NSMutableDictionary *parameters;
    
    /* find establishments surrounding current location */
    // fetch surrounding geometries at a distance n
    // get objectIds contained by rings

//    surroundingRings = @"{\"rings\":[[[-122.808125305845,49.1216753824737],[-122.807264813252,49.1216561987713],[-122.80640785549,49.1216015837696],[-122.805557816386,49.1215117531265],[-122.804718052402,49.1213870615528],[-122.803891879363,49.121228001409],[-122.803082559343,49.1210352007583],[-122.802293287769,49.1208094208828],[-122.801527180785,49.1205515532727],[-122.800787262936,49.1202626161014],[-122.800076455214,49.1199437501994],[-122.799397563519,49.1195962145436],[-122.798753267569,49.1192213812796],[-122.798146110325,49.1188207302981],[-122.797578487944,49.1183958433841],[-122.797052640328,49.1179483979655],[-122.796570642286,49.1174801604834],[-122.796134395356,49.116992979412],[-122.795745620304,49.1164887779543],[-122.795405850357,49.115969546444],[-122.795116425161,49.1154373344832],[-122.794878485518,49.1148942428466],[-122.794692968908,49.1143424151848],[-122.794560605808,49.1137840295591],[-122.794481916842,49.113221289842],[-122.79445721075,49.1126564170167],[-122.794486583198,49.11209164041],[-122.794569916432,49.1115291888938],[-122.794706879769,49.1109712820896],[-122.794896930934,49.1104201216104],[-122.795139318223,49.1098778823747],[-122.795433083499,49.1093467040277],[-122.795777065996,49.1088286825018],[-122.796169906924,49.1083258617513],[-122.79661005485,49.1078402256926],[-122.797095771837,49.1073736903822],[-122.797625140318,49.1069280964636],[-122.798196070674,49.1065052019114],[-122.798806309487,49.1061066751032],[-122.799453448436,49.1057340882438],[-122.800134933804,49.1053889111705],[-122.800848076549,49.1050725055616],[-122.801590062913,49.1047861195712],[-122.802357965511,49.1045308829126],[-122.803148754874,49.1043078024075],[-122.803959311386,49.1041177580204],[-122.804786437575,49.1039614993926],[-122.805626870711,49.1038396428897],[-122.806477295658,49.1037526691738],[-122.807334357928,49.1037009213107],[-122.808194676898,49.1036846034187],[-122.809054859115,49.103703779865],[-122.809911511668,49.1037583750116],[-122.810761255544,49.1038481735139],[-122.811600738935,49.1039728211678],[-122.812426650443,49.1041318263056],[-122.813235732118,49.1043245617315],[-122.814024792292,49.1045502671921],[-122.814790718154,49.1048080523706],[-122.815530488017,49.1050969003938],[-122.81624118322,49.1054156718369],[-122.816919999641,49.105763109213],[-122.817564258746,49.106137841926],[-122.818171418158,49.1065383916714],[-122.818739081684,49.1069631782604],[-122.819265008772,49.1074105258475],[-122.819747123362,49.1078786695342],[-122.820183522078,49.1083657623259],[-122.820572481757,49.1088698824115],[-122.820912466265,49.1093890407407],[-122.821202132569,49.1099211888655],[-122.821440336065,49.1104642270179],[-122.821626135113,49.1110160123909],[-122.82175879478,49.11157436759],[-122.821837789767,49.1121370892226],[-122.821862806508,49.1127019565907],[-122.821833744436,49.1132667404536],[-122.82175071641,49.1138292118248],[-122.821614048301,49.1143871507698],[-122.821424277729,49.1149383551687],[-122.821182151971,49.1154806494104],[-122.82088862504,49.1160118929822],[-122.820544853943,49.116529988923],[-122.820152194137,49.1170328921051],[-122.819712194198,49.117518617312],[-122.819226589729,49.1179852470812],[-122.818697296522,49.1184309392796],[-122.818126403011,49.1188539343826],[-122.817516162031,49.1192525624271],[-122.816868981937,49.1196252496115],[-122.816187417096,49.1199705245163],[-122.815474157803,49.1202870239205],[-122.814732019654,49.1205734981907],[-122.813963932428,49.1208288162214],[-122.813172928504,49.1210519699076],[-122.812362130885,49.1212420781307],[-122.811534740842,49.1213983902426],[-122.810694025268,49.1215202890343],[-122.809843303753,49.1216072931769],[-122.808985935462,49.1216590591245],[-122.808125305845,49.1216753824737]]]}";
    
    parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
//                Object,                    Key
                  @"json",                   @"f",
                  surroundingRings,          @"geometry",
                  @"esriGeometryPolygon",    @"geometryType",
                  @"4326",                   @"inSR",
                  @"",                       @"maxAllowableOffset",
                  @"",                       @"objectIds",
                  @"*",                      @"outFields",
                  @"",                       @"outSR",
                  @"",                       @"relationParam",
                  @"false",                  @"returnCountOnly",
                  @"false",                  @"returnGeometry",
                  @"false",                  @"returnIdsOnly",
                  @"esriSpatialRelContains", @"spatialRel",
                  @"",                       @"text",
                  @"",                       @"time",
                  @"",                       @"where",
                  
                             nil];
    
//    NSLog(@"parameters: %@", parameters);

    [[DSFApiClient sharedInstance] postPath:@"query" parameters:parameters
    success:
     ^(AFHTTPRequestOperation *operation, id response) {
//         NSLog(@"request = %@", [operation request]);
         NSLog(@"response = %@", response);

         // Reset objectIds and load array
         if (self.objectIds == nil) {
             self.objectIds = [NSMutableArray array];
         } else {
             [self.objectIds removeAllObjects];
         }

         // TODO: add resetEstablishments
         if (self.establishments == nil) {
             self.establishments = [NSMutableArray array];
         } else {
             [self.establishments removeAllObjects];
         }

         for (id establishmentDictionary in response[@"features"]) {
             
             NSString *objectId = establishmentDictionary[@"attributes"][@"OBJECTID"];
             [self.objectIds addObject:objectId];
             
             DSFSurreyEstablishment *establishment = [[DSFSurreyEstablishment alloc] initWithDictionary:establishmentDictionary[@"attributes"]];
             [self.establishments addObject:establishment];
         }
         NSLog(@"Retrieved %d objectIds", [self.objectIds count]);
         
         [self.pullToRefreshView finishLoading];
         [self.tableView reloadData];

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
    [self fetchSurroundingGeometries:@"10000"];
    
}

- (void)xfetchEstablishmentsWithReset:(BOOL)reset {
    
    if (reset) {
        // Need to set current page to 1 before the API request if resetting.
        self._currentPage = 1;
    }
    
    NSMutableDictionary *parameters;
    NSString *path;

    // TODO: sort not working
    // @"where=NAME like '%%'&f=json&outfields=*&returnGeometry=false&orderByFields=NAME ASC";
    
    if (DINE_SURREY) {
        
        [self fetchSurroundingGeometries:@"1000"];
        
        // If user is out of range, return everything
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
