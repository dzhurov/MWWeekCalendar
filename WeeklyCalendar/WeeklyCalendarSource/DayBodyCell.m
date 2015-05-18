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
#import "NSDate+Utilities.h"

@interface DayBodyCell () <MWWeekEventViewDelegate>
{
    NSMutableArray *_events;
}

@property (weak, nonatomic) IBOutlet UIView *eventViewsContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventContainerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventContainerBottomConstraint;

@end

@implementation DayBodyCell

- (void)awakeFromNib
{
    self.axisColor = [UIColor lightGrayColor];
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
                              kHoursAxisInset.top + 0.5),
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
    
    [self.eventViewsContainer addSubview:eventView];
    
    CGFloat relatedHeight = eventView.event.duration / (60. * 60. * 24.);
    CGFloat relatedYPosition = [eventView.event.startDate timeIntervalSinceDate:[eventView.event.startDate dateAtStartOfDay]] / (60. * 60. * 24.);
    if (relatedYPosition == 0)
        relatedYPosition = 0.0001;
    
    [eventView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.eventViewsContainer withMultiplier:relatedHeight];
    [eventView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [eventView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [eventView autoConstrainAttribute:ALAttributeTop toAttribute:ALAttributeBottom ofView:self.eventViewsContainer withMultiplier:relatedYPosition];
    [_events addObject:eventView.event];
}

- (NSArray *)eventViews
{
    return self.eventViewsContainer.subviews;
}

- (MWWeekEventView *)eventViewForEvent:(MWCalendarEvent *)event
{
    for (MWWeekEventView *eventView in self.eventViews) {
        if (eventView.event == event) {
            return eventView;
        }
    }
    return nil;
}

- (void)setEvents:(NSArray *)events
{
    [self.eventViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (MWCalendarEvent *event in events) {
        MWWeekEventView *eventView = [MWWeekEventView new];
        eventView.delegate = self;
        eventView.event = event;
        [self addEventView:eventView];
    }
    _events = [events mutableCopy];
}

#pragma mark -MWWeekEventViewDelegate <NSObject>

- (void)weekEventViewDidTap:(MWWeekEventView *)weekEventView
{
    if ([self.delegate respondsToSelector:@selector(dayBodyCell:eventDidTapped:)]) {
        [self.delegate dayBodyCell:self eventDidTapped:weekEventView.event];
    }
}

@end
