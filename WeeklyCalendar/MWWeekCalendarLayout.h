//
//  MWWeekCalendarLayout.h
//  WeeklyCalendar
//
//  Created by DZhurov on 5/14/15.
//
//

#import <UIKit/UIKit.h>

@interface MWWeekCalendarLayout : UICollectionViewFlowLayout

@property (nonatomic) NSUInteger numberOfVisibleDays;
@property (nonatomic, weak) id delegate;


@end

@protocol MWWeekCalendarLayoutDelegate <UICollectionViewDelegateFlowLayout>
@required
- (CGFloat)calendarLayoutCellWidth:(MWWeekCalendarLayout*)calendarLayotu;

@end
