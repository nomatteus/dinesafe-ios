//
//  DinesafeRootTableViewController.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-20.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DinesafeRootTableViewController.h"

@interface DinesafeRootTableViewController ()
@property (nonatomic, strong) NSMutableArray *establishments;
- (void)fetchEstablishments;
@end

@implementation DinesafeRootTableViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.establishments = [NSMutableArray array];
    _currentPage = 0; // no pages means we'll show single cell activity indicator
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
    return 1; // Everything in one section for now
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Loading cell only
    if (_currentPage == 0) {
        return 1;
    }
    
    // Establishments + loading cell at bottom
    if (_currentPage < _totalPages) {
        return self.establishments.count + 1;
    }
    
    // On last page, so no loading cell
    return [self.establishments count];
}

- (UITableViewCell *)establishmentCellForIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"EstablishmentCell";
    DinesafeEstablishmentTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    DinesafeEstablishment *establishment = [self.establishments objectAtIndex:[indexPath row]];
    [cell setEstablishment: establishment];
    
    [cell updateCellContent];
    
    return cell;
}

- (UITableViewCell *)loadingCell {
    DinesafeLoadingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
    return cell;
}

// Use this if need different heights for different cells
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 99;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.establishments.count) {
        return [self establishmentCellForIndexPath:indexPath];
    } else {
        return [self loadingCell];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.tag == kLoadingCellTag) {
        _currentPage++;
        [self fetchEstablishments];
    }
}


#pragma mark = fetching data

- (void)fetchEstablishments {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"43.65100,-79.47702", @"near",
                                [NSString stringWithFormat:@"%d", _currentPage], @"page",
                                nil];
    [[DinesafeApiClient sharedInstance] getPath:@"establishments.json" parameters:parameters success:
     ^(AFHTTPRequestOperation *operation, id response) {
         
         NSLog(@"Response: %@", response);
         _totalPages = [response[@"paging"][@"total_pages"] intValue];
         
         for (id establishmentDictionary in response[@"data"]) {
             DinesafeEstablishment *establishment = [[DinesafeEstablishment alloc] initWithDictionary:establishmentDictionary];
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
