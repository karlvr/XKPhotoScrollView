/*
 *  XKCGUtils.h
 *  XKPhotoScrollView
 *
 *  Created by Karl von Randow on 12/04/09.
 *  Copyright 2009 XK72 Ltd. All rights reserved.
 *
 */

#import <CoreGraphics/CoreGraphics.h>

CGPoint CGPointNegate(CGPoint p);
CGPoint CGPointAdd(CGPoint a, CGPoint b);
CGPoint CGPointOffset(CGPoint a, CGFloat x, CGFloat y);
CGPoint CGPointMul(CGPoint a, CGFloat m);
CGPoint CGPointMid(CGPoint a, CGPoint b);
CGFloat CGPointDist(CGPoint a, CGPoint b);
CGPoint CGPointMakeProportional(CGPoint a, CGSize b);
CGPoint CGPointFromProportional(CGPoint a, CGSize b);
CGSize CGSizeMul(CGSize size, CGFloat m);
CGSize CGSizeInvert(CGSize size);
CGRect CGRectMakeCentered(CGSize size, CGSize inside);
CGRect CGRectMakeCenteredInRect(CGSize size, CGRect inside);
CGRect CGRectExpand(CGRect rect, CGFloat w, CGFloat h);
CGFloat CGRectGetArea(CGRect rect);
CGPoint CGRectGetCenter(CGRect rect);
CGRect CGRectWithZeroOrigin(CGRect rect);

CGFloat CGMinAngleDiff(CGFloat a, CGFloat b);

void CGContextAddRoundedRect(CGContextRef c, CGRect rect, int corner_radius);

CGPoint CGPointOnLineClosestToPoint(CGPoint point, CGPoint lineStart, CGPoint lineEnd, bool constrainToLineSegment);

CGFloat XKCGPixelsToPoints(CGFloat pixels);

CGFloat XKCGFloatRoundToWholePixel(CGFloat f);
CGFloat XKCGFloatFloorToWholePixel(CGFloat f);
CGFloat XKCGFloatCeilToWholePixel(CGFloat f);

CGPoint XKCGPointRoundToWholePixel(CGPoint pt);
CGPoint XKCGPointFloorToWholePixel(CGPoint pt);
CGPoint XKCGPointCeilToWholePixel(CGPoint pt);

CGSize XKCGSizeRoundToWholePixel(CGSize sz);
CGSize XKCGSizeFloorToWholePixel(CGSize sz);
CGSize XKCGSizeCeilToWholePixel(CGSize sz);

CGRect XKCGRectOriginRoundToWholePixel(CGRect r);
CGRect XKCGRectOriginFloorToWholePixel(CGRect r);
CGRect XKCGRectExpandToWholePixel(CGRect r);

#define CGRectDelta XKCGRectDelta
CGRect XKCGRectDelta(CGRect rect, CGFloat dx, CGFloat dy, CGFloat dw, CGFloat dh);

CGImageRef XKCGImageMaskCreateWithImage(CGImageRef image);
