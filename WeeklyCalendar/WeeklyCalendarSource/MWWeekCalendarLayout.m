//
//  MWWeekCalendarLayout.m
//  WeeklyCalendar
//
//  Created by DZhurov on 5/14/15.
//
//

#import "MWWeekCalendarLayout.h"
#import "CGHelper.h"
#import "RZCollectionViewAnimationAssistant.h"

@interface MWWeekCalendarLayout ()

@property (nonatomic, strong) NSMutableArray *indexPathsToAnimate;
//@property (nonatomic, strong) RZCollectionViewAnimationAssistant *assistant;
@property (nonatomic, strong) NSMutableDictionary *layoutAttributes;

@property (nonatomic) CGRect oldBounds;

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
    self.oldBounds = CGRectZero;
    self.indexPathsToAnimate = [NSMutableArray new];
    self.layoutAttributes = [NSMutableDictionary new];
}

- (void)invalidateLayout
{
    [super invalidateLayout];
}

- (void)prepareForAnimatedBoundsChange:(CGRect)oldBounds
{
//    [super prepareForAnimatedBoundsChange:oldBounds];
    
    CGFloat contentOffsetCoefficient = self.dayColumnWidth / [self dayColumnWidthForWidth: oldBounds.size.width];
    CGPoint offset = self.collectionView.contentOffset;
    offset.x = oldBounds.origin.x * contentOffsetCoefficient;
    [self.collectionView setContentOffset:offset];

    
    
    self.oldBounds = oldBounds;
    CGFloat width = [self.delegate calendarLayoutCellWidth:self];
    NSLog(@"oldBounds: %@ newBounds: %@ width: %f", NSStringFromCGRect(oldBounds), NSStringFromCGRect(self.collectionView.bounds), width);
}

- (void)finalizeAnimatedBoundsChange
{
    [super finalizeAnimatedBoundsChange];
    self.oldBounds = CGRectZero;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    
//    NSMutableArray *indexPaths = [NSMutableArray array];
//    for (UICollectionViewUpdateItem *updateItem in updateItems) {
//        switch (updateItem.updateAction) {
//            case UICollectionUpdateActionInsert:
//                [indexPaths addObject:updateItem.indexPathAfterUpdate];
//                break;
//            case UICollectionUpdateActionDelete:
//                [indexPaths addObject:updateItem.indexPathBeforeUpdate];
//                break;
//            case UICollectionUpdateActionMove:
//                [indexPaths addObject:updateItem.indexPathBeforeUpdate];
//                [indexPaths addObject:updateItem.indexPathAfterUpdate];
//                break;
//            default:
//                NSLog(@"unhandled case: %@", updateItem);
//                break;
//        }
//    }
//    self.indexPathsToAnimate = indexPaths;
}

- (void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    CGFloat width = self.dayColumnWidth;
    CGRect itemFrame = CGRectMake(0, 0, width, self.collectionView.frame.size.height);
    NSInteger itemNo = floorf(rect.origin.x / width);
    itemFrame.origin.x = itemNo * width;
    NSMutableArray *attributes = [NSMutableArray arrayWithCapacity:ceilf(rect.size.width / width)];
    do {
        if (itemNo >= 0 && itemNo < [self.collectionView numberOfItemsInSection:0]){
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemNo inSection:0];
            UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:indexPath withFrame:itemFrame];
            self.layoutAttributes[indexPath] = attr;
            [attributes addObject:attr];
        }
        itemFrame.origin.x += width;
        itemNo++;
    } while (CGRectIntersectsRect(itemFrame, rect));
    
    return attributes;
    
//    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
//    
//    NSLog(@"self.oldBounds = %@", NSStringFromCGRect(self.oldBounds));
//    if (CGRectEqualToRect(self.oldBounds, CGRectZero)){
//        NSLog(@"zero");
//    }
//    for (UICollectionViewLayoutAttributes *attr in attributes) {
//        attr.size = CGSizeMake([self dayColumnWidth], attr.size.height);
//    }
//    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self layoutAttributesForItemAtIndexPath:indexPath withFrame:CGRectZero];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath withFrame:(CGRect)itemFrame
{
    UICollectionViewLayoutAttributes *attr = self.layoutAttributes[indexPath];
    if (!attr){
        attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        self.layoutAttributes[indexPath] = attr;
    }
    if (CGRectEqualToRect(itemFrame, CGRectZero)){
        CGFloat width = self.dayColumnWidth;
        itemFrame = CGRectMake(indexPath.item * width, 0, width, self.collectionView.frame.size.height);
    }
    attr.frame = itemFrame;
    return attr;
}

- (UICollectionViewLayoutAttributes*)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath: itemIndexPath] ;
    if (!CGRectEqualToRect(self.oldBounds, CGRectZero)){
        CGFloat width = [self dayColumnWidthForWidth:self.oldBounds.size.width];
        CGRect frame = CGRectMake(itemIndexPath.item * width, 0, width, self.collectionView.frame.size.height);
        attributes.frame = frame;
    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath: itemIndexPath];
    NSLog(@"%s indexPath.item = %d attributes: %@", __PRETTY_FUNCTION__, itemIndexPath.item, attributes);
    
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    CGRect oldBounds = self.collectionView.bounds;
    if (!CGSizeEqualToSize(oldBounds.size, newBounds.size)) {
        return YES;
    }
    return NO;
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake(self.dayColumnWidth * [self.collectionView numberOfItemsInSection:0], self.collectionView.frame.size.height);
}

- (CGFloat)dayColumnWidth
{
    return [self dayColumnWidthForWidth:self.collectionView.frame.size.width];
}

- (CGFloat)dayColumnWidthForWidth:(CGFloat)width
{
    return roundTo1Px( width / self.numberOfVisibleDays );
}

@end
