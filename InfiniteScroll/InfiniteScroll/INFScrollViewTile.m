//
//  InfiniteScrollViewTile.m
//  Infinite Scroll
//
//  Created by Vova Galchenko on 1/19/13.
//  Copyright (c) 2013 Vova Galchenko. All rights reserved.
//

#import "INFScrollViewTile.h"

@implementation INFScrollViewTile

- (id)init
{
    if (self = [super init])
    {
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (CGSize)requestingSize
{
    return CGSizeZero;
}

- (BOOL)isSelectable
{
    return NO;
}

@end
