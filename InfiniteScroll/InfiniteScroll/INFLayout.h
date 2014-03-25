//
//  INFLayout.h
//  InfiniteScroll
//
//  Created by Vova Galchenko on 3/23/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface INFLayout : NSObject

- (void)layoutTilesInContainer:(UIView *)tilesContainer visibleFrame:(CGRect)visibleFrame;

@end