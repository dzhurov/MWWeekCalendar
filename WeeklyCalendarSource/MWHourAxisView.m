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
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Background
    CGRect insetRect = CGRectMake(kHoursAxisInset.left,
                              kHoursAxisInset.top,
                              self.bounds.size.width - kHoursAxisInset.left - kHoursAxisInset.right,
                              self.bounds.size.height - kHoursAxisInset.top - kHoursAxisInset.bottom);
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.5 alpha:0.05].CGColor);

    CGFloat startWorkingHours = MAXFLOAT;
    CGFloat endWorkingHours = MAXFLOAT;
    
    if (self.startWorkingDay && self.endWorkingDay) {
        NSDate *startDate = [[NSCalendar currentCalendar] dateFromComponents:self.startWorkingDay];
        NSDate *endDate = [[NSCalendar currentCalendar] dateFromComponents:self.endWorkingDay];
        if ([endDate timeIntervalSinceDate:startDate] > 0) {
            startWorkingHours = [self.startWorkingDay hour] + [self.startWorkingDay minute] / 60.0;
            endWorkingHours = [self.endWorkingDay hour] + [self.endWorkingDay minute] / 60.0;
        }
    }
    
    if (startWorkingHours == MAXFLOAT || endWorkingHours == MAXFLOAT) {
        startWorkingHours = 9;
        endWorkingHours = 19;
    }
    
    CGFloat startWorkingXPosition = self.hourStepHeight * startWorkingHours;
    CGRect beforeRect = insetRect;
    beforeRect.size.height = startWorkingXPosition;
    
    CGFloat endWorkingXPosition = self.hourStepHeight * endWorkingHours;
    CGRect afterRect = insetRect;
    afterRect.origin.y = kHoursAxisInset.top + endWorkingXPosition;
    afterRect.size.height -= endWorkingXPosition;
    
    CGContextFillRect(context, beforeRect);
    CGContextFillRect(context, afterRect);

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
    
    CGRect currentDateRect = CGRectZero;
    if (self.showCurrentDate) {
        NSDate *currentDate = [NSDate date];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:currentDate];
        CGFloat currentDateHours = [components hour] + [components minute] / 60.0;
        CGFloat currentDateXPosition = kHoursAxisInset.top + self.hourStepHeight * currentDateHours;
        currentDateRect = hourLabelRectForLinePosition(currentDateXPosition);
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"h:mm a";
        NSString *currentHourString = [formatter stringFromDate:currentDate];
        NSDictionary *currentDateAttributes = @{ NSFontAttributeName:              font,
                                                 NSParagraphStyleAttributeName:    paragraphStyle,
                                                 NSForegroundColorAttributeName:   [UIColor redColor]};

        [currentHourString drawInRect:currentDateRect withAttributes:currentDateAttributes];
    }
    
    // Adding Hours labels and horizontal lines
    CGFloat horizontalLineXPosition = kHoursAxisInset.top;
    for (int hour = 0; hour <= 24; hour++) {
        CGFloat halfPx = onePx() / 2.f;
        draw1PxStroke(context,
                      CGPointMake(kHoursAxisInset.left/* + 0.5*/,
                                  horizontalLineXPosition + halfPx),
                      CGPointMake(CGRectGetMaxX(rect)/* + 0.5*/,
                                  horizontalLineXPosition + halfPx),
                      self.axisColor.CGColor);
        
        dateComponents.hour = hour;
        NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
        NSString *hourString = [NSDate timeStringFromDate:date];
        
        CGRect hourRect = hourLabelRectForLinePosition(horizontalLineXPosition);
        if (!CGRectIntersectsRect(hourRect, currentDateRect)) {
            [hourString drawInRect:hourRect withAttributes:attributes];
        }
        horizontalLineXPosition += self.hourStepHeight;
    }
    
    // Draw current event minutes
    if (self.currentEventDate){
        NSUInteger minutes = self.currentEventDate.dateComponents.minute;
        if (minutes != 0){
            CGFloat linePosition = (minutes / 60. + self.currentEventDate.dateComponents.hour) * self.hourStepHeight + kHoursAxisInset.top;
            CGRect minutesRect = hourLabelRectForLinePosition(linePosition);
            NSString *minutesString = [NSString stringWithFormat:@":%d", minutes];
            if (!CGRectIntersectsRect(minutesRect, currentDateRect)) {
                [minutesString drawInRect:minutesRect withAttributes:attributes];
            }
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

- (void)setShowCurrentDate:(BOOL)showCurrentDate
{
    BOOL lastValue = _showCurrentDate;
    _showCurrentDate = showCurrentDate;
    if (showCurrentDate != lastValue) {
        [self setNeedsDisplay];
    }
}

@end
