//
//  InfiniteScrollView.m
//  Infinite Scroll
//
//  Created by Vova Galchenko on 1/17/13.
//  Copyright (c) 2013 Vova Galchenko. All rights reserved.
//

#import "INFScrollView.h"
#import "INFScrollViewTile.h"
#import "INFLayout.h"
#import <QuartzCore/QuartzCore.h>
     
#define FADE_ANIMATION_DURATION         .4

const unsigned short INFScrollHorizontally = 1;
const unsigned short INFScrollVertically = 1 << 1;

@interface INFScrollView()

@property (nonatomic, readwrite, strong) UIView *tileContainer;
@property (nonatomic, readwrite, strong) NSMutableSet *visibleTiles;

@end

@implementation INFScrollView

#pragma mark - Initializers

- (id)init
{
    if ((self = [super init]))
    {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecode
{
    if ((self = [super initWithCoder:aDecode]))
    {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    super.bounces = NO;
    super.scrollsToTop = NO;
    super.pagingEnabled = NO;
    super.alwaysBounceHorizontal = NO;
    super.alwaysBounceVertical = NO;
    super.bouncesZoom = NO;
    super.showsHorizontalScrollIndicator = NO;
    super.showsVerticalScrollIndicator = NO;
    _visibleTiles = [[NSMutableSet alloc] init];
    self.scrollDirection = INFScrollVertically | INFScrollHorizontally;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTile:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGestureRecognizer];
}

#pragma - View Lifecycle

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    self.contentSize = [self calculateContentSize];
    if (!self.window)
    {
        self.tileContainer = nil;
    }
    else
    {
        [self doInitialTileSetup];
    }
}

#pragma mark - Content Size

- (CGSize)calculateContentSize
{
    CGFloat maxDimension = MAX(self.bounds.size.width, self.bounds.size.height) * 20;
    CGFloat verticalContentDimension = (self.scrollDirection & INFScrollVertically) ? maxDimension : self.bounds.size.height;
    CGFloat horizontalContentDimension = (self.scrollDirection & INFScrollHorizontally) ? maxDimension : self.bounds.size.width;
    return CGSizeMake(horizontalContentDimension, verticalContentDimension);
}

#pragma mark - Tap Handling

- (void)didTapTile:(UITapGestureRecognizer *)tapRecognizer
{
    if ([self.infiniteScrollViewDelegate respondsToSelector:@selector(didTapInfiniteScrollViewTile:)])
    {
        for (INFScrollViewTile *tile in self.visibleTiles)
        {
            if (CGRectContainsPoint(tile.bounds, [tapRecognizer locationInView:tile]))
            {
                if ([tile isSelectable])
                {
                    [self.infiniteScrollViewDelegate didTapInfiniteScrollViewTile:tile];
                }
                return;
            }
        }
        NSAssert(NO, @"Tapped something that wasn't a tile.");
    }
}

#pragma mark - Tile Management

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGPoint currentOffset = self.contentOffset;
    CGFloat contentWidth = self.contentSize.width;
    CGFloat contentHeight = self.contentSize.height;
    
#define MAX_CONTENT_OFFSET_PROPORTION       (.25)
    CGPoint centerOffset = CGPointMake(contentWidth/2, contentHeight/2);
    CGFloat maxXOffset = centerOffset.x + contentWidth*MAX_CONTENT_OFFSET_PROPORTION;
    CGFloat minXOffset = centerOffset.x - contentWidth*MAX_CONTENT_OFFSET_PROPORTION;
    CGFloat newXOffset = currentOffset.x;
    CGFloat maxYOffset = centerOffset.y + contentHeight*MAX_CONTENT_OFFSET_PROPORTION;
    CGFloat minYOffset = centerOffset.y - contentHeight*MAX_CONTENT_OFFSET_PROPORTION;
    CGFloat newYOffset = currentOffset.y;
    
    if (currentOffset.x > maxXOffset ||
        currentOffset.x < minXOffset)
    {
        newXOffset = centerOffset.x;
    }
    if (currentOffset.y > maxYOffset ||
        currentOffset.y < minYOffset)
    {
        newYOffset = centerOffset.y;
    }
    if (newXOffset != currentOffset.x || newYOffset != currentOffset.y)
    {
        // If we've scrolled fairly far vertically or horizontally, let's change the
        // content offset to the other side and move the tileContainer to counteract
        // the content offset change.
        
        CGFloat dxCounteract = newXOffset - currentOffset.x;
        CGFloat dyCounteract = newYOffset - currentOffset.y;
        
        self.contentOffset = CGPointMake(newXOffset, newYOffset);
        self.tileContainer.center = CGPointMake(self.tileContainer.center.x + dxCounteract, self.tileContainer.center.y + dyCounteract);
    }
    
    // Tile content within the visible bounds.
    CGRect visibleBounds = [self convertRect:[self bounds] toView:self.tileContainer];
    
    CGFloat minimumVisibleX = CGRectGetMinX(visibleBounds);
    CGFloat maximumVisibleX = CGRectGetMaxX(visibleBounds);
    CGFloat minimumVisibleY = CGRectGetMinY(visibleBounds);
    CGFloat maximumVisibleY = CGRectGetMaxY(visibleBounds);
    CGFloat tileAreaWidth = self.tileContainer.bounds.size.width;
    CGFloat tileAreaHeight = self.tileContainer.bounds.size.height;
    for (INFScrollViewTile *subview in self.tileContainer.subviews)
    {
        CGRect tileFrame = subview.frame;
        CGFloat subviewsMaxVisibleX = CGRectGetMaxX(tileFrame);
        CGFloat subviewsMinVisibleX = CGRectGetMinX(tileFrame);
        if (minimumVisibleX > subviewsMaxVisibleX && // the subview is to the left of the visible bounds
            subviewsMinVisibleX + tileAreaWidth < maximumVisibleX) // the subview would be in bounds if we moved it
        {
            NSUInteger numWidths = (NSUInteger)(maximumVisibleX - subviewsMinVisibleX)/tileAreaWidth;
            tileFrame = CGRectMake(tileFrame.origin.x + numWidths*tileAreaWidth, tileFrame.origin.y, tileFrame.size.width, tileFrame.size.height);
        }
        else if (subviewsMinVisibleX > maximumVisibleX && // the subview is to the right of the visible bounds
                 subviewsMaxVisibleX - tileAreaWidth > minimumVisibleX) // the subview would be in bounds if we moved it
        {
            NSUInteger numWidths = (NSUInteger)(subviewsMaxVisibleX - minimumVisibleX)/tileAreaWidth;
            tileFrame = CGRectMake(tileFrame.origin.x - numWidths*tileAreaWidth, tileFrame.origin.y, tileFrame.size.width, tileFrame.size.height);
        }
        
        CGFloat subviewsMaxVisibleY = CGRectGetMaxY(tileFrame);
        CGFloat subviewsMinVisibleY = CGRectGetMinY(tileFrame);
        if (minimumVisibleY > subviewsMaxVisibleY && // the subview is on the top of the visible bounds
            subviewsMinVisibleY + tileAreaHeight < maximumVisibleY) // the subview would be in bounds if we moved it
        {
            NSUInteger numHeights = (NSUInteger)(maximumVisibleY - subviewsMinVisibleY)/tileAreaHeight;
            tileFrame = CGRectMake(tileFrame.origin.x, tileFrame.origin.y + numHeights*tileAreaHeight, tileFrame.size.width, tileFrame.size.height);
        }
        else if (subviewsMinVisibleY > maximumVisibleY && // the subview is on the bottom of the visible bounds
                 subviewsMaxVisibleY - tileAreaHeight > minimumVisibleY) // the subview would be in bounds if we moved it
        {
            NSUInteger numHeights = (NSUInteger)(subviewsMaxVisibleY - minimumVisibleY)/tileAreaHeight;
            tileFrame = CGRectMake(tileFrame.origin.x, tileFrame.origin.y - numHeights*tileAreaHeight, tileFrame.size.width, tileFrame.size.height);
        }
        subview.frame = tileFrame;

        BOOL tileWasVisible = [self.visibleTiles containsObject:subview];
        if (CGRectIntersectsRect(visibleBounds, tileFrame))
        {
            if (!tileWasVisible)
            {
                [self.visibleTiles addObject:subview];
                [self.infiniteScrollViewDelegate infiniteScrollView:self
                                     willUseInfiniteScrollViewTitle:subview
                                                     atPositionHash:positionHashForTile(subview)];
            }
        }
        else if (tileWasVisible)
        {
            [self.visibleTiles removeObject:subview];
            [self.infiniteScrollViewDelegate infiniteScrollView:self
                                                isDoneUsingTile:subview
                                                 atPositionHash:positionHashForTile(subview)];
        }
    }
}

- (void)updateVisibleTiles
{
    CGRect visibleBounds = [self convertRect:[self bounds] toView:self.tileContainer];
    for (INFScrollViewTile *tile in self.tileContainer.subviews)
    {
        BOOL tileWasVisible = [self.visibleTiles containsObject:tile];
        if (CGRectIntersectsRect(visibleBounds, tile.frame))
        {
            if (!tileWasVisible)
            {
                [self.visibleTiles addObject:tile];
                [self.infiniteScrollViewDelegate infiniteScrollView:self
                                     willUseInfiniteScrollViewTitle:tile
                                                     atPositionHash:positionHashForTile(tile)];
            }
        }
        else if (tileWasVisible)
        {
            [self.visibleTiles removeObject:tile];
            [self.infiniteScrollViewDelegate infiniteScrollView:self
                                                isDoneUsingTile:tile
                                                 atPositionHash:positionHashForTile(tile)];
        }
    }
}

static inline NSInteger positionHashForTile(INFScrollViewTile *tile)
{
    CGPoint origin = tile.frame.origin;
    // Need to generate a unique hash for an x, y pair.
    // idk... accumulating x and y and multiplying by a prime for good measure seems decent.
    NSInteger hash = origin.x;
    hash *= 29;
    hash += origin.y;
    return hash;
}

- (void)reloadData:(BOOL)relayTiles
{
    if (relayTiles)
    {
        [UIView animateWithDuration:FADE_ANIMATION_DURATION
                         animations:^
        {
            self.tileContainer.alpha = 0;
        }
                         completion:^(BOOL finished)
        {
            for (INFScrollViewTile *tile in self.visibleTiles)
            {
                [self.infiniteScrollViewDelegate infiniteScrollView:self
                                                    isDoneUsingTile:tile
                                                     atPositionHash:positionHashForTile(tile)];
            }
            [self.visibleTiles removeAllObjects];
            for (INFScrollViewTile *tile in self.tileContainer.subviews)
            {
                [tile removeFromSuperview];
            }
            [self doInitialTileSetup];
            [self updateVisibleTiles];
            [UIView animateWithDuration:FADE_ANIMATION_DURATION
                             animations:^
            {
                [self.tileContainer setAlpha:1.0];
            }];
        }];
    }
    else
    {
        for (INFScrollViewTile *tile in self.visibleTiles)
        {
            [self.infiniteScrollViewDelegate infiniteScrollView:self
                                                isDoneUsingTile:tile
                                                 atPositionHash:positionHashForTile(tile)];
        }
        [self.visibleTiles removeAllObjects];
        [self updateVisibleTiles];
    }
}

- (INFScrollViewTile *)tileWithFrame:(CGRect)frame
{
    NSAssert([self.infiniteScrollViewDelegate respondsToSelector:@selector(infiniteScrollViewTileForInfiniteScrollView:)],
             @"Must have infiniteScrollViewDelegate to have an operational infiniteScrollView");
    INFScrollViewTile *tile = [self.infiniteScrollViewDelegate infiniteScrollViewTileForInfiniteScrollView:self];
    tile.frame = frame;
    return tile;
}

- (void)doInitialTileSetup
{
    id<INFLayout> layout = [self.infiniteScrollViewDelegate layoutForInfiniteScrollView:self];
    self.tileContainer = [layout tileContainerUsingTileProvider:self
                                          forInfiniteScrollView:self];
    [self addSubview:self.tileContainer];
    self.contentOffset = CGPointMake((self.tileContainer.bounds.size.width - self.bounds.size.width)/2, (self.tileContainer.bounds.size.height - self.bounds.size.height)/2);
}

- (void)addTile:(INFScrollViewTile *)tile
{
    tile.frame = [self.tileContainer convertRect:tile.frame fromView:tile.superview];
    [self.tileContainer addSubview:tile];
}

@end
