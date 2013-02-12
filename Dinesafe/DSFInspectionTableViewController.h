//
//  DinesafeInspectionDetailTableViewController.h
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-25.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>
#import "DSFApiClient.h"
#import "DSFEstablishment.h"
#import "DSFEstablishmentCell.h"
#import "DSFEstablishmentExtendedInfoCell.h"
#import "DSFInspectionCell.h"

@interface DSFInspectionTableViewController : UITableViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) DSFEstablishment *establishment;

@property (nonatomic, strong) CLLocation *currentLocation;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *actionButton;

- (IBAction)actionTap:(id)sender;

@end
