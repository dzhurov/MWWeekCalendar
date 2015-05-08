//
//  CGHelper.h
//  WeeklyCalendar
//
//  Created by DZhurov on 5/5/15.
//
//
#import <UIKit/UIKit.h>

void draw1PxStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGColorRef color);
CGFloat roundTo1Px(CGFloat f);
CGFloat roundWithStep(CGFloat f, CGFloat step);
CGFloat vectorLength(CGPoint p);
