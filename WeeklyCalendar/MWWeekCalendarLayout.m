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
@property (nonatomic, strong) RZCollectionViewAnimationAssistant *assistant;

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
    self.assistant = [RZCollectionViewAnimationAssistant new];
    [self.assistant setAttributesBlockForAnimatedCellUpdate:^(UICollectionViewLayoutAttributes *attributes, RZCollectionViewCellAttributeUpdateOptions *options) {
        if (options.isBoundsUpdate){
            CGRect oldBounds = options.previousBounds;
            CGSize size = attributes.size;
            size.width = [self dayColumnWidth];
            attributes.size = size;
        }
    }];
    self.oldBounds = CGRectZero;
    self.indexPathsToAnimate = [NSMutableArray new];
}

- (void)invalidateLayout
{
    [super invalidateLayout];
}

- (void)prepareForAnimatedBoundsChange:(CGRect)oldBounds
{
    [super prepareForAnimatedBoundsChange:oldBounds];
    [self.assistant prepareForAnimatedBoundsChange:oldBounds];
    self.oldBounds = oldBounds;
    CGFloat width = [self.delegate calendarLayoutCellWidth:self];
    NSLog(@"oldBounds: %@ newBounds: %@ width: %f", NSStringFromCGRect(oldBounds), NSStringFromCGRect(self.collectionView.bounds), width);
}

- (void)finalizeAnimatedBoundsChange
{
    [super finalizeAnimatedBoundsChange];
    self.oldBounds = CGRectZero;
    [self.assistant finalizeAnimatedBoundsChange];
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
    
    [self.assistant prepareForUpdates:updateItems];
    
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
    [self.assistant finalizeUpdates];
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
            UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:itemNo inSection:0]];
            attr.frame = itemFrame;
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
    UICollectionViewLayoutAttributes *attr = [super layoutAttributesForItemAtIndexPath:indexPath];
    return attr;
}

- (UICollectionViewLayoutAttributes*)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    NSLog(@"%s indexPath.item = %d attributes: %@", __PRETTY_FUNCTION__, itemIndexPath.item, attributes);
    
    CGFloat width = [self dayColumnWidthForWidth:self.oldBounds.size.width];
    CGRect frame = CGRectMake(itemIndexPath.item * width, 0, width, self.collectionView.frame.size.height);
    attributes.frame = frame;
//    attributes.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(0.2, 0.2), M_PI);
    return [self.assistant initialAttributesForCellWithAttributes:attributes atIndexPath:itemIndexPath];
    
//    if ([_indexPathsToAnimate containsObject:itemIndexPath]) {
//        attr.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(0.2, 0.2), M_PI);
//        attr.center = CGPointMake(CGRectGetMidX(self.collectionView.bounds), CGRectGetMaxY(self.collectionView.bounds));
//        [_indexPathsToAnimate removeObject:itemIndexPath];
//    }
//    
//    return attr;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    NSLog(@"%s indexPath.item = %d attributes: %@", __PRETTY_FUNCTION__, itemIndexPath.item, attributes);
//    CGSize size = attributes.size;
//    size.width = [self dayColumnWidth];
//    attributes.size = size;
    
    return [self.assistant finalAttributesForCellWithAttributes:attributes atIndexPath:itemIndexPath];;
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
