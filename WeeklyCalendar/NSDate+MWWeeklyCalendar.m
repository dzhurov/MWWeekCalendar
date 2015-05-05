//
//  NSDate+MWWeeklyCalendar.m
//  WeeklyCalendar
//
//  Created by DZhurov on 5/5/15.
//
//

#import "NSDate+MWWeeklyCalendar.h"

@implementation NSDate (MWWeeklyCalendar)


+ (NSDateFormatter *)timeDateFormatter
{
    static NSDateFormatter *dateFormater = nil;
    if (!dateFormater){
        dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:@"h a"];
    }
    return dateFormater;
}

+ (NSDateComponents *)componentsOfDate:(NSDate *)date
{
    
    return [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth| NSCalendarUnitHour |
            NSCalendarUnitMinute fromDate:date];
}

+ (NSString *)timeStringFromDate:(NSDate *)date
{
    return [[self timeDateFormatter] stringFromDate:date];
}

@end
