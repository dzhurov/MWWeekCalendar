//
//  MWDayBodyCell.m
//  WeeklyCalendar
//
//  Created by DZhurov on 4/27/15.
//
//

#import "MWDayBodyCell.h"
#import "CGHelper.h"
#import "MWWeekCalendarConsts.h"
#import <PureLayout.h>
#import "NSDate+Utilities.h"

@interface MWDayBodyCell () <MWWeekEventViewDelegate>
{
    NSMutableArray *_events;
}

@property (weak, nonatomic) IBOutlet UIView *eventViewsContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventContainerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventContainerBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorWidthConstraint;

@end

@implementation MWDayBodyCell

- (void)awakeFromNib
{
    self.axisColor = [UIColor lightGrayColor];
    _events = [NSMutableArray new];
    self.eventContainerTopConstraint.constant = kHoursAxisInset.top;
    self.eventContainerBottomConstraint.constant = kHoursAxisInset.bottom;
    [self setNeedsDisplay];
    self.separatorWidthConstraint.constant = onePx();
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self setNeedsDisplay];
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

- (MWWeekEventView *)eventViewForPosition:(CGPoint)position
{
    for (MWWeekEventView *eventView in self.eventViews) {
        if (CGRectContainsPoint(CGRectMake(0, eventView.frame.origin.y, 2, eventView.frame.size.height), CGPointMake(1, position.y))) {
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
        eventView.alpha = 1;
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
