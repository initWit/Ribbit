//
//  FriendsTableViewController.h
//  Ribbit
//
//  Created by Robert Figueras on 4/30/14.
//  Copyright (c) 2014 AppSpaceship. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FriendsTableViewController : UITableViewController

@property (nonatomic,strong) PFRelation* friendsRelation;
@property (nonatomic,strong) NSArray* friends;


@end
