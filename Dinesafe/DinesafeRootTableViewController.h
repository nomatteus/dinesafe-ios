//
//  DinesafeRootTableViewController.h
//  Dinesafe
//
//  Created by Matt Ruten on 2012-11-20.
//  Copyright (c) 2012 Matt Ruten. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DinesafeApiClient.h"
#import "DinesafeEstablishment.h"
#import "DinesafeEstablishmentTableViewCell.h"
#import "DinesafeLoadingTableViewCell.h"

@interface DinesafeRootTableViewController : UITableViewController {
    NSInteger _currentPage;
    NSInteger _totalPages;
}

@end
