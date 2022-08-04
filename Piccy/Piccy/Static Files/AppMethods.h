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
#import "ReportedUser.h"
#import "ReportedPiccy.h"
#import "CommentsViewController.h"
#import "APIManager.h"
#import "DailyPiccyViewController.h"
#import "ProfilePictureViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppMethods : NSObject
//Sets up activity indicators throughout the app to inform user information is loading
+(UIActivityIndicatorView *) setupActivityIndicator:(UIActivityIndicatorView *) activityIndicator onView:(UIView *) view;

//Swaps the state of two buttons (background color, tint color, alpha, and userinteractionenabled)
+(void) button:(UIButton *) button1 swapStateWithButton: (UIButton *) button2;

//Presents an alert with a title and message on specified VC
+(void) alertWithTitle:(NSString *)title message:(NSString *)message onViewController:(UIViewController *) viewController;

//Pauses the screen with an activity indicator
+(void) pauseWithActivityIndicator:(UIActivityIndicatorView *)activityIndicator onView:(UIView *) view;

//Unpauses the screen with an activity indicator
+(void) unpauseWithActivityIndicator:(UIActivityIndicatorView *)activityIndicator onView:(UIView *) view;

//Adds the done button to a given text field with a barbutton item
+(void) addDoneToUITextField:(UITextField *) textField withBarButtonItem:(UIBarButtonItem *) barButtonItem;

//Converts a given date to a hour/minutes/seconds string
+(NSString *) dateToHMSString:(NSDate *) date;

//Converts a given date to a day/month/yr string
+(NSString *) dateToDMYString:(NSDate *) date;

//Given a UIImage view and a URL as a string, make a round view with the image in it
+(UIImageView *) roundImageView:(UIImageView *) imageView withURL:(NSString *) url;;

//Given a UIImage view and a URL as a string, make a view with rounded corners and the image in it
+(UIImageView *) roundedCornerImageView:(UIImageView *) imageView withURL:(NSString *) url;

//Detes a given piccy from the backend
+(void) deletePiccy:(Piccy *) piccy;

//Calls cloud function in Parse that changes the other user for me using a master key. this was becasue parse cannot save other users without them being logged in
+(void) postOtherUser:(PFUser *) otherUser;

//Posts the current user of the app
+(void) postUser: (PFUser *) user;

//Deny Friend Request
+(void) denyFriendRequestFromUser:(PFUser *) otherUser;

//Remove friend
+(void) removeFriendUser:(PFUser *) otherUser;

//Add friend
+(void) addFriendUser:(PFUser *) otherUser;

//Cancel Friend Request
+(void) cancelFriendRequestOnUser:(PFUser *) otherUser;

//Send friend request
+(void) sendFriendRequestOnUser:(PFUser *) otherUser;

//Blocks a user then prevents an alert on the view controller specified
+(void) blockUser:(PFUser *) otherUser onViewController:(UIViewController *) viewController;

//Unblocks a user
+(void) unblockUser:(PFUser *) otherUser;

//Reports a user, presents an alert and allows you to block the user
+(void) reportUser:(PFUser *) otherUser onViewController:(UIViewController *) viewController;

//Reports a piccy, presents an alert and allows you to block the poster as well
+(void) reportPiccy:(Piccy *) piccy onViewController:(UIViewController *) viewController;

@end

NS_ASSUME_NONNULL_END
