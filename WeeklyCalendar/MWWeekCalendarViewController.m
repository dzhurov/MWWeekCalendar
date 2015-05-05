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
#import "HoursScaleCollectionHeaderView.h"
#import "MWHourAxisView.h"
#import "CGHelper.h"

@interface MWWeekCalendarViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *headerCollectionView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *bodyCollectionView;
@property (weak, nonatomic) IBOutlet MWHourAxisView *hourAxisView;

@end

@implementation MWWeekCalendarViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.numberOfVisibleDays = 7;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *headerDayCellId = NSStringFromClass([HeaderDayCell class]);
    NSString *bodyDayCellId = NSStringFromClass([DayBodyCell class]);
    NSString *hoursScaleHeaderId = NSStringFromClass([HoursScaleCollectionHeaderView class]);
    
    [self.headerCollectionView registerNib:[UINib nibWithNibName:headerDayCellId bundle:nil] forCellWithReuseIdentifier:headerDayCellId];
    [self.bodyCollectionView registerNib:[UINib nibWithNibName:bodyDayCellId bundle:nil] forCellWithReuseIdentifier:bodyDayCellId];
    [self.bodyCollectionView registerNib:[UINib nibWithNibName:hoursScaleHeaderId bundle:nil]
              forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                     withReuseIdentifier:hoursScaleHeaderId];
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
    return 30;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _headerCollectionView){
        HeaderDayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HeaderDayCell class]) forIndexPath:indexPath];
        return cell;
    }
    else{
        DayBodyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DayBodyCell class]) forIndexPath:indexPath];
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]){
        HoursScaleCollectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                    withReuseIdentifier:NSStringFromClass([HoursScaleCollectionHeaderView class])
                                                                                           forIndexPath:indexPath];
        return header;
    }
    return nil;
}

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

#pragma mark - Rotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.bodyCollectionView performBatchUpdates:nil completion:nil];
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
        CGFloat pageWidth = self.bodyCollectionView.frame.size.width;
        
        // When Velocity is low paging makes by day
        if (fabs(velocity.x) < 0.5){
            pageWidth = roundTo1Px( pageWidth / self.numberOfVisibleDays );
            NSLog(@"Paging by day. Velocity : %f", velocity.x);
        }
        
        [self getPagingOffsetsForOffset:scrollView.contentOffset.x
                           forPageWidth:pageWidth
                             leftOffset:&leftOffset
                            rigthOffset:&rightOffset];
        
        if (fabs(leftOffset - (*targetContentOffset).x) > fabs((*targetContentOffset).x - rightOffset)){
            (*targetContentOffset).x = rightOffset;
        }
        else{
            (*targetContentOffset).x = leftOffset;
        }
        
        if (fabs(velocity.x) < 0.5){
            CGPoint point = *targetContentOffset;
            dispatch_async(dispatch_get_main_queue(), ^{
                [scrollView setContentOffset:point animated:YES];
            });
        }
    }
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

@end
