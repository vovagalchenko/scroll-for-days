//
//  FlickrPhoto.m
//  Infinite Scroll
//
//  Created by Vova Galchenko on 1/19/13.
//  Copyright (c) 2013 Vova Galchenko. All rights reserved.
//

#import "FlickrPhoto.h"

@implementation FlickrPhoto

- (id)initWithFlickrID:(NSString *)flickrID
                secret:(NSString *)secret
                  farm:(NSString *)farmID
                server:(NSString *)serverString
{
    return [super initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@.jpg", farmID, serverString, flickrID, secret]]
                      imageID:flickrID];
}


@end
