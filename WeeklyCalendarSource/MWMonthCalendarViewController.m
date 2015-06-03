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

@interface MWMonthCalendarViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *calendarCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *weekdayTitleCollectionView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

#define DAYS_IN_WEEK 7
#define MONTH_IN_YEAR 12

#define INSET 0.5

@implementation MWMonthCalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.dataSource = [[NSMutableArray alloc] init];
    
    [self setupDataSource];
    
    [self configurateCollectionViews];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[self.calendarCollectionView scrollToItemAtIndexPath:[self indexPathForTodayDate] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
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

-(void)setupDataSource
{
    [self.dataSource removeAllObjects];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:(NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitYear) fromDate:[NSDate date]];
    
    for (NSInteger month = 1; month <= MONTH_IN_YEAR; month++) {
        
        NSMutableArray *monthArray = [[NSMutableArray alloc] initWithCapacity:MONTH_IN_YEAR];

        [components setMonth:month];
        
        NSUInteger monthDaysCount = 31;
        
        for (NSInteger day = 1; day <= monthDaysCount; day++ ) {
            
            [components setDay:day];
            
            NSDate *date = [calendar dateFromComponents:components];
            
            if (day == 1) {
                NSUInteger weekDay = [[calendar components:NSCalendarUnitWeekday fromDate:date] weekday];
                monthDaysCount = [calendar rangeOfUnit:NSCalendarUnitDay
                                           inUnit:NSCalendarUnitMonth
                                          forDate:date].length;
                if (weekDay == 1) {
                    weekDay = DAYS_IN_WEEK + 1;
                }
                
                for (NSInteger i = 1; i < weekDay; i++) {
                    [monthArray addObject:[NSNull null]];
                }
            }
            [monthArray addObject:date];
        }
        
        while (monthArray.count % DAYS_IN_WEEK != 0) {
            [monthArray addObject:[NSNull null]];
        }
        
        [self.dataSource addObject:monthArray];
    }
}

-(NSIndexPath*)indexPathForTodayDate
{
    __block NSIndexPath *indexPath = nil;
    
    [self.dataSource enumerateObjectsUsingBlock:^(NSArray *obj, NSUInteger idx, BOOL *stop) {
        
        [obj enumerateObjectsUsingBlock:^(id innerObj, NSUInteger innerIndex, BOOL *innerStop) {
            if ([innerObj isKindOfClass:[NSDate class]] && [[NSCalendar currentCalendar] isDateInToday:innerObj]) {
                indexPath = [NSIndexPath indexPathForRow:innerIndex inSection:idx];
                *innerStop = YES;
            }
        }];
        *stop = (indexPath!=nil);
    }];
    
    return indexPath;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.weekdayTitleCollectionView) {
        return DAYS_IN_WEEK;
    }
    
    return [self.dataSource[section] count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    if (collectionView == self.weekdayTitleCollectionView) {
        return 1;
    }
    
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.weekdayTitleCollectionView) {
        MWWeekdayTitleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[MWWeekdayTitleCollectionViewCell identifier] forIndexPath:indexPath];
        cell.textLabel.text = [[NSCalendar currentCalendar] shortWeekdaySymbols][indexPath.row];
        return cell;
    }
    
    MWMonthCalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[MWMonthCalendarCollectionViewCell identifier] forIndexPath:indexPath];
    [cell configurateWithObject:[self objectForIndexPath:indexPath]];
    //cell.isDayOff = (indexPath.row%DAYS_IN_WEEK==0) || (indexPath.row%(DAYS_IN_WEEK-1)==0);
    return cell;
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.weekdayTitleCollectionView) {
        return NO;
    }
    return [[self objectForIndexPath:indexPath] isKindOfClass:[NSDate class]];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", [self objectForIndexPath:indexPath]);
}

-(id)objectForIndexPath:(NSIndexPath*)indexPath
{
    return self.dataSource[indexPath.section][indexPath.row];
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







//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;

//-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
//{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//}
//
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (decelerate) {
//        NSLog(@"YES");
    }
    
    NSArray *visibleIndexPath = [self.calendarCollectionView indexPathsForVisibleItems];
    for (NSIndexPath *indexPath in [visibleIndexPath reverseObjectEnumerator]) {
        NSDate *firstVisibleDate = [self objectForIndexPath:indexPath];
        if ([firstVisibleDate isKindOfClass:[NSNull class]]) {
            continue;
        }
        
        NSLog(@"%@", firstVisibleDate);
        
        return;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self setupDataSource];
}

@end
