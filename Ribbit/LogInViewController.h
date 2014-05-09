//
//  LogInViewController.h
//  Ribbit
//
//  Created by Robert Figueras on 4/30/14.
//  Copyright (c) 2014 AppSpaceship. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogInViewController : UIViewController// <UITextFieldDelegate> // *** replaced by functionality in TPKeyboardAvoidingScrollView


@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)login:(id)sender;

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end
