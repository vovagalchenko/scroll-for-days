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
@class INFLayout;

@protocol INFScrollViewDelegate <NSObject>

@required
// Implement this to provide INFScrollViewTiles to the INFScrollView. You need not worry about
// setting the frame for tiles. Just provide an instance of INFScrollViewTile and you're all set.
- (INFScrollViewTile *)infiniteScrollViewTileForInfiniteScrollView:(INFScrollView *)infiniteScrollView;

// INFScrollView calls this method when it's about to use an INFScrollViewTile. You can use this
// opportunity to set up how you want the tile and its subviews to look.
- (void)infiniteScrollView:(INFScrollView *)infiniteScrollView willUseInfiniteScrollViewTitle:(INFScrollViewTile *)tile atPositionHash:(NSInteger)positionHash;

// INFScrollView calls this method when it's done using an INFScrollViewTile. If you have resources
// associated with this tile feel free to release them here.
- (void)infiniteScrollView:(INFScrollView *)infiniteScrollView isDoneUsingTile:(INFScrollViewTile *)tile atPositionHash:(NSInteger)positionHash;

// Use this to provide the layout for your INFScrollView. The returned layout object will be used
// to create a container view containing the initial tile layout. The same tile arrangement will
// be extended in all directions as the user pans around.
- (id<INFLayout>)layoutForInfiniteScrollView:(INFScrollView *)infiniteScrollView;

@optional
- (void)didTapInfiniteScrollViewTile:(INFScrollViewTile *)tile;

@end

@interface INFScrollView : UIScrollView <INFScrollViewTileProvider>
{
    __weak id<INFScrollViewDelegate>_infiniteScrollViewDelegate;
}

- (void)reloadData:(BOOL)layoutTiles;
- (void)addTile:(INFScrollViewTile *)tile;

@property (nonatomic, readwrite, assign) unsigned short scrollDirection;
@property (nonatomic, readwrite, weak) IBOutlet id<INFScrollViewDelegate>infiniteScrollViewDelegate;

@end
