//
//  DinesafeInspectionDetailTableViewController.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-25.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DSFInspectionTableViewController.h"
#import "NSString+URLEncoding.h"
#import "FrameworkCheck.h"

@interface DSFInspectionTableViewController ()
@property (nonatomic, strong) NSMutableArray *tableCellHeights;
@property (nonatomic, strong) DSFEstablishmentExtendedInfoCell *extendedInfoCell;
@end

@implementation DSFInspectionTableViewController

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

    self.tableCellHeights = [[NSMutableArray alloc] init];

    [self fetchEstablishment];
    [self calculateTableCellHeights:self.view.frame.size];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - view rotation callback

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    // Calculate table cell heights for new size
    [self calculateTableCellHeights:size];

    // Reload data so that the text will fit in the new size
    [self.tableView reloadData];
}

#pragma mark - Action button tap & sharing actions

- (IBAction)actionTap:(id)sender
{
    // TODO: Store buttons & actions in array, so we can use it to print button titles, and also
    //       in actionSheet deletate switch statement
    NSString *actionSheetTitle = [NSString stringWithFormat:@"%@", self.establishment.latestName];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Post to Twitter", @"Post to Facebook", @"Email Link", @"Copy Link", @"Open in Maps",
                                                                      nil];
    [actionSheet showFromBarButtonItem:self.actionButton animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self postToTwitter];
            break;
        case 1:
            [self postToFacebook];
            break;
        case 2:
            [self emailResult];
            break;
        case 3:
            [self copyLink];
            break;
        case 4:
            [self openInMaps];
            break;
        default:
            break;
    }
}

- (void)copyLink
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.establishment.shareURL;
}

- (void)openInMaps
{
    NSDictionary *addressDict = @{
        (NSString *)kABPersonAddressStreetKey : self.establishment.address,
                    (NSString *)
        kABPersonAddressCityKey : @"Toronto",
        (NSString *)
        kABPersonAddressStateKey : @"Ontario"
    };
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.establishment.location
                                                   addressDictionary:addressDict];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:self.establishment.latestName];
    [mapItem openInMapsWithLaunchOptions:nil];
}

- (void)postToFacebook
{
    NSLog(@"post to facebook");
    if (![self canPostToFacebook]) {
        [self openWebFacebookURL];
        return;
    }

    SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [composeViewController setInitialText:self.establishment.shareTextShort];
    //        [composeViewController addImage:[UIImage imageNamed:@"something.png"]];
    NSString *shareURL = [NSString stringWithFormat:@"%@?utm_source=app_share&utm_medium=facebook&utm_campaign=dinesafe", self.establishment.shareURL];
    [composeViewController addURL:[NSURL URLWithString:shareURL]];
    [composeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
      switch (result) {
          case SLComposeViewControllerResultCancelled:
              NSLog(@"Post canceled");
              break;
          case SLComposeViewControllerResultDone:
              NSLog(@"Post successful");
              break;
          default:
              break;
      }
    }];
    [self presentViewController:composeViewController animated:YES completion:nil];
}

- (BOOL)canPostToFacebook
{
    return [FrameworkCheck isSocialAvailable] && [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook];
}

- (void)openWebFacebookURL
{
    // Fall back to FB web link
    // Docs: http://stackoverflow.com/a/12800739/76710 or http://goo.gl/PXqmR
    // Link Sample: https://www.facebook.com/dialog/feed?app_id=136579186509696&link=https://dinesafe.to/app&picture=http://fbrell.com/f8.jpg&%20name=Dinesafe%20Toronto&caption=Restaurant%20Health%20Inspections%20iOS%20App&description=Using%20Dialogs%20to%20interact%20with%20users.&redirect_uri=http://dinesafe.to/app
    UIApplication *app = [UIApplication sharedApplication];
    NSString *fbText = [self.establishment.shareTextShort urlEncode];
    NSString *shareURL = [NSString stringWithFormat:@"%@?utm_source=app_share&utm_medium=facebook&utm_campaign=dinesafe", self.establishment.shareURL];
    NSString *dsfURLforFb = [shareURL urlEncode];
    NSString *fbURL = [NSString stringWithFormat:@"https://www.facebook.com/dialog/feed?app_id=136579186509696&link=%@&picture=http://dinesafe.to/assets/logos/dinesafe-128-square.png&%%20name=Dinesafe%%20Toronto&caption=Restaurant%%20Health%%20Inspections%%20iOS%%20App&description=%@&redirect_uri=%@",
                                                 dsfURLforFb, fbText, dsfURLforFb];
    [app openURL:[NSURL URLWithString:fbURL]];
}

- (void)postToTwitter
{
    NSLog(@"post to twitter");
    if (![self canPostToTwitter]) {
        [self openWebTweetURL];
        return;
    }
    SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [composeViewController setInitialText:self.establishment.shareTextShort];
    NSString *shareURL = [NSString stringWithFormat:@"%@?utm_source=app_share&utm_medium=twitter&utm_campaign=dinesafe", self.establishment.shareURL];
    [composeViewController addURL:[NSURL URLWithString:shareURL]];
    [composeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
      switch (result) {
          case SLComposeViewControllerResultCancelled:
              NSLog(@"Post canceled");
              break;
          case SLComposeViewControllerResultDone:
              NSLog(@"Post successful");
              break;
          default:
              break;
      }
    }];
    [self presentViewController:composeViewController animated:YES completion:nil];
}

- (BOOL)canPostToTwitter
{
    return [FrameworkCheck isSocialAvailable] && [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)openWebTweetURL
{
    // Twitter fallback to web link:
    // https://twitter.com/intent/tweet?text=An+Awesome+Link&url=http%3A%2F%2Fwww.google.com%2F
    UIApplication *app = [UIApplication sharedApplication];
    NSString *tweetText = [self.establishment.shareTextShort urlEncode];
    NSString *shareURL = [NSString stringWithFormat:@"%@?utm_source=app_share&utm_medium=twitter&utm_campaign=dinesafe", self.establishment.shareURL];
    NSString *tweetURL = [shareURL urlEncode];
    NSString *twitterURL = [NSString stringWithFormat:@"https://twitter.com/intent/tweet?text=%@&url=%@", tweetText, tweetURL];
    [app openURL:[NSURL URLWithString:twitterURL]];
}

- (void)emailResult
{
    NSLog(@"email result");
    // This is a good tutorial (though a tad outdated): http://mobile.tutsplus.com/tutorials/iphone/mfmailcomposeviewcontroller/
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController navigationBar].barStyle = UIBarStyleBlack;

        [mailViewController setSubject:[NSString stringWithFormat:@"Dinesafe Results for %@", self.establishment.latestName]];

        NSString *shareURLHref = [NSString stringWithFormat:@"%@?utm_source=app_share&utm_medium=email&utm_campaign=dinesafe", self.establishment.shareURL];
        NSString *emailBodyHtml = [NSString stringWithFormat:@"%@<br><br>Check it out here: <a href=\"%@\">%@</a>",
                                                             self.establishment.shareTextLongHtml,
                                                             shareURLHref,
                                                             self.establishment.shareURL];
        [mailViewController setMessageBody:emailBodyHtml isHTML:YES];
        [self presentViewController:mailViewController animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot create mail."
                                                        message:@"Your device is not configured for sending email."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled, and no draft saved.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail not sent, but draft saved.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent!");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed to send.");
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:self completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.establishment.inspections.count + 2; // +2 for the establishment info cells
}

// Calculates and stores table heights, so we don't have to do the logic/calulations
//      constantly. i.e. a caching mechanism to avoid laggy scrolling
- (void)calculateTableCellHeights:(CGSize)frameSize
{
    // Establishment Info
    self.tableCellHeights[0] = [NSNumber numberWithInt:110];

    // Map/Inspections Summary
    self.tableCellHeights[1] = [NSNumber numberWithInt:184];

    // Offset to take into account the two cells above
    int inspectionsOffset = 2;
    int numEstablishments = self.establishment.inspections.count;
    for (int i = inspectionsOffset; i < (numEstablishments + inspectionsOffset); i++) {
        // Reversing inspection order for this
        //     numEstablishments - 1   takes us to the end of the list (counting from 0)
        //     i + inspectionsOffset   subtracts the current inspection's index
        int inspectionIndex = numEstablishments - 1 - i + inspectionsOffset;
        DSFInspection *inspection = self.establishment.inspections[inspectionIndex];
        int cellHeight;
        if (inspection.infractions.count > 0) {
            // 120 is base height
            cellHeight = 120 + [inspection heightForInfractionsWithSize:CGSizeMake(frameSize.width - 132, 1000) andFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0]];
        } else {
            cellHeight = 40;
        }
        self.tableCellHeights[i] = [NSNumber numberWithInt:cellHeight];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.tableCellHeights[indexPath.row] floatValue];
}

- (UITableViewCell *)establishmentInfoCell
{
    DSFEstablishmentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EstablishmentInfo"];
    cell.establishment = self.establishment;
    [cell updateCellContent];
    return cell;
}

- (UITableViewCell *)establishmentExtendedInfoCell
{
    if (self.extendedInfoCell == nil) {
        // Only create cell once, to avoid map resetting each time.
        self.extendedInfoCell = [self.tableView dequeueReusableCellWithIdentifier:@"EstablishmentExtendedInfo"];
        self.extendedInfoCell.establishment = self.establishment;
        [self.extendedInfoCell updateCellContent];
    }
    return self.extendedInfoCell;
}

- (UITableViewCell *)inspectionCellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"InspectionCell";
    DSFInspectionCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // TODO: Move inspectionIndex and cell order/etc to a consolidated place, i.e. figure out cell heights and orders once, and then return that instead of doing the calculations on every cell load, Also we're calculating inspectionIndex in 2 different places and that's confusing to update. Also, I'm very tired right now and can't articulate myself very well.
    int inspectionIndex = self.establishment.inspections.count - 1 - indexPath.row + 2; // reverse order

    cell.inspection = self.establishment.inspections[inspectionIndex];
    [cell updateCellContentWithHeight:[self.tableCellHeights[indexPath.row] floatValue]];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [self establishmentInfoCell];
    } else if (indexPath.row == 1) {
        return [self establishmentExtendedInfoCell];
    } else {
        return [self inspectionCellForIndexPath:indexPath];
    }
}

#pragma mark = fetching data

- (void)fetchEstablishment
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];

    if (self.currentLocation != nil) {
        parameters[@"near"] = [NSString stringWithFormat:@"%f,%f",
                                                         self.currentLocation.coordinate.latitude,
                                                         self.currentLocation.coordinate.longitude];
    }
    NSString *establishmentPath = [NSString stringWithFormat:@"establishments/%lu.json", (unsigned long)self.establishment.establishmentId];
    [[DSFApiClient sharedInstance] getPath:establishmentPath
        parameters:parameters
        success:
            ^(AFHTTPRequestOperation *operation, id response) {

              [self.establishment updateWithDictionary:response[@"data"]];
              [self calculateTableCellHeights:self.view.frame.size];
              [self.tableView reloadData];

            }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

          // TODO: Handle this stuff in a generic/shared class, somehow.
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
                            otherButtonTitles:nil] show];

          NSLog(@"%@", error);

        }];
}

@end
