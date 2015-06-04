//
//  NSDate+MWWeeklyCalendar.m
//  WeeklyCalendar
//
//  Created by DZhurov on 5/5/15.
//
//

#import "NSDate+MWWeeklyCalendar.h"

@implementation NSDate (MWWeeklyCalendar)

+ (NSDateFormatter *)dateFormatterWithFormat:(NSString*)format
{
    static NSMutableDictionary *formatsToFormattes = nil;
    if (!formatsToFormattes){
        formatsToFormattes = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    NSDateFormatter *formatter = formatsToFormattes[format];
    if (!formatter){
        formatter = [NSDateFormatter new];
        formatter.dateFormat = format;
        formatsToFormattes[format] = formatter;
    }
    return formatter;
}

+ (NSDateFormatter *)timeDateFormatter
{
    return [self dateFormatterWithFormat:@"h a"];
}

- (NSDateComponents *)dateComponents
{
    return [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth| NSCalendarUnitWeekOfYear | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:self];
}

+ (NSString *)timeStringFromDate:(NSDate *)date
{
    return [[self timeDateFormatter] stringFromDate:date];
}

+ (NSString *)dayOfWeekOfDate:(NSDate *)date
{
    NSDateFormatter *formatter = [self dateFormatterWithFormat:@"E"];
    return [formatter stringFromDate:date];
}

+ (NSString *)dayOfMonthOfDate:(NSDate *)date
{
    NSDateFormatter *formatter = [self dateFormatterWithFormat:@"d"];
    return [formatter stringFromDate:date];
}

+ (NSString *)monthOfDate:(NSDate *)date
{
    NSDateFormatter *formatter = [self dateFormatterWithFormat:@"MMM"];
    return [formatter stringFromDate:date];
}

- (BOOL)isToday
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSUInteger componentsMask = NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    NSDateComponents *components = [cal components:componentsMask fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:componentsMask fromDate:self];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    return [today isEqualToDate:otherDate];
}


@end
