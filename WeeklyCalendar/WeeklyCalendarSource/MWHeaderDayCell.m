//
//  HeaderDayCell.m
//  WeeklyCalendar
//
//  Created by DZhurov on 4/27/15.
//
//

#import "MWHeaderDayCell.h"
#import "NSDate+MWWeeklyCalendar.h"
#import "UIColor+MWWeeklyCalendar.h"

@implementation MWHeaderDayCell

- (void)awakeFromNib
{
    self.dayOfMonthLabel.layer.cornerRadius = self.dayOfMonthLabel.frame.size.height / 2;
    [self.dayOfMonthLabel.layer setMasksToBounds:YES];
}

- (void)setDate:(NSDate *)date selected:(BOOL)selected weekend:(BOOL)weekend
{
    self.dayOfMonthLabel.text = [NSDate dayOfMonthOfDate:date];
    self.dayOfWeekLabel.text = [NSDate dayOfWeekOfDate:date];
    
    if (weekend){
        self.dayOfWeekLabel.textColor = [UIColor lightGrayColor];
        self.dayOfMonthLabel.textColor = [UIColor lightGrayColor];
    }
    else{
        self.dayOfWeekLabel.textColor = [UIColor blackColor];
        self.dayOfMonthLabel.textColor = [UIColor blackColor];
    }
    
    if (selected){
        self.dayOfWeekLabel.textColor = [UIColor blackColor];
        self.dayOfMonthLabel.textColor = [UIColor whiteColor];
        self.dayOfMonthLabel.backgroundColor = [UIColor MWBadgeRedColor];
    }
    else{
        self.dayOfMonthLabel.backgroundColor = [UIColor clearColor];
    }
}

@end
