//
//  XKSimpleExampleViewController.m
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 17/07/15.
//  Copyright (c) 2015 Karl von Randow. All rights reserved.
//

#import "XKSimpleExampleViewController.h"

#import <XKPhotoScrollView/XKPhotoScrollView.h>

@interface XKSimpleExampleViewController() <XKPhotoScrollViewDataSource, XKPhotoScrollViewDelegate>

@end

@implementation XKSimpleExampleViewController {
    NSArray *_views;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        NSMutableArray *views = [NSMutableArray array];
        [views addObject:[UIImage imageNamed:@"photo1.jpg"]];
        [views addObject:[UIImage imageNamed:@"photo2.jpg"]];
        [views addObject:[UIImage imageNamed:@"photo3.jpg"]];
        [views addObject:[UIImage imageNamed:@"photo4.jpg"]];
        [views addObject:[UIImage imageNamed:@"photo5.jpg"]];
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

#pragma mark - XKPhotoScrollView

#pragma mark XKPhotoScrollViewDataSource

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView requestViewAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *image = _views[(indexPath.row + indexPath.col) % _views.count];
    UIImageView *view = [[UIImageView alloc] initWithImage:image];
    
    [photoScrollView setView:view atIndexPath:indexPath placeholder:NO];
}

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView cancelRequestAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSUInteger)photoScrollViewRows:(XKPhotoScrollView *)photoScrollView
{
    return 3;
}

- (NSUInteger)photoScrollViewCols:(XKPhotoScrollView *)photoScrollView
{
    return _views.count;
}

#pragma mark XKPhotoScrollViewDelegate

@end
