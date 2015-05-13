//
//  MWWeekCalendarViewController.m
//  WeeklyCalendar
//
//  Created by DZhurov on 4/27/15.
//
//

#import "MWWeekCalendarViewController.h"
#import "HeaderDayCell.h"
#import "DayBodyCell.h"
#import "MWHourAxisView.h"
#import "CGHelper.h"
#import "NSDate+Utilities.h"
#import "NSDate+MWWeeklyCalendar.h"
#import "MWWeekEventView.h"
#import <POP.h>
#import <QuartzCore/QuartzCore.h>
#import "MWWeekEvent.h"

@interface MWWeekCalendarViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>{
    NSUInteger _numberOfDays;
    NSUInteger _todaysDayIndex;
    BOOL _initializationInProgress;
    
    MWWeekEventView *_currentAddingWeekEventView;
    NSUInteger _currentAddingEventColumn;
    CGPoint _currentAddintEventPreviousPoint;
    CFAbsoluteTime _currentAddingEventPreviousPointTime;
}
@property (weak, nonatomic) IBOutlet UICollectionView *headerCollectionView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *bodyCollectionView;
@property (weak, nonatomic) IBOutlet MWHourAxisView *hourAxisView;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

@implementation MWWeekCalendarViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.numberOfVisibleDays = 7;
    _numberOfDays = 60;
    _todaysDayIndex = self.numberOfVisibleDays * 4 + [[NSDate date] dateComponents].weekday - 1;
    _initializationInProgress = YES;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *headerDayCellId = NSStringFromClass([HeaderDayCell class]);
    NSString *bodyDayCellId = NSStringFromClass([DayBodyCell class]);
    
    [self.headerCollectionView registerNib:[UINib nibWithNibName:headerDayCellId bundle:nil] forCellWithReuseIdentifier:headerDayCellId];
    [self.bodyCollectionView registerNib:[UINib nibWithNibName:bodyDayCellId bundle:nil] forCellWithReuseIdentifier:bodyDayCellId];

    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *initialIndexPath = [self indexPathForFirstDayOfWeek:[NSDate date]];
        [self.bodyCollectionView scrollToItemAtIndexPath:initialIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        _initializationInProgress = NO;
    });
    [self.longPressGestureRecognizer addTarget:self action:@selector(longPressed:)];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _numberOfDays;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *date = [self dateForIndexPath:indexPath];
    if (collectionView == _headerCollectionView){
        HeaderDayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HeaderDayCell class]) forIndexPath:indexPath];
        [cell setDate:date selected:[date isToday] weekend:[date isTypicallyWeekend]];
        
        return cell;
    }
    else{
        DayBodyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DayBodyCell class]) forIndexPath:indexPath];
        return cell;
    }
}


#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(roundTo1Px( collectionView.bounds.size.width / self.numberOfVisibleDays ), -1);
    if (collectionView == self.bodyCollectionView){
        size.height = self.hourAxisView.bounds.size.height;
    }
    else{
        size.height = self.headerCollectionView.bounds.size.height;
    }

    // Adjust cell size for orientation
    if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
//        return CGSizeMake(170.f, 170.f);
    }
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_initializationInProgress)
        return;
    
    NSUInteger kIncrementationStep = self.numberOfVisibleDays * 2;
    
    if (indexPath.item < kIncrementationStep){
//        _todaysDayIndex -= kIncrementationStep;
//        _numberOfDays += kIncrementationStep;
//        
//        //TODO: move contentOffset somehow
//        [self.bodyCollectionView reloadData];
//        [self.headerCollectionView reloadData];
    }
    else if (indexPath.item > _numberOfDays + kIncrementationStep){
        _numberOfDays += kIncrementationStep;
        [self.bodyCollectionView reloadData];
        [self.headerCollectionView reloadData];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.headerCollectionView || scrollView == self.bodyCollectionView){
        UIScrollView *anotherScrollView = scrollView == self.headerCollectionView ? self.bodyCollectionView : self.headerCollectionView;
        anotherScrollView.contentOffset = scrollView.contentOffset;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView == self.headerCollectionView || scrollView == self.bodyCollectionView){
        CGFloat leftOffset, rightOffset;
        CGFloat oneDayPageWidth = self.dayColumnWidth;
        CGFloat pageWidth = oneDayPageWidth * self.numberOfVisibleDays;
        
        // When Velocity is low paging makes by day
        if (fabs(velocity.x) < 0.5){
            pageWidth = oneDayPageWidth;
            NSLog(@"Paging by day.  Velocity : %f", velocity.x);
        }
        else{
            NSLog(@"Paging by week. Velocity : %f", velocity.x);
        }
        
        [self getPagingOffsetsForOffset:scrollView.contentOffset.x
                           forPageWidth:pageWidth
                             leftOffset:&leftOffset
                            rigthOffset:&rightOffset];
        
        CGPoint neededContentOffset = scrollView.contentOffset;
        
        if (fabs(velocity.x) >= 0.5){
            if (velocity.x > 0){
                neededContentOffset.x = rightOffset;
            }
            else{
                neededContentOffset.x = leftOffset;
            }
            *targetContentOffset = neededContentOffset;
//            [scrollView setContentOffset:neededContentOffset animated:YES];
        }
        else{
            if (fabs(leftOffset - scrollView.contentOffset.x) > fabs(scrollView.contentOffset.x - rightOffset)){
                neededContentOffset.x = rightOffset;
            }
            else{
                neededContentOffset.x = leftOffset;
            }
            *targetContentOffset = neededContentOffset;
        }
    }
}

#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskAll);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.bodyCollectionView performBatchUpdates:nil completion:nil];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}

#pragma mark - Paging 

- (void)getPagingOffsetsForOffset:(CGFloat)offset forPageWidth:(CGFloat)pageWidth leftOffset:(out CGFloat*)leftOffset rigthOffset:(out CGFloat*)rightOffset
{
    int fullPages = (int)( offset / pageWidth );
    if (leftOffset){
        *leftOffset = fullPages * pageWidth;
    }
    
    if (rightOffset){
        *rightOffset = (fullPages + 1) * pageWidth;
    }
}

#pragma mark - Private

- (NSDate *)dateForIndexPath:(NSIndexPath*)indexPath
{
    NSInteger daysAfterToday = indexPath.item - _todaysDayIndex;
    return [NSDate dateWithTimeIntervalSinceNow:daysAfterToday * D_DAY];
}

- (NSIndexPath *)indexPathForDate:(NSDate*)date
{
    NSUInteger index = [[NSDate date] distanceInDaysToDate:date] + _todaysDayIndex;
    return [NSIndexPath indexPathForItem:index inSection:0];
}

- (NSIndexPath *)indexPathForFirstDayOfWeek:(NSDate*)date
{
    NSUInteger index = [[NSDate date] distanceInDaysToDate:date] + _todaysDayIndex - (date.dateComponents.weekday - 1);
    return [NSIndexPath indexPathForItem:index inSection:0];
}

- (CGFloat)dayColumnWidth
{
    return roundTo1Px( self.bodyCollectionView.frame.size.width / self.numberOfVisibleDays );
}

- (NSIndexPath *)indexPathOfFirstVisibleCell
{
    NSUInteger indexOfFirstColumn = self.bodyCollectionView.contentOffset.x / self.dayColumnWidth;
    return [NSIndexPath indexPathForItem:indexOfFirstColumn inSection:0];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

- (void)longPressed:(UILongPressGestureRecognizer*)recognizer
{
    CGPoint point = [recognizer locationInView:self.bodyCollectionView];
    NSUInteger previousColumn = _currentAddingEventColumn;
    _currentAddingEventColumn = floor(point.x / self.dayColumnWidth);
    CFTimeInterval timeInterval = CFAbsoluteTimeGetCurrent() - _currentAddingEventPreviousPointTime;
    
    CGPoint position;
    position.x = _currentAddingEventColumn * self.dayColumnWidth;
    position.y = roundTo1Px(point.y - self.hourAxisView.hourStepHeight / 2);
    
    CGPoint positionOnHourAxisView = [self.bodyCollectionView convertPoint:position toView:self.hourAxisView];
    if (recognizer.state == UIGestureRecognizerStateBegan){
        _currentAddingWeekEventView = [[MWWeekEventView alloc] initWithFrame:(CGRect){position,{self.dayColumnWidth - 1, self.hourAxisView.hourStepHeight - 1}}];
        [self.bodyCollectionView addSubview:_currentAddingWeekEventView];
        MWWeekEvent *event = [MWWeekEvent new];
        
        
        _currentAddingWeekEventView.event = event;
        _currentAddingWeekEventView.layer.affineTransform = CGAffineTransformMakeScale(0.1, 0.1);
        _currentAddingWeekEventView.alpha = 0.f;
        _currentAddingWeekEventView.selected = YES;
        
        [UIView animateWithDuration:0.4
                              delay:0
             usingSpringWithDamping:0.5
              initialSpringVelocity:1
                            options:0 animations:^{
                                _currentAddingWeekEventView.layer.affineTransform = CGAffineTransformIdentity;
                            }
                         completion:nil];

        POPBasicAnimation *alphaAnimation = [POPBasicAnimation easeOutAnimation];
        alphaAnimation.property = [POPAnimatableProperty propertyWithName: kPOPViewAlpha];
        alphaAnimation.fromValue = @(0.);
        alphaAnimation.toValue = @(1.);
        [_currentAddingWeekEventView pop_addAnimation:alphaAnimation forKey:@"AppearAlpha"];
        [_currentAddingWeekEventView setNeedsLayout];
        [self.hourAxisView showEventTimeForTouch:positionOnHourAxisView];
    }
    _currentAddingEventPreviousPointTime = CFAbsoluteTimeGetCurrent();
    
    if (recognizer.state == UIGestureRecognizerStateChanged){
        CGRect frame = _currentAddingWeekEventView.frame;
        frame.origin = position;

        POPBasicAnimation *moveAnimation = [_currentAddingWeekEventView pop_animationForKey:@"Move"];
        if (previousColumn != _currentAddingEventColumn){
            moveAnimation = [POPBasicAnimation easeInEaseOutAnimation];
            moveAnimation.property = [POPAnimatableProperty propertyWithName: kPOPViewFrame];
            moveAnimation.toValue = [NSValue valueWithCGRect:frame];
            moveAnimation.duration = 0.15;
            [_currentAddingWeekEventView pop_addAnimation:moveAnimation forKey:@"Move"];
        }
        else if (moveAnimation){
            moveAnimation.toValue = [NSValue valueWithCGRect:frame];
        }
        else{
            _currentAddingWeekEventView.frame = frame;
        }
        [self.hourAxisView showEventTimeForTouch:positionOnHourAxisView];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded){
        NSDate *hoursMinutesDate = [self.hourAxisView showEventTimeForTouch:positionOnHourAxisView];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentAddingEventColumn inSection:0];
        NSDate *date = [self dateForIndexPath:indexPath];
        NSDateComponents *dateComponents = date.dateComponents;
        dateComponents.minute = hoursMinutesDate.dateComponents.minute;
        dateComponents.hour = hoursMinutesDate.dateComponents.hour;
        _currentAddingWeekEventView.event.startDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
        dateComponents.hour ++;
        _currentAddingWeekEventView.event.endDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
        [_currentAddingWeekEventView removeFromSuperview];
        DayBodyCell *dayBodyCell = (DayBodyCell*)[self.bodyCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentAddingEventColumn inSection:0]];
        [dayBodyCell addEventView:_currentAddingWeekEventView];
        _currentAddingWeekEventView.selected = NO;
        _currentAddingWeekEventView = nil;
        [self.hourAxisView hideEventTouch];
    }
    
    _currentAddintEventPreviousPoint = point;
}

@end
