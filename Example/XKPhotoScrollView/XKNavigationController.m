//
//  XKNavigationViewController.m
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 17/07/15.
//  Copyright (c) 2015 Karl von Randow. All rights reserved.
//

#import "XKNavigationController.h"

@implementation XKNavigationController

- (NSUInteger)supportedInterfaceOrientations
{
    /* Respect the supportedInterfaceOrientations of the topmost view controller */
    UIViewController *viewController = self.topViewController;
    return [viewController supportedInterfaceOrientations];
}

@end
