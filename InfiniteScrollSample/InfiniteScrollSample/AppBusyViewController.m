//
//  AppBusyViewController.m
//  YouTubeStats
//
//  Created by Vova Galchenko on 6/15/11.

#import "AppBusyViewController.h"

#define ANIMATION_LENGTH        .4


@implementation AppBusyViewController

@synthesize activityLabel = _activityLabel;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize window = _window;

- (id)initWithWindow:(UIWindow *)window
{
    if (self = [super initWithNibName:@"AppBusyViewController" bundle:nil])
    {
        self.window = window;
    }
    return self;
}

- (void)startActivity
{
    [self startActivity:@""];
}

- (void)startActivity:(NSString *)activityName
{
    [self.activityIndicatorView startAnimating];
    
    if (self.view.window &&
        ![activityName isEqualToString:self.activityLabel.text])
    {
        // We were in the middle of another activity.
        // Fade out the label, and fade in the next activity's text.
        [UIView animateWithDuration:ANIMATION_LENGTH
                         animations:^
        {
            self.activityLabel.alpha = 0;
        }
                         completion:^(BOOL finished)
        {
            self.activityLabel.text = activityName;
            [UIView animateWithDuration:ANIMATION_LENGTH
                             animations:^
            {
                self.activityLabel.alpha = 1;
            }];
        }];
    }
    else if (!self.view.window)
    {
        self.view.alpha = 0;
        self.activityLabel.text = activityName;
        [self.window.rootViewController.view addSubview:self.view];
        self.view.frame = CGRectMake(0, 0, self.window.rootViewController.view.bounds.size.width, self.window.rootViewController.view.bounds.size.height);
        [UIView animateWithDuration:ANIMATION_LENGTH
                         animations:^
        {
            self.view.alpha = 1;
        }];
    }
}

- (void)stopActivity
{
    [UIView animateWithDuration:ANIMATION_LENGTH
                     animations:^
    {
        self.view.alpha = 0;
    }
                     completion:^(BOOL finished)
    {
        [self.view removeFromSuperview];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && !self.view.window)
    {
        self.view = nil;
    }
}

@end
