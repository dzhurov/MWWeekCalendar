//
//  MWMonthCalendarViewController.m
//  TempMonthCalendar
//
//  Created by Andrey Durbalo on 6/2/15.
//  Copyright (c) 2015 Andrey Durbalo. All rights reserved.
//

#import "MWMonthCalendarViewController.h"
#import "MWMonthCalendarCollectionViewCell.h"
#import "MWWeekdayTitleCollectionViewCell.h"

#import "NSDate+Utilities.h"
#import "NSDate+MWWeeklyCalendar.h"

@interface MWMonthCalendarViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *calendarCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *weekdayTitleCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *monthAndYearLabel;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic) NSUInteger numberOfVisibleWeeks;
@property (nonatomic) NSUInteger numberOfRealPages;
@property (nonatomic) NSUInteger numberOfVirtualPages;
@property (nonatomic) NSInteger currentWeekIndex;

@end

#define DAYS_IN_WEEK 7
#define MONTH_IN_YEAR 12
#define INSET 0.5

@implementation MWMonthCalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configurateCollectionViews];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configurate];
    [self.calendarCollectionView.collectionViewLayout invalidateLayout];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self scrollToDate:[NSDate date]];
}

-(void)configurate
{
    self.numberOfVisibleWeeks = CGRectGetHeight(self.calendarCollectionView.frame)*DAYS_IN_WEEK/CGRectGetWidth(self.calendarCollectionView.frame);
    self.numberOfRealPages = 5;
    self.numberOfVirtualPages = self.numberOfRealPages + 2;
    self.currentWeekIndex = (self.numberOfVirtualPages / 2) * self.numberOfVisibleWeeks;
    
    [self.calendarCollectionView reloadData];
    [self updateMonthAndYearLabel];
}

- (void)configurateCollectionViews
{
    [self.calendarCollectionView registerNib:[UINib  nibWithNibName:NSStringFromClass([MWMonthCalendarCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:[MWMonthCalendarCollectionViewCell identifier]];
    self.calendarCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    [self.weekdayTitleCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([MWWeekdayTitleCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:[MWWeekdayTitleCollectionViewCell identifier]];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.calendarCollectionView.collectionViewLayout invalidateLayout];
    [self.weekdayTitleCollectionView.collectionViewLayout invalidateLayout];
}

-(void)updateMonthAndYearLabel
{
    if (!self.dateFormatter) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"MMMM YYYY"];
    }
    
    self.monthAndYearLabel.text = [self.dateFormatter stringFromDate:[self centralDate]];
}

-(NSDate*)dateByIndexPath:(NSIndexPath*)indexPath
{
    NSDate *firstDayOfWeek = [NSDate dateWithTimeIntervalSinceNow:(indexPath.section - self.currentWeekIndex)*D_WEEK];
    firstDayOfWeek = [firstDayOfWeek dateAtStartOfDay];
    NSUInteger weekDay = [[firstDayOfWeek dateComponents] weekday];
    NSInteger daysDiff = (indexPath.row - weekDay + 1);
    NSDate *resultDate = [firstDayOfWeek dateByAddingDays:daysDiff];
    return resultDate;
}

-(NSIndexPath*)indexPathAfterIndexPath:(NSIndexPath*)indexPath
{
    NSInteger row = indexPath.row==6?0:indexPath.row+1;
    NSInteger section = indexPath.row==6?indexPath.section+1:indexPath.section;
    return [NSIndexPath indexPathForRow:row inSection:section];
}

-(void)scrollToDate:(NSDate*)targetDate
{
    NSInteger diff = [targetDate timeIntervalSinceDate:[self centralDate]]/D_WEEK;
    NSInteger weeksToShow = self.numberOfRealPages * self.numberOfVisibleWeeks;
    self.currentWeekIndex -= (diff/weeksToShow)*weeksToShow;

    CGPoint offset = self.calendarCollectionView.contentOffset;
    offset.y += (diff%weeksToShow)*CGRectGetWidth(self.calendarCollectionView.frame)/DAYS_IN_WEEK;
    
    self.calendarCollectionView.contentOffset = offset;
    [self.calendarCollectionView reloadData];
    
    [self updateMonthAndYearLabel];
}

-(NSDate*)centralDate
{
    CGPoint centerPoint = CGPointMake(self.calendarCollectionView.frame.size.width / 2 + self.calendarCollectionView.contentOffset.x, self.calendarCollectionView.frame.size.height /2 + self.calendarCollectionView.contentOffset.y);
    NSIndexPath *indexPath = [self.calendarCollectionView indexPathForItemAtPoint:centerPoint];
    
    NSDate *centralDate = [self dateByIndexPath:indexPath];
    return centralDate;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return DAYS_IN_WEEK;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    if (collectionView == self.weekdayTitleCollectionView) {
        return 1;
    }
    
    return self.numberOfVisibleWeeks * self.numberOfVirtualPages;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isDayOff = (indexPath.row%DAYS_IN_WEEK==0) || (indexPath.row%(DAYS_IN_WEEK-1)==0);
    
    if (collectionView == self.weekdayTitleCollectionView) {
        MWWeekdayTitleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[MWWeekdayTitleCollectionViewCell identifier] forIndexPath:indexPath];
        cell.textLabel.text = [[NSCalendar currentCalendar] shortWeekdaySymbols][indexPath.row];
        cell.textLabel.textColor = isDayOff?[UIColor grayColor]:[UIColor blackColor];
        return cell;
    }
    
    MWMonthCalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[MWMonthCalendarCollectionViewCell identifier] forIndexPath:indexPath];
    
    NSDate *date = [self dateByIndexPath:indexPath];
    [cell configurateWithObject:date];
    cell.events = [self.calendarDataSource calendarController:self eventsForDate:date];
    cell.isDayOff = isDayOff;
    return cell;
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.weekdayTitleCollectionView) {
        return NO;
    }
    return [[self dateByIndexPath:indexPath] isKindOfClass:[NSDate class]];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", [self dateByIndexPath:indexPath]);
}

#pragma mark - 

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemWidth = CGRectGetWidth(collectionView.frame)/DAYS_IN_WEEK;
    CGFloat itemHeight = itemWidth;
    
    UIEdgeInsets insets = [self collectionView:collectionView layout:collectionViewLayout insetForSectionAtIndex:indexPath.section];
    
    if (collectionView == self.weekdayTitleCollectionView) {
        itemHeight = CGRectGetHeight(collectionView.frame);
    }
    
    return CGSizeMake(itemWidth - insets.left - insets.right, itemHeight - insets.top - insets.bottom);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(INSET, INSET, INSET, INSET);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return INSET;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
{
    return INSET;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self configurateScrollView:scrollView];
}

-(void)configurateScrollView:(UIScrollView*)scrollView
{
    static CGFloat lastContentOffsetY = FLT_MIN;
    if (FLT_MIN == lastContentOffsetY) {
        lastContentOffsetY = scrollView.contentOffset.y;
        return;
    }
    CGFloat currentOffsetX = lroundf(scrollView.contentOffset.x);
    CGFloat currentOffsetY = lroundf(scrollView.contentOffset.y);
    CGFloat oneWeekHeight = lroundf(CGRectGetWidth(self.calendarCollectionView.frame)/DAYS_IN_WEEK);
    CGFloat pageHeight = lroundf(oneWeekHeight * self.numberOfVisibleWeeks);
    CGFloat offset = lroundf(pageHeight * self.numberOfRealPages);
    
    // the first page(showing the last item) is visible and user is still scrolling to the left
    if (currentOffsetY < pageHeight && lastContentOffsetY > currentOffsetY) {
        lastContentOffsetY = currentOffsetY + offset;
        scrollView.contentOffset = (CGPoint){currentOffsetX, lastContentOffsetY};
        self.currentWeekIndex += self.numberOfRealPages * self.numberOfVisibleWeeks;
    }
    // the last page (showing the first item) is visible and the user is still scrolling to the right
    else if (currentOffsetY > offset && lastContentOffsetY < currentOffsetY) {
        lastContentOffsetY = currentOffsetY - offset;
        scrollView.contentOffset = (CGPoint){currentOffsetX, lastContentOffsetY};
        self.currentWeekIndex -= self.numberOfRealPages * self.numberOfVisibleWeeks;
    } else {
        lastContentOffsetY = currentOffsetY;
    }
    
    [self updateMonthAndYearLabel];
}

#pragma mark - Public

-(void)showToday
{
    [self scrollToDate:[NSDate date]];
}

@end
