//
//  XKPhotoScrollView.h
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 2/08/08.
//  Copyright 2008 XK72 Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XKPhotoScrollViewViewType) {
	XKPhotoScrollViewViewTypeMain = 1,
	XKPhotoScrollViewViewTypeReveal,
};

typedef NS_ENUM(NSInteger, XKPhotoScrollViewAnimationType) {
	XKPhotoScrollViewAnimationTypeFade,
	XKPhotoScrollViewAnimationTypeSlide
};

@class XKPhotoScrollView;

@interface XKPhotoScrollViewViewState : NSObject <NSCopying>

@property (nonatomic, strong) UIView *view;

/** The current scale of the view, relative to the baseScale. This applies when the view is zoomed by the user. */
@property (nonatomic, assign) CGFloat scale;

/** The baseScale of the view is the scale applied to the view in order to fit it to the photo scroll view. It is governed by the photo scroll view's maximumBaseScale. */
@property (nonatomic, assign) CGFloat baseScale;

/** The row and column that this view state represents */
@property (nonatomic, assign) NSUInteger row, col;

/** Whether this view is a placeholder, that is expected to be replaced by the real view later. */
@property (nonatomic, assign) BOOL placeholder;

@end

@protocol XKPhotoScrollViewDataSource

/** Called when the photo scroll view wants the data source to provide a view for the given index path. */
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView requestViewAtRow:(NSUInteger)row col:(NSUInteger)col;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView cancelRequestAtRow:(NSUInteger)row col:(NSUInteger)col;
- (NSUInteger)photoScrollViewRows:(XKPhotoScrollView *)photoScrollView;
- (NSUInteger)photoScrollViewCols:(XKPhotoScrollView *)photoScrollView;

@end

@protocol XKPhotoScrollViewDelegate <NSObject>

@optional

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didTapView:(UIView *)view atPoint:(CGPoint)pt atRow:(NSUInteger)row atCol:(NSUInteger)col;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didLongPressView:(UIView *)view atPoint:(CGPoint)pt atRow:(NSUInteger)row atCol:(NSUInteger)col;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didTouchView:(UIView *)view withTouches:(NSSet *)touches atRow:(NSUInteger)row atCol:(NSUInteger)col;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didDragView:(UIView *)view atRow:(NSUInteger)row atCol:(NSUInteger)col;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didUpdateTransformationForView:(UIView *)view withState:(XKPhotoScrollViewViewState *)state;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didZoomView:(UIView *)view atRow:(NSUInteger)row atCol:(NSUInteger)col;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didPinchDismissView:(UIView *)view atRow:(NSUInteger)row atCol:(NSUInteger)col;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didRotateTo:(CGFloat)rotation;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didChangeToRow:(NSUInteger)row col:(NSUInteger)col;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didSetCurrentView:(UIView *)view withState:(XKPhotoScrollViewViewState *)state;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView isStabilizing:(UIView *)view;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didStabilizeView:(UIView *)view;

@end

@interface XKPhotoScrollView : UIView

- (void)reloadData;
- (void)setView:(UIView *)view atRow:(NSUInteger)row col:(NSUInteger)col placeholder:(BOOL)placeholder;
- (void)setViewOnMainThread:(UIView *)view atRow:(NSUInteger)row col:(NSUInteger)col placeholder:(BOOL)placeholder;
- (BOOL)wantsViewAtRow:(NSUInteger)row col:(NSUInteger)col;
- (void)setViewScale:(CGFloat)scale;
- (void)setCurrentRow:(NSUInteger)row col:(NSUInteger)col;
- (void)setCurrentRow:(NSUInteger)aRow col:(NSUInteger)aCol animated:(BOOL)animated;
- (void)notifyDeviceOrientationDidChange:(UIDeviceOrientation)orientation animated:(BOOL)animated;

@property (weak, nonatomic) IBOutlet id<XKPhotoScrollViewDataSource> dataSource;
@property (weak, nonatomic) IBOutlet id<XKPhotoScrollViewDelegate> delegate;
@property (assign, nonatomic) BOOL bouncesZoom;
@property (assign, nonatomic) BOOL alwaysBounceScroll;

/** The maximum scale factor to apply when zooming, relative to the base scale of the view. Default 3.0, meaning the user can zoom the view up to 3x of the base scale */
@property (assign, nonatomic) CGFloat maximumZoomScale;

/** The minimum scale factor to apply when zooming, relative to the base scale of the view. Default 1.0, meaning the user cannot shrink the view. */
@property (assign, nonatomic) CGFloat minimumZoomScale;

/** The maximum scale factor to apply to views in order to make them fit the available bounds. Default 1.0, meaning don't enlarge a view to make it fit. */
@property (assign, nonatomic) CGFloat maximumBaseScale;

@property (assign, nonatomic) CGFloat minimumDrag;
@property (readonly, nonatomic) NSUInteger col;
@property (readonly, nonatomic) NSUInteger row;
@property (readonly, nonatomic) int rotation;
@property (readonly, nonatomic) BOOL touching;
@property (assign, nonatomic) CGFloat viewScale;
@property (readonly, nonatomic) CGFloat baseScale;
@property (assign, nonatomic) UIEdgeInsets insets;
@property (assign, nonatomic) UIEdgeInsets baseInsets;
@property (assign, nonatomic) CGPoint viewOffset;
@property (readonly, nonatomic) CGRect viewFrame;
@property (weak, readonly, nonatomic) UIView *currentView;
@property (assign, nonatomic) XKPhotoScrollViewAnimationType animationType;
@property (readonly, copy, nonatomic) XKPhotoScrollViewViewState *currentViewState;
@property (assign, nonatomic) NSTimeInterval minimumLongPressDuration;
@end

@interface XKPhotoScrollView (ExtraForExperts)

- (void)configureView:(XKPhotoScrollViewViewState *)viewState andInitialise:(BOOL)andInitialise;

@end

@interface XKPhotoScrollViewGestureRecognizer : UIGestureRecognizer

@property (weak, nonatomic) XKPhotoScrollView *photoScrollView;

@end
