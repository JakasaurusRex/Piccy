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

//Swaps the state of two buttons (background color, tint color, alpha, and userinteractionenabled)
+(void) button:(UIButton *) button1 swapStateWithButton: (UIButton *) button2 {
    UIColor *button1BGColor = button1.backgroundColor;
    UIColor *button1TintColor = button1.tintColor;
    float button1Alpha = button1.alpha;
    bool button1UserInteraction = button1.userInteractionEnabled;
    
    UIColor *button2BGColor = button2.backgroundColor;
    UIColor *button2TintColor = button2.tintColor;
    float button2Alpha = button2.alpha;
    bool button2UserInteraction = button2.userInteractionEnabled;
    
    button1.alpha = button2Alpha;
    button1.tintColor = button2TintColor;
    button1.backgroundColor = button2BGColor;
    button1.userInteractionEnabled = button2UserInteraction;
    
    button2.alpha = button1Alpha;
    button2.tintColor = button1TintColor;
    button2.backgroundColor = button1BGColor;
    button2.userInteractionEnabled = button1UserInteraction;
}

@end
