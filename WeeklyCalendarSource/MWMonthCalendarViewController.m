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

-(id)objectByIndexPath:(NSIndexPath*)indexPath
{
    NSDate *firstDayOfWeek = [NSDate dateWithTimeIntervalSinceNow:(indexPath.section - self.currentWeekIndex)*D_WEEK];
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
    
    self.calendarCollectionView.contentOffset = CGPointMake(self.calendarCollectionView.contentOffset.x, self.calendarCollectionView.contentOffset.y + diff * CGRectGetWidth(self.calendarCollectionView.frame)/DAYS_IN_WEEK);
    
    [self.calendarCollectionView reloadData];
}

-(NSDate*)centralDate
{
    CGPoint centerPoint = CGPointMake(self.calendarCollectionView.frame.size.width / 2 + self.calendarCollectionView.contentOffset.x, self.calendarCollectionView.frame.size.height /2 + self.calendarCollectionView.contentOffset.y);
    NSIndexPath *indexPath = [self.calendarCollectionView indexPathForItemAtPoint:centerPoint];
    
    NSDate *centralDate = [self objectByIndexPath:indexPath];
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
    if (collectionView == self.weekdayTitleCollectionView) {
        MWWeekdayTitleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[MWWeekdayTitleCollectionViewCell identifier] forIndexPath:indexPath];
        cell.textLabel.text = [[NSCalendar currentCalendar] shortWeekdaySymbols][indexPath.row];
        return cell;
    }
    
    MWMonthCalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[MWMonthCalendarCollectionViewCell identifier] forIndexPath:indexPath];
    [cell configurateWithObject:[self objectByIndexPath:indexPath]];
    //cell.isDayOff = (indexPath.row%DAYS_IN_WEEK==0) || (indexPath.row%(DAYS_IN_WEEK-1)==0);
    return cell;
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.weekdayTitleCollectionView) {
        return NO;
    }
    return [[self objectByIndexPath:indexPath] isKindOfClass:[NSDate class]];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", [self objectByIndexPath:indexPath]);
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

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    if (scrollView == self.calendarCollectionView && !decelerate) {
//        [self configurateScrollView:self.calendarCollectionView];
//    }
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    if (scrollView == self.calendarCollectionView) {
//        [self configurateScrollView:self.calendarCollectionView];
//    }
//}

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
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    CGFloat currentOffsetY = scrollView.contentOffset.y;
    CGFloat oneWeekHeight = CGRectGetWidth(self.calendarCollectionView.frame)/DAYS_IN_WEEK;;
    CGFloat pageHeight = oneWeekHeight * self.numberOfVisibleWeeks;
    CGFloat offset = pageHeight * self.numberOfRealPages;
    
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
