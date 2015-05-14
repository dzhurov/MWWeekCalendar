//
//  MWWeekCalendarLayout.m
//  WeeklyCalendar
//
//  Created by DZhurov on 5/14/15.
//
//

#import "MWWeekCalendarLayout.h"

@interface MWWeekCalendarLayout ()

@property (nonatomic, strong) NSMutableArray *indexPathsToAnimate;

@end

@implementation MWWeekCalendarLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.indexPathsToAnimate = [NSMutableArray new];
}

- (void)invalidateLayout
{
    [super invalidateLayout];
}

- (void)prepareForAnimatedBoundsChange:(CGRect)oldBounds
{
    [super prepareForAnimatedBoundsChange:oldBounds];
    CGFloat width = [self.delegate calendarLayoutCellWidth:self];
    
    
    NSLog(@"oldBounds: %@ newBounds: %@ width: %f", NSStringFromCGRect(oldBounds), NSStringFromCGRect(self.collectionView.bounds), width);
}

- (void)finalizeAnimatedBoundsChange
{
    [super finalizeAnimatedBoundsChange];
//    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
//        CGRect frame = cell.frame;
//        CGFloat width = [self.delegate calendarLayoutCellWidth:self];
//        frame.size.width = width;
//        cell.frame = frame;
//    }
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (UICollectionViewUpdateItem *updateItem in updateItems) {
        switch (updateItem.updateAction) {
            case UICollectionUpdateActionInsert:
                [indexPaths addObject:updateItem.indexPathAfterUpdate];
                break;
            case UICollectionUpdateActionDelete:
                [indexPaths addObject:updateItem.indexPathBeforeUpdate];
                break;
            case UICollectionUpdateActionMove:
                [indexPaths addObject:updateItem.indexPathBeforeUpdate];
                [indexPaths addObject:updateItem.indexPathAfterUpdate];
                break;
            default:
                NSLog(@"unhandled case: %@", updateItem);
                break;
        }
    }
    self.indexPathsToAnimate = indexPaths;
}

- (UICollectionViewLayoutAttributes*)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    
    if ([_indexPathsToAnimate containsObject:itemIndexPath]) {
        attr.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(0.2, 0.2), M_PI);
        attr.center = CGPointMake(CGRectGetMidX(self.collectionView.bounds), CGRectGetMaxY(self.collectionView.bounds));
        [_indexPathsToAnimate removeObject:itemIndexPath];
    }
    
    return attr;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    CGRect oldBounds = self.collectionView.bounds;
    if (!CGSizeEqualToSize(oldBounds.size, newBounds.size)) {
        return YES;
    }
    return NO;
}

@end
