//
//  INFUniformSizeLayout.h
//  InfiniteScroll
//
//  Created by Vova Galchenko on 5/30/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INFLayout.h"

@interface INFUniformSizeLayout : NSObject <INFLayout>

- (id)initWithTileSize:(CGSize)desiredTileSize;

@end
