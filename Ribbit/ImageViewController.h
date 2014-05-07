//
//  ImageViewController.h
//  Ribbit
//
//  Created by Robert Figueras on 5/5/14.
//  Copyright (c) 2014 AppSpaceship. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ImageViewController : UIViewController

@property (nonatomic,strong) PFObject *message;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end
