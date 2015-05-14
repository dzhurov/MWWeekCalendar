//
//  MWEventsContainer.h
//  WeeklyCalendar
//
//  Created by Sergey Konovorotskiy on 5/14/15.
//
//

#import <Foundation/Foundation.h>

@class MWWeekEvent;

@interface MWEventsContainer : NSObject

- (void)addEvent:(MWWeekEvent *)event forDate:(NSDate *)date;
- (NSArray *)eventsForDay:(NSDate *)day;

@end
