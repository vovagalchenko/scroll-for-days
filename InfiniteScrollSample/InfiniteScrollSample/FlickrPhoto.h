//
//  FlickrPhoto.h
//  Infinite Scroll
//
//  Created by Vova Galchenko on 1/19/13.
//  Copyright (c) 2013 Vova Galchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "INFNetworkImage.h"
#import "InfiniteScroll/INFNetworkImage.h"

#define kFlickrAPIKey   @"0b6b24ec0d693e335ca8b15990e01ec2"

@interface FlickrPhoto : INFNetworkImage <NSURLConnectionDataDelegate>

- (id)initWithFlickrID:(NSString *)flickrID
                secret:(NSString *)secret
                  farm:(NSString *)farmID
                server:(NSString *)serverString;

@end
