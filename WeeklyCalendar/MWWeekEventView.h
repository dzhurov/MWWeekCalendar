//
//  MWWeekEventView.h
//  WeeklyCalendar
//
//  Created by DZhurov on 5/7/15.
//
//

#import <UIKit/UIKit.h>
#import "MWWeekEvent.h"

@protocol MWWeekEventViewDelegate;

@interface MWWeekEventView : UIView

@property (nonatomic, strong) MWWeekEvent *event;
@property (nonatomic) BOOL selected;

@property (nonatomic, strong) UIView *verticalLineView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailsLabel;
@property (nonatomic, weak) id <MWWeekEventViewDelegate> delegate;

@end

@protocol MWWeekEventViewDelegate <NSObject>

- (void)weekEventViewDidTap:(MWWeekEventView *)weekEventView;

@end
