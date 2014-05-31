//
//  INFLayout.h
//  InfiniteScroll
//
//  Created by Vova Galchenko on 5/30/14.
//  Copyright (c) 2014 Vova Galchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class INFScrollViewTile;
@protocol INFScrollViewTileProvider <NSObject>

@required
- (INFScrollViewTile *)tileWithFrame:(CGRect)frame;

@end

@class INFScrollView;
@protocol INFLayout <NSObject>

@required
// Use this method to return a container view with tiles arranged in the way that will be extended
// in all directions as the user pans around the infinite scrollview. The size of the container you
// return here will be used as the size of the pattern that INFScrollView will repeat. Check out
// INFUniformSizeLayout and INFRandomLayout for example implementations this protocol.
- (UIView *)tileContainerUsingTileProvider:(id<INFScrollViewTileProvider>)tileProvider
                     forInfiniteScrollView:(INFScrollView *)scrollView;

@end
