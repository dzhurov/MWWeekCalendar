//
//  DayBodyCell.m
//  WeeklyCalendar
//
//  Created by DZhurov on 4/27/15.
//
//

#import "DayBodyCell.h"
#import "CGHelper.h"
#import "MWWeekCalendarConsts.h"
#import <PureLayout.h>

@interface DayBodyCell ()

@property (nonatomic, strong) NSMutableArray *eventViews;
@property (weak, nonatomic) IBOutlet UIView *eventViewsContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventContainerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventContainerBottomConstraint;

@end

@implementation DayBodyCell

- (void)awakeFromNib
{
    self.axisColor = [UIColor lightGrayColor];
    _eventViews = [NSMutableArray new];
    _events = [NSMutableArray new];
    self.eventContainerTopConstraint.constant = kHoursAxisInset.top;
    self.eventContainerBottomConstraint.constant = kHoursAxisInset.bottom;
    [self setNeedsDisplay];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();

    draw1PxStroke(context,
                  CGPointMake(CGRectGetMaxX(rect) - 0.5,
                              kHoursAxisInset.top),
                  CGPointMake(CGRectGetMaxX(rect) - 0.5,
                              CGRectGetMaxY(rect) - kHoursAxisInset.bottom),
                  self.axisColor.CGColor);
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self setNeedsDisplay];
}

- (void)addEventView:(MWWeekEventView *)eventView
{
    NSAssert(eventView.event, @"Event View must contain event");
    
}

@end
