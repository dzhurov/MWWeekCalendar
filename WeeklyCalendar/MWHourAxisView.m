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
#import "MWWeekCalendarConsts.h"


@interface MWHourAxisView ()
@property (nonatomic, strong) NSDate *currentEventDate;
@end

@implementation MWHourAxisView

#define kCurrentEventMinutesStep 15 // minutes

IB_DESIGNABLE
- (void)drawRect:(CGRect)rect
{
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
    
    CGRect(^hourLabelRectForLinePosition)(CGFloat horizontalLineXPosition) = ^(CGFloat horizontalLineXPosition){
        const CGFloat hourStringHeight = font.pointSize;
        return CGRectMake(0, roundTo1Px(horizontalLineXPosition - hourStringHeight / 2), kHoursAxisInset.left - 8, hourStringHeight);
    };
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Adding Hours labels and horizontal lines
    CGFloat horizontalLineXPosition = kHoursAxisInset.top;
    for (int hour = 0; hour <= 24; hour++) {
        draw1PxStroke(context, CGPointMake( kHoursAxisInset.left + 0.5,
                                            horizontalLineXPosition + 0.5),
                                            CGPointMake(CGRectGetMaxX(rect) + 0.5,
                                            horizontalLineXPosition + 0.5),
                                            self.axisColor.CGColor);
        
        dateComponents.hour = hour;
        NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
        NSString *hourString = [NSDate timeStringFromDate:date];
        
        CGRect hourRect = hourLabelRectForLinePosition(horizontalLineXPosition);
        [hourString drawInRect:hourRect withAttributes:attributes];
        
        horizontalLineXPosition += self.hourStepHeight;
    }
    
    // Draw current event minutes
    if (self.currentEventDate){
        NSUInteger minutes = self.currentEventDate.dateComponents.minute;
        if (minutes != 0){
            CGFloat linePosition = (minutes / 60. + self.currentEventDate.dateComponents.hour) * self.hourStepHeight + kHoursAxisInset.top;
            CGRect minutesRect = hourLabelRectForLinePosition(linePosition);
            NSString *minutesString = [NSString stringWithFormat:@":%d", minutes];
            [minutesString drawInRect:minutesRect withAttributes:attributes];
        }
        //TODO: handle current time and not show in case abs(current_time - event_time) < 15
    }
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

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self setNeedsDisplay];
}

- (NSDate *)showEventTimeForTouch:(CGPoint)touchPoint
{
    float hours = (touchPoint.y - kCurrentEventMinutesStep / 2) /  self.hourStepHeight;
//    float fullHours = floor(hours);
    float minutes = roundWithStep(hours * 60, kCurrentEventMinutesStep); // Step = 15 minutes
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
//    dateComponents.hour = fullHours;
    dateComponents.minute = minutes;
    
    self.currentEventDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    [self setNeedsDisplay];
    return self.currentEventDate;
}

- (void)hideEventTouch
{
    self.currentEventDate = nil;
    [self setNeedsDisplay];
}

@end
