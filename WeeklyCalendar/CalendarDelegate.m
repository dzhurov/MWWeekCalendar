//
//  CalendarDelegate.m
//  WeeklyCalendar
//
//  Created by Sergey Konovorotskiy on 5/18/15.
//
//

#import "CalendarDelegate.h"
#import "MWEventsContainer.h"
#import "MWCalendarEvent.h"

@interface CalendarDelegate ()

@property (nonatomic, strong) MWEventsContainer *eventsContainer;

@end

@implementation CalendarDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        _eventsContainer = [MWEventsContainer new];
    }
    return self;
}

#pragma mark - MWCalendarDelegate <NSObject>

- (void)calendarController:(MWWeekCalendarViewController *)controller didScrollToStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{

}

- (BOOL)calendarController:(MWWeekCalendarViewController *)controller shouldAddEventForStartDate:(NSDate *)startDate
{
    return YES;
}

- (void)calendarController:(MWWeekCalendarViewController *)controller didAddEvent:(MWCalendarEvent *)event
{
    [self.eventsContainer addEvent:event forDate:event.startDate];
}

- (BOOL)calendarController:(MWWeekCalendarViewController *)controller shouldStartEditingForEvent:(MWCalendarEvent *)event
{
    return YES;
}

- (void)calendarController:(MWWeekCalendarViewController *)controller eventDidRemove:(MWCalendarEvent *)event
{
    
}

- (void)calendarController:(MWWeekCalendarViewController *)controller eventDidChange:(MWCalendarEvent *)event
{
    
}

#pragma mark - MWCalendarDataSource <NSObject>

/*! [MWCalendarEvent]   */
- (NSArray *)calendarController:(MWWeekCalendarViewController *)controller eventsForDate:(NSDate *)date
{
    return [self.eventsContainer eventsForDay:date];
}

- (UIViewController <MWCalendarEditingControllerProtocol> *)calendarController:(MWWeekCalendarViewController *)controller
                                                     editingControllerForEvent:(MWCalendarEvent *)event
{
    return nil;
}

@end
