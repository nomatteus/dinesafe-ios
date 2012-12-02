//
//  DinesafeInspectionDetailTableViewController.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-25.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DSFInspectionTableViewController.h"

@interface DSFInspectionTableViewController ()

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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.establishment.inspections.count + 2; // +2 for the establishment info cells
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        // Establishment Info
        return 110;
    } else if (indexPath.row == 1) {
        // Map / Inspections summary
        return 203;
    } else {
        // Inspections List & Infractions
        // Reversing inspection order for this list
        int inspectionIndex = self.establishment.inspections.count - indexPath.row + 2 - 1 ;  // reverse order
        DSFInspection *inspection = self.establishment.inspections[inspectionIndex];
        if (inspection.infractions.count > 0) {
            // 120 is base height, then 50 for each infraction
            return 120 + inspection.infractions.count * 50;
        } else {
            return 40;
        }
    }
}


- (UITableViewCell *)establishmentInfoCell {
    DSFEstablishmentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EstablishmentInfo"];
    cell.establishment = self.establishment;
    [cell updateCellContent];
    return cell;
}

- (UITableViewCell *)establishmentExtendedInfoCell {
    DSFEstablishmentExtendedInfoCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EstablishmentExtendedInfo"];
    cell.establishment = self.establishment;
    [cell updateCellContent];
    return cell;
}

- (UITableViewCell *)inspectionCellForIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"InspectionCell";
    DSFInspectionCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // TODO: Move inspectionIndex and cell order/etc to a consolidated place, i.e. figure out cell heights and orders once, and then return that instead of doing the calculations on every cell load, Also we're calculating inspectionIndex in 2 different places and that's confusing to update. Also, I'm very tired right now and can't articulate myself very well.
    int inspectionIndex = self.establishment.inspections.count - indexPath.row + 2 - 1;  // reverse order
    cell.inspection = self.establishment.inspections[inspectionIndex];
    [cell updateCellContent];
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
    NSString *establishmentPath = [NSString stringWithFormat:@"establishments/%d.json", self.establishment.establishmentId];
    [[DSFApiClient sharedInstance] getPath:establishmentPath parameters:parameters success:
     ^(AFHTTPRequestOperation *operation, id response) {
         
         [self.establishment updateWithDictionary:response[@"data"]];
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
