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
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat baseScale;
@property (nonatomic, assign) NSUInteger row, col;
@property (nonatomic, assign) BOOL placeholder;

@end

@protocol XKPhotoScrollViewDataSource

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
@property (assign, nonatomic) CGFloat maximumZoomScale;
@property (assign, nonatomic) CGFloat minimumZoomScale;
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
