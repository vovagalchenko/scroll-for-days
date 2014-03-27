//
//  INFLayout.m
//  InfiniteScroll
//
//  Created by Vova Galchenko on 3/23/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

#import "INFLayout.h"
#import "INFScrollViewTile.h"
#import "INFScrollView.h"

@implementation INFLayout

- (void)layoutTilesForInfiniteScrollView:(INFScrollView *)infiniteScrollView
                             inContainer:(UIView *)tilesContainer
                            visibleFrame:(CGRect)visibleFrame
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (INFScrollViewTile *)createTileForInfiniteScrollView:(INFScrollView *)infiniteScrollView
                                             withFrame:(CGRect)frame
{
    NSAssert([infiniteScrollView.infiniteScrollViewDelegate respondsToSelector:@selector(infiniteScrollViewTileForInfiniteScrollView:)], @"Must have infiniteScrollViewDelegate to have an operational infiniteScrollView");
    INFScrollViewTile *tile = [infiniteScrollView.infiniteScrollViewDelegate infiniteScrollViewTileForInfiniteScrollView:infiniteScrollView];
    tile.frame = frame;
    return tile;
}

@end