//
//  XKPhotoScrollViewAnimatedTransitioning.h
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 17/07/15.
//  Copyright (c) 2015 Karl von Randow. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XKPhotoScrollView;

@interface XKPhotoScrollViewAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

- (XKPhotoScrollView *)photoScrollViewForViewController:(UIViewController *)viewController;

@end
