//
//  CameraViewController.h
//  Ribbit
//
//  Created by Robert Figueras on 5/1/14.
//  Copyright (c) 2014 AppSpaceship. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface CameraViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *videoFilePath;

@property (nonatomic,strong) PFRelation* friendsRelation;
@property (nonatomic,strong) NSArray* friends;
@property (nonatomic,strong) NSMutableArray* recipients;

- (IBAction)cancel:(id)sender;
- (IBAction)send:(id)sender;

- (void) uploadMessage;
- (UIImage *)resizeImge: (UIImage *)image toWidth:(float)width andHeight:(float)height;

@end
