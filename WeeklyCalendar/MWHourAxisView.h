//
//  MWHourAxisView.h
//  WeeklyCalendar
//
//  Created by DZhurov on 4/30/15.
//
//

#import <UIKit/UIKit.h>

static const UIEdgeInsets kHoursAxisInset= {10.f, 64.f, 10.f, 0.f};

IB_DESIGNABLE
@interface MWHourAxisView : UIView

@property (nonatomic) IBInspectable CGFloat hourStepHeight;
@property (nonatomic) IBInspectable UIColor* axisColor;
@end
