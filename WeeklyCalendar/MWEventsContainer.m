//
//  MWEventsContainer.m
//  WeeklyCalendar
//
//  Created by Sergey Konovorotskiy on 5/14/15.
//
//

#import "MWEventsContainer.h"

@interface MWEventsContainer ()

@property (nonatomic, strong) NSMutableDictionary *dictionaty;

@end

@implementation MWEventsContainer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dictionaty = [NSMutableDictionary new];
    }
    return self;
}

- (void)addEvent:(MWWeekEvent *)event forDate:(NSDate *)date
{
    NSNumber *dayOfYear = [self dayOfYearForDate:date];
    NSMutableArray *mutableArray = self.dictionaty[dayOfYear];
    if (!mutableArray) {
        mutableArray = [NSMutableArray new];
        self.dictionaty[dayOfYear] = mutableArray;
    }
    [mutableArray addObject:event];
    [mutableArray sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES]]];
}

- (NSArray *)eventsForDay:(NSDate *)day
{
    NSMutableArray *events = self.dictionaty[[self dayOfYearForDate:day]];
    if (events.count) {
        return events;
    }
    return nil;
}

#pragma mark - private

- (NSNumber *)dayOfYearForDate:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitWeekday | NSCalendarUnitWeekOfYear) fromDate:date];
    NSInteger day = components.weekday + (components.weekOfYear * 7);
    return @(day);
}

@end
