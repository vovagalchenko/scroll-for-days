//
//  NetworkImage.m
//  Infinite Scroll
//
//  Created by Vova Galchenko on 2/2/13.
//  Copyright (c) 2013 Vova Galchenko. All rights reserved.
//

#import "INFNetworkImage.h"
#import "INFNetworkImageScrollViewTile.h"

@interface INFNetworkImage()

@property (nonatomic, readonly, strong) NSString *imageFilePath;
@property (nonatomic, readwrite, strong) UIImage *image;
@property (nonatomic, readwrite, strong) NSMutableData *receivedData;
@property (nonatomic, readwrite, strong) NSMutableSet *imageConsumers;
@property (nonatomic, readwrite, strong) NSURLConnection *imageDownloadConnection;
@property (nonatomic, readwrite, assign) BOOL cachedOnHDD;
@property (nonatomic, readwrite, assign, getter = isConnectionQueued) BOOL connectionQueued;

@end

@implementation INFNetworkImage

@synthesize imageID = _imageID;
@synthesize imageURL = _imageURL;
@synthesize receivedData = _receivedData;
@synthesize imageConsumers = _imageConsumers;
@synthesize imageDownloadConnection = _imageDownloadConnection;
@synthesize image = _image;
@synthesize imageFilePath = _imageFilePath;
@synthesize cachedOnHDD = _cachedOnHDD;
@synthesize connectionQueued = _connectionQueued;

#define IMAGE_CACHE_SIZE        25
static NSMutableDictionary *cachedPhotos;

#pragma mark - Object Lifecycle

- (id)initWithURL:(NSURL *)url
          imageID:(NSString *)imageID
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cachedPhotos = [[NSMutableDictionary alloc] initWithCapacity:IMAGE_CACHE_SIZE];
    });
    if (self = [super init])
    {
        _imageID = imageID;
        _imageURL = url;
        _image = nil;
        _imageConsumers = [NSMutableSet set];
    }
    return self;
}

#pragma mark - Image Consumers

- (void)fetchImageForImageConsumer:(id<ImageConsumer>)imageConsumer
{
    if (self.image)
    {
        [imageConsumer consumeImage:self.image animated:NO];
    }
    else
    {
        if (self.cachedOnHDD)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
            {
                NSString *filePath = [self imageFilePath];
                UIImage *imageFromHD = [UIImage imageWithData:[NSData dataWithContentsOfFile:filePath] scale:[[UIScreen mainScreen] scale]];
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    self.image = imageFromHD;
                    [imageConsumer consumeImage:self.image animated:YES];
                });
            });
        }
        else
        {
            self.receivedData = [NSMutableData data];
            [self.imageConsumers addObject:imageConsumer];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
            {
                if (!self.isConnectionQueued)
                {
                    self.connectionQueued = YES;
                    // According to the Time Profiler instrument, creating and scheduling a connection is kinda slow, so moving it to a background queue.
                    self.imageDownloadConnection = [[NSURLConnection alloc] initWithRequest:[self urlRequest] delegate:self startImmediately:NO];
                    [self.imageDownloadConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:UITrackingRunLoopMode];
                    [self.imageDownloadConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
                    [self.imageDownloadConnection start];
                    while(self.isConnectionQueued)
                    {
                        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                    }
                }
            });
        }
    }
}

- (void)unhookImageConsumer:(id<ImageConsumer>)imageConsumer
{
    [self.imageConsumers removeObject:imageConsumer];
    if (self.imageDownloadConnection && self.imageConsumers.count == 0)
    {
        [self.imageDownloadConnection cancel];
        self.imageDownloadConnection = nil;
        self.connectionQueued = NO;
    }
}

#pragma mark - URL Connection

- (NSURLRequest *)urlRequest
{
    return [[NSURLRequest alloc] initWithURL:self.imageURL];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *imageFromWeb = [UIImage imageWithData:self.receivedData scale:[[UIScreen mainScreen] scale]];
    dispatch_sync(dispatch_get_main_queue(), ^
    {
        self.image = imageFromWeb;
        for (id<ImageConsumer>imageConsumer in self.imageConsumers)
        {
            [imageConsumer consumeImage:self.image animated:YES];
        }
        [self.imageConsumers removeAllObjects];
    });
    self.cachedOnHDD = [self.receivedData writeToFile:[self imageFilePath] atomically:YES];
    self.receivedData = nil;
    self.imageDownloadConnection = nil;
    self.connectionQueued = NO;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed with error: %@", error);
    for (id<ImageConsumer>imageConsumer in self.imageConsumers)
    {
        [imageConsumer consumeImage:nil animated:NO];
    }
    [self.imageConsumers removeAllObjects];
    self.receivedData = nil;
    self.connectionQueued = NO;
    self.imageDownloadConnection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

#pragma mark - Dealing With The Image

- (void)setImage:(UIImage *)image
{
    _image = image;
    NSNumber *myHash = [NSNumber numberWithUnsignedInteger:[self hash]];
    if (_image && ![cachedPhotos objectForKey:myHash])
    {
        while (cachedPhotos.count >= IMAGE_CACHE_SIZE)
        {
            ((INFNetworkImage *)[[cachedPhotos allValues] objectAtIndex:0]).image = nil;
        }
        [cachedPhotos setObject:self forKey:myHash];
    }
    else if (!_image)
    {
        [cachedPhotos removeObjectForKey:myHash];
    }
}

- (NSString *)imageFilePath
{
    if (!_imageFilePath)
    {
        _imageFilePath = [[[self class] hddImageCacheDirectory] stringByAppendingPathComponent:self.imageID];
    }
    return _imageFilePath;
}

+ (NSString *)hddImageCacheDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return [basePath stringByAppendingPathComponent:@"infinite_scroll_cache"];
}

@end
