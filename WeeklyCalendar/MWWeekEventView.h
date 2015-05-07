//
//  MWWeekEventView.h
//  WeeklyCalendar
//
//  Created by DZhurov on 5/7/15.
//
//

#import <UIKit/UIKit.h>

@interface MWWeekEventView : UIView

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) UIColor *calendarColor;       // default R27 G173 B248
@property (nonatomic, strong) UIColor *titleColor;          // default R0 G60 B87
@property (nonatomic, strong) UIColor *selectedTitleColor;  // default is whiteColor
@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) UIView *verticalLineView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailsLabel;
@end
