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

- (NSComparisonResult)compareToX:(CGFloat)x
{
    NSComparisonResult result = NSOrderedSame;
    if (self.rect.origin.x > x)
    {
        result = NSOrderedDescending;
    }
    else if (self.rect.origin.x <= x && self.rect.origin.x + self.rect.size.width > x)
    {
        result = NSOrderedSame;
    }
    else
    {
        result = NSOrderedAscending;
    }
    return result;
}

- (NSComparisonResult)compareToY:(CGFloat)y
{
    NSComparisonResult result = NSOrderedSame;
    if (self.rect.origin.y > y)
    {
        result = NSOrderedDescending;
    }
    else if (self.rect.origin.y <= y && self.rect.origin.y + self.rect.size.height > y)
    {
        result = NSOrderedSame;
    }
    else
    {
        result = NSOrderedAscending;
    }
    return result;
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
