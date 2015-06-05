//
//  MWMonthCalendarViewController.h
//  TempMonthCalendar
//
//  Created by Andrey Durbalo on 6/2/15.
//  Copyright (c) 2015 Andrey Durbalo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWCalendarProtocols.h"

@interface MWMonthCalendarViewController : UIViewController

@property(nonatomic, weak) id <MWCalendarDataSource> calendarDataSource;

-(void)showToday;

@end
