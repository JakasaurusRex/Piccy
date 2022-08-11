//
//  HomeNavigationController.m
//  Piccy
//
//  Created by Jake Torres on 7/18/22.
//

#import "NavigationController.h"
#import <Parse/Parse.h>

@interface NavigationController ()

@end

@implementation NavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /*[self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[[UIImage alloc] init]];*/
    //Notification for loading home
    [self loadNav];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNav) name:@"loadNav" object:nil];
}

-(void) loadNav {
    PFUser *currentUser = [PFUser currentUser];
    if([currentUser[@"darkMode"] isEqual:@(YES)]) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    } else {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskPortrait;
    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
