//
//  AppMethods.h
//  Piccy
//
//  Created by Jake Torres on 8/1/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Piccy.h"
#import "MagicalEnums.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppMethods : NSObject
//Sets up activity indicators throughout the app to inform user information is loading
+(UIActivityIndicatorView *) setupActivityIndicator:(UIActivityIndicatorView *) activityIndicator onView:(UIView *) view;

//Swaps the state of two buttons (background color, tint color, alpha, and userinteractionenabled)
+(void) button:(UIButton *) button1 swapStateWithButton: (UIButton *) button2;

//Presents an alert with a title and message on specified VC
+(void) alertWithTitle:(NSString *)title message:(NSString *)message onViewController:(UIViewController *) viewController;

//Adds the done button to a given text field with a barbutton item
+(void) addDoneToUITextField:(UITextField *) textField withBarButtonItem:(UIBarButtonItem *) barButtonItem;

//Converts a given date to a hour/minutes/seconds string
+(NSString *) dateToHMSString:(NSDate *) date;

//Given a UIImage view and a URL as a string, make a round view with the image in it
+(UIImageView *) roundImageView:(UIImageView *) imageView withURL:(NSString *) url;;

//Given a UIImage view and a URL as a string, make a view with rounded corners and the image in it
+(UIImageView *) roundedCornerImageView:(UIImageView *) imageView withURL:(NSString *) url;

//Detes a given piccy from the backend
+(void) deletePiccy:(Piccy *) piccy;

//Calls cloud function in Parse that changes the other user for me using a master key. this was becasue parse cannot save other users without them being logged in
+(void) postOtherUser:(PFUser *) otherUser;
@end

NS_ASSUME_NONNULL_END
