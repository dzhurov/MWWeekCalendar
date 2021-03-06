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

- (void)addTemporaryEventView:(MWWeekEventView *)eventView
{
    [eventView removeFromSuperview];
    eventView.frame = eventView.bounds;
    [self.eventViewsContainer addSubview:eventView];
    CGFloat relatedHeight = eventView.event.duration / (60. * 60. * 24.);
    CGFloat relatedYPosition = [eventView.event.startDate timeIntervalSinceDate:[eventView.event.startDate dateAtStartOfDay]] / (60. * 60. * 24.);
    if (relatedYPosition == 0) {
        relatedYPosition = 0.0001;
    }
    [eventView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.eventViewsContainer withMultiplier:relatedHeight];
    [eventView autoConstrainAttribute:ALAttributeTop toAttribute:ALAttributeBottom ofView:self.eventViewsContainer withMultiplier:relatedYPosition];
    [eventView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    eventView.trailing  = [eventView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
}

- (void)addEventView:(MWWeekEventView *)eventView
{
    NSAssert(eventView.event, @"Event View must contain event");
    
    MWWeekEventView *theMostRightEventView = [self theMostRightEventViewIntersectedWithStartTime:eventView.event.startDate];
    [self.eventViewsContainer addSubview:eventView];
    
    CGFloat relatedHeight = eventView.event.duration / (60. * 60. * 24.);
    CGFloat relatedYPosition = [eventView.event.startDate timeIntervalSinceDate:[eventView.event.startDate dateAtStartOfDay]] / (60. * 60. * 24.);
    if (relatedYPosition == 0) {
        relatedYPosition = 0.0001;
    }
    
    [eventView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.eventViewsContainer withMultiplier:relatedHeight];
    [eventView autoConstrainAttribute:ALAttributeTop toAttribute:ALAttributeBottom ofView:self.eventViewsContainer withMultiplier:relatedYPosition];
    
    if (theMostRightEventView == nil) {
        [eventView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    }
    else {
        theMostRightEventView.trailing = [theMostRightEventView autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:eventView];
        [eventView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:theMostRightEventView];
    }
}

- (MWWeekEventView *)theMostRightEventViewIntersectedWithStartTime:(NSDate *)time
{
    NSArray *eventViews = [self eventViews];
    if (eventViews.count == 0) {
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event.startDate <= %@ && event.endDate > %@", time, time];
    NSArray *filteredArray = [eventViews filteredArrayUsingPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"event.startDate" ascending:YES];
    NSArray *sortedArray = [filteredArray sortedArrayUsingDescriptors:@[sortDescriptor]];
    return [sortedArray lastObject];
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
        if (CGRectContainsPoint(eventView.frame, [self.eventViewsContainer convertPoint:position fromView:self])) {
            return eventView;
        }
    }
    return nil;
}

- (void)setEvents:(NSArray *)events
{
    [self.eventViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (MWCalendarEvent *event in [events sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES]]]) {
        MWWeekEventView *eventView = [MWWeekEventView new];
        eventView.delegate = self;
        eventView.event = event;
        eventView.alpha = 1;
        [self addEventView:eventView];
    }
    
    for (MWWeekEventView *eventView in [self eventViews]) {
        if (eventView.trailing == nil) {
            eventView.trailing  = [eventView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
        }
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
