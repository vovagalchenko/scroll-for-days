//
//  INFSpaceRegion.m
//  InfiniteScroll
//
//  Created by Vova Galchenko on 3/22/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

#import "INFSpaceRegion.h"

@implementation INFSpaceRegion

+ (id)spaceRegionWithRect:(CGRect)rect
{
    return [[self alloc] initWithRect:rect];
}

- (id)initWithRect:(CGRect)rect
{
    if (self = [super init])
    {
        self.rect = rect;
        self.occupyingTile = [[INFTilePlaceholder alloc] init];
    }
    return self;
}

- (NSString *)description
{
    NSString *result = nil;
    if (CGRectIsNull(self.occupyingTile.rect))
    {
        result = @"---,---";
    }
    else
    {
        result = [NSString stringWithFormat:@"%3.0f,%3.0f", self.occupyingTile.rect.size.width, self.occupyingTile.rect.size.height];
    }
    return result;
}

@end
