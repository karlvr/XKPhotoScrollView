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
@property (nonatomic, assign) float scale;
@property (nonatomic, assign) float baseScale;
@property (nonatomic, assign) unsigned int row, col;
@property (nonatomic, assign) BOOL placeholder;

@end

@protocol XKPhotoScrollViewDataSource

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView requestViewAtRow:(unsigned int)row col:(unsigned int)col;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView cancelRequestAtRow:(unsigned int)row col:(unsigned int)col;
- (unsigned int)photoScrollViewRows:(XKPhotoScrollView *)photoScrollView;
- (unsigned int)photoScrollViewCols:(XKPhotoScrollView *)photoScrollView;

@end

@protocol XKPhotoScrollViewDelegate <NSObject>

@optional

- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didTapView:(UIView *)view atPoint:(CGPoint)pt atRow:(unsigned int)row atCol:(unsigned int)col;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didLongPressView:(UIView *)view atPoint:(CGPoint)pt atRow:(unsigned int)row atCol:(unsigned int)col;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didTouchView:(UIView *)view withTouches:(NSSet *)touches atRow:(unsigned int)row atCol:(unsigned int)col;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didDragView:(UIView *)view atRow:(unsigned int)row atCol:(unsigned int)col;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didUpdateTransformationForView:(UIView *)view withState:(XKPhotoScrollViewViewState *)state;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didZoomView:(UIView *)view atRow:(unsigned int)row atCol:(unsigned int)col;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didPinchDismissView:(UIView *)view atRow:(unsigned int)row atCol:(unsigned int)col;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didRotateTo:(float)rotation;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didChangeToRow:(unsigned int)row col:(unsigned int)col;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didSetCurrentView:(UIView *)view withState:(XKPhotoScrollViewViewState *)state;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView isStabilizing:(UIView *)view;
- (void)photoScrollView:(XKPhotoScrollView *)photoScrollView didStabilizeView:(UIView *)view;

@end

@interface XKPhotoScrollView : UIView

- (void)reloadData;
- (void)setView:(UIView *)view atRow:(unsigned int)row col:(unsigned int)col placeholder:(BOOL)placeholder;
- (void)setViewOnMainThread:(UIView *)view atRow:(unsigned int)row col:(unsigned int)col placeholder:(BOOL)placeholder;
- (BOOL)wantsViewAtRow:(unsigned int)row col:(unsigned int)col;
- (void)setViewScale:(float)scale;
- (void)setCurrentRow:(unsigned int)row col:(unsigned int)col;
- (void)setCurrentRow:(unsigned int)aRow col:(unsigned int)aCol animated:(BOOL)animated;
- (void)notifyDeviceOrientationDidChange:(UIDeviceOrientation)orientation animated:(BOOL)animated;

@property (weak, nonatomic) id<XKPhotoScrollViewDataSource> dataSource;
@property (weak, nonatomic) id<XKPhotoScrollViewDelegate> delegate;
@property (assign, nonatomic) BOOL bouncesZoom;
@property (assign, nonatomic) BOOL alwaysBounceScroll;
@property (assign, nonatomic) float maximumZoomScale;
@property (assign, nonatomic) float minimumZoomScale;
@property (assign, nonatomic) float maximumBaseScale;
@property (assign, nonatomic) float minimumDrag;
@property (readonly, nonatomic) unsigned int col;
@property (readonly, nonatomic) unsigned int row;
@property (readonly, nonatomic) int rotation;
@property (readonly, nonatomic) BOOL touching;
@property (assign, nonatomic) float viewScale;
@property (readonly, nonatomic) float baseScale;
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
