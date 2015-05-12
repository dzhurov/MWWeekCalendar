//
//  DayBodyCell.h
//  WeeklyCalendar
//
//  Created by DZhurov on 4/27/15.
//
//

#import <UIKit/UIKit.h>
#import "MWWeekEventView.h"

@interface DayBodyCell : UICollectionViewCell

@property (nonatomic, strong) UIColor *axisColor; //Default: lightGrayColor
/*! [MWWeekEventView]   */
@property (nonatomic, readonly) NSArray *eventViews;
/*! [MWWeekEvent]       */
@property (nonatomic, strong) NSArray *events;

- (void)addEventView:(MWWeekEventView*)eventView;

@end
