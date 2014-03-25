//
//  INFSpaceRegion.h
//  InfiniteScroll
//
//  Created by Vova Galchenko on 3/22/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>
#import "INFTilePlaceholder.h"

@interface INFSpaceRegion : NSObject

+ (id)spaceRegionWithRect:(CGRect)rect;

@property (nonatomic, readwrite, assign) CGRect rect;
@property (nonatomic, readwrite, strong) INFTilePlaceholder *occupyingTile;

@end