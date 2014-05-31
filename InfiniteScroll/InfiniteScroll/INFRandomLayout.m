//
//  INFRandomLayout.m
//  InfiniteScroll
//
//  Created by Vova Galchenko on 5/30/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

#import "INFRandomLayout.h"
#import "INFScrollViewTile.h"
#import "INFScrollView.h"

#define MIN_DIMENSION                   100
#define MAX_DIMENSION                   MIN_DIMENSION*2 + 200

@implementation INFRandomLayout

static INFRandomLayout *sharedInstance;

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[INFRandomLayout alloc] init];
    });
}

+ (INFRandomLayout *)layout
{
    return sharedInstance;
}

- (UIView *)tileContainerUsingTileProvider:(id<INFScrollViewTileProvider>)tileProvider
                     forInfiniteScrollView:(INFScrollView *)scrollView
{
    CGFloat maxDimension = MAX(scrollView.bounds.size.width, scrollView.bounds.size.height);
    CGSize tileAreaSize = CGSizeMake(maxDimension*2, maxDimension*2);
    UIView *tileContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tileAreaSize.width, tileAreaSize.height)];
    INFScrollViewTile *initialView = [tileProvider tileWithFrame:CGRectMake(0, 0, tileContainer.frame.size.width, tileContainer.frame.size.height)];
    [tileContainer addSubview:initialView];
    NSMutableArray *tilesToSplit = [NSMutableArray arrayWithObject:initialView];
    int numVertSplits = 0, numHorizSplits = 0;
    srand((unsigned int) time(NULL));
    while (tilesToSplit.count > 0)
    {
        int randomInt = rand();
        INFScrollViewTile *tileToSplit = [tilesToSplit objectAtIndex:randomInt%tilesToSplit.count];
        BOOL splitVertical = NO;
        if (tileToSplit.bounds.size.width > MIN_DIMENSION*2 && tileToSplit.bounds.size.height > MIN_DIMENSION*2)
        {
            splitVertical = (randomInt%2);
        }
        else if (tileToSplit.bounds.size.width > MIN_DIMENSION*2)
        {
            splitVertical = NO;
        }
        else if (tileToSplit.bounds.size.height > MIN_DIMENSION*2)
        {
            splitVertical = YES;
        }
        else
        {
            NSAssert(NO, @"A view was deemed as a view to split, when in fact it shouldn't have been: %@", tileToSplit);
        }
        CGRect newRect = CGRectNull;
        if (splitVertical)
        {
            // split vertical
            CGFloat newSplittingViewHeight = MIN_DIMENSION + randomInt%((int)tileToSplit.bounds.size.height - 2*MIN_DIMENSION);
            CGFloat newViewHeight = tileToSplit.bounds.size.height - newSplittingViewHeight;
            tileToSplit.frame = CGRectMake(tileToSplit.frame.origin.x, tileToSplit.frame.origin.y,
                                           tileToSplit.frame.size.width, newSplittingViewHeight);
            newRect = CGRectMake(tileToSplit.frame.origin.x, tileToSplit.frame.origin.y + newSplittingViewHeight,
                                 tileToSplit.frame.size.width, newViewHeight);
            numVertSplits++;
        }
        else
        {
            // split horizontal
            CGFloat newSplittingViewWidth = MIN_DIMENSION + randomInt%((int)tileToSplit.bounds.size.width - 2*MIN_DIMENSION);
            CGFloat newViewWidth = tileToSplit.bounds.size.width - newSplittingViewWidth;
            tileToSplit.frame = CGRectMake(tileToSplit.frame.origin.x, tileToSplit.frame.origin.y,
                                           newSplittingViewWidth, tileToSplit.frame.size.height);
            newRect = CGRectMake(tileToSplit.frame.origin.x + newSplittingViewWidth, tileToSplit.frame.origin.y,
                                 newViewWidth, tileToSplit.frame.size.height);
            numHorizSplits++;
        }
        if (tileToSplit.bounds.size.height <= MAX_DIMENSION && tileToSplit.bounds.size.width <= MAX_DIMENSION)
        {
            [tilesToSplit removeObject:tileToSplit];
        }
        INFScrollViewTile *tileToAdd = [tileProvider tileWithFrame:newRect];
        if (tileToAdd.bounds.size.width > MAX_DIMENSION || tileToAdd.bounds.size.height > MAX_DIMENSION)
        {
            [tilesToSplit addObject:tileToAdd];
        }
        [tileContainer addSubview:tileToAdd];
    }
    return tileContainer;
}

@end
