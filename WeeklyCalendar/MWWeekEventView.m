//
//  MWWeekEventView.m
//  WeeklyCalendar
//
//  Created by DZhurov on 5/7/15.
//
//

#import "MWWeekEventView.h"
#import "PureLayout.h"

static const float kNotSelectedAlpha = 0.2;

@implementation MWWeekEventView

@dynamic calendarColor;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self initialize];
    self.calendarColor = [UIColor colorWithRed:27 / 255. green:173 / 255. blue:248 / 255. alpha:1.];
    self.titleColor = [UIColor colorWithRed:0 / 255. green:60 / 255. blue:87 / 255. alpha:1.f];
    self.selectedTitleColor = [UIColor whiteColor];
    
    self.titleLabel.text = @"Hello Event";
    self.detailsLabel.text = @"This is a description of the event";
    
    return self;
}

- (void)initialize
{
    self.verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2., self.bounds.size.height)];
    [self addSubview:self.verticalLineView];
    [self.verticalLineView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.verticalLineView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [self.verticalLineView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.verticalLineView autoSetDimension:ALDimensionWidth toSize:2.];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(4., 1., 0., 0.)];
    [self addSubview:self.titleLabel];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:1.f];
    [self.titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.verticalLineView withOffset:2.f];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
    
    self.detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(4., 17., 0, 0)];
    [self addSubview:self.detailsLabel];
    [self.detailsLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.titleLabel];
    [self.detailsLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:2.f];
    self.detailsLabel.font = [UIFont systemFontOfSize:12.f];
    self.detailsLabel.numberOfLines = 0;
}

#pragma mark - Getters/Setters

- (UIColor *)calendarColor { return self.verticalLineView.backgroundColor; }
- (void)  setCalendarColor:(UIColor *)calendarColor
{
    self.verticalLineView.backgroundColor = calendarColor;
    self.backgroundColor = [calendarColor colorWithAlphaComponent:kNotSelectedAlpha];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    self.titleLabel.textColor = _titleColor;
    self.detailsLabel.textColor = _titleColor;
}

@end
