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
#import "PDKTStickySectionHeadersCollectionViewLayout.h"

@interface MWWeekCalendarViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *headerCollectionView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *bodyCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bodyCollectionHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bodyCollectionWidthConstraint;

@end

@implementation MWWeekCalendarViewController

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
//    self.bodyCollectionView.collectionViewLayout = [PDKTStickySectionHeadersCollectionViewLayout new];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.bodyCollectionHeightConstraint.constant = self.view.bounds.size.height;
    self.bodyCollectionWidthConstraint.constant = self.view.bounds.size.width;
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



@end
