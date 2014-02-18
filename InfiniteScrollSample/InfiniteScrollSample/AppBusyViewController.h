//
//  AppBusyViewController.h
//  YouTubeStats
//
//  Created by Vova Galchenko on 6/15/11.
//

#import <UIKit/UIKit.h>


@interface AppBusyViewController : UIViewController

- (id)initWithWindow:(UIWindow *)window;
- (void)startActivity;
- (void)startActivity:(NSString *)activityName;
- (void)stopActivity;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *activityLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (unsafe_unretained, nonatomic) UIWindow *window;

@end
