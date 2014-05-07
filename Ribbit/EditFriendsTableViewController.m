//
//  EditFriendsTableViewController.m
//  Ribbit
//
//  Created by Robert Figueras on 4/30/14.
//  Copyright (c) 2014 AppSpaceship. All rights reserved.
//

#import "EditFriendsTableViewController.h"

@interface EditFriendsTableViewController ()

@end

@implementation EditFriendsTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PFQuery *query = [PFUser query]; // *** set a query against all the users and sort
    [query orderByAscending:@"username"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) { // *** run query in background
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        else{
            self.allUsers = objects; // *** put all objects into array
            [self.tableView reloadData];
        }
    }];

    self.currentUser = [PFUser currentUser];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.allUsers count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    
    if ([self isFriend:user]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO]; // *** so that the selection highlight goes away
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
    PFRelation *friendsRelation = [self.currentUser relationForKey:@"friendsRelation"];

    if ([self isFriend:user]) {
        
        // remove checkmark
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        // remove from the array of friends
        for (PFUser *friend in self.friends) {
            
            if ([friend.objectId isEqualToString:user.objectId]){
                [self.friends removeObject:friend];
                break;
            }
            
        }
        
        // remove from the backend
        [friendsRelation removeObject:user];


        
    }else{
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        [self.friends addObject:user];
        
        // add selected user to relation
        [friendsRelation addObject:user];
        
    }
    
    //  save to Parse backend
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@",error, error.userInfo);
        }
    }];
    
}

#pragma mark - Helper methods

- (BOOL) isFriend:(PFUser*)user{
    
    for (PFUser *friend in self.friends) {
        
        if ([friend.objectId isEqualToString:user.objectId]){
            return YES;
        }
        
    }
    return NO;
}

@end
