//
//  FlickrMainViewController.h
//  Infinite Scroll
//
//  Created by Vova Galchenko on 5/10/13.
//  Copyright (c) 2013 Vova Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class INFScrollView;

@interface FlickrMainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet INFScrollView *infiniteScrollView;

@end
