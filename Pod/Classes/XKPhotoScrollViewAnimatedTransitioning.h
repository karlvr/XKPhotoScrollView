//
//  XKPhotoScrollViewAnimatedTransitioning.h
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 17/07/15.
//  Copyright (c) 2015 Karl von Randow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XKPhotoScrollViewAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

/** Returns the view to use as the target view of the transition for the given
    view controller. This view should either be an XKPhotoScrollView or a UIImageView.
 */
- (UIView *)targetViewForViewController:(UIViewController *)viewController;

@end
