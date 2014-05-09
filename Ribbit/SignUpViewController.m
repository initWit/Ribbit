//
//  SignUpViewController.m
//  Ribbit
//
//  Created by Robert Figueras on 4/30/14.
//  Copyright (c) 2014 AppSpaceship. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>


@interface SignUpViewController ()

@end

@implementation SignUpViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if ([UIScreen mainScreen].bounds.size.height == 568) {
        self.backgroundImageView.image = [UIImage imageNamed:@"loginBackground-568h"];
    }

}


- (IBAction)signUp:(id)sender {
    
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username length] == 0 || [password length] == 0 || [email length] == 0) {
        UIAlertView *myAlert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"Make sure you enter all information!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [myAlert show];
    }
    else{
        PFUser *newUser = [PFUser user];
        newUser.username = username;
        newUser.password = password;
        newUser.email = email;
        
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Sorry!" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            }
            else{
                [self.navigationController popToRootViewControllerAnimated:YES];
            
            }
        }];
    
    
    }
    
}

- (IBAction)dismiss:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
    
}
@end
