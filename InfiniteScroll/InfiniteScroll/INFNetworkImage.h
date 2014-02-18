//
//  NetworkImage.h
//  Infinite Scroll
//
//  Created by Vova Galchenko on 2/2/13.
//  Copyright (c) 2013 Vova Galchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ImageConsumer;

@interface INFNetworkImage : NSObject

@property (nonatomic, readwrite, strong) NSURL *imageURL;
@property (nonatomic, readwrite, strong) NSString *imageID;
@property (nonatomic, readonly, strong) UIImage *image;

- (id)initWithURL:(NSURL *)url
          imageID:(NSString *)imageID;
- (void)fetchImageForImageConsumer:(id<ImageConsumer>)imageConsumer;
- (void)unhookImageConsumer:(id<ImageConsumer>)imageConsumer;
+ (NSString *)hddImageCacheDirectory;

@end
