//
//  XKDeviceRotationModalExampleViewController.m
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 17/07/15.
//  Copyright (c) 2015 Karl von Randow. All rights reserved.
//

#import "XKDeviceRotationModalExampleViewController.h"

#import <XKPhotoScrollView/XKPhotoScrollView.h>

#import "XKDeviceRotationPhotoScrollViewController.h"
#import "XKPhotoScrollViewAnimatedTransitioning.h"

@interface XKDeviceRotationModalExampleViewController () <XKPhotoScrollViewDataSource, XKPhotoScrollViewDelegate, UIViewControllerTransitioningDelegate>

@property (weak, nonatomic) IBOutlet XKPhotoScrollView *photoScrollView;

@end

@implementation XKDeviceRotationModalExampleViewController {
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
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
        XKDeviceRotationPhotoScrollViewController *viewController = [XKDeviceRotationPhotoScrollViewController new];
        viewController.indexPath = self.photoScrollView.currentIndexPath;
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
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [XKPhotoScrollViewAnimatedTransitioning new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [XKPhotoScrollViewAnimatedTransitioning new];
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

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didPinchDismissView:(UIView *)view atIndexPath:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
