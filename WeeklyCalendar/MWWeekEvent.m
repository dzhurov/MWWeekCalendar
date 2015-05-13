//
//  MWWeekEvent.m
//  WeeklyCalendar
//
//  Created by DZhurov on 5/12/15.
//
//

#import "MWWeekEvent.h"

@implementation MWWeekEvent

+ (instancetype)eventWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    MWWeekEvent *event = [[self alloc] init];
    event.startDate = startDate;
    event.endDate = endDate;
    return event;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"Hello Event";
        self.eventDescription = @"This is a description of the event";
        self.calendarColor = [UIColor colorWithRed:27 / 255. green:173 / 255. blue:248 / 255. alpha:1.];
    }
    return self;
}

- (NSTimeInterval)duration
{
    return [self.endDate timeIntervalSinceDate:self.startDate];
}

@end
