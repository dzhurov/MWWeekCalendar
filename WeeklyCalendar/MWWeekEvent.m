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

- (id)copyWithZone:(NSZone *)zone
{
    MWWeekEvent *event = [MWWeekEvent eventWithStartDate:self.startDate endDate:self.endDate];
    event.eventDescription = self.eventDescription;
    event.title = self.title;
    event.calendarColor = self.calendarColor;
    return event;
}

- (BOOL)isEqual:(MWWeekEvent *)object
{
    return [self.startDate isEqual:object.startDate] &&
    [self.endDate isEqual:object.endDate] &&
    [self.eventDescription isEqual:object.eventDescription] &&
    [self.title isEqual:object.title] &&
    [self.calendarColor isEqual:object.calendarColor];
}

- (NSUInteger)hash
{
    return [NSStringFromClass([MWWeekEvent class]) hash] ^ self.startDate.hash ^ self.endDate.hash ^ self.eventDescription.hash ^ self.title.hash ^ self.calendarColor.hash;
}

@end
