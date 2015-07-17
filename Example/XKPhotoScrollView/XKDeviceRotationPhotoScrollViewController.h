//
//  XKDeviceRotationPhotoScrollViewController.h
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 17/07/15.
//  Copyright (c) 2015 Karl von Randow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XKPhotoScrollViewDelegate;
@protocol XKPhotoScrollViewDataSource;
@class XKPhotoScrollView;

/** A view controller that creates its own photo scroll view, without a nib, and configures it as per the properties on this class. */
@interface XKDeviceRotationPhotoScrollViewController : UIViewController

@property (weak, nonatomic) XKPhotoScrollView *photoScrollView;
@property (weak, nonatomic) id<XKPhotoScrollViewDelegate> delegate;
@property (weak, nonatomic) id<XKPhotoScrollViewDataSource> dataSource;

@property (strong, nonatomic) NSIndexPath *indexPath;

@property (nonatomic) BOOL dismissOnPortrait;

@end
