//
//  XKModalExampleViewController.m
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 17/07/15.
//  Copyright (c) 2015 Karl von Randow. All rights reserved.
//

#import "XKModalExampleViewController.h"

#import <XKPhotoScrollView/XKPhotoScrollView.h>

@interface XKModalExampleViewController () <XKPhotoScrollViewDataSource, XKPhotoScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation XKModalExampleViewController {
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _toolbar.alpha = 0.0;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Actions

- (IBAction)doClose:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Private

- (void)hideToolbar
{
    [UIView animateWithDuration:0.2 animations:^{
        _toolbar.alpha = 0.0;
    }];
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
    if (_toolbar.alpha == 1.0) {
        [self hideToolbar];
    } else {
        _toolbar.alpha = 1.0;
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideToolbar) object:nil];
        [self performSelector:@selector(hideToolbar) withObject:nil afterDelay:2];
    }
}

@end
