//
//  XKImageTransitionExampleViewController.m
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 22/07/15.
//  Copyright (c) 2015 Karl von Randow. All rights reserved.
//

#import "XKImageTransitionExampleViewController.h"

@import XKPhotoScrollView;

#import "XKDeviceRotationPhotoScrollViewController.h"

@interface XKImageTransitionExampleViewController () <XKPhotoScrollViewDataSource, XKPhotoScrollViewDelegate, UIViewControllerTransitioningDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@interface XKImageTransitionExampleAnimatedTransitioning : XKPhotoScrollViewAnimatedTransitioning

@end

@implementation XKImageTransitionExampleViewController {
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

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)viewDidLoad
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self.imageView addGestureRecognizer:tap];
    self.imageView.userInteractionEnabled = YES;
    
    self.imageView.image = _images[0];
}

#pragma mark - Actions

- (void)tap
{
    XKDeviceRotationPhotoScrollViewController *viewController = [XKDeviceRotationPhotoScrollViewController new];
    viewController.indexPath = [NSIndexPath indexPathForRow:0 inColumn:0];
    viewController.dataSource = self;
    viewController.delegate = self;
    //        viewController.dismissOnPortrait = YES;
    
    /* Use UIModalPresentationFullScreen modal presentation style so we don't need to use a UIPresentationController to remove
     the UINavigationController (and view controllers) from the window. We can't use this in XKTransitionExampleViewController
     as it causes the status bar to hide awkwardly if you are in landscape and presenting a view that supports landscape while
     the presenting view doesn't.
     */
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    viewController.transitioningDelegate = self;
    [self presentViewController:viewController animated:YES completion:NULL];
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
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [XKImageTransitionExampleAnimatedTransitioning new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [XKImageTransitionExampleAnimatedTransitioning new];
}

@end


@implementation XKImageTransitionExampleAnimatedTransitioning

- (UIView *)targetViewForViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[XKImageTransitionExampleViewController class]]) {
        return ((XKImageTransitionExampleViewController *)viewController).imageView;
    } else {
        return [super targetViewForViewController:viewController];
    }
}

@end
