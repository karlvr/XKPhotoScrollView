//
//  XKFillModeExampleViewController.m
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 18/07/15.
//  Copyright (c) 2015 Karl von Randow. All rights reserved.
//

#import "XKFillModeExampleViewController.h"

@import XKPhotoScrollView;

@interface XKFillModeExampleViewController () <XKPhotoScrollViewDataSource>

@property (weak, nonatomic) XKPhotoScrollView *photoScrollView;

@end

@implementation XKFillModeExampleViewController {
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.photoScrollView.fillMode = XKPhotoScrollViewFillModeAspectFill;
    self.photoScrollView.minimumZoomScale = 0.3;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
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
