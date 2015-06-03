//
//  MWCalendarEditingControllerProtocol.h
//  WeeklyCalendar
//
//  Created by Sergey Konovorotskiy on 5/15/15.
//
//

#import <Foundation/Foundation.h>

@class MWCalendarEvent, MWWeekCalendarViewController;

@protocol MWCalendarEditingControllerDelegate <NSObject>
- (void)saveEvent:(MWCalendarEvent *)event withNew:(MWCalendarEvent *)newEvent;
- (void)deleteEvent:(MWCalendarEvent *)event;
- (void)createEvent:(MWCalendarEvent *)event;
- (void)cancelEditingForEvent:(MWCalendarEvent *)event;
@end


@protocol MWCalendarEditingControllerProtocol <NSObject>
@property (nonatomic, strong) MWCalendarEvent *event;
@property (nonatomic, weak) MWWeekCalendarViewController <MWCalendarEditingControllerDelegate> *calendarVC;
@property (nonatomic) BOOL isCreationMode;
@end
