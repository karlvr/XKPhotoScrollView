//
//  XKPhotoScrollView.h
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 2/08/08.
//  Copyright 2008 XK72 Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum XKPhotoScrollViewViewType {
	XKPhotoScrollViewViewTypeMain = 1,
	XKPhotoScrollViewViewTypeReveal,
} XKPhotoScrollViewViewType;

typedef enum XKPhotoScrollViewAnimationType {
	XKPhotoScrollViewAnimationTypeFade,
	XKPhotoScrollViewAnimationTypeSlide
} XKPhotoScrollViewAnimationType;

@interface XKPhotoScrollViewViewState : NSObject <NSCopying>

@property (nonatomic, strong) UIView *view;
@property (nonatomic, assign) float scale;
@property (nonatomic, assign) float baseScale;
@property (nonatomic, assign) unsigned int row, col;
@property (nonatomic, assign) BOOL placeholder;

@end

@protocol XKPhotoScrollViewDataSource

- (void)photoScrollView:(id)photoScrollView requestViewAtRow:(unsigned int)row col:(unsigned int)col;
- (void)photoScrollView:(id)photoScrollView cancelRequestAtRow:(unsigned int)row col:(unsigned int)col;
- (unsigned int)photoScrollViewRows:(id)photoScrollView;
- (unsigned int)photoScrollViewCols:(id)photoScrollView;

@end

@protocol XKPhotoScrollViewDelegate <NSObject>

@optional

- (void)photoScrollView:(id)photoScrollView didTapView:(UIView *)view atPoint:(CGPoint)pt atRow:(unsigned int)row atCol:(unsigned int)col;
- (void)photoScrollView:(id)photoScrollView didLongPressView:(UIView *)view atPoint:(CGPoint)pt atRow:(unsigned int)row atCol:(unsigned int)col;
- (void)photoScrollView:(id)photoScrollView didTouchView:(UIView *)view withTouches:(NSSet *)touches atRow:(unsigned int)row atCol:(unsigned int)col;
- (void)photoScrollView:(id)photoScrollView didDragView:(UIView *)view atRow:(unsigned int)row atCol:(unsigned int)col;
- (void)photoScrollView:(id)photoScrollView didUpdateTransformationForView:(UIView *)view withState:(XKPhotoScrollViewViewState *)state;
- (void)photoScrollView:(id)photoScrollView didZoomView:(UIView *)view atRow:(unsigned int)row atCol:(unsigned int)col;
- (void)photoScrollView:(id)photoScrollView didPinchDismissView:(UIView *)view atRow:(unsigned int)row atCol:(unsigned int)col;
- (void)photoScrollView:(id)photoScrollView didRotateTo:(float)rotation;
- (void)photoScrollView:(id)photoScrollView didChangeToRow:(unsigned int)row col:(unsigned int)col;
- (void)photoScrollView:(id)photoScrollView didSetCurrentView:(UIView *)view withState:(XKPhotoScrollViewViewState *)state;
- (void)photoScrollView:(id)photoScrollView isStabilizing:(UIView *)view;
- (void)photoScrollView:(id)photoScrollView didStabilizeView:(UIView *)view;
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
