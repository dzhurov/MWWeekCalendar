//
//  MWWeekEventView.m
//  WeeklyCalendar
//
//  Created by DZhurov on 5/7/15.
//
//

#import "MWWeekEventView.h"
#import "PureLayout.h"
#import "CGHelper.h"

static const float kNotSelectedAlpha = 0.2;

@implementation MWWeekEventView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self initialize];
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
    
    UIFont *titleFont =         [UIFont boldSystemFontOfSize:14.f];
    UIFont *descriptionFont =   [UIFont systemFontOfSize:12.f];
    
    self.titleLabel = [UILabel new];
    [self addSubview:self.titleLabel];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:1.f];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [self.titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.verticalLineView withOffset:2.f];
    self.titleLabel.font = titleFont;
    
    self.detailsLabel = [UILabel new];
    [self addSubview:self.detailsLabel];
    [self.detailsLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.titleLabel];
    [self.detailsLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:2.f];
    [self.detailsLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [self.detailsLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:2. relation:NSLayoutRelationLessThanOrEqual];
    self.detailsLabel.font = descriptionFont;
    self.detailsLabel.numberOfLines = 0;
}

#pragma mark - Getters/Setters

- (void)setEvent:(MWWeekEvent *)event
{
    _event = event;
    self.titleLabel.text = event.title;
    self.detailsLabel.text = event.eventDescription;
    self.verticalLineView.backgroundColor = _event.calendarColor;
    [self setSelected:self.selected];
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (_selected){
        self.backgroundColor = _event.calendarColor;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.detailsLabel.textColor = [UIColor whiteColor];
    }
    else{
        self.backgroundColor = [_event.calendarColor colorWithAlphaComponent:kNotSelectedAlpha];
        UIColor *textColor = [_event.calendarColor colorWithBrightnessMultiplier:0.5];
        self.titleLabel.textColor = textColor;
        self.detailsLabel.textColor = textColor;
    }
}

@end
