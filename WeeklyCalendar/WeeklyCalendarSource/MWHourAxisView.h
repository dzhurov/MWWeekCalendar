//
//  MWHourAxisView.h
//  WeeklyCalendar
//
//  Created by DZhurov on 4/30/15.
//
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface MWHourAxisView : UIView

@property (nonatomic) IBInspectable CGFloat hourStepHeight;
@property (nonatomic) IBInspectable UIColor* axisColor;
@property (nonatomic) BOOL showCurrentDate;
@property (nonatomic, strong) NSDateComponents *startWorkingDay; // hours and minutes
@property (nonatomic, strong) NSDateComponents *endWorkingDay; // hours and minutes

/*! @return time date for current touch NOTE: use only time (hours and minutes) from returned value */
- (NSDate*)showEventTimeForTouch:(CGPoint)touchPoint;
- (void)hideEventTouch;

@end
