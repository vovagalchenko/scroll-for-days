//
//  INFRandomSizeLayout.m
//  InfiniteScroll
//
//  Created by Vova Galchenko on 3/23/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

#import "INFRandomSizeLayout.h"
#import "INFSpaceRegion.h"

#define MIN_DIMENSION                   100
#define MAX_DIMENSION                   MIN_DIMENSION*2 + 200
#define PATTERN_DIMENSION               1136

@interface INFRandomSizeLayout()

@property (nonatomic, readwrite, strong) NSArray *pattern;

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
        while (tilesToSplit.count > 0)
        {
            int randomInt = rand();
            INFTilePlaceholder *tileToSplit = [tilesToSplit firstObject];
            BOOL shouldSplitVertical = NO;
            if (tileToSplit.rect.size.width > MIN_DIMENSION*2 && tileToSplit.rect.size.height > MIN_DIMENSION*2)
            {
                shouldSplitVertical = (randomInt%2);
            }
            else if (tileToSplit.rect.size.width > MIN_DIMENSION*2)
            {
                shouldSplitVertical = NO;
            }
            else if (tileToSplit.rect.size.height > MIN_DIMENSION*2)
            {
                shouldSplitVertical = YES;
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
                    if ([column[0] rect].origin.x > tileToSplit.rect.origin.x ||
                        [column[0] rect].origin.x + [column[0] rect].size.width < tileToSplit.rect.origin.x + tileToSplit.rect.size.width)
                        continue;
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
                            INFSpaceRegion *newSpaceRegion = [INFSpaceRegion spaceRegionWithRect:CGRectMake(currentSpaceRegion.rect.origin.x, currentSpaceRegion.rect.origin.y,
                                                                                                            currentSpaceRegion.rect.size.width, currentSpaceRegion.rect.size.height - newSplitRegionHeight)];
                            currentSpaceRegion.rect = CGRectMake(currentSpaceRegion.rect.origin.x, currentSpaceRegion.rect.origin.y,
                                                                 currentSpaceRegion.rect.size.width, newSplitRegionHeight);
                            [column insertObject:newSpaceRegion atIndex:rowIndex];
                        }
                        else if (currentSpaceRegion.rect.origin.y + currentSpaceRegion.rect.size.height > tileToSplit.rect.origin.y + newSplittingTileHeight)
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
                CGFloat rightOfOldTile = tileToSplit.rect.origin.x + tileToSplit.rect.size.height;
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
                        CGFloat newRegionWidth = rightOfOldTile - ([column[0] rect].origin.x + newSplitRegionWidth);
                        for (INFSpaceRegion *region in column)
                        {
                            region.rect = CGRectMake(region.rect.origin.x, region.rect.origin.y, newSplitRegionWidth, region.rect.size.height);
                            [newColumn addObject:[INFSpaceRegion spaceRegionWithRect:CGRectMake(region.rect.origin.x + newSplitRegionWidth, region.rect.origin.y, newRegionWidth, region.rect.size.height)]];
                        }
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
    }
    return self;
}

- (void)layoutTilesInContainer:(UIView *)tilesContainer visibleFrame:(CGRect)visibleFrame
{
    NSLog(@"(%f, %f, %f, %f)", visibleFrame.origin.x, visibleFrame.origin.y, visibleFrame.size.width, visibleFrame.size.height);
}

@end
