//
//  MWWeekCalendarViewController.m
//  WeeklyCalendar
//
//  Created by DZhurov on 4/27/15.
//
//

#import "MWWeekCalendarViewController.h"
#import "MWHeaderDayCell.h"
#import "MWDayBodyCell.h"
#import "MWHourAxisView.h"
#import "CGHelper.h"
#import "NSDate+Utilities.h"
#import "NSDate+MWWeeklyCalendar.h"
#import "MWWeekEventView.h"
#import <QuartzCore/QuartzCore.h>
#import "MWCalendarEvent.h"
#import "MWWeekCalendarConsts.h"
#import "MWWeekCalendarLayout.h"
#import "MWCalendarViewController.h"

#define kNumberOfRealPages      3
#define kNumberOfVirtualPages   (kNumberOfRealPages + 2)

struct TouchInfo {
    CGPoint point;
    CFAbsoluteTime time;
    CGVector velocity;
};


@interface MWWeekCalendarViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, MWDayBodyCellDelegate, MWWeekCalendarLayoutDelegate, UIPopoverControllerDelegate>
{
    NSInteger _todaysDayIndex;
    BOOL _initializationInProgress;
    
    MWWeekEventView *_currentAddingWeekEventView;
    NSUInteger _currentAddingEventColumn;
    MWWeekEventView *_editingEventView;
    
    struct TouchInfo _addingEventTouchInfo;
}
@property (weak, nonatomic) IBOutlet UICollectionView *headerCollectionView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *bodyCollectionView;
@property (weak, nonatomic) IBOutlet MWWeekCalendarLayout *bodyCollectionViewLayout;
@property (weak, nonatomic) IBOutlet MWWeekCalendarLayout *headerCollectionViewLayout;
@property (weak, nonatomic) IBOutlet MWHourAxisView *hourAxisView;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (weak, nonatomic) IBOutlet UIView *redCircle;
@property (weak, nonatomic) IBOutlet UIView *redCircleSubview;
@property (weak, nonatomic) IBOutlet UIView *redLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *redLineYPositionConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *redCircleXPositionConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerCollectionLeadingSpaceConstraint;
@property (strong, nonatomic) NSTimer *redLineTimer;
@property (strong, nonatomic) MWCalendarEvent *eventBeforeEditing;
@property (nonatomic, readonly) MWCalendarViewController* calendarViewController;

@end

@implementation MWWeekCalendarViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.numberOfVisibleDays = 7;
        _todaysDayIndex = (kNumberOfVirtualPages / 2) * self.numberOfVisibleDays  + [[NSDate date] dateComponents].weekday - 1;
        _initializationInProgress = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *headerDayCellId = NSStringFromClass([MWHeaderDayCell class]);
    NSString *bodyDayCellId = NSStringFromClass([MWDayBodyCell class]);
    
    self.bodyCollectionViewLayout.delegate = self;
    self.bodyCollectionViewLayout.numberOfVisibleDays = self.numberOfVisibleDays;
    self.headerCollectionViewLayout.numberOfVisibleDays = self.numberOfVisibleDays;
    self.bodyCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.headerCollectionView.decelerationRate = self.bodyCollectionView.decelerationRate;
    
    [self.headerCollectionView registerNib:[UINib nibWithNibName:headerDayCellId bundle:nil] forCellWithReuseIdentifier:headerDayCellId];
    [self.bodyCollectionView registerNib:[UINib nibWithNibName:bodyDayCellId bundle:nil] forCellWithReuseIdentifier:bodyDayCellId];

    dispatch_async(dispatch_get_main_queue(), ^{
//        NSIndexPath *initialIndexPath = [self indexPathForFirstDayOfWeek:[NSDate date]];
//        [self.bodyCollectionView scrollToItemAtIndexPath:initialIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        [self.bodyCollectionView  setContentOffset:CGPointMake( (_todaysDayIndex / _numberOfVisibleDays) * [self pageWidth], 0) animated:YES];
        _initializationInProgress = NO;
    });
    
    
    
    [self.longPressGestureRecognizer addTarget:self action:@selector(longPressed:)];
    self.redCircle.layer.cornerRadius = 5;
    self.redCircleSubview.layer.cornerRadius = 4;
    self.redLineTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                         target:self
                                                       selector:@selector(redLineTimerMethod:)
                                                       userInfo:nil
                                                        repeats:YES];
    self.hourAxisView.startWorkingDay = self.startWorkingDay;
    self.hourAxisView.endWorkingDay = self.endWorkingDay;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self setupRedLinePosition];
    [self setupRedCirclePosition];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if ([self.redLineTimer isValid]) {
        [self.redLineTimer invalidate];
    }
}

#pragma mark - public

- (void)reloadEventsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSInteger firstItem = [self indexPathForDate:fromDate].item;
    NSInteger lastItem = [self indexPathForDate:toDate].item;
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (NSInteger item = firstItem; item <= lastItem; ++item) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:item inSection:0]];
    }
    [self.bodyCollectionView reloadItemsAtIndexPaths:indexPaths];
}

- (void)reloadEvents
{
    [self.bodyCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _numberOfVisibleDays * kNumberOfVirtualPages;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *date = [self dateForItem:indexPath.item];
    if (collectionView == _headerCollectionView){
        MWHeaderDayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MWHeaderDayCell class]) forIndexPath:indexPath];
        [cell setDate:date selected:[date isToday] weekend:[date isTypicallyWeekend]];
        
        return cell;
    }
    else{
        MWDayBodyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MWDayBodyCell class]) forIndexPath:indexPath];
// For debug:
//        cell.contentView.backgroundColor = [UIColor colorWithHue: indexPath.item % 6 / 6.0 + 0.1 saturation:0.7 brightness:1.0 alpha:0.3];
        cell.events = [self.dataSource calendarController:self eventsForDate:date];
        cell.delegate = self;
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
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
//        return CGSizeMake(170.f, 170.f);
    }
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_initializationInProgress)
        return;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.headerCollectionView || scrollView == self.bodyCollectionView){
        static CGFloat lastContentOffsetX = FLT_MIN;
        if (FLT_MIN == lastContentOffsetX) {
            lastContentOffsetX = scrollView.contentOffset.x;
            return;
        }
        CGFloat currentOffsetX = scrollView.contentOffset.x;
        CGFloat currentOffsetY = scrollView.contentOffset.y;
        CGFloat oneDayPageWidth = self.dayColumnWidth;
        CGFloat pageWidth = oneDayPageWidth * self.numberOfVisibleDays;
        CGFloat offset = pageWidth * kNumberOfRealPages;
        
        // the first page(showing the last item) is visible and user is still scrolling to the left
        if (currentOffsetX < pageWidth && lastContentOffsetX > currentOffsetX) {
            lastContentOffsetX = currentOffsetX + offset;
            scrollView.contentOffset = (CGPoint){lastContentOffsetX, currentOffsetY};
            _todaysDayIndex += kNumberOfRealPages * self.numberOfVisibleDays;
        }
        // the last page (showing the first item) is visible and the user is still scrolling to the right
        else if (currentOffsetX > offset && lastContentOffsetX < currentOffsetX) {
            lastContentOffsetX = currentOffsetX - offset;
            scrollView.contentOffset = (CGPoint){lastContentOffsetX, currentOffsetY};
            _todaysDayIndex -= kNumberOfRealPages * self.numberOfVisibleDays;
        } else {
            lastContentOffsetX = currentOffsetX;
        }
    
        UIScrollView *anotherScrollView = scrollView == self.headerCollectionView ? self.bodyCollectionView : self.headerCollectionView;
        anotherScrollView.contentOffset = scrollView.contentOffset;
        [self setupRedCirclePosition];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.headerCollectionView || scrollView == self.bodyCollectionView) {
        CGFloat cellWidth = roundTo1Px( self.headerCollectionView.bounds.size.width / self.numberOfVisibleDays );
        CGFloat contentOffset = self.headerCollectionView.contentOffset.x;
        NSInteger firstVisibleCellIndex = roundf(contentOffset / cellWidth);
        NSInteger lastVisibleCellIndex = firstVisibleCellIndex + self.numberOfVisibleDays - 1;
        NSDate *fromDate = [self dateForItem:firstVisibleCellIndex];
        NSDate *toDate = [self dateForItem:lastVisibleCellIndex];
        if ([self.delegate respondsToSelector:@selector(calendarController:didScrollToStartDate:endDate:)]) {
            [self.delegate calendarController:self didScrollToStartDate:fromDate endDate:toDate];
        }
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
    [self setupRedCirclePosition];
//    [self.bodyCollectionView.collectionViewLayout invalidateLayout];
//    [self.headerCollectionView.collectionViewLayout invalidateLayout];
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

- (NSDate *)dateForItem:(NSInteger)item
{
    NSInteger daysAfterToday = item - _todaysDayIndex;
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

- (CGFloat)pageWidth
{
    return self.dayColumnWidth * self.numberOfVisibleDays;
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
    NSLog(@"point %@", NSStringFromCGPoint(point));
    NSUInteger previousColumn = _currentAddingEventColumn;
    _currentAddingEventColumn = floor(point.x / self.dayColumnWidth);
    CFTimeInterval timeInterval = CFAbsoluteTimeGetCurrent() - _addingEventTouchInfo.time;
    if (recognizer.state != UIGestureRecognizerStateEnded){
        _addingEventTouchInfo.velocity = CGVectorMake((point.x - _addingEventTouchInfo.point.x) / timeInterval,
                                                      (point.y - _addingEventTouchInfo.point.y) / timeInterval);
        _addingEventTouchInfo.point = point;
    }
    else{
        if (timeInterval > 0.1){
            _addingEventTouchInfo.velocity = CGVectorMake(0, 0);
        }
    }
    _addingEventTouchInfo.time = CFAbsoluteTimeGetCurrent();
    CGPoint position;
    position.x = _currentAddingEventColumn * self.dayColumnWidth;
    position.y = roundTo1Px(point.y - self.hourAxisView.hourStepHeight / 2);
    
    CGPoint positionOnHourAxisView = [self.bodyCollectionView convertPoint:position toView:self.hourAxisView];
    NSDate *hoursMinutesDate = [self.hourAxisView showEventTimeForTouch:positionOnHourAxisView];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentAddingEventColumn inSection:0];

    if (recognizer.state == UIGestureRecognizerStateBegan){
        MWDayBodyCell *cell = (MWDayBodyCell *)[self.bodyCollectionView cellForItemAtIndexPath:indexPath];
        MWWeekEventView *eventView = [cell eventViewForPosition:[recognizer locationInView:cell]];
        MWCalendarEvent *event = eventView.event;
        
        if (event != nil) { // move
            self.eventBeforeEditing = event;
            eventView.alpha = 0.3;
        }
        else {
            event = [MWCalendarEvent new];
        }
        
        if ([self.delegate respondsToSelector:@selector(calendarController:shouldAddEventForStartDate:)]) {
            NSDate *currentDate = [self dateForItem:_currentAddingEventColumn];
            if ([self.delegate calendarController:self shouldAddEventForStartDate:currentDate]) {
                [self addEventViewWithPosition:position event:[event copy] forCellAtIndexPath:indexPath];
            }
        }
        else {
            [self addEventViewWithPosition:position event:[event copy] forCellAtIndexPath:indexPath];
        }
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged){
        [self moveCurrentEventViewToPoint:position animated: previousColumn != _currentAddingEventColumn];
    }
    
    if (recognizer.state == UIGestureRecognizerStateCancelled){
        NSLog(@"UIGestureRecognizerStateCancelled");
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded){
        if (vectorLength(_addingEventTouchInfo.velocity) > 100){
            NSLog(@"UIGestureRecognizerStateEnded >>>> velocity (%f, %f) = %f", _addingEventTouchInfo.velocity.dx, _addingEventTouchInfo.velocity.dy, vectorLength(_addingEventTouchInfo.velocity));
            if (self.eventBeforeEditing != nil) {
                [self.bodyCollectionView reloadItemsAtIndexPaths:@[[self indexPathForDate:self.eventBeforeEditing.startDate]]];
                self.eventBeforeEditing = nil;
                [_currentAddingWeekEventView removeFromSuperview];
                _currentAddingWeekEventView = nil;
            }
            else {
                [self removeCurerntEventFromPoint:position withVelocity:_addingEventTouchInfo.velocity];
            }
        }
        else{
            NSLog(@"UIGestureRecognizerStateEnded ||");
            [self addCurrentEventToCellAtIndexPath:indexPath timeDate:hoursMinutesDate];
            [self.hourAxisView hideEventTouch];
        }
    }
}

#pragma mark - MWWeekEvent Movements

- (void)addEventViewWithPosition:(CGPoint)position event:(MWCalendarEvent *)event forCellAtIndexPath:(NSIndexPath *)indexPath
{
    _currentAddingWeekEventView = [[MWWeekEventView alloc] initWithFrame:(CGRect){position,{self.dayColumnWidth - 1, self.hourAxisView.hourStepHeight - 1}}];
    [self.bodyCollectionView addSubview:_currentAddingWeekEventView];
    
    _currentAddingWeekEventView.event = event;
    _currentAddingWeekEventView.layer.affineTransform = CGAffineTransformMakeScale(0.1, 0.1);
    _currentAddingWeekEventView.alpha = 0.f;
    _currentAddingWeekEventView.selected = YES;
    
    _currentAddingWeekEventView.layer.shadowRadius = 10.f;
    _currentAddingWeekEventView.layer.shadowOpacity = 0.3f;
    _currentAddingWeekEventView.layer.shadowColor = [UIColor blackColor].CGColor;
    
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:1
                        options:0
                     animations:^{
                         _currentAddingWeekEventView.layer.affineTransform = CGAffineTransformIdentity;
                     }
                     completion:nil];
    
    _currentAddingWeekEventView.alpha = 0;
    [UIView animateWithDuration:0.15 animations:^{
        _currentAddingWeekEventView.alpha = 1;
    }];
    [_currentAddingWeekEventView setNeedsLayout];
}

- (void)moveCurrentEventViewToPoint:(CGPoint)position animated:(BOOL)animated
{
    CGRect frame = _currentAddingWeekEventView.frame;
    frame.origin = position;
    
    if (animated){
        [UIView animateWithDuration:0.15 animations:^{
            _currentAddingWeekEventView.frame = frame;
        }];
    }
    else{
        _currentAddingWeekEventView.frame = frame;
    }
}

- (void)addCurrentEventToCellAtIndexPath:(NSIndexPath *)indexPath timeDate:(NSDate*)timeDate
{
    NSDate *date = [self dateForItem:indexPath.item];
    NSDateComponents *dateComponents = date.dateComponents;
    dateComponents.minute = timeDate.dateComponents.minute;
    dateComponents.hour = timeDate.dateComponents.hour;
    _currentAddingWeekEventView.event.startDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    dateComponents.hour ++;
    _currentAddingWeekEventView.event.endDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    _currentAddingWeekEventView.layer.shadowRadius = 0.f;
    _currentAddingWeekEventView.layer.shadowOpacity = 0.f;
    [_currentAddingWeekEventView removeFromSuperview];

    if (self.eventBeforeEditing != nil) {
        if ([self.delegate respondsToSelector:@selector(calendarController:saveEvent:withNew:)]) {
            [self.delegate calendarController:self saveEvent:self.eventBeforeEditing withNew:_currentAddingWeekEventView.event];
        }
        
        NSIndexPath *eventBeforeEditingIndexPath = [self indexPathForDate:self.eventBeforeEditing.startDate];
        if (indexPath.item != eventBeforeEditingIndexPath.item) {
            [self.bodyCollectionView reloadItemsAtIndexPaths:@[indexPath, eventBeforeEditingIndexPath]];
        }
        [self.bodyCollectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    else {
        if ([self.delegate respondsToSelector:@selector(calendarController:didAddEvent:)]) {
            [self.delegate calendarController:self didAddEvent:_currentAddingWeekEventView.event];
        }
        
        [self.bodyCollectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    
    self.eventBeforeEditing = nil;
    _currentAddingWeekEventView.selected = NO;
    _currentAddingWeekEventView = nil;
}

- (void)removeCurerntEventFromPoint:(CGPoint)point withVelocity:(CGVector)velocity
{
    CGRect targetRect = _currentAddingWeekEventView.frame;
    
    NSTimeInterval duration = 0.3;
    
    targetRect.origin.x += velocity.dx * duration;
    targetRect.origin.y += velocity.dy * duration;
    [UIView animateWithDuration:duration animations:^{
        _currentAddingWeekEventView.frame = targetRect;
        _currentAddingWeekEventView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [_currentAddingWeekEventView removeFromSuperview];
        _currentAddingWeekEventView = nil;
    }];
}

#pragma mark - MWWeekCalendarLayoutDelegate

- (CGFloat)calendarLayoutCellWidth:(MWWeekCalendarLayout *)calendarLayotu
{
    return self.dayColumnWidth;
}

- (void)redLineTimerMethod:(NSTimer *)timer
{
    [self setupRedLinePosition];
    [self.hourAxisView setNeedsDisplay];
}

- (void)setupRedLinePosition
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
    CGFloat hours = [components hour] + [components minute] / 60.0;
    self.redLineYPositionConstraint.constant = ((self.contentScrollView.contentSize.height - kHoursAxisInset.top - kHoursAxisInset.bottom) * hours / 24) + kHoursAxisInset.top;
}

- (void)setupRedCirclePosition
{
    CGFloat cellWidth = roundTo1Px( self.headerCollectionView.bounds.size.width / self.numberOfVisibleDays );
    CGFloat contentOffset = self.headerCollectionView.contentOffset.x;
    self.redCircleXPositionConstraint.constant = kHoursAxisInset.left - (self.redCircle.bounds.size.width / 2) - contentOffset + cellWidth *_todaysDayIndex;
    [self setupRedLineVisible];
}

- (void)setupRedLineVisible
{
    CGFloat cellWidth = roundTo1Px( self.headerCollectionView.bounds.size.width / self.numberOfVisibleDays );
    CGFloat contentOffset = self.headerCollectionView.contentOffset.x;
    NSInteger indexFofFirstCell = floorf(contentOffset / cellWidth);
    NSInteger indexFofLastCell = floorf((contentOffset - 1) / cellWidth) + self.numberOfVisibleDays;
    NSDate *dateFofFirstCell = [self dateForItem:indexFofFirstCell];
    NSDate *dateFofLastCell = [self dateForItem:indexFofLastCell];
    NSDateComponents *firstCellDateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitWeekOfYear) fromDate:dateFofFirstCell];
    NSDateComponents *lastCellDateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitWeekOfYear) fromDate:dateFofLastCell];
    NSDateComponents *currentDateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitWeekOfYear) fromDate:[NSDate date]];
    CGFloat firstCellWeek = firstCellDateComponents.weekOfYear;
    CGFloat lastCellWeek = lastCellDateComponents.weekOfYear;
    CGFloat currentDateWeek = currentDateComponents.weekOfYear;
    self.redLine.hidden = (currentDateWeek - firstCellWeek > 1) || (lastCellWeek - currentDateWeek > 1);
    self.redCircle.hidden = self.redLine.hidden || (self.redCircleXPositionConstraint.constant < kHoursAxisInset.left);
    self.hourAxisView.showCurrentDate = !self.redLine.hidden;
}

#pragma mark - MWDayBodyCellDelegate

- (void)dayBodyCell:(MWDayBodyCell *)cell eventDidTapped:(MWCalendarEvent *)event
{
    [self editEvent:event inCell:cell];
}

#pragma mark - MWCalendarEditingControllerDelegate <NSObject>

- (void)saveEvent:(MWCalendarEvent *)event withNew:(MWCalendarEvent *)newEvent
{
    if ([self.delegate respondsToSelector:@selector(calendarController:saveEvent:withNew:)]) {
        [self.delegate calendarController:self saveEvent:event withNew:newEvent];
    }
    [self.bodyCollectionView reloadItemsAtIndexPaths:@[[self indexPathForDate:event.startDate]]];
    [self endEditingEvent:event];
}

- (void)deleteEvent:(MWCalendarEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(calendarController:removeEvent:)]) {
        [self.delegate calendarController:self removeEvent:event];
    }
    [self.bodyCollectionView reloadItemsAtIndexPaths:@[[self indexPathForDate:event.startDate]]];
    [self endEditingEvent:event];
}

- (void)cancelEditingForEvent:(MWCalendarEvent *)event
{
    [self endEditingEvent:event];
}

#pragma mark -

- (void)editEvent:(MWCalendarEvent *)event inCell:(MWDayBodyCell *)cell
{
    [_editingEventView setSelected:NO];
    _editingEventView = nil;
    
    UIViewController *editingController = [self.dataSource calendarController:self editingControllerForEvent:event];
    [self.calendarViewController showEditingController:editingController
                                              fromRect:[cell eventViewForEvent:event].frame
                                                inView:[cell eventViewForEvent:event].superview
                                            completion:nil];
    
    _editingEventView = [cell eventViewForEvent:event];
    [_editingEventView setSelected:YES];
}

- (void)endEditingEvent:(MWCalendarEvent *)event
{
    [self.calendarViewController hideEditingController:[self.dataSource calendarController:self editingControllerForEvent:event] completion:^{
        
    }];
    [_editingEventView setSelected:NO];
    _editingEventView = nil;
}

#pragma mark - MWCalendarViewControllerProtocol

-(MWCalendarViewController*)calendarViewController
{
    return [self.parentViewController isKindOfClass:[MWCalendarViewController class]]?((MWCalendarViewController*)self.parentViewController):nil;
}

@end
