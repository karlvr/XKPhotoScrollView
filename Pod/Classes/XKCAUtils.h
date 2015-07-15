//
//  XKCAUtils.h
//  XKPhotoScrollView
//
//  Created by Karl von Randow on 3/07/10.
//  Copyright 2010 XK72 Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef COREANIMATION_H

CALayer * FindLayerWithContents(CALayer *layer);
NSString * NSStringFromCATransform3D(CATransform3D transform);

#endif
