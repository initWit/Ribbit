//
//  InboxTableViewController.m
//  Ribbit
//
//  Created by Robert Figueras on 4/29/14.
//  Copyright (c) 2014 AppSpaceship. All rights reserved.
//

#import "InboxTableViewController.h"

#import "ImageViewController.h"

#import "MSCellAccessory.h"

@interface InboxTableViewController ()

@end

@implementation InboxTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.moviePlayer = [[MPMoviePlayerController alloc]init];

    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser) {
        NSLog(@"currentUser:%@",currentUser.username);
    }
    else {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }

}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:NO];


    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"recipientIds" equalTo:[[PFUser currentUser]objectId]];

    [query orderByDescending:@"createdAt"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        else{
            self.messages = objects;
            [self.tableView reloadData];

            NSLog(@"Retrieved %lu messages", (unsigned long)[self.messages count]);


        }
    }];

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
    return [self.messages count];
}


#pragma mark - Table view delegate source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    PFObject *message = [self.messages objectAtIndex:indexPath.row];
    cell.textLabel.text = [message objectForKey:@"senderName"];


    UIColor *disclosureColor = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1.0];

    cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:disclosureColor];


    NSString *fileType = [message objectForKey:@"fileType"];

    if ([fileType isEqualToString:@"image"]) {
        cell.imageView.image = [UIImage imageNamed:@"icon_image"];
    }
    else{
        cell.imageView.image = [UIImage imageNamed:@"icon_video"];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    self.selectedMessage = [self.messages objectAtIndex:indexPath.row];

    NSString *fileType = [self.selectedMessage objectForKey:@"fileType"];

    if ([fileType isEqualToString:@"image"]) { // *** if the selected message is an image
        [self performSegueWithIdentifier:@"showImage" sender:self]; // *** go to the imageViewController
    }
    else{
        // *** if the selected message is a video

        PFFile *videoFile = [self.selectedMessage objectForKey:@"file"]; // *** get the path to the video (on parse) and load it into moviePlayer
        NSURL *fileURL = [NSURL URLWithString:videoFile.url];
        self.moviePlayer.contentURL = fileURL;
        [self.moviePlayer prepareToPlay];

        // *** iOS 7 version to create a thumbnail when the movie is played
        AVAsset *videoThumbnail = [AVAsset assetWithURL:fileURL];
        [AVAssetImageGenerator assetImageGeneratorWithAsset:videoThumbnail];


        // *** add it to the view controller as a SubView to actually play the moviePlayer
        [self.view addSubview:self.moviePlayer.view];
        [self.moviePlayer setFullscreen:YES animated:YES];

    }

    // *** delete the media after it is viewed
    NSMutableArray * recipientIds = [NSMutableArray arrayWithArray:[self.selectedMessage objectForKey:@"recipientIds"]];

    NSLog(@"Recipients %@", recipientIds);

    if ([recipientIds count] == 1) { // *** if this is the last recipient
        [self.selectedMessage deleteInBackground]; // *** then delete the media
    }else{
        // *** if there are still other recipients, then just remove current user recipientId from recipientIds array
        [recipientIds removeObject:[[PFUser currentUser]objectId]];

        // *** save the change in Parse
        [self.selectedMessage setObject:recipientIds forKey:@"recipientIds"];
        [self.selectedMessage saveInBackground];
    }

}


- (IBAction)logout:(id)sender {
    
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogin" sender:self];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"showLogin"]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    }
    else if ([segue.identifier isEqualToString:@"showImage"]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        ImageViewController *imageViewController = (ImageViewController *)segue.destinationViewController;
        imageViewController.message = self.selectedMessage; // *** load the message info into the imageViewController
    }



}
@end
