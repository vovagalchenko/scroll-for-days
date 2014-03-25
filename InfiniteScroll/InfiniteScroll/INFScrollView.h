//
//  InfiniteScrollView.h
//  Infinite Scroll
//
//  Created by Vova Galchenko on 1/17/13.
//  Copyright (c) 2013 Vova Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INFLayout.h"

extern const unsigned short INFScrollHorizontally;
extern const unsigned short INFScrollVertically;

@class INFScrollViewTile;
@class INFScrollView;

@protocol INFScrollViewDelegate <NSObject>

@required
- (INFScrollViewTile *)infiniteScrollViewTileForInfiniteScrollView:(INFScrollView *)infiniteScrollView;
- (void)infiniteScrollView:(INFScrollView *)infiniteScrollView willUseInfiniteScrollViewTitle:(INFScrollViewTile *)tile atPositionHash:(NSInteger)positionHash;
- (void)infiniteScrollView:(INFScrollView *)infiniteScrollView isDoneUsingTile:(INFScrollViewTile *)tile atPositionHash:(NSInteger)positionHash;

@optional
- (void)didTapInfiniteScrollViewTile:(INFScrollViewTile *)tile;

@end

@interface INFScrollView : UIScrollView
{
    __weak id<INFScrollViewDelegate>_infiniteScrollViewDelegate;
}

- (void)reloadData:(BOOL)layoutTiles;
- (void)addTile:(INFScrollViewTile *)tile;

@property (nonatomic, readwrite, assign) unsigned short scrollDirection;
@property (nonatomic, readwrite, weak) IBOutlet id<INFScrollViewDelegate>infiniteScrollViewDelegate;
@property (nonatomic, readonly, strong) IBOutlet INFLayout *layout;

@end
