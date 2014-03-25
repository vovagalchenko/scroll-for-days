//
//  INFTilePlaceholder.h
//  InfiniteScroll
//
//  Created by Vova Galchenko on 3/24/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INFScrollViewTile.h"

@interface INFTilePlaceholder : NSObject

@property (nonatomic, readwrite, strong) INFScrollViewTile *tile;
@property (nonatomic, readwrite, assign) CGRect rect;

@end
