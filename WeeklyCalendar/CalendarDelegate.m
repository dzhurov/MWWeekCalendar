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
#import "MWCalendarEditingVC.h"

@interface CalendarDelegate ()

@property (nonatomic, strong) MWEventsContainer *eventsContainer;
@property (nonatomic, strong) MWCalendarEditingVC *editingVC;

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

- (void)calendarController:(MWWeekCalendarViewController *)controller removeEvent:(MWCalendarEvent *)event
{
    [self.eventsContainer removeEvent:event withDate:event.startDate];
}

- (void)calendarController:(MWWeekCalendarViewController *)controller saveEvent:(MWCalendarEvent *)event withNew:(MWCalendarEvent *)newEvent
{
    [self.eventsContainer removeEvent:event withDate:event.startDate];
    [self.eventsContainer addEvent:newEvent forDate:newEvent.startDate];
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
    if (!self.editingVC) {
        self.editingVC = [MWCalendarEditingVC new];
    }
    self.editingVC.event = event;
    self.editingVC.calendarVC = controller;
    return self.editingVC;
}

-(MWCalendarEditingPresentationMode)calendarEditingPresentationMode
{    
    return MWCalendarEditingPresentationModeSideMenu;
}

@end
