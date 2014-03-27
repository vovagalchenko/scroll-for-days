//
//  INFLayout.h
//  InfiniteScroll
//
//  Created by Vova Galchenko on 3/23/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "INFScrollViewTile.h"

@class INFScrollView;
@interface INFLayout : NSObject

- (void)layoutTilesForInfiniteScrollView:(INFScrollView *)infiniteScrollView
                             inContainer:(UIView *)tilesContainer
                            visibleFrame:(CGRect)visibleFrame;
- (INFScrollViewTile *)createTileForInfiniteScrollView:(INFScrollView *)infiniteScrollView
                                             withFrame:(CGRect)frame;

@end

static inline NSInteger positionHashForTile(INFScrollViewTile *tile)
{
    CGPoint origin = tile.frame.origin;
    // Need to generate a unique hash for an x, y pair.
    // idk... accumulating x and y and multiplying by a prime for good measure seems decent.
    NSInteger hash = origin.x;
    hash *= 29;
    hash += origin.y;
    return hash;
}