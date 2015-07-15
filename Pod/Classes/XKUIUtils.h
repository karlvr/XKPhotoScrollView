//
//  XKUIUtils.h
//  CameraPlus
//
//  Created by Karl von Randow on 7/06/11.
//  Copyright 2011 XK72 Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

CGFloat XKUIMainScreenScale(void);
CGFloat XKUIScreenScale(UIScreen *screen);

#define UIScreenScale XKUIScreenScale
#define UIMainScreenScale XKUIMainScreenScale

UIView *XKViewWithClass(UIView *search, Class klass);
