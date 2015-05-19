//
//  MWWeekEvent.h
//  WeeklyCalendar
//
//  Created by DZhurov on 5/12/15.
//
//

#import <UIKit/UIKit.h>

@interface MWCalendarEvent : NSObject <NSCopying>

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *eventDescription;
@property (nonatomic, strong) UIColor *calendarColor;       // default R27 G173 B248

+ (instancetype)eventWithStartDate:(NSDate*)startDate endDate:(NSDate*)endDate;
- (NSTimeInterval)duration;

@end
