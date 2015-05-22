//
//  NSDate+MWWeeklyCalendar.h
//  WeeklyCalendar
//
//  Created by DZhurov on 5/5/15.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (MWWeeklyCalendar)

- (NSDateComponents *)dateComponents;
+ (NSString *)timeStringFromDate:(NSDate *)date;
+ (NSString *)dayOfWeekOfDate:(NSDate *)date;
+ (NSString *)dayOfMonthOfDate:(NSDate *)date;
+ (NSString *)monthOfDate:(NSDate *)date;
- (BOOL)isToday;

@end
