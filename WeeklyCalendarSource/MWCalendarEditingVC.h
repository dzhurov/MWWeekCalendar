//
//  MWCalendarEditingVC.h
//  WeeklyCalendar
//
//  Created by Sergey Konovorotskiy on 5/18/15.
//
//

#import <UIKit/UIKit.h>
#import "MWCalendarEditingControllerProtocol.h"

@interface MWCalendarEditingVC : UIViewController <MWCalendarEditingControllerProtocol>

@property (nonatomic, strong) MWCalendarEvent *event;
@property (nonatomic, weak) MWWeekCalendarViewController <MWCalendarEditingControllerDelegate> *calendarVC;

@end
