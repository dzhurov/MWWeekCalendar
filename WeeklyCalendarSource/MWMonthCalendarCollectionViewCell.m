//
//  MWMonthCalendarCollectionViewCell.m
//  TempMonthCalendar
//
//  Created by Andrey Durbalo on 6/2/15.
//  Copyright (c) 2015 Andrey Durbalo. All rights reserved.
//

#import "MWMonthCalendarCollectionViewCell.h"

@interface MWMonthCalendarCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *redRoundView;
@property (nonatomic, strong) NSDateFormatter *dateFormat;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftSeparatorViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSeparatorViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *event0Label;
@property (weak, nonatomic) IBOutlet UILabel *event1Label;
@property (weak, nonatomic) IBOutlet UILabel *event2Label;
@property (weak, nonatomic) IBOutlet UILabel *eventMoreLabel;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *eventLabels;

@end

@implementation MWMonthCalendarCollectionViewCell

- (void)awakeFromNib {
    
    self.dateFormat = [[NSDateFormatter alloc] init];
    
    CGFloat separatorWidth = 0.5;
    
    self.leftSeparatorViewWidthConstraint.constant = separatorWidth;
    self.topSeparatorViewHeightConstraint.constant = separatorWidth;
    
    self.redRoundView.layer.cornerRadius = CGRectGetHeight(self.redRoundView.frame)/2;
}

-(void)setEvents:(NSArray *)events
{
    _events = events;
    
    [self.eventLabels setValue:@YES forKeyPath:@"hidden"];
    
    [_events enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (idx < self.eventLabels.count) {
            
        }
        
    }];
}

-(void)setIsDayOff:(BOOL)isDayOff
{
    _isDayOff = isDayOff;
    
    if (_isDayOff) {
        self.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.05];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

-(void)configurateWithObject:(id)object
{
    if ([object isKindOfClass:[NSNull class]]) {
        self.dateLabel.text = @"";
        return;
    }
    
    NSDate *date = object;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitMonth fromDate:date];
    
    if (components.day == 1) {
        [self.dateFormat setDateFormat:@"MMM dd"];
    } else {
        [self.dateFormat setDateFormat:@"dd"];
    }
    self.dateLabel.text = [self.dateFormat stringFromDate:date];
    
    UIColor *textLabelBackgroundColor = [UIColor clearColor];
    UIColor *textColor = [UIColor blackColor];
    
    self.redRoundView.hidden = YES;
    
    if ([[NSCalendar currentCalendar] isDateInToday:date]) {
        self.redRoundView.hidden = NO;
        textColor = [UIColor whiteColor];
    } else if ( components.weekday == 7 || components.weekday == 1) { //Weekend
        textColor = [UIColor grayColor];
    }
    
    self.dateLabel.backgroundColor = textLabelBackgroundColor;
    self.dateLabel.textColor = textColor;
}

+(NSString*)identifier
{
    return NSStringFromClass([self class]);
}

@end
