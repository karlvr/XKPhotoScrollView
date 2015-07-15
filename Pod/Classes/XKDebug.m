//
//  XKDebug.m
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 8/02/09.
//  Copyright 2009 XK72 Ltd. All rights reserved.
//

#import "XKDebug.h"
#import "XKCAUtils.h"


static NSMutableDictionary *allocced = nil;
static NSLock *allocLock;

void CountAlloc(id ob);
void CountAlloc(id ob) {
	NSString *id = [NSString stringWithFormat:@"%@", [ob class]];

	if (!allocced) {
		allocced = [[NSMutableDictionary alloc] initWithCapacity:100];
		allocLock = [[NSLock alloc] init];
	}

	[allocLock lock];
	NSNumber *count = allocced[id];
	if (count) {
		count = @([count intValue] + 1);
	} else {
		count = @1;
	}
	allocced[id] = count;
	[allocLock unlock];
}

void CountDealloc(id ob);
void CountDealloc(id ob) {
	NSString *id = [NSString stringWithFormat:@"%@", [ob class]];

	if (!allocced) {
		allocced = [[NSMutableDictionary alloc] initWithCapacity:100];
		allocLock = [[NSLock alloc] init];
	}

	[allocLock lock];
	NSNumber *count = allocced[id];
	if (count) {
		count = @([count intValue] - 1);
	} else {
		NSLog(@"COUNT DEALLOC WITHOUT ALLOC: %@", ob);
	}
	allocced[id] = count;
	[allocLock unlock];

#ifdef DEBUG_ALLOCS_VERBOSE
	NSLog(@"COUNT DEALLOC %@ %i", ob, [count intValue]);
#endif
}

void ReportAllocs(void);
void ReportAllocs() {
	NSLog(@"***REMAINING ALLOCS***");
	if (allocced) {
		[allocLock lock];
		for (id key in allocced) {
			int allocs = [allocced[key] intValue];
			if (allocs != 0)
				NSLog(@"REMAINING ALLOCS FOR %@ %i", key, allocs);
		}
		[allocLock unlock];
	}
}

void XKDumpViews(UIView *view, NSString *text, NSString *indent) {
	Class cl = [view class];
	NSString *classDescription = [cl description];

	while ([cl superclass]) {
		cl = [cl superclass];
		classDescription = [classDescription stringByAppendingFormat:@":%@", [cl description]];
	}

	NSMutableString *output = [NSMutableString string];
	if ([text compare:@""] != NSOrderedSame)
		[output appendString:text];
	[output appendFormat:@" %@ %@", classDescription, NSStringFromCGRect(view.frame)];
	if (view.hidden)
		[output appendFormat:@" hidden"];
	if (view.alpha != 1)
		[output appendFormat:@" alpha=%0.1f", view.alpha];
	if (!CGAffineTransformIsIdentity(view.transform))
		[output appendFormat:@" transform=%@", NSStringFromCGAffineTransform(view.transform)];
	NSLog(@"%@", output);

	for (NSUInteger i = 0; i < [view.subviews count]; i++) {
		UIView *subView = (view.subviews)[i];
		NSString *newIndent = [[NSString alloc] initWithFormat:@"  %@", indent];
		NSString *msg = [[NSString alloc] initWithFormat:@"%@%lu:", newIndent, (unsigned long)i];
		XKDumpViews(subView, msg, newIndent);
	}
}

#ifdef COREANIMATION_H
void XKDumpLayers(CALayer *layer, NSString *text, NSString *indent) {
	Class cl = [layer class];
	NSString *classDescription = [cl description];

	while ([cl superclass]) {
		cl = [cl superclass];
		classDescription = [classDescription stringByAppendingFormat:@":%@", [cl description]];
	}

	NSMutableString *output = [NSMutableString string];
	if ([text compare:@""] != NSOrderedSame)
		[output appendString:text];
	[output appendFormat:@" %@ %@", classDescription, NSStringFromCGRect(layer.frame)];
	if (layer.contents)
		[output appendFormat:@" contents=%@", layer.contents];
//	if (!CATransform3DIsIdentity(layer.transform))
//		[output appendFormat:@" transform=%@", NSStringFromCATransform3D(layer.transform)];
//	if (!CATransform3DIsIdentity(layer.sublayerTransform))
//		[output appendFormat:@" sublayerTransform=%@", NSStringFromCATransform3D(layer.sublayerTransform)];
	NSLog(@"%@", output);

	for (NSUInteger i = 0; i < [layer.sublayers count]; i++) {
		CALayer *subLayer = (layer.sublayers)[i];
		NSString *newIndent = [[NSString alloc] initWithFormat:@"  %@", indent];
		NSString *msg = [[NSString alloc] initWithFormat:@"%@%lu:", newIndent, (unsigned long)i];
		XKDumpLayers(subLayer, msg, newIndent);
	}
}
#endif /* ifdef COREANIMATION_H */
