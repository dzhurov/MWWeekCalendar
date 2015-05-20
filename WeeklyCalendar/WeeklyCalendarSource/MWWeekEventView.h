//
//  MWWeekEventView.h
//  WeeklyCalendar
//
//  Created by DZhurov on 5/7/15.
//
//

#import <UIKit/UIKit.h>
#import "MWCalendarEvent.h"

@protocol MWWeekEventViewDelegate;

@interface MWWeekEventView : UIView

@property (nonatomic, strong) MWCalendarEvent *event;
@property (nonatomic) BOOL selected;

@property (nonatomic, weak) id <MWWeekEventViewDelegate> delegate;
@property (nonatomic, weak) NSLayoutConstraint *trailing;

@end

@protocol MWWeekEventViewDelegate <NSObject>

- (void)weekEventViewDidTap:(MWWeekEventView *)weekEventView;

@end
