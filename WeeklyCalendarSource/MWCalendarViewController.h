//
//  MWCalendarViewController.h
//  WeeklyCalendar
//
//  Created by Andrey Durbalo on 5/19/15.
//
//

#import <UIKit/UIKit.h>
#import "MWCalendarViewControllerProtocols.h"

@protocol MWCalendarDelegate, MWCalendarDataSource;

@interface MWCalendarViewController : UIViewController <MWCalendarViewControllerProtocol>

-(instancetype)initWithDelegate:(NSObject<MWCalendarDelegate>*)delegate andDataSource:(NSObject<MWCalendarDataSource>*)dataSource;

@end
