//
//  KTCAppDelegate.h
//  Infinite Scroll
//
//  Created by Vova Galchenko on 1/17/13.
//  Copyright (c) 2013 Vova Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#define AppDelegate     ((FlickrAppDelegate *)[[UIApplication sharedApplication] delegate])

@interface FlickrAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)startActivityIndicatorWithStatus:(NSString *)status;
- (void)stopActivityIndicator;

@end
