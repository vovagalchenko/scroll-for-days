//
//  FlickrScrollViewTile.m
//  InfiniteScrollSample
//
//  Created by Vova Galchenko on 2/17/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

#import "FlickrScrollViewTile.h"

@implementation FlickrScrollViewTile

- (void)consumeImage:(UIImage *)image animated:(BOOL)animated
{
    if (!image)
    {
        image = [UIImage imageNamed:@"noimage.jpg"];
    }
    [super consumeImage:image animated:animated];
}

@end
