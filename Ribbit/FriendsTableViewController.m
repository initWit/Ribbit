//
//  FriendsTableViewController.m
//  Ribbit
//
//  Created by Robert Figueras on 4/30/14.
//  Copyright (c) 2014 AppSpaceship. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "EditFriendsTableViewController.h"


@interface FriendsTableViewController ()

@end

@implementation FriendsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // *** Moved this into viewWillAppear; otherwise friends do not get refreshed between different users in same app session
    //self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"]; // *** get the relation for the current user
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"]; // *** get the relation for the current user

    PFQuery *query = [self.friendsRelation query]; // *** add a query to the relation
    [query orderByAscending:@"username"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) { // *** run the query
        if (error) {
            NSLog(@"error %@ %@", error, error.userInfo);
        }
        else {
            self.friends = objects; // *** get the objects returned from the query and load into array
            
            NSLog(@"current user : %@",[PFUser currentUser]);
            NSLog(@"self.friends : %@",self.friends);
            
            [self.tableView reloadData]; // *** reload the table data
        }
    }];

}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString: @"showEditFriends"]) {
        EditFriendsTableViewController *vc = (EditFriendsTableViewController *) segue.destinationViewController;
        vc.friends = [NSMutableArray arrayWithArray:self.friends]; // *** when you go back to edit screen, load the array on that vc
    }

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friends count];
}

#pragma mark - Table view delegate source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // ***** get PFUser object from friends array for each row
    PFUser *friendSelected = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = [friendSelected username];

    
    return cell;
}




@end
