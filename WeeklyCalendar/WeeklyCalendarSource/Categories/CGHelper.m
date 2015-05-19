//
//  CGHelper.c
//  WeeklyCalendar
//
//  Created by DZhurov on 5/5/15.
//
//
#import "CGHelper.h"

CGFloat onePx()
{
    return 1.f / [UIScreen mainScreen].scale;
}

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
    return roundWithStep(f, scale);
}

CGFloat roundWithStep(CGFloat f, CGFloat step)
{
    CGFloat result = roundf(f / step) * step;
    return result;
}

CGFloat vectorLength(CGVector v)
{
    return sqrt(v.dx * v.dx + v.dy * v.dy);
}

@implementation UIColor (Brightness)

- (UIColor *)colorWithBrightness:(CGFloat)brightness
{
    CGFloat hue, saturation, alpha;
    [self getHue:&hue saturation:&saturation brightness: NULL alpha:&alpha];
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

- (UIColor *)colorWithBrightnessMultiplier:(CGFloat)brightnessMultiplier
{
    CGFloat hue, saturation, brightness, alpha;
    [self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness * brightnessMultiplier alpha:alpha];
}

@end
