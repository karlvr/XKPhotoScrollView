//
//  XKRootViewController.m
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 17/07/15.
//  Copyright (c) 2015 Karl von Randow. All rights reserved.
//

#import "XKRootViewController.h"

@interface XKRootViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation XKRootViewController {
    NSArray *_viewControllers;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        
    }
    return self;
}

- (void)awakeFromNib
{
    NSMutableArray *viewControllers = [NSMutableArray array];
    [viewControllers addObject:[self.storyboard instantiateViewControllerWithIdentifier:@"simple"]];
    [viewControllers addObject:[self.storyboard instantiateViewControllerWithIdentifier:@"modal"]];
    [viewControllers addObject:[self.storyboard instantiateViewControllerWithIdentifier:@"multirow"]];
    [viewControllers addObject:[self.storyboard instantiateViewControllerWithIdentifier:@"transition"]];
    [viewControllers addObject:[self.storyboard instantiateViewControllerWithIdentifier:@"rotate"]];
    [viewControllers addObject:[self.storyboard instantiateViewControllerWithIdentifier:@"manual"]];
    [viewControllers addObject:[self.storyboard instantiateViewControllerWithIdentifier:@"devicerotation"]];
    [viewControllers addObject:[self.storyboard instantiateViewControllerWithIdentifier:@"devicerotationautolayout"]];
    [viewControllers addObject:[self.storyboard instantiateViewControllerWithIdentifier:@"rotatemodal"]];
    [viewControllers addObject:[self.storyboard instantiateViewControllerWithIdentifier:@"devicerotationmodal"]];
    _viewControllers = [NSArray arrayWithArray:viewControllers];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UITableView

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _viewControllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"item"];
    
    UIViewController *viewController = _viewControllers[indexPath.row];
    cell.textLabel.text = viewController.title;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = _viewControllers[indexPath.row];
    [self.navigationController pushViewController:viewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
