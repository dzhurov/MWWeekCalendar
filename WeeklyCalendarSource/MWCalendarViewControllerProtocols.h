//
//  MWCalendarViewControllerProtocols.h
//  WeeklyCalendar
//
//  Created by Andrey Durbalo on 5/19/15.
//
//

#ifndef WeeklyCalendar_MWCalendarViewControllerProtocols_h
#define WeeklyCalendar_MWCalendarViewControllerProtocols_h

@protocol MWCalendarViewControllerProtocol <NSObject>
-(void)showEditingController:(UIViewController *)editingController fromRect:(CGRect)rect inView:(UIView*)view completion:(void (^)())completion;
-(void)hideEditingController:(UIViewController *)editingController completion:(void (^)())completion;
@end


#endif
