//
//  FlickrMainViewController.m
//  Infinite Scroll
//
//  Created by Vova Galchenko on 5/10/13.
//  Copyright (c) 2013 Vova Galchenko. All rights reserved.
//

#import "FlickrMainViewController.h"
#import "FlickrAppDelegate.h"
#import "FlickrPhoto.h"
#import <InfiniteScroll/INFScrollView.h>
#import <InfiniteScroll/INFNetworkImageScrollViewTile.h>

#define SEARCH_BAR_ANIMATION_DURATION       .2
#define INITIAL_FLICKR_SEARCH_TERM          @"nature"
#define TILE_SELECTION_ANIMATION_DURATION   .5
#define SELECTED_TILE_PADDING               5

@interface FlickrMainViewController ()

@property (nonatomic, readwrite, strong) INFScrollViewTile *selectedTile;
@property (nonatomic, readwrite, assign) CGRect selectedTileOriginalFrame;
@property (nonatomic, readwrite, strong) NSArray *images;

@end

@implementation FlickrMainViewController

#pragma mark - UIViewController Lifecycle Management

- (id)init
{
    return [super initWithNibName:@"FlickrMainViewController" bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *buttonBG = [[UIImage imageNamed:@"whiteButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(13, 7, 9, 7)];
    [self.searchButton setBackgroundImage:buttonBG forState:UIControlStateNormal];
    [self performSearchWithString:INITIAL_FLICKR_SEARCH_TERM];
    [self.infiniteScrollView setScrollEnabled:self.images.count];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && !self.view.window)
    {
        self.view = nil;
    }
}

#pragma mark - INFScrollViewDelegate

- (void)infiniteScrollView:(INFScrollView *)infiniteScrollView willUseInfiniteScrollViewTitle:(INFScrollViewTile *)tile atPositionHash:(NSInteger)positionHash
{
    if (self.images.count == 0)
        return;
    NSUInteger photoIndex = abs((int)positionHash)%self.images.count;
    [(INFNetworkImageScrollViewTile *)tile fillTileWithNetworkImage:[self.images objectAtIndex:photoIndex]];
}

- (INFScrollViewTile *)infiniteScrollViewTileForInfiniteScrollView:(INFScrollView *)infiniteScrollView
{
    return [[INFNetworkImageScrollViewTile alloc] init];
}

- (void)infiniteScrollView:(INFScrollView *)infiniteScrollView isDoneUsingTile:(INFScrollViewTile *)tile atPositionHash:(NSInteger)positionHash
{
    [(INFNetworkImageScrollViewTile *)tile fillTileWithNetworkImage:nil];
}

- (void)didTapInfiniteScrollViewTile:(INFScrollViewTile *)tile
{
    [self dismissSearchBar];
    self.searchButton.userInteractionEnabled = NO;
    tile.frame = [self.view convertRect:tile.frame fromView:tile.superview];
    [self.view insertSubview:tile belowSubview:self.searchButton];
    self.selectedTileOriginalFrame = tile.frame;
    self.selectedTile = tile;
    tile.selected = YES;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didCancelTileSelection:)]];
    self.infiniteScrollView.userInteractionEnabled = NO;
    
    [UIView transitionWithView:tile
                      duration:TILE_SELECTION_ANIMATION_DURATION
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^
     {
         CGSize sizeToScale = CGSizeEqualToSize([tile requestingSize], CGSizeZero)? tile.bounds.size : [tile requestingSize];
         CGSize scaledViewSize = sizeToFitInsideSize(sizeToScale, CGRectInset(tile.superview.bounds, SELECTED_TILE_PADDING, SELECTED_TILE_PADDING).size);
         tile.bounds = CGRectMake(0, 0, scaledViewSize.width, scaledViewSize.height);
         tile.center = [tile.superview convertPoint:self.view.center fromView:self.view.superview];
         self.infiniteScrollView.alpha = .25;
     }
                    completion:nil];
}

#pragma mark - Misc. Helpers

static inline CGSize sizeToFitInsideSize(CGSize sizeToScale, CGSize sizeToFitTo)
{
    CGFloat oldTileHeight= sizeToScale.height;
    CGFloat oldTileWidth = sizeToScale.width;
    CGFloat widthDiff = sizeToScale.width/sizeToFitTo.width;
    CGFloat heightDiff = sizeToScale.height/sizeToFitTo.height;
    BOOL scalingByHeight = heightDiff > widthDiff;
    CGFloat newFittedDimension = (scalingByHeight?  sizeToFitTo.height : sizeToFitTo.width);
    CGFloat newScaledDimension = scalingByHeight?   oldTileWidth * (newFittedDimension/oldTileHeight) :
    oldTileHeight * (newFittedDimension/oldTileWidth);
    return CGSizeMake(scalingByHeight? newScaledDimension : newFittedDimension, scalingByHeight? newFittedDimension : newScaledDimension);
}

- (void)dismissSelectedTile
{
    [UIView transitionWithView:self.selectedTile
                      duration:TILE_SELECTION_ANIMATION_DURATION
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^
     {
         self.selectedTile.frame = self.selectedTileOriginalFrame;
         self.infiniteScrollView.alpha = 1.0;
     }
                    completion:^(BOOL finished)
     {
         [[self infiniteScrollView] addTile:self.selectedTile];
         
         self.infiniteScrollView.userInteractionEnabled = YES;
         self.selectedTile.selected = NO;
         self.selectedTile = nil;
         self.selectedTileOriginalFrame = CGRectNull;
         self.searchButton.userInteractionEnabled = YES;
     }];
}

- (void)didCancelTileSelection:(UITapGestureRecognizer *)tapRecognizer
{
    [self.view removeGestureRecognizer:tapRecognizer];
    [self dismissSelectedTile];
}

#pragma mark - Data Reload

- (void)reloadInfiniteScrollViewWithData:(NSArray *)images
{
    self.images = images;
    [self.infiniteScrollView setScrollEnabled:images.count];
    [self.infiniteScrollView reloadData:NO];
}

#pragma mark - Search

- (IBAction)searchButtonPressed:(id)sender
{
 //   [self dismissSelectedTile];
    [self.searchBar becomeFirstResponder];
    [UIView animateWithDuration:SEARCH_BAR_ANIMATION_DURATION
                     animations:^
     {
         self.searchBar.frame = CGRectMake(0, 0, self.searchBar.bounds.size.width, self.searchBar.bounds.size.height);
     }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self dismissSearchBar];
    [self performSearchWithString:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    searchBar.text = @"";
    [self dismissSearchBar];
}

- (void)dismissSearchBar
{
    [UIView animateWithDuration:SEARCH_BAR_ANIMATION_DURATION
                     animations:^
     {
         self.searchBar.frame = CGRectMake(0, -self.searchBar.bounds.size.height, self.searchBar.bounds.size.width, self.searchBar.bounds.size.height);
     }];
    [self.searchBar resignFirstResponder];
}

- (void)performSearchWithString:(NSString *)query
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *filePath in [fileManager contentsOfDirectoryAtPath:[FlickrPhoto hddImageCacheDirectory] error:nil])
    {
        [fileManager removeItemAtPath:[[FlickrPhoto hddImageCacheDirectory] stringByAppendingPathComponent:filePath] error:nil];
    }
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&format=json&tags=%@&per_page=1000", kFlickrAPIKey, [query stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]]];
    [AppDelegate startActivityIndicatorWithStatus:@"Searching Flickr"];
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (error)
         {
             
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                [AppDelegate stopActivityIndicator];
                                [[[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"Unable to get search results from Flickr" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                            });
         }
         else
         {
             __autoreleasing NSError *error = nil;
             // Flickr API wraps their JSON responses in 'jsonFlickrApi()' call.
             // I think that's like JSONP or something.
             NSUInteger prefixStringLength = @"jsonFlickrApi(".length;
             NSUInteger postfixStringLength = 1;
             NSData *jsonData = [data subdataWithRange:NSMakeRange(prefixStringLength, data.length - prefixStringLength - postfixStringLength)];
             NSDictionary *flickrResponseDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                options:0
                                                                                  error:&error];
             if (error)
             {
                 NSLog(@"Error parsing JSON: %@", error);
                 NSLog(@"%@", [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding]);
                 return;
             }
             NSArray *photoDicts = [[flickrResponseDict objectForKey:@"photos"] objectForKey:@"photo"];
             NSMutableArray *photos = [NSMutableArray array];
             for (NSDictionary *photoDict in photoDicts)
             {
                 [photos addObject:[[FlickrPhoto alloc] initWithFlickrID:[photoDict objectForKey:@"id"]
                                                                  secret:[photoDict objectForKey:@"secret"]
                                                                    farm:[photoDict objectForKey:@"farm"]
                                                                  server:[photoDict objectForKey:@"server"]]];
             }
             
             dispatch_async(dispatch_get_main_queue(), ^
             {
                 [self reloadInfiniteScrollViewWithData:photos];
                 [AppDelegate stopActivityIndicator];
             });
         }
     }];
}

#pragma mark - Interface Orientation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self dismissSearchBar];
    [self dismissSelectedTile];
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

@end
