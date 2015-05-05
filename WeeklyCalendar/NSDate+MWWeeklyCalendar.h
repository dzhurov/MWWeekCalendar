//
//  NSDate+MWWeeklyCalendar.h
//  WeeklyCalendar
//
//  Created by DZhurov on 5/5/15.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (MWWeeklyCalendar)

+ (NSDateComponents *)componentsOfDate:(NSDate *)date;
+ (NSString *)timeStringFromDate:(NSDate *)date;


@end
