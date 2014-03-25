//
//  INFLayout.m
//  InfiniteScroll
//
//  Created by Vova Galchenko on 3/23/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

#import "INFLayout.h"

@implementation INFLayout

- (void)layoutTilesInContainer:(UIView *)tilesContainer visibleFrame:(CGRect)visibleFrame
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end