//
//  MWWeekEvent.m
//  WeeklyCalendar
//
//  Created by DZhurov on 5/12/15.
//
//

#import "MWCalendarEvent.h"

@implementation MWCalendarEvent

#pragma mark - init

+ (instancetype)eventWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    MWCalendarEvent *event = [[self alloc] init];
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

#pragma mark - accessors and public methods

- (NSTimeInterval)duration
{
    return [self.endDate timeIntervalSinceDate:self.startDate];
}

- (void)moveStartDateTo:(NSDate *)startDate
{
    NSTimeInterval duration = [self.endDate timeIntervalSinceDate:self.startDate];
    self.startDate = startDate;
    self.endDate = [self.startDate dateByAddingTimeInterval:duration];
}

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
    MWCalendarEvent *copyEvent = [[[self class] allocWithZone:zone] init];
    if (copyEvent) {
        copyEvent.startDate = self.startDate;
        copyEvent.endDate = self.endDate;
        copyEvent.title = self.title;
        copyEvent.eventDescription = self.eventDescription;
        copyEvent.calendarColor = self.calendarColor;
    }
    return copyEvent;
}

@end
