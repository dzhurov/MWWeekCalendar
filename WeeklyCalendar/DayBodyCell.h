//
//  DayBodyCell.h
//  WeeklyCalendar
//
//  Created by DZhurov on 4/27/15.
//
//

#import <UIKit/UIKit.h>
#import "MWWeekEventView.h"

@protocol DayBodyCellDelegate;

@interface DayBodyCell : UICollectionViewCell

@property (nonatomic, strong) UIColor *axisColor; //Default: lightGrayColor
/*! [MWWeekEvent]       */
@property (nonatomic, copy) NSArray *events;
@property (nonatomic, weak) id <DayBodyCellDelegate> delegate;

- (MWWeekEventView *)eventViewForEvent:(MWWeekEvent *)event;

@end

@protocol DayBodyCellDelegate <NSObject>

- (void)dayBodyCell:(DayBodyCell *)cell eventDidTapped:(MWWeekEvent *)event;

@end
