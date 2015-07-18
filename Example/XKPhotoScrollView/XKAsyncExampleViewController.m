//
//  XKAsyncExampleViewController.m
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 18/07/15.
//  Copyright (c) 2015 Karl von Randow. All rights reserved.
//

#import "XKAsyncExampleViewController.h"

@import XKPhotoScrollView;

@interface XKAsyncExampleViewController () <XKPhotoScrollViewDelegate, XKPhotoScrollViewDataSource>

@property (weak, nonatomic) IBOutlet XKPhotoScrollView *photoScrollView;

@end

@implementation XKAsyncExampleViewController {
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
    /* Simulate loading this image, such as from the network */
    [self performSelector:@selector(fulfillImage:) withObject:indexPath afterDelay:1.0];
    
    /* Deliver a placeholder for the moment */
    UIActivityIndicatorView *placeholder = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [placeholder startAnimating];
    [photoScrollView setView:placeholder atIndexPath:indexPath placeholder:YES];
}

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView cancelRequestAtIndexPath:(NSIndexPath *)indexPath
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fulfillImage:) object:indexPath];
}

- (NSUInteger)photoScrollViewCols:(XKPhotoScrollView *)photoScrollView
{
    return _images.count;
}

#pragma mark - Private

- (void)fulfillImage:(NSIndexPath *)indexPath
{
    NSLog(@"Fulfilling image at %li", (long) indexPath.col);
    
    UIImage *image = _images[indexPath.col];
    UIImageView *view = [[UIImageView alloc] initWithImage:image];
    
    [self.photoScrollView setView:view atIndexPath:indexPath placeholder:NO];
}

@end
