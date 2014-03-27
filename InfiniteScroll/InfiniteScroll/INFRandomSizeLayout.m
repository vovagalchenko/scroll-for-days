//
//  INFRandomSizeLayout.m
//  InfiniteScroll
//
//  Created by Vova Galchenko on 3/23/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

#import "INFRandomSizeLayout.h"
#import "INFSpaceRegion.h"
#import "INFScrollView.h"

#define MIN_DIMENSION                   100
#define MAX_DIMENSION                   MIN_DIMENSION*2 + 200
#define PATTERN_DIMENSION               1136

@interface INFRandomSizeLayout()

@property (nonatomic, readwrite, strong) NSArray *pattern;
@property (nonatomic, readwrite, strong) NSMutableArray *tilePool;

@end

@implementation INFRandomSizeLayout

- (id)init
{
    if (self = [super init])
    {
        INFSpaceRegion *firstRegion = [INFSpaceRegion spaceRegionWithRect:CGRectMake(0, 0, PATTERN_DIMENSION, PATTERN_DIMENSION)];
        firstRegion.occupyingTile.rect = CGRectMake(0, 0, PATTERN_DIMENSION, PATTERN_DIMENSION);
        NSMutableArray *pattern = [NSMutableArray arrayWithObject:[NSMutableArray arrayWithObject:firstRegion]];
        NSMutableArray *tilesToSplit = [NSMutableArray arrayWithObject:firstRegion.occupyingTile];
        srand((unsigned int) time(NULL));
        while (tilesToSplit.count > 0)
        {
            int randomInt = rand();
            INFTilePlaceholder *tileToSplit = [tilesToSplit firstObject];
            BOOL shouldSplitVertical = NO;
            if (tileToSplit.rect.size.width > MIN_DIMENSION*2 && tileToSplit.rect.size.height > MIN_DIMENSION*2)
            {
                shouldSplitVertical = (randomInt%2);
            }
            else if (tileToSplit.rect.size.height > MIN_DIMENSION*2)
            {
                shouldSplitVertical = YES;
            }
            else if (tileToSplit.rect.size.width > MIN_DIMENSION*2)
            {
                shouldSplitVertical = NO;
            }
            else
            {
                NSAssert(NO, @"A tile was deemed as a tile to split, when in fact it shouldn't have been: %@", tileToSplit);
            }
            
            INFTilePlaceholder *newOccupyingTile = [[INFTilePlaceholder alloc] init];
            if (shouldSplitVertical)
            {
                CGFloat newSplittingTileHeight = MIN_DIMENSION + randomInt%((int)tileToSplit.rect.size.height - 2*MIN_DIMENSION);
                CGFloat topOfOldTile = tileToSplit.rect.origin.y + tileToSplit.rect.size.height;
                tileToSplit.rect = CGRectMake(tileToSplit.rect.origin.x, tileToSplit.rect.origin.y, tileToSplit.rect.size.width, newSplittingTileHeight);
                newOccupyingTile.rect = CGRectMake(tileToSplit.rect.origin.x, tileToSplit.rect.origin.y + tileToSplit.rect.size.height,
                                                   tileToSplit.rect.size.width, topOfOldTile - (tileToSplit.rect.origin.y + tileToSplit.rect.size.height));
                // Could turn this into a binary search if performance optimization is desired
                for (NSMutableArray *column in pattern)
                {
                    BOOL columnNeedsNewOccupyingTile = ([column[0] rect].origin.x > tileToSplit.rect.origin.x ||
                                                        [column[0] rect].origin.x + [column[0] rect].size.width < tileToSplit.rect.origin.x + tileToSplit.rect.size.width);
                    NSUInteger rowIndex = 0;
                    INFSpaceRegion *currentSpaceRegion = nil;
                    do
                    {
                        currentSpaceRegion = column[rowIndex++];
                        if (currentSpaceRegion.rect.origin.y < tileToSplit.rect.origin.y + newSplittingTileHeight &&
                            currentSpaceRegion.rect.origin.y + currentSpaceRegion.rect.size.height > tileToSplit.rect.origin.y + newSplittingTileHeight)
                        {
                            // Need to split this region
                            CGFloat newSplitRegionHeight = newSplittingTileHeight - (currentSpaceRegion.rect.origin.y - tileToSplit.rect.origin.y);
                            INFSpaceRegion *newSpaceRegion = [INFSpaceRegion spaceRegionWithRect:CGRectMake(currentSpaceRegion.rect.origin.x, currentSpaceRegion.rect.origin.y + newSplitRegionHeight,
                                                                                                            currentSpaceRegion.rect.size.width, currentSpaceRegion.rect.size.height - newSplitRegionHeight)];
                            newSpaceRegion.occupyingTile = currentSpaceRegion.occupyingTile;
                            currentSpaceRegion.rect = CGRectMake(currentSpaceRegion.rect.origin.x, currentSpaceRegion.rect.origin.y,
                                                                 currentSpaceRegion.rect.size.width, newSplitRegionHeight);
                            [column insertObject:newSpaceRegion atIndex:rowIndex];
                        }
                        else if (columnNeedsNewOccupyingTile &&
                                 currentSpaceRegion.rect.origin.y + currentSpaceRegion.rect.size.height > tileToSplit.rect.origin.y + newSplittingTileHeight)
                        {
                            currentSpaceRegion.occupyingTile = newOccupyingTile;
                        }
                    }
                    while (currentSpaceRegion.rect.origin.y + currentSpaceRegion.rect.size.height <= topOfOldTile && rowIndex < column.count);
                }
            }
            else
            {
                CGFloat newSplittingTileWidth = MIN_DIMENSION + randomInt%((int)tileToSplit.rect.size.width - 2*MIN_DIMENSION);
                CGFloat rightOfOldTile = tileToSplit.rect.origin.x + tileToSplit.rect.size.width;
                tileToSplit.rect = CGRectMake(tileToSplit.rect.origin.x, tileToSplit.rect.origin.y,
                                              newSplittingTileWidth, tileToSplit.rect.size.height);
                newOccupyingTile.rect = CGRectMake(tileToSplit.rect.origin.x + tileToSplit.rect.size.width, tileToSplit.rect.origin.y,
                                                   rightOfOldTile - (tileToSplit.rect.origin.x + tileToSplit.rect.size.width), tileToSplit.rect.size.height);
                // Could turn this into a binary search if performance optimization is desired
                for (int i = 0; i < pattern.count; i++)
                {
                    NSArray *column = pattern[i];
                    if ([column[0] rect].origin.x < tileToSplit.rect.origin.x + newSplittingTileWidth &&
                        [column[0] rect].origin.x + [column[0] rect].size.width > tileToSplit.rect.origin.x + newSplittingTileWidth)
                    {
                        // Need to split this column
                        NSMutableArray *newColumn = [NSMutableArray arrayWithCapacity:column.count];
                        CGFloat newSplitRegionWidth = newSplittingTileWidth - ([column[0] rect].origin.x - tileToSplit.rect.origin.x);
                        for (INFSpaceRegion *region in column)
                        {
                            [newColumn addObject:[INFSpaceRegion spaceRegionWithRect:CGRectMake(region.rect.origin.x + newSplitRegionWidth, region.rect.origin.y, region.rect.size.width - newSplitRegionWidth, region.rect.size.height)]];
                            region.rect = CGRectMake(region.rect.origin.x, region.rect.origin.y, newSplitRegionWidth, region.rect.size.height);
                        }
                        [pattern insertObject:newColumn atIndex:i+1];
                    }
                    else if ([column[0] rect].origin.x + [column[0] rect].size.width > tileToSplit.rect.origin.x + newSplittingTileWidth)
                    {
                        for (INFSpaceRegion *region in column)
                        {
                            region.occupyingTile = newOccupyingTile;
                        }
                    }
                }
            }
            
            if (tileToSplit.rect.size.height <= MAX_DIMENSION && tileToSplit.rect.size.width <= MAX_DIMENSION)
            {
                [tilesToSplit removeObject:tileToSplit];
            }
            if (newOccupyingTile.rect.size.height > MAX_DIMENSION || newOccupyingTile.rect.size.width > MAX_DIMENSION)
            {
                [tilesToSplit addObject:newOccupyingTile];
            }
        }
        self.pattern = [NSArray arrayWithArray:pattern];
        self.tilePool = [NSMutableArray arrayWithCapacity:pattern.count * [pattern[0] count]];
    }
    return self;
}

static inline NSUInteger findX(NSArray *columns, CGFloat xToFind, NSUInteger startSearch, NSUInteger endSearch)
{
    if (startSearch == endSearch)
    {
        NSUInteger result = NSNotFound;
        if ([columns[startSearch][0] compareToX:xToFind] == NSOrderedSame)
            result = startSearch;
        return result;
    }
    
    NSUInteger midIndex = (startSearch + endSearch)/2 + 1;
    NSComparisonResult comparisonOfRangeToX = [columns[midIndex][0] compareToX:xToFind];
    if (comparisonOfRangeToX == NSOrderedDescending)
    {
        return findX(columns, xToFind, startSearch, midIndex - 1);
    }
    else if (comparisonOfRangeToX == NSOrderedSame)
    {
        return midIndex;
    }
    else
    {
        return findX(columns, xToFind, midIndex + 1, endSearch);
    }
}

static inline NSUInteger findY(NSArray *regions, CGFloat yToFind, NSUInteger startSearch, NSUInteger endSearch)
{
    if (startSearch >= endSearch)
    {
        NSUInteger result = NSNotFound;
        if ([regions[endSearch] compareToY:yToFind] == NSOrderedSame)
            result = endSearch;
        return result;
    }
    
    NSUInteger midIndex = (startSearch + endSearch)/2;
    NSComparisonResult comparisonOfRangeToX = [regions[midIndex] compareToY:yToFind];
    if (comparisonOfRangeToX == NSOrderedDescending)
    {
        return findY(regions, yToFind, startSearch, midIndex - 1);
    }
    else if (comparisonOfRangeToX == NSOrderedSame)
    {
        return midIndex;
    }
    else
    {
        return findY(regions, yToFind, midIndex + 1, endSearch);
    }
}

static inline NSIndexPath *search(NSArray *pattern, CGPoint pointToFind)
{
    NSUInteger columnIndex = findX(pattern, pointToFind.x, 0, pattern.count - 1);
    NSCAssert(columnIndex != NSNotFound, @"Couldn't find the column containing point: (%f, %f)", pointToFind.x, pointToFind.y);
    NSUInteger rowIndex = findY(pattern[columnIndex], pointToFind.y, 0, [pattern[columnIndex] count] - 1);
    NSCAssert(rowIndex != NSNotFound, @"Couldn't find the row containing point: (%f, %f)", pointToFind.x, pointToFind.y);
    return [NSIndexPath indexPathForRow:rowIndex inSection:columnIndex];
}

static BOOL CGRectAreSame(CGRect rect1, CGRect rect2)
{
    return  rect1.origin.x == rect2.origin.x &&
            rect1.origin.y == rect2.origin.y &&
            rect1.size.width == rect2.size.width &&
            rect1.size.height == rect2.size.height;
}

- (void)layoutTilesForInfiniteScrollView:(INFScrollView *)infiniteScrollView
                             inContainer:(UIView *)tilesContainer
                            visibleFrame:(CGRect)visibleFrame
{
    NSMutableArray *availableTiles = [NSMutableArray arrayWithCapacity:self.tilePool.count];
    for (INFScrollViewTile *tile in self.tilePool)
    {
        if (!CGRectIntersectsRect(tile.frame, visibleFrame))
        {
            [availableTiles addObject:tile];
            [infiniteScrollView.infiniteScrollViewDelegate infiniteScrollView:infiniteScrollView
                                                              isDoneUsingTile:tile
                                                               atPositionHash:positionHashForTile(tile)];
        }
    }
    CGPoint origin = CGPointMake(
                                 visibleFrame.origin.x - floor(visibleFrame.origin.x/PATTERN_DIMENSION)*PATTERN_DIMENSION,
                                 visibleFrame.origin.y - floor(visibleFrame.origin.y/PATTERN_DIMENSION)*PATTERN_DIMENSION
                                 );
    NSIndexPath *startRegionIndexPath = search(self.pattern, origin);
    CGFloat rightMostX = visibleFrame.origin.x + visibleFrame.size.width;
    CGFloat bottomMostY = visibleFrame.origin.y + visibleFrame.size.height;
    for (NSInteger column = startRegionIndexPath.section; [self.pattern[column][0] rect].origin.x <= rightMostX; column++)
    {
        for (NSInteger row = startRegionIndexPath.row; [self.pattern[column][row] rect].origin.y <= bottomMostY; row++)
        {
            INFSpaceRegion *spaceRegion = self.pattern[column][row];
            if (!spaceRegion.occupyingTile.tile)
            {
                INFScrollViewTile *tile = nil;
                if (availableTiles.count > 0)
                {
                    tile = [availableTiles lastObject];
                }
                else
                {
                    
                    tile = [self createTileForInfiniteScrollView:infiniteScrollView withFrame:CGRectNull];
                    [tilesContainer addSubview:tile];
                }
                spaceRegion.occupyingTile.tile = tile;
            }
            if (!CGRectAreSame(spaceRegion.occupyingTile.tile.frame, spaceRegion.occupyingTile.rect))
            {
                NSLog(@"%@", CGRectCreateDictionaryRepresentation(spaceRegion.occupyingTile.rect));
                spaceRegion.occupyingTile.tile.frame = spaceRegion.occupyingTile.rect;
                [infiniteScrollView.infiniteScrollViewDelegate infiniteScrollView:infiniteScrollView
                                                   willUseInfiniteScrollViewTitle:spaceRegion.occupyingTile.tile
                                                                   atPositionHash:positionHashForTile(spaceRegion.occupyingTile.tile)];
            }
            
        }
    }
}

@end
