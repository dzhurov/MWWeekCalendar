//
//  MWCalendarProtocols.h
//  Pods
//
//  Created by Andrey Durbalo on 6/5/15.
//
//

#ifndef Pods_MWCalendarProtocols_h
#define Pods_MWCalendarProtocols_h

typedef NS_ENUM(NSUInteger, MWCalendarEditingPresentationMode) {
    MWCalendarEditingPresentationModeSideMenu = 0,
    MWCalendarEditingPresentationModePopover,
    MWCalendarEditingPresentationModeModal
};

@class MWCalendarEvent;

@protocol MWCalendarEditingControllerProtocol;

@protocol MWCalendarDelegate <NSObject>
@optional
- (void)calendarController:(UIViewController *)controller didScrollToStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
- (BOOL)calendarController:(UIViewController *)controller shouldAddEventForStartDate:(NSDate *)startDate;
- (void)calendarController:(UIViewController *)controller didAddEvent:(MWCalendarEvent *)event;
- (BOOL)calendarController:(UIViewController *)controller shouldStartEditingForEvent:(MWCalendarEvent *)event;
- (void)calendarController:(UIViewController *)controller removeEvent:(MWCalendarEvent *)event;
- (void)calendarController:(UIViewController *)controller saveEvent:(MWCalendarEvent *)event withNew:(MWCalendarEvent *)newEvent isMoving:(BOOL)isMoving;
@end

@protocol MWCalendarDataSource <NSObject>
/*! [MWCalendarEvent]   */
- (NSArray *)calendarController:(UIViewController *)controller eventsForDate:(NSDate *)date;
- (UIViewController <MWCalendarEditingControllerProtocol> *)calendarController:(UIViewController *)controller
                                                     editingControllerForEvent:(MWCalendarEvent *)event;
- (MWCalendarEditingPresentationMode)calendarEditingPresentationMode;
- (MWCalendarEvent *)calendarController:(UIViewController *)controller newEventForStartDate:(NSDate *)startDate;
@end

@protocol MWCalendarViewControllerProtocol <NSObject>
-(void)showEditingController:(UIViewController *)editingController fromRect:(CGRect)rect inView:(UIView*)view completion:(void (^)())completion;
-(void)hideEditingController:(UIViewController *)editingController completion:(void (^)())completion;
@end

#endif
