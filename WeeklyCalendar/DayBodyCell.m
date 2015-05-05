//
//  DayBodyCell.m
//  WeeklyCalendar
//
//  Created by DZhurov on 4/27/15.
//
//

#import "DayBodyCell.h"
#import "CGHelper.h"

@implementation DayBodyCell

- (void)awakeFromNib
{
    self.axisColor = [UIColor magentaColor];
    [self setNeedsDisplay];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();

    draw1PxStroke(context, CGPointMake(CGRectGetMaxX(rect) - 0.5, 0.5), CGPointMake(CGRectGetMaxX(rect) - 0.5, CGRectGetMaxY(rect) + 0.5), self.axisColor.CGColor);
}

@end
