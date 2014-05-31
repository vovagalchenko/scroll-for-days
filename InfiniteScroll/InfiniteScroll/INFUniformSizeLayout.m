//
//  INFUniformSizeLayout.m
//  InfiniteScroll
//
//  Created by Vova Galchenko on 5/30/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

#import "INFUniformSizeLayout.h"
#import "INFScrollView.h"
#import "INFScrollViewTile.h"

@interface INFUniformSizeLayout()

@property (nonatomic, readwrite, assign) CGSize tileSize;

@end

@implementation INFUniformSizeLayout

- (id)initWithTileSize:(CGSize)desiredTileSize
{
    if (self = [super init])
    {
        self.tileSize = desiredTileSize;
    }
    return self;
}

- (UIView *)tileContainerUsingTileProvider:(id<INFScrollViewTileProvider>)tileProvider
                     forInfiniteScrollView:(INFScrollView *)scrollView
{
    CGFloat maxDimension = MAX(scrollView.bounds.size.width, scrollView.bounds.size.height);
    CGSize desiredTileAreaSize = CGSizeMake(maxDimension, maxDimension);
    CGFloat maxX = 0;
    CGFloat maxY = 0;
    UIView *container = [[UIView alloc] init];
    while (maxX < desiredTileAreaSize.width)
    {
        maxY = 0;
        while (maxY < desiredTileAreaSize.height)
        {
            [container addSubview:[tileProvider tileWithFrame:CGRectMake(maxX, maxY, self.tileSize.width, self.tileSize.height)]];
            maxY += self.tileSize.height;
        }
        maxX += self.tileSize.width;
    }
    container.frame = CGRectMake(0, 0, maxX, maxY);
    return container;
}

@end
