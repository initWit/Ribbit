//
//  CameraViewController.m
//  Ribbit
//
//  Created by Robert Figueras on 5/1/14.
//  Copyright (c) 2014 AppSpaceship. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface CameraViewController ()

@end

@implementation CameraViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.recipients = [[NSMutableArray alloc]init];

}

- (void) viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];

    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"]; // *** get the relation for the current user

    PFQuery *query = [self.friendsRelation query]; // *** add a query to the relation
    [query orderByAscending:@"username"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) { // *** run the query in background
        if (error) {
            NSLog(@"error %@ %@", error, error.userInfo);
        }
        else {
            self.friends = objects; // *** get the objects returned from the query and load into array property
            [self.tableView reloadData]; // *** reload the table data
        }
    }];

    if (self.image == nil && self.videoFilePath.length == 0) {

        self.imagePicker = [[UIImagePickerController alloc]init];
        self.imagePicker.delegate = self;
        self.imagePicker.allowsEditing = NO;
        self.imagePicker.videoMaximumDuration = 10; // *** limit the lenghth of the videos (10 sec)
        
        // *** check to see if a camera source is available; if not, show the photo library instead ***/
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        self.imagePicker.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:self.imagePicker.sourceType];
        
        [self presentViewController:self.imagePicker animated:NO completion:nil];

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
    
    if([self.recipients containsObject:friendSelected.objectId]){ // *** if user in the cell is in the recipients array
        cell.accessoryType = UITableViewCellAccessoryCheckmark; // *** make sure it is checked when SCROLLING (do to reuse)
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone; // *** else remove checkmark when SCROLLING (do to reuse)
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [self.tableView deselectRowAtIndexPath:indexPath animated:NO]; // *** so that the selection highlight goes away

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    PFUser *user = [self.friends objectAtIndex:indexPath.row]; // get the selected friend and create user object
    
    if(cell.accessoryType == UITableViewCellAccessoryNone){ // *** if there is no check mark
        cell.accessoryType = UITableViewCellAccessoryCheckmark; // *** then add a check mark
        [self.recipients addObject:user.objectId]; // *** add the friend to the recipients array
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone; // *** if there is a check mark, then remove it
        [self.recipients removeObject:user.objectId];
    }
    
}


#pragma mark - Image Picker Controller Delegate

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    // *** override method to display a different view controller ***/
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    // *** self.tabBarController will access the nearest tabBarController from any view controller ***/
    // *** this will display the first tab's viewcontroller right when the cancel button is clicked ***/

    [self.tabBarController setSelectedIndex:0];

}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if([mediaType isEqualToString:(NSString *)kUTTypeImage]){ // *** if the media is a photo (and not a video)
        
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage]; // *** then get the image
        
        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera){ // *** if they used the camera (and not existing)
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil); // *** then save to album
        }
        
        [self dismissViewControllerAnimated:YES completion:nil]; // *** since you are overriding the method, need to dismiss modal controller
        
    } else { // *** if the media is a video
        
        NSURL *imagePickerURL = [info objectForKey:UIImagePickerControllerMediaURL]; // *** find the video path
        self.videoFilePath = [imagePickerURL path];
        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera){ // *** if they used the camera (and not existing)
            
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoFilePath)){ // *** and if the video is compatible
                UISaveVideoAtPathToSavedPhotosAlbum(self.videoFilePath, nil, nil, nil); // *** then save the video
            }
        }
        
        [self dismissViewControllerAnimated:YES completion:nil]; // *** since you are overriding the method, need to dismiss modal controller
    }
}

# pragma mark - IBActions



- (IBAction)cancel:(id)sender {

    [self reset];

    [self.tabBarController setSelectedIndex:0];

}

- (IBAction)send:(id)sender {

    if (self.image == nil && [self.videoFilePath length]==0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Try Again!" message:@"Add media" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];

        [alertView show];
        [self presentViewController:self.imagePicker animated:NO completion:nil];

    }else{
        [self uploadMessage];
        [self.tabBarController setSelectedIndex:0];
    }
}

# pragma mark - Helper methods

- (void) uploadMessage{

    NSData *fileData;
    NSString *fileName;
    NSString *fileType;


    if (self.image != nil) {
        UIImage *newImage = [self resizeImge:self.image toWidth:320.0f andHeight:480.0f];

        fileData = UIImagePNGRepresentation(newImage);
        fileName = @"image.png";
        fileType = @"image";

    }else{

        fileData = [NSData dataWithContentsOfFile:self.videoFilePath];
        fileName = @"video.mov";
        fileType = @"video";

    }

    PFFile *file = [PFFile fileWithName:fileName data:fileData];

    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        //TODO: DELETE THIS!! This is to test the error message
        //error = [[NSError alloc]init];

        if(error){

            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error Occurred" message:@"Try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];

            [alertView show];
            [self presentViewController:self.imagePicker animated:NO completion:nil];

        }
        else {

            PFObject *message = [PFObject objectWithClassName:@"Messages"];
            [message setObject:file forKey:@"file"];
            [message setObject:fileType forKey:@"fileType"];
            [message setObject:self.recipients forKey:@"recipientIds"];
            [message setObject:[[PFUser currentUser]objectId] forKey:@"senderId"];
            [message setObject:[[PFUser currentUser]username] forKey:@"senderName"];
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error Occurred" message:@"Try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];

                    [alertView show];
                    [self presentViewController:self.imagePicker animated:NO completion:nil];
                }
                 else{
                    // Awesome!
                     [self reset];
                 }

            }];

        }
    }];

}

- (void)reset {
    self.image = nil;
    self.videoFilePath = nil;
    [self.recipients removeAllObjects];
}

- (UIImage *)resizeImge:(UIImage *)image toWidth:(float)width andHeight:(float)height{

    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);

    UIGraphicsBeginImageContext(newSize);
    [self.image drawInRect:newRectangle];

    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return resizedImage;

}


@end
