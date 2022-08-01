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

//Presents an alert with a title and message on specified VC
+(void) alertWithTitle:(NSString *)title message:(NSString *)message onViewController:(UIViewController *) viewController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                               message:message
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                             // handle response here.
                                                     }];
    // add the OK action to the alert controller
    [alert addAction:okAction];
    [viewController presentViewController:alert animated:YES completion:^{
        // optional code for what happens after the alert controller has finished presenting
    }];
}

//Converts a given date to a hour/minutes/seconds string
+(NSString *) dateToHMSString:(NSDate *) date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm:ss a"];
    NSString *finalString = [dateFormatter stringFromDate:date];
    return finalString;
}

//Adds the done button to the comment field
+(void) addDoneToField:(UITextField *)field withBarButtonItem:(UIBarButtonItem *) barButtonItem {
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar sizeToFit];
    
    NSArray *array = [[NSArray alloc] initWithObjects:barButtonItem, nil];
    [toolbar setItems:array animated:true];
    [field setInputAccessoryView:toolbar];
}

//Given a UIImage view and a URL as a string, make a round view with the image in it
+ (UIImageView *)roundImageView:(UIImageView *)imageView withURL:(NSString *)url {
    imageView.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:url]];
    imageView.layer.masksToBounds = false;
    imageView.layer.cornerRadius = imageView.bounds.size.width/UIIntValuesRoundedCornerDivisor;
    imageView.clipsToBounds = true;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.borderWidth = 0.05;
    
    return imageView;
}

//Detes a given piccy from the backend
+(void) deletePiccy:(Piccy *)piccy {
    PFUser *user = [PFUser currentUser];
    [piccy deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil) {
            NSLog(@"Piccy deleted");
            user[@"postedToday"] = @(NO);
            user[@"deletedToday"] = @(YES);
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(error == nil) {
                    NSLog(@"User posted today after deleting piccy saved");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadHome" object:nil];
                }
            }];
        } else {
            NSLog(@"Could not delete piccy");
        }
        
    }];
}

//Calls cloud function in Parse that changes the other user for me using a master key. this was becasue parse cannot save other users without them being logged in
+(void) postOtherUser:(PFUser *)otherUser {
    //creating a parameters dictionary with all the items in the user that need to be changed and saved
    NSMutableDictionary *paramsMut = [[NSMutableDictionary alloc] init];
    [paramsMut setObject:otherUser.username forKey:@"username"];
    [paramsMut setObject:otherUser[@"friendsArray"] forKey:@"friendsArray"];
    [paramsMut setObject:otherUser[@"blockedByArray"] forKey:@"blockedByArray"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsMut];
    //calling the function in the parse cloud code
    [PFCloud callFunctionInBackground:@"saveOtherUser" withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
        if(!error) {
            NSLog(@"Saving other user worked");
        } else {
            NSLog(@"Error saving other user with error: %@", error);
        }
    }];
}

@end
