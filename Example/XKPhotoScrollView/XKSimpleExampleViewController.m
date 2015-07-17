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
    return UIInterfaceOrientationMaskAll;
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

@end
