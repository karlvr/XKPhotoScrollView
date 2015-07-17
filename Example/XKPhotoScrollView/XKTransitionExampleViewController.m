//
//  XKTransitionExampleViewController.m
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 17/07/15.
//  Copyright (c) 2015 Karl von Randow. All rights reserved.
//

#import "XKTransitionExampleViewController.h"

#import <XKPhotoScrollView/XKPhotoScrollView.h>

@protocol XKHasPhotoScrollView <NSObject>

- (XKPhotoScrollView *)photoScrollView;

@end

@interface XKTransitionFullScreenViewController : UIViewController <XKPhotoScrollViewDelegate, XKHasPhotoScrollView>

@property (strong, nonatomic) id<XKPhotoScrollViewDataSource> dataSource;
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (weak, nonatomic) XKPhotoScrollView *photoScrollView;

@end

@interface XKTransitionFullScreenAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>

@end

@interface XKTransitionExampleViewController() <XKPhotoScrollViewDataSource, XKPhotoScrollViewDelegate, XKHasPhotoScrollView, UIViewControllerTransitioningDelegate>

@end

@implementation XKTransitionExampleViewController {
    NSArray *_images;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        NSMutableArray *images = [NSMutableArray array];
        [images addObject:[UIImage imageNamed:@"photo1.jpg"]];
        [images addObject:[UIImage imageNamed:@"photo2.jpg"]];
        [images addObject:[UIImage imageNamed:@"photo3.jpg"]];
        [images addObject:[UIImage imageNamed:@"photo4.jpg"]];
        [images addObject:[UIImage imageNamed:@"photo5.jpg"]];
        _images = [NSArray arrayWithArray:images];
    }
    return self;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - XKPhotoScrollView

#pragma mark XKPhotoScrollViewDataSource

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView requestViewAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *image = _images[indexPath.col];
    UIImageView *view = [[UIImageView alloc] initWithImage:image];
    
    [photoScrollView setView:view atIndexPath:indexPath placeholder:NO];
}

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView cancelRequestAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSUInteger)photoScrollViewRows:(XKPhotoScrollView *)photoScrollView
{
    return 1;
}

- (NSUInteger)photoScrollViewCols:(XKPhotoScrollView *)photoScrollView
{
    return _images.count;
}

#pragma mark XKPhotoScrollViewDelegate

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didTapView:(UIView *)view atPoint:(CGPoint)pt atIndexPath:(NSIndexPath *)indexPath
{
    [self goFullScreen];
}

#pragma mark - Internal

- (void)goFullScreen
{
    if (self.presentedViewController) {
        /* Prevent multiple simultaneous presentations */
        return;
    }
    
    XKTransitionFullScreenViewController *manual = [XKTransitionFullScreenViewController new];
    manual.dataSource = self;
    manual.indexPath = self.photoScrollView.currentIndexPath;
    
    manual.modalPresentationStyle = UIModalPresentationFullScreen; /* If set to UIModalPresentationCustom we don't get views for the UINavigationController */
    manual.transitioningDelegate = self;
    [self presentViewController:manual animated:YES completion:NULL];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [XKTransitionFullScreenAnimatedTransition new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [XKTransitionFullScreenAnimatedTransition new];
}

@end

#pragma mark -

@implementation XKTransitionFullScreenViewController

- (void)loadView
{
    XKPhotoScrollView *photoScrollView = [XKPhotoScrollView new];
    photoScrollView.currentIndexPath = self.indexPath;
    photoScrollView.dataSource = self.dataSource;
    photoScrollView.delegate = self;
    photoScrollView.backgroundColor = [UIColor blackColor];
    
    self.photoScrollView = photoScrollView;
    self.view = photoScrollView;
}

/** Allow the full-screen view to rotate upside down */
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - XKPhotoScrollView

#pragma mark XKPhotoScrollViewDelegate

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didTapView:(UIView *)view atPoint:(CGPoint)pt atIndexPath:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didPinchDismissView:(UIView *)view atIndexPath:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end

#pragma mark -

@implementation XKTransitionFullScreenAnimatedTransition

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
    
    UIImageView * const sourceView = (UIImageView *)fromPhotoScrollView.currentView;
    sourceView.alpha = 0.0;
    
    UIImageView * const animatingView = [[UIImageView alloc] initWithImage:sourceView.image];
    animatingView.bounds = sourceView.bounds;
    animatingView.center = [transitionContext.containerView convertPoint:sourceView.center fromView:sourceView.superview];
    
    /* Calculate initial transform (rotation) on the animating image view */
    CGAffineTransform containerViewTransform = transitionContext.containerView.transform;
    CGAffineTransform fromViewTransform = fromView.transform;
    CGAffineTransform result = fromViewTransform;
    result = CGAffineTransformConcat(result, CGAffineTransformInvert(containerViewTransform));
    result = CGAffineTransformConcat(result, sourceView.transform);
    animatingView.transform = result;
    
    [transitionContext.containerView addSubview:animatingView];
    
    UIView * const destView = toPhotoScrollView.currentView;
    destView.alpha = 0.0;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        CGPoint animationDestination = [transitionContext.containerView convertPoint:destView.center fromView:destView.superview];
        animatingView.center = animationDestination;
        animatingView.bounds = destView.bounds;
        animatingView.transform = destView.transform;
        
        toView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [fromView removeFromSuperview];
        
        sourceView.alpha = 1.0;
        destView.alpha = 1.0;
        [animatingView removeFromSuperview];
        
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
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        return [self photoScrollViewForViewController:((UINavigationController *)viewController).topViewController];
    } else if ([viewController conformsToProtocol:@protocol(XKHasPhotoScrollView)]) {
        return ((UIViewController<XKHasPhotoScrollView> *)viewController).photoScrollView;
    } else {
        NSLog(@"Can't find photoScrollView from %@", viewController);
        abort();
    }
}

@end
