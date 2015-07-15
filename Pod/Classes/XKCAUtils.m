//
//  XKCAUtils.m
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 3/07/10.
//  Copyright 2010 XK72 Ltd. All rights reserved.
//

#import "XKCAUtils.h"

#ifdef COREANIMATION_H

CALayer * FindLayerWithContents(CALayer *layer) {
	if (layer.contents)
		return layer;

	for (CALayer *aLayer in layer.sublayers) {
		CALayer *result = FindLayerWithContents(aLayer);
		if (result)
			return result;
	}

	return nil;
}

NSString * NSStringFromCATransform3D(CATransform3D transform) {
	if (CATransform3DIsAffine(transform)) {
		return NSStringFromCGAffineTransform(CATransform3DGetAffineTransform(transform));
	} else {
		return @"not affine";
	}
}

#endif /* ifdef COREANIMATION_H */