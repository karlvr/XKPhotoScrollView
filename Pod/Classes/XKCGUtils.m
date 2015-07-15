/*
 *  XKCGUtils.c
 *  XKPhotoScrollView
 *
 *  Created by Karl von Randow on 12/04/09.
 *  Copyright 2009 XK72 Ltd. All rights reserved.
 *
 */

#include "XKCGUtils.h"

#import <math.h>
#import "XKUIUtils.h"

inline CGPoint CGPointNegate(CGPoint p) {
	return CGPointMake(-p.x, -p.y);
}

inline CGPoint CGPointAdd(CGPoint a, CGPoint b) {
	return CGPointMake(a.x + b.x, a.y + b.y);
}

inline CGPoint CGPointOffset(CGPoint a, CGFloat x, CGFloat y) {
	return CGPointMake(a.x + x, a.y + y);
}

inline CGPoint CGPointMul(CGPoint a, CGFloat m) {
	return CGPointMake(a.x * m, a.y * m);
}

inline CGPoint CGPointMid(CGPoint a, CGPoint b) {
	return CGPointMake((a.x + b.x) / 2, (a.y + b.y) / 2);
}

inline CGFloat CGPointDist(CGPoint a, CGPoint b) {
	float x = a.x - b.x;
	float y = a.y - b.y;
	return sqrt(x * x + y * y);
}

inline CGPoint CGPointMakeProportional(CGPoint a, CGSize b) {
	return CGPointMake(a.x / b.width, a.y / b.height);
}

inline CGPoint CGPointFromProportional(CGPoint a, CGSize b) {
	return CGPointMake(a.x * b.width, a.y * b.height);
}

inline CGSize CGSizeMul(CGSize size, CGFloat m) {
	return CGSizeMake(size.width * m, size.height * m);
}

inline CGSize CGSizeInvert(CGSize size) {
	return CGSizeMake(size.height, size.width);
}

inline CGRect CGRectMakeCentered(CGSize size, CGSize inside) {
	return CGRectMake(inside.width / 2 - size.width / 2, inside.height / 2 - size.height / 2, size.width, size.height);
}

inline CGRect CGRectMakeCenteredInRect(CGSize size, CGRect inside) {
	return CGRectMake(inside.origin.x + inside.size.width / 2 - size.width / 2, inside.origin.y + inside.size.height / 2 - size.height / 2, size.width, size.height);
}

CGRect CGRectExpand(CGRect rect, CGFloat w, CGFloat h) {
	rect.origin.x -= w / 2;
	rect.origin.y -= h / 2;
	rect.size.width += w;
	rect.size.height += h;
	return rect;
}

CGFloat CGRectGetArea(CGRect rect) {
    return rect.size.width * rect.size.height;
}

CGPoint CGRectGetCenter(CGRect rect) {
    return CGPointMake(rect.origin.x + rect.size.width / 2.0, rect.origin.y + rect.size.height / 2.0);
}

CGRect CGRectWithZeroOrigin(CGRect rect) {
    return CGRectMake(0, 0, rect.size.width, rect.size.height);
}

CGFloat CGMinAngleDiff(CGFloat a, CGFloat b) {
    CGFloat result = fabs(a - b);
    result = MIN(result, fabs(a - (b + 2 * M_PI)));
    result = MIN(result, fabs(a - (b - 2 * M_PI)));
    return result;
}

CGRect XKCGRectDelta(CGRect rect, CGFloat dx, CGFloat dy, CGFloat dw, CGFloat dh) {
    rect.origin.x += dx;
    rect.origin.y += dy;
    rect.size.width += dw;
    rect.size.height += dh;
    return rect;
}

/**
 * Sample code from:
 * http://www.iphonedevforums.com/forum/iphone-sdk-development/200-problem-make-rounded-rectangle.html
 */
void CGContextAddRoundedRect (CGContextRef c, CGRect rect, int corner_radius) {
	int x_left = rect.origin.x;
	int x_left_center = rect.origin.x + corner_radius;
	int x_right_center = rect.origin.x + rect.size.width - corner_radius;
	int x_right = rect.origin.x + rect.size.width;
	int y_top = rect.origin.y;
	int y_top_center = rect.origin.y + corner_radius;
	int y_bottom_center = rect.origin.y + rect.size.height - corner_radius;
	int y_bottom = rect.origin.y + rect.size.height;
	
	/* Begin! */
	CGContextBeginPath(c);
	CGContextMoveToPoint(c, x_left, y_top_center);
	
	/* First corner */
	CGContextAddArcToPoint(c, x_left, y_top, x_left_center, y_top, corner_radius);
	CGContextAddLineToPoint(c, x_right_center, y_top);
	
	/* Second corner */
	CGContextAddArcToPoint(c, x_right, y_top, x_right, y_top_center, corner_radius);
	CGContextAddLineToPoint(c, x_right, y_bottom_center);
	
	/* Third corner */
	CGContextAddArcToPoint(c, x_right, y_bottom, x_right_center, y_bottom, corner_radius);
	CGContextAddLineToPoint(c, x_left_center, y_bottom);
	
	/* Fourth corner */
	CGContextAddArcToPoint(c, x_left, y_bottom, x_left, y_bottom_center, corner_radius);
	CGContextAddLineToPoint(c, x_left, y_top_center);
	
	/* Done */
	CGContextClosePath(c);
}

/**
 * Returns the point on the line that passes through lineStart and lineEnd, that is closest
 * to the point. Note that the returned point may not be between lineStart and lineEnd if
 * constrain is NO.
 */
CGPoint CGPointOnLineClosestToPoint(CGPoint point, CGPoint lineStart, CGPoint lineEnd, bool constrainToLineSegment) {
	float lineMag = CGPointDist( lineEnd, lineStart );
	if (lineMag == 0) {
		if (constrainToLineSegment)
			return lineStart;
		else
			return point;
	}
	
    float u = ( ( ( point.x - lineStart.x ) * ( lineEnd.x - lineStart.x ) ) +
		 ( ( point.y - lineStart.y ) * ( lineEnd.y - lineStart.y ) ) ) /
		( lineMag * lineMag );
	
	if (constrainToLineSegment) {
		u = fmaxf(0, fminf(1, u));
	}
	
	CGPoint intersection;
    intersection.x = lineStart.x + u * ( lineEnd.x - lineStart.x );
    intersection.y = lineStart.y + u * ( lineEnd.y - lineStart.y );
	
    return intersection;
}

CGFloat XKCGPixelsToPoints(CGFloat pixels) {
    CGFloat scale = UIMainScreenScale();
    return pixels / scale;
}

CGFloat XKCGFloatRoundToWholePixel(CGFloat f) {
    CGFloat scale = UIMainScreenScale();
    return roundf(f * scale) / scale;
}

CGFloat XKCGFloatFloorToWholePixel(CGFloat f) {
    CGFloat scale = UIMainScreenScale();
    return floorf(f * scale) / scale;
}

CGFloat XKCGFloatCeilToWholePixel(CGFloat f) {
    CGFloat scale = UIMainScreenScale();
    return ceilf(f * scale) / scale;
}

CGPoint XKCGPointRoundToWholePixel(CGPoint pt) {
    CGFloat scale = UIMainScreenScale();
    return CGPointMake(roundf(pt.x * scale) / scale, roundf(pt.y * scale) / scale);
}

CGPoint XKCGPointFloorToWholePixel(CGPoint pt) {
    CGFloat scale = UIMainScreenScale();
    return CGPointMake(floorf(pt.x * scale) / scale, floorf(pt.y * scale) / scale);
}

CGPoint XKCGPointCeilToWholePixel(CGPoint pt) {
    CGFloat scale = UIMainScreenScale();
    return CGPointMake(ceilf(pt.x * scale) / scale, ceilf(pt.y * scale) / scale);
}

CGSize XKCGSizeRoundToWholePixel(CGSize sz) {
    CGFloat scale = UIMainScreenScale();
    return CGSizeMake(roundf(sz.width * scale) / scale, roundf(sz.height * scale) / scale);
}

CGSize XKCGSizeFloorToWholePixel(CGSize sz) {
    CGFloat scale = UIMainScreenScale();
    return CGSizeMake(floorf(sz.width * scale) / scale, floorf(sz.height * scale) / scale);
}

CGSize XKCGSizeCeilToWholePixel(CGSize sz) {
    CGFloat scale = UIMainScreenScale();
    return CGSizeMake(ceilf(sz.width * scale) / scale, ceilf(sz.height * scale) / scale);
}

CGRect XKCGRectOriginRoundToWholePixel(CGRect r) {
    r.origin = XKCGPointRoundToWholePixel(r.origin);
    return r;
}

CGRect XKCGRectOriginFloorToWholePixel(CGRect r) {
    r.origin = XKCGPointFloorToWholePixel(r.origin);
    return r;
}

CGRect XKCGRectExpandToWholePixel(CGRect r) {
    r.origin = XKCGPointFloorToWholePixel(r.origin);
    r.size = XKCGSizeCeilToWholePixel(r.size);
    return r;
}

CGImageRef XKCGImageMaskCreateWithImage(CGImageRef image) {
    return CGImageMaskCreate(CGImageGetWidth(image), CGImageGetHeight(image), CGImageGetBitsPerComponent(image), CGImageGetBitsPerPixel(image), CGImageGetBytesPerRow(image), CGImageGetDataProvider(image), CGImageGetDecode(image), CGImageGetShouldInterpolate(image));
}
