//
//  ImageViewController.m
//  Ribbit
//
//  Created by Robert Figueras on 5/5/14.
//  Copyright (c) 2014 AppSpaceship. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController



- (void)viewDidLoad
{
    [super viewDidLoad];

    PFFile *imageFile = [self.message objectForKey:@"file"];

    NSURL *imageFileURL = [[NSURL alloc]initWithString:imageFile.url];
    NSData *imageData = [NSData dataWithContentsOfURL:imageFileURL];

    self.imageView.image = [UIImage imageWithData:imageData];

    NSString *senderName = [self.message objectForKey:@"senderName"];
    NSString *tite = [NSString stringWithFormat:@"Sent from %@",senderName];
    self.navigationItem.title = tite;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([self respondsToSelector:@selector(timeout)]) {
        [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timeout) userInfo:nil repeats:NO];
    }
    else {
        NSLog(@"Error: Selector Missing!");
    }

}

#pragma mark - Helper methods

-(void) timeout {
    [self.navigationController popViewControllerAnimated:YES];
}





@end
