//
//  XKTransitionExampleViewController.m
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 17/07/15.
//  Copyright (c) 2015 Karl von Randow. All rights reserved.
//

#import "XKTransitionExampleViewController.h"

#import <XKPhotoScrollView/XKPhotoScrollView.h>

@interface XKTransitionFullScreenViewController : UIViewController <XKPhotoScrollViewDelegate>

@property (strong, nonatomic) id<XKPhotoScrollViewDataSource> dataSource;
@property (strong, nonatomic) id<XKPhotoScrollViewDelegate> delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (weak, nonatomic) XKPhotoScrollView *photoScrollView;

@end

@interface XKTransitionFullScreenAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>

@end

@interface XKTransitionPresentationController : UIPresentationController

@end

@interface XKTransitionExampleViewController() <XKPhotoScrollViewDataSource, XKPhotoScrollViewDelegate, UIViewControllerTransitioningDelegate>

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* Don't allow zooming on the small photo scroll view */
    _photoScrollView.maximumZoomScale = _photoScrollView.minimumZoomScale;
    _photoScrollView.bouncesZoom = NO;
}

#pragma mark - XKPhotoScrollView

#pragma mark XKPhotoScrollViewDataSource

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView requestViewAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *image = _images[indexPath.col];
    UIImageView *view = [[UIImageView alloc] initWithImage:image];
    
    [photoScrollView setView:view atIndexPath:indexPath placeholder:NO];
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
    
    XKTransitionFullScreenViewController *fullScreen = [XKTransitionFullScreenViewController new];
    fullScreen.dataSource = self;
    fullScreen.delegate = fullScreen;
    fullScreen.indexPath = self.photoScrollView.currentIndexPath;
    
    fullScreen.modalPresentationStyle = UIModalPresentationCustom;
    fullScreen.transitioningDelegate = self;
    [self presentViewController:fullScreen animated:YES completion:NULL];
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

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    return [[XKTransitionPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

@end

@implementation XKTransitionPresentationController

- (BOOL)shouldRemovePresentersView
{
    /* We need to remove the presenter's view in order to take over control of the supported interface orientations */
    return YES;
}

@end

#pragma mark -

@implementation XKTransitionFullScreenViewController

- (void)loadView
{
    XKPhotoScrollView *photoScrollView = [XKPhotoScrollView new];
    photoScrollView.currentIndexPath = self.indexPath;
    photoScrollView.dataSource = self.dataSource;
    photoScrollView.delegate = self.delegate;
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
        animatingImageView.transform = CGAffineTransformConcat(toImageView.transform, toPhotoScrollView.transform);
        
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
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        return [self photoScrollViewForViewController:((UINavigationController *)viewController).topViewController];
    } else if ([viewController respondsToSelector:@selector(photoScrollView)]) {
        return (XKPhotoScrollView *) [viewController performSelector:@selector(photoScrollView)];
    } else {
        NSLog(@"Can't find photoScrollView from %@", viewController);
        abort();
    }
}

@end
