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
@property (nonatomic, strong) NSDateComponents *startWorkingDay; // hours and minutes
@property (nonatomic, strong) NSDateComponents *endWorkingDay; // hours and minutes

- (void)reloadEventsForDates:(NSArray *)dates;
- (void)reloadEvents;
@end