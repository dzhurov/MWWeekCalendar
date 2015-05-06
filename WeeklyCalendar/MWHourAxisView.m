//
//  MWHourAxisView.m
//  WeeklyCalendar
//
//  Created by DZhurov on 4/30/15.
//
//

#import "MWHourAxisView.h"
#import "CGHelper.h"
#import "NSDate+MWWeeklyCalendar.h"

@implementation MWHourAxisView

IB_DESIGNABLE
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //// Date Component
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    
    //// Label
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingHead;
    paragraphStyle.alignment = NSTextAlignmentRight;
    NSDictionary *attributes = @{ NSFontAttributeName:              font,
                                  NSParagraphStyleAttributeName:    paragraphStyle,
                                  NSForegroundColorAttributeName:   self.axisColor};
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat horizontalLineXPosition = kHoursAxisInset.top;
    for (int hour = 0; hour <= 24; hour++) {
        draw1PxStroke(context, CGPointMake(kHoursAxisInset.left + 0.5, horizontalLineXPosition + 0.5), CGPointMake(CGRectGetMaxX(rect) + 0.5, horizontalLineXPosition + 0.5), self.axisColor.CGColor);
        
        dateComponents.hour = hour;
        NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
        NSString *hourString = [NSDate timeStringFromDate:date];
        const CGFloat hourStringHeight = font.pointSize;
        CGRect hourRect = CGRectMake(0, roundTo1Px(horizontalLineXPosition - hourStringHeight / 2), kHoursAxisInset.left - 8, hourStringHeight);
        [hourString drawInRect:hourRect withAttributes:attributes];
        
        horizontalLineXPosition += self.hourStepHeight;
    }
}

- (void)prepareForInterfaceBuilder
{
    [self setNeedsDisplay];
}

- (void)setHourStepHeight:(CGFloat)hourStepHeight
{
    _hourStepHeight = hourStepHeight;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, 24 * self.hourStepHeight + kHoursAxisInset.top + kHoursAxisInset.bottom);
}

@end
