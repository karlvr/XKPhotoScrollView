//
//  XKRotateTransitionExampleViewController.m
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 17/07/15.
//  Copyright (c) 2015 Karl von Randow. All rights reserved.
//

#import "XKRotateTransitionExampleViewController.h"

#import "XKTransitionExampleViewController_Internal.h"

@interface XKRotateTransitionExampleViewController ()

@end

@implementation XKRotateTransitionExampleViewController

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if (size.width > size.height) {
            [self goFullScreen];
        } else {
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
    }];
}

@end
