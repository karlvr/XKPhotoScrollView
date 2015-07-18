//
//  XKPhotoScrollViewAnimatedTransitioning.m
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 17/07/15.
//  Copyright (c) 2015 Karl von Randow. All rights reserved.
//

#import "XKPhotoScrollViewAnimatedTransitioning.h"

#import "XKPhotoScrollView.h"

@interface UIViewController (WithPhotoScrollView)

- (XKPhotoScrollView *)photoScrollView;

@end

@implementation XKPhotoScrollViewAnimatedTransitioning

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController * const to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController * const from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView * const fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    UIView * const toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    toView.alpha = 0.0;
    toView.frame = [transitionContext finalFrameForViewController:to];
    [transitionContext.containerView addSubview:toView];
    [toView layoutIfNeeded]; /* Force layout so views are positioned correctly for animation calculations below */
    
    XKPhotoScrollView * const toPhotoScrollView = [self photoScrollViewForViewController:to];
    XKPhotoScrollView * const fromPhotoScrollView = [self photoScrollViewForViewController:from];
    
    toPhotoScrollView.currentIndexPath = fromPhotoScrollView.currentIndexPath;
    
    UIImageView * const fromImageView = (UIImageView *)fromPhotoScrollView.currentView;
    fromImageView.alpha = 0.0;
    
    UIImageView * const animatingImageView = [[UIImageView alloc] initWithImage:fromImageView.image];
    animatingImageView.bounds = fromImageView.bounds;
    animatingImageView.center = [transitionContext.containerView convertPoint:fromImageView.center fromView:fromImageView.superview];
    
    /* Calculate initial transform (rotation) on the animating image view */
    CGAffineTransform containerViewTransform = transitionContext.containerView.transform;
    CGAffineTransform fromViewTransform = fromView.transform;
    CGAffineTransform result = fromViewTransform;
    result = CGAffineTransformConcat(result, CGAffineTransformInvert(containerViewTransform));
    result = CGAffineTransformConcat(result, fromImageView.transform);
    animatingImageView.transform = result;
    
    [transitionContext.containerView addSubview:animatingImageView];
    
    UIView * const toImageView = toPhotoScrollView.currentView;
    toImageView.alpha = 0.0;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        CGPoint animationDestination = [transitionContext.containerView convertPoint:toImageView.center fromView:toImageView.superview];
        animatingImageView.center = animationDestination;
        animatingImageView.bounds = toImageView.bounds;
        animatingImageView.transform = CGAffineTransformConcat(toImageView.transform, toPhotoScrollView.contentViewTransform);
        
        toView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [fromView removeFromSuperview];
        
        fromImageView.alpha = 1.0;
        toImageView.alpha = 1.0;
        [animatingImageView removeFromSuperview];
        
        [transitionContext completeTransition:finished];
    }];
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

- (XKPhotoScrollView *)photoScrollViewForViewController:(UIViewController *)viewController
{
    if ([viewController respondsToSelector:@selector(photoScrollView)]) {
        return (XKPhotoScrollView *) [viewController performSelector:@selector(photoScrollView)];
    } else if ([viewController isKindOfClass:[UINavigationController class]]) {
        return [self photoScrollViewForViewController:((UINavigationController *)viewController).topViewController];
    } else {
        NSLog(@"Can't find photoScrollView from %@", viewController);
        abort();
    }
}

@end
