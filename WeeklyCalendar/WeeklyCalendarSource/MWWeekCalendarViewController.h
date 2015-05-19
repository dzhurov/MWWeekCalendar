//
//  MWWeekCalendarViewController.h
//  WeeklyCalendar
//
//  Created by DZhurov on 4/27/15.
//
//

#import <UIKit/UIKit.h>
#import "MWCalendarEditingControllerProtocol.h"

@class MWCalendarEvent;
@protocol MWCalendarDelegate, MWCalendarDataSource;

@interface MWWeekCalendarViewController : UIViewController <MWCalendarEditingControllerDelegate>
/*! Number of colums visible at the moment. 
 Default is 7*/
@property (nonatomic) NSUInteger numberOfVisibleDays;
@property (nonatomic, weak) id <MWCalendarDelegate> delegate;
@property (nonatomic, weak) id <MWCalendarDataSource> dataSource;
- (void)reloadEventsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (void)reloadEvents;
@end


@protocol MWCalendarDelegate <NSObject>
@optional
- (void)calendarController:(MWWeekCalendarViewController *)controller didScrollToStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
- (BOOL)calendarController:(MWWeekCalendarViewController *)controller shouldAddEventForStartDate:(NSDate *)startDate;
- (void)calendarController:(MWWeekCalendarViewController *)controller didAddEvent:(MWCalendarEvent *)event;
- (BOOL)calendarController:(MWWeekCalendarViewController *)controller shouldStartEditingForEvent:(MWCalendarEvent *)event;
- (void)calendarController:(MWWeekCalendarViewController *)controller removeEvent:(MWCalendarEvent *)event;
- (void)calendarController:(MWWeekCalendarViewController *)controller saveEvent:(MWCalendarEvent *)event withNew:(MWCalendarEvent *)newEvent;
@end


@protocol MWCalendarDataSource <NSObject>
/*! [MWCalendarEvent]   */
- (NSArray *)calendarController:(MWWeekCalendarViewController *)controller eventsForDate:(NSDate *)date;
- (UIViewController <MWCalendarEditingControllerProtocol> *)calendarController:(MWWeekCalendarViewController *)controller
                                                     editingControllerForEvent:(MWCalendarEvent *)event;
@end
