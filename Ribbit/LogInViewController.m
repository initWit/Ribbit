//
//  LogInViewController.m
//  Ribbit
//
//  Created by Robert Figueras on 4/30/14.
//  Copyright (c) 2014 AppSpaceship. All rights reserved.
//

#import "LogInViewController.h"
#import <Parse/Parse.h>

@interface LogInViewController ()

@end

@implementation LogInViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.navigationItem.hidesBackButton = YES;

    if ([UIScreen mainScreen].bounds.size.height == 568) {
        self.backgroundImageView.image = [UIImage imageNamed:@"loginBackground-568h"];
    }

// *** replaced by functionality in TPKeyboardAvoidingScrollView
//    self.usernameField.delegate = self;
//    self.passwordField.delegate = self;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES];

}

- (IBAction)login:(id)sender {
    
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username length] == 0 || [password length] == 0) {
        UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"Make sure you enter all information!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [myAlert show];
    }
    else {
    
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
           
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Sorry!" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            }
            else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            
        }];
    
    }

    
}

// *** replaced by functionality in TPKeyboardAvoidingScrollView

//#pragma mark - UITextField Delegate Methods
//
//- (BOOL) textFieldShouldReturn:(UITextField *)textField { // *** called when return key is pressed
//
//    [textField resignFirstResponder]; // *** this indirectly dismisses the keyboard (by resigning focus)
//    return YES;
//
//}


@end
