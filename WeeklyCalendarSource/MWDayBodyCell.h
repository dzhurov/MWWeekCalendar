//
//  MWDayBodyCell.h
//  WeeklyCalendar
//
//  Created by DZhurov on 4/27/15.
//
//

#import <UIKit/UIKit.h>
#import "MWWeekEventView.h"

@protocol MWDayBodyCellDelegate;

@interface MWDayBodyCell : UICollectionViewCell

@property (nonatomic, strong) UIColor *axisColor; //Default: lightGrayColor
/*! [MWWeekEvent]       */
@property (nonatomic, copy) NSArray *events;
@property (nonatomic, weak) id <MWDayBodyCellDelegate> delegate;

- (MWWeekEventView *)eventViewForEvent:(MWCalendarEvent *)event;
- (MWWeekEventView *)eventViewForPosition:(CGPoint)position;
- (void)addTemporaryEventView:(MWWeekEventView *)eventView;

@end

@protocol MWDayBodyCellDelegate <NSObject>

- (void)dayBodyCell:(MWDayBodyCell *)cell eventDidTapped:(MWCalendarEvent *)event;

@end
