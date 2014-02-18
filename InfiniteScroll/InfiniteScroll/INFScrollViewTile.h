//
//  InfiniteScrollViewTile.h
//  Infinite Scroll
//
//  Created by Vova Galchenko on 1/19/13.
//  Copyright (c) 2013 Vova Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class INFScrollViewTile;

@interface INFScrollViewTile : UIView <UIGestureRecognizerDelegate>

- (CGSize)requestingSize;
- (BOOL)isSelectable;

@property (nonatomic, readwrite, assign, getter = isSelected) BOOL selected;

@end
