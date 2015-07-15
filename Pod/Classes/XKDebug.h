/*
 *  XKDebug.h
 *  XKPhotoScrollView
 *
 *  Created by Karl von Randow on 23/01/09.
 *  Copyright 2009 XK72 Ltd. All rights reserved.
 *
 */

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#endif

#define NSLOG(...)               NSLog(@"%s:%u %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#define NSLOG_RECT(name, rect)   NSLog(@"%s:%u %@: %@", __PRETTY_FUNCTION__, __LINE__, name, NSStringFromCGRect(rect))
#define NSLOG_SIZE(name, size)   NSLog(@"%s:%u %@: %@", __PRETTY_FUNCTION__, __LINE__, name, NSStringFromCGSize(size))
#define NSLOG_POINT(name, point) NSLog(@"%s:%u %@: %@", __PRETTY_FUNCTION__, __LINE__, name, NSStringFromCGPoint(point))

#if DEBUG_OUTPUT
#define DEBUG_LOG(...)           NSLOG(__VA_ARGS__)
#define DEBUG_RECT(name, rect)   NSLOG_RECT(name, rect)
#define DEBUG_SIZE(name, size)   NSLOG_SIZE(name, size)
#define DEBUG_POINT(name, size)  NSLOG_POINT(name, size)
#else
#define DEBUG_LOG(...)
#define DEBUG_RECT(name, rect)
#define DEBUG_SIZE(name, size)
#define DEBUG_POINT(name, size)
#endif

// #define DEBUG_ALLOCS
// #define DEBUG_ALLOCS_VERBOSE

#ifdef DEBUG_ALLOCS
#define COUNT_ALLOC(x)   CountAlloc(x)
#define COUNT_DEALLOC(x) CountDealloc(x)
#define REPORT_ALLOCS()  ReportAllocs()

#ifdef __OBJC__
void CountAlloc(id ob);
void CountDealloc(id ob);
void ReportAllocs();
#endif
#else
#define COUNT_ALLOC(x)
#define COUNT_DEALLOC(x)
#define REPORT_ALLOCS()
#endif

#ifdef __OBJC__
#ifdef DEBUG_OUTPUT

#define START_TIME(x) \
	NSString * __startTimeLabel = x; \
	NSTimeInterval __startTimeInterval = [NSDate timeIntervalSinceReferenceDate]; \
	NSTimeInterval __lastTimeInterval = __startTimeInterval;
#define START_TIME2(x, y) \
	START_TIME(x); \
	if (y) NSLog(@"TIME: %s %@: %@", __PRETTY_FUNCTION__, x, y);
#define MARK_TIME(x) \
	{ \
		NSTimeInterval __nowTimeInterval = [NSDate timeIntervalSinceReferenceDate];		\
		NSLog(@"TIME: %s %@: %@: %fs (total %fs)", __PRETTY_FUNCTION__, __startTimeLabel, x, __nowTimeInterval - __lastTimeInterval, __nowTimeInterval - __startTimeInterval); \
		__lastTimeInterval = __nowTimeInterval;	\
	}

#define START_PERFORMANCE_CHECK(x) \
    NSTimeInterval __startTimeInterval = [NSDate timeIntervalSinceReferenceDate];

#define END_PERFORMANCE_CHECK(x) \
    { \
        NSTimeInterval __nowTimeInterval = [NSDate timeIntervalSinceReferenceDate];		\
        static NSTimeInterval __totalTimeInterval = 0; \
        static int __totalCount = 0; \
        __totalTimeInterval += (__nowTimeInterval - __startTimeInterval); \
        __totalCount++; \
        NSLog(@"AVERAGE TIME: %s %@: %fs (%i iterations)", __PRETTY_FUNCTION__, x, (__totalTimeInterval / __totalCount), __totalCount); \
    }

#else

#define START_TIME(x)
#define START_TIME2(x, y)
#define MARK_TIME(x)

#endif
#endif

#ifdef __OBJC__
void XKDumpViews(UIView *view, NSString *text, NSString *indent);
#ifdef COREANIMATION_H
void XKDumpLayers(CALayer *layer, NSString *text, NSString *indent);
#endif
#endif