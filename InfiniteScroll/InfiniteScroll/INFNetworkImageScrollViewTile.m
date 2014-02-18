//
//  FlickrInfiniteScrollViewTile.m
//  Infinite Scroll
//
//  Created by Vova Galchenko on 1/19/13.
//  Copyright (c) 2013 Vova Galchenko. All rights reserved.
//

#import "INFNetworkImageScrollViewTile.h"
#import "INFNetworkImage.h"
#import <QuartzCore/QuartzCore.h>

#define BORDER_WIDTH        2

@interface INFNetworkImageScrollViewTile()

@property (nonatomic, readwrite, strong) INFNetworkImage *networkImage;
@property (nonatomic, readwrite, strong) UIImageView *imageView;

@end

@implementation INFNetworkImageScrollViewTile

@synthesize imageView = _imageView;
@synthesize networkImage = _networkImage;

- (id)init
{
    if (self = [super init])
    {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(BORDER_WIDTH, BORDER_WIDTH, self.frame.size.width - 2*BORDER_WIDTH, self.frame.size.height - 2*BORDER_WIDTH)];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        super.layer.borderColor = [[UIColor whiteColor] CGColor];
        super.layer.borderWidth = BORDER_WIDTH;
        super.clipsToBounds = YES;
        super.backgroundColor = [UIColor grayColor];
 //       self.backgroundColor = [UIColor colorWithRed:(float)rand()/RAND_MAX green:(float)rand()/RAND_MAX blue:(float)rand()/RAND_MAX alpha:1.0];
        [self addSubview:_imageView];
    }
    return self;
}

- (void)fillTileWithNetworkImage:(INFNetworkImage *)networkImage
{
    self.imageView.image = nil;
    self.networkImage = networkImage;
}

- (void)setNetworkImage:(INFNetworkImage *)networkImage
{
    [self.networkImage unhookImageConsumer:self];
    _networkImage = networkImage;
    [networkImage fetchImageForImageConsumer:self];
}

- (void)consumeImage:(UIImage *)image animated:(BOOL)animated
{
    if (self.networkImage.image != image)
    {
        return;
    }

    if (image && self.imageView.alpha != (!animated))
    {
        self.imageView.alpha = !animated;
    }
    
    self.imageView.image = image;
    if (animated && self.imageView.alpha != 1.0)
    {
        [UIView animateWithDuration:.4 animations:^
        {
            self.imageView.alpha = 1.0;
        }];
    }
}

- (CGSize)requestingSize
{
    return self.imageView.image.size;
}

- (BOOL)isSelectable
{
    return self.imageView.image != nil;
}

@end
