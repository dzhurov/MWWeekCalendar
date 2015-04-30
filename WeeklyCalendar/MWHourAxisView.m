//
//  MWHourAxisView.m
//  WeeklyCalendar
//
//  Created by DZhurov on 4/30/15.
//
//

#import "MWHourAxisView.h"

@implementation MWHourAxisView


- (void)drawRect:(CGRect)rect
{
    //// Color Declarations
    UIColor* axisColor = [UIColor colorWithRed: 1 green: 0.149 blue: 0 alpha: 1];
    
    //// Frames
    CGRect frame = CGRectMake(0, 0, 148, 119);
    
    
    //// Abstracted Attributes
    NSString* textContent = @"12 PM";
    
    
    //// Bezier Line uno Drawing
    UIBezierPath* bezierLineUnoPath = [UIBezierPath bezierPath];
    [bezierLineUnoPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 72, CGRectGetMinY(frame) + 16.5)];
    [bezierLineUnoPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 148, CGRectGetMinY(frame) + 16.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 148, CGRectGetMinY(frame) + 16.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 148, CGRectGetMinY(frame) + 16.5)];
    [axisColor setStroke];
    bezierLineUnoPath.lineWidth = 1;
    [bezierLineUnoPath stroke];
    
    
    //// Text Drawing
    CGRect textRect = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame) + 8, 64, 16);
    [axisColor setFill];
    [textContent drawInRect: textRect withFont: [UIFont fontWithName: @"Helvetica" size: 12] lineBreakMode: UILineBreakModeWordWrap alignment: UITextAlignmentRight];

}


@end
