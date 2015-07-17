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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Notifications

- (void)orientationDidChangeNotification:(NSNotification *)notification
{
    const UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    if (UIDeviceOrientationIsLandscape(orientation)) {
        [self goFullScreen];
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
//{
//    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
//    
//    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
//        if (size.width > size.height) {
//            [self goFullScreen];
//        } else {
//            [self dismissViewControllerAnimated:YES completion:NULL];
//        }
//    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
//        
//    }];
//}

@end
