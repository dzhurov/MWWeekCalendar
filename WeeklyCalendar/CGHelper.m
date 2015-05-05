//
//  CGHelper.c
//  WeeklyCalendar
//
//  Created by DZhurov on 5/5/15.
//
//
#import "CGHelper.h"

void draw1PxStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGColorRef color)
{
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetLineWidth(context, 1.0 / [UIScreen mainScreen].scale);
    CGContextMoveToPoint(context, startPoint.x , startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x , endPoint.y);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

CGFloat roundTo1Px(CGFloat f)
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat result = roundf(f * scale) / scale;
    return result;
}