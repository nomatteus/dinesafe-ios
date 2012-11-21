//
//  DinesafeRootTableViewController.m
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-20.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import "DinesafeRootTableViewController.h"

@interface DinesafeRootTableViewController () {

}
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
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.establishments = [[NSMutableArray alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //code executed in the background
        NSData* dinesafeData = [NSData dataWithContentsOfURL:
                            [NSURL URLWithString:@"http://dinesafe.dev/api/1.0/establishments.json"]
                            ];

        NSDictionary* json = nil;
        if (dinesafeData) {
            json = [NSJSONSerialization
                    JSONObjectWithData:dinesafeData
                    options:kNilOptions
                    error:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //code executed on the main queue
            [self updateUIWithDictionary: json];
        });
        
    });
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
    // Return the number of rows in the section.
    return [self.establishments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EstablishmentCell";
    DinesafeEstablishmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    DinesafeEstablishment *establishment = [self.establishments objectAtIndex:[indexPath row]];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:10];
    nameLabel.text = establishment.latestName;
    UILabel *addressLabel = (UILabel *)[cell viewWithTag:20];
    addressLabel.text = establishment.address;
    // Configure the cell...
    
    return cell;
}

-(void)updateUIWithDictionary:(NSDictionary*)json {
    @try {
        for (NSDictionary *establishmentInfo in json[@"data"]) {
//            NSLog(@"establishment: %@", establishmentInfo[@"latest_name"]);
            DinesafeEstablishment *establishment = [[DinesafeEstablishment alloc] init];
            establishment.latestName = establishmentInfo[@"latest_name"];
            establishment.address = establishmentInfo[@"address"];
            [self.establishments addObject:establishment];
        }
//        NSLog(@"number of establishments in array: %i", self.establishments.count);
//        NSString *text = [NSString stringWithFormat:
//                      @"Establishment %@ of type %@ is located at %@ . Establishment id: %@ ",
//                      json[@"data"][0][@"latest_name"],
//                      json[@"data"][0][@"latest_type"],
//                      json[@"data"][0][@"address"],
//                      json[@"data"][0][@"id"],
//                      nil];
//        NSLog(@"%@", text);
        [self.tableView reloadData];
    }
    @catch (NSException *exception) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Could not parse the JSON feed."
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles: nil] show];
        NSLog(@"Exception: %@", exception);
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
