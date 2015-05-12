//
//  MWWeekEventView.h
//  WeeklyCalendar
//
//  Created by DZhurov on 5/7/15.
//
//

#import <UIKit/UIKit.h>
#import "MWWeekEvent.h"

@interface MWWeekEventView : UIView

@property (nonatomic, strong) MWWeekEvent *event;
@property (nonatomic) BOOL selected;

@property (nonatomic, strong) UIView *verticalLineView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailsLabel;
@end
