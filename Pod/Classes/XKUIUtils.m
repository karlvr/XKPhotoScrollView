//
//  XKUIUtils.m
//  CameraPlus
//
//  Created by Karl von Randow on 7/06/11.
//  Copyright 2011 XK72 Ltd. All rights reserved.
//

#import "XKUIUtils.h"


CGFloat XKUIMainScreenScale() {
	return UIScreenScale([UIScreen mainScreen]);
}

CGFloat XKUIScreenScale(UIScreen *screen) {
#if 40000 <= __IPHONE_OS_VERSION_MAX_ALLOWED
	if ([screen respondsToSelector:@selector(scale)]) {
		return screen.scale;
	} else {
		return 1;
	}
#else
	return 1;
#endif
}

UIView *XKViewWithClass(UIView *search, Class klass) {
    if ([search isKindOfClass:klass]) {
        return search;
    }
    
    for (UIView *subview in [search subviews]) {
        UIView *result = XKViewWithClass(subview, klass);
        if (result)
            return result;
    }
    
    return nil;
}
