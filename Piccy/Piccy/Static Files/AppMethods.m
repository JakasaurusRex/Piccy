//
//  AppMethods.m
//  Piccy
//
//  Created by Jake Torres on 8/1/22.
//

#import "AppMethods.h"

@implementation AppMethods

//Sets up activity indicators throughout the app to inform user information is loading
+(UIActivityIndicatorView *) setupActivityIndicator:(UIActivityIndicatorView *) activityIndicator onView:(UIView *) view {
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    activityIndicator.center = view.center;
    activityIndicator.hidesWhenStopped = true;
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleMedium];
    [view addSubview:activityIndicator];
    
    return activityIndicator;
}

@end
