//
//  XKViewController.m
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 07/16/2015.
//  Copyright (c) 2015 Karl von Randow. All rights reserved.
//

#import "XKViewController.h"

#import <XKPhotoScrollView/XKPhotoScrollView.h>

@interface XKViewController () <XKPhotoScrollViewDataSource, XKPhotoScrollViewDelegate>

@end

@implementation XKViewController {
    NSArray *_views;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        NSMutableArray *views = [NSMutableArray array];
        [views addObject:[self viewForImageNamed:@"photo1.jpg"]];
        [views addObject:[self viewForImageNamed:@"photo2.jpg"]];
        [views addObject:[self viewForImageNamed:@"photo3.jpg"]];
        [views addObject:[self viewForImageNamed:@"photo4.jpg"]];
        [views addObject:[self viewForImageNamed:@"photo5.jpg"]];
        _views = [NSArray arrayWithArray:views];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* Example - no zooming */
//    _photoScrollView.maximumZoomScale = _photoScrollView.minimumZoomScale;
//    _photoScrollView.bouncesZoom = NO;
}

#pragma mark - Private

- (UIView *)viewForImageNamed:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *view = [[UIImageView alloc] initWithImage:image];
    return view;
}

#pragma mark - XKPhotoScrollView

#pragma mark XKPhotoScrollViewDataSource

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView requestViewAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *view = _views[indexPath.col];
    
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
    return _views.count;
}

#pragma mark XKPhotoScrollViewDelegate



@end
