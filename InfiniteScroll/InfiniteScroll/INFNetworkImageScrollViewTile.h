//
//  FlickrInfiniteScrollViewTile.h
//  Infinite Scroll
//
//  Created by Vova Galchenko on 1/19/13.
//  Copyright (c) 2013 Vova Galchenko. All rights reserved.
//

#import "INFScrollViewTile.h"
@class INFNetworkImage;

@protocol ImageConsumer <NSObject>

- (void)consumeImage:(UIImage *)image animated:(BOOL)animated;

@end

@interface INFNetworkImageScrollViewTile : INFScrollViewTile <ImageConsumer>

- (id)init;
- (void)fillTileWithNetworkImage:(INFNetworkImage *)networkImage;
- (void)consumeImage:(UIImage *)image animated:(BOOL)animated;

@end