//
//  MasterViewController.h
//  SocialStash
//
//  Created by Russ Fellman on 9/4/13.
//  Copyright (c) 2013 Russ Fellman. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

#import <iAd/iAd.h>

#import "StatusCreationViewController.h"

#import "Post.h"

#import "GAI.h"

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, StatusCreationDelegate, ADBannerViewDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (atomic, assign) id<GAITracker> tracker;

@end
