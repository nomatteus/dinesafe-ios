//
//  DinesafeInspectionDetailTableViewController.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-25.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DinesafeInspectionDetailTableViewController.h"

@interface DinesafeInspectionDetailTableViewController ()

@end

@implementation DinesafeInspectionDetailTableViewController

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

    [self fetchEstablishment];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        // Establishment Info
        return 322;
    } else {
        // Inspections List & Infractions
        // Infraction is 44, infraction list is 280
        return 280;
        // TODO: Height will be higher for infractions list active cells (i.e. "tap to show" infractions)
    }
}


- (UITableViewCell *)establishmentInfoCell {
    DinesafeEstablishmentTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EstablishmentInfo"];
    cell.establishment = self.establishment;
    NSLog(@"self.establishment: %@", self.establishment);
    [cell updateCellContent];
    return cell;
}

- (UITableViewCell *)inspectionCell {
    static NSString *CellIdentifier = @"InspectionInfractionsCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [self establishmentInfoCell];
    } else {
        return [self inspectionCell];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark = fetching data

- (void)fetchEstablishment {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"43.65100,-79.47702", @"near",
                                nil];
    NSString *establishmentPath = [NSString stringWithFormat:@"establishments.json/%@.json", self.establishment.establishmentId];
    [[DinesafeApiClient sharedInstance] getPath:establishmentPath parameters:parameters success:
     ^(AFHTTPRequestOperation *operation, id response) {
         //NSLog(@"Response: %@", response);
         // TODO: Change this to load a single establishment
         
//         for (id establishmentDictionary in response[@"data"]) {
//             DinesafeEstablishment *establishment = [[DinesafeEstablishment alloc] initWithDictionary:establishmentDictionary];
//             [self.establishments addObject:establishment];
//         }
         
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
