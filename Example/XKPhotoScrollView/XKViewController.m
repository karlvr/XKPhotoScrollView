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

#pragma mark - Private

- (UIView *)viewForImageNamed:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *view = [[UIImageView alloc] initWithImage:image];
    return view;
}

#pragma mark - XKPhotoScrollView

#pragma mark XKPhotoScrollViewDataSource

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView requestViewAtRow:(unsigned int)row col:(unsigned int)col
{
    UIView *view = _views[col];
    NSLog(@"VIEW %@", view);
    
    [photoScrollView setView:view atRow:0 col:col placeholder:NO];
}

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView cancelRequestAtRow:(unsigned int)row col:(unsigned int)col
{
    
}

- (unsigned int)photoScrollViewRows:(XKPhotoScrollView *)photoScrollView
{
    return 1;
}

- (unsigned int)photoScrollViewCols:(XKPhotoScrollView *)photoScrollView
{
    return _views.count;
}

#pragma mark XKPhotoScrollViewDelegate



@end
