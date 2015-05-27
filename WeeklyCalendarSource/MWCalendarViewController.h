//
//  MWCalendarViewController.h
//  WeeklyCalendar
//
//  Created by Andrey Durbalo on 5/19/15.
//
//

#import <UIKit/UIKit.h>
#import "MWCalendarViewControllerProtocols.h"

@class MWWeekCalendarViewController;
@protocol MWCalendarDelegate, MWCalendarDataSource;

@interface MWCalendarViewController : UIViewController <MWCalendarViewControllerProtocol>

-(instancetype)initWithDelegate:(NSObject<MWCalendarDelegate>*)delegate andDataSource:(NSObject<MWCalendarDataSource>*)dataSource;

@property (nonatomic, readonly) MWWeekCalendarViewController *weekCalendarVC;

@end
