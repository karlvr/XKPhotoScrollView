//
//  XKTransitionExampleViewController.m
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 17/07/15.
//  Copyright (c) 2015 Karl von Randow. All rights reserved.
//

#import "XKTransitionExampleViewController.h"

#import <XKPhotoScrollView/XKPhotoScrollView.h>

@interface XKTransitionExampleViewController() <XKPhotoScrollViewDataSource, XKPhotoScrollViewDelegate>

/** Note that the constraints must be strong so we can deactivate and reactivate */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *nonFullScreenConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fullScreenConstraint;

@end

@implementation XKTransitionExampleViewController {
    NSArray *_images;
    BOOL _fullScreen;
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
    [self toggleFullScreen];
}

#pragma mark - Private

- (void)toggleFullScreen
{
    _fullScreen = !_fullScreen;
    
    [self.navigationController setNavigationBarHidden:_fullScreen animated:YES];
    
    if (_fullScreen) {
        _nonFullScreenConstraint.active = NO;
        _fullScreenConstraint.active = YES;
    } else {
        _fullScreenConstraint.active = NO;
        _nonFullScreenConstraint.active = YES;
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
