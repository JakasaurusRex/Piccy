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

+(void) pauseWithActivityIndicator:(UIActivityIndicatorView *)activityIndicator onView:(UIView *)view {
    activityIndicator.center = view.center;
    activityIndicator.hidesWhenStopped = true;
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleMedium];
    [view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    [view setUserInteractionEnabled:NO];
}

+ (void)unpauseWithActivityIndicator:(UIActivityIndicatorView *)activityIndicator onView:(UIView *)view {
    [activityIndicator stopAnimating];
    [view setUserInteractionEnabled:YES];
}

//Adds the done button to the comment field
+(void) addDoneToUITextField:(UITextField *) textField withBarButtonItem:(UIBarButtonItem *) barButtonItem {
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar sizeToFit];
    
    NSArray *array = [[NSArray alloc] initWithObjects:barButtonItem, nil];
    [toolbar setItems:array animated:true];
    [textField setInputAccessoryView:toolbar];
}

//Converts a given date to a hour/minutes/seconds string
+(NSString *) dateToHMSString:(NSDate *) date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm:ss a"];
    NSString *finalString = [dateFormatter stringFromDate:date];
    return finalString;
}

//Converts a given date to a day/month/yr string
+(NSString *) dateToDMYString:(NSDate *) date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    NSString *finalString = [formatter stringFromDate:date];
    
    return finalString;
}

//Given a UIImage view and a URL as a string, make a round view with the image in it
+ (UIImageView *)roundImageView:(UIImageView *)imageView withURL:(NSString *)url {
    imageView.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:url]];
    imageView.layer.masksToBounds = false;
    imageView.layer.cornerRadius = imageView.bounds.size.width/UIIntValuesCircularIconDivisor;
    imageView.clipsToBounds = true;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    if([[PFUser currentUser][@"darkMode"] isEqual:@(YES)]) {
        imageView.layer.borderWidth = 0.05;
    } else {
        imageView.layer.borderWidth = 0;
    }
    return imageView;
}

//Given a UIImage view and a URL as a string, make a view with rounded corners and the image in it
+(UIImageView *) roundedCornerImageView:(UIImageView *) imageView withURL:(NSString *) url {
    imageView.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:url]];
    imageView.layer.masksToBounds = false;
    imageView.layer.cornerRadius = imageView.bounds.size.width/UIIntValuesRoundedCornerDivisor;
    imageView.clipsToBounds = true;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    if([[PFUser currentUser][@"darkMode"] isEqual:@(YES)]) {
        imageView.layer.borderWidth = 0.05;
    } else {
        imageView.layer.borderWidth = 0;
    }
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
    [paramsMut setObject:otherUser[@"friendRequestsArrayIncoming"] forKey:@"friendRequestsArrayIncoming"];
    [paramsMut setObject:otherUser[@"friendRequestsArrayOutgoing"] forKey:@"friendRequestsArrayOutgoing"];
    [paramsMut setObject:otherUser[@"blockedUsers"] forKey:@"blockedUsers"];
    [paramsMut setObject:otherUser[@"blockedByArray"] forKey:@"blockedByArray"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsMut];
    //calling the function in the parse cloud code
    [PFCloud callFunctionInBackground:@"saveOtherUser" withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
        if(!error) {
            NSLog(@"Saving other user worked");
        } else {
            NSLog(@"Error saving other user with mode");
        }
    }];
}

//Changes the current user of the app
+(void) postUser: (PFUser *) user {
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil) {
            NSLog(@"Friend status changed");
        } else {
            NSLog(@"Error changing friend status");
        }
    }];
}

//Deny Friend Request
+(void) denyFriendRequestFromUser:(PFUser *) otherUser {
    PFUser *appUser = [PFUser currentUser];
    NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithArray:appUser[@"friendRequestsArrayIncoming"]];
    [mutableArr removeObject:otherUser.username];
    appUser[@"friendRequestsArrayIncoming"] = [NSArray arrayWithArray:mutableArr];
    
    mutableArr = [NSMutableArray arrayWithArray:otherUser[@"friendRequestsArrayOutgoing"]];
    [mutableArr removeObject:appUser.username];
    otherUser[@"friendRequestsArrayOutgoing"] = [NSArray arrayWithArray:mutableArr];
    
    [AppMethods postOtherUser:otherUser];
    [AppMethods postUser:appUser];
}

//Remove friend
+(void) removeFriendUser:(PFUser *) otherUser {
    PFUser *appUser = [PFUser currentUser];
    NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithArray:appUser[@"friendsArray"]];
    [mutableArr removeObject:otherUser.username];
    appUser[@"friendsArray"] = [NSArray arrayWithArray:mutableArr];
    
    mutableArr = [NSMutableArray arrayWithArray:otherUser[@"friendsArray"]];
    [mutableArr removeObject:appUser.username];
    otherUser[@"friendsArray"] = [NSArray arrayWithArray:mutableArr];
    
    [AppMethods postOtherUser:otherUser];
    [AppMethods postUser:appUser];
}

//Add friend
+(void) addFriendUser:(PFUser *) otherUser {
    //Accepting a friend request
    //in the requests tab you can accept friend requests.
    PFUser *appUser = [PFUser currentUser];
    NSMutableArray *requests = [[NSMutableArray alloc] initWithArray:appUser[@"friendRequestsArrayIncoming"]];
    NSMutableArray *friends = [[NSMutableArray alloc] initWithArray:appUser[@"friendsArray"]];
    
    [requests removeObject:otherUser.username];
    [friends addObject:otherUser.username];
    
    appUser[@"friendRequestsArrayIncoming"] = [NSArray arrayWithArray:requests];
    appUser[@"friendsArray"] = [NSArray arrayWithArray:friends];
    
    requests = [[NSMutableArray alloc] initWithArray:otherUser[@"friendRequestsArrayOutgoing"]];
    friends = [[NSMutableArray alloc] initWithArray:otherUser[@"friendsArray"]];
    
    [requests removeObject:appUser.username];
    [friends addObject:appUser.username];
    
    otherUser[@"friendRequestsArrayOutgoing"] = requests;
    otherUser[@"friendsArray"] = friends;
    
    [AppMethods postUser:appUser];
    [AppMethods postOtherUser:otherUser];
}

//Cancel Friend Request
+(void) cancelFriendRequestOnUser:(PFUser *) otherUser {
    //Canceling a friend request
    PFUser *appUser = [PFUser currentUser];
    NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithArray:appUser[@"friendRequestsArrayOutgoing"]];
    [mutableArr removeObject:otherUser.username];
    appUser[@"friendRequestsArrayOutgoing"] = [NSArray arrayWithArray:mutableArr];
    
    mutableArr = [NSMutableArray arrayWithArray:otherUser[@"friendRequestsArrayIncoming"]];
    [mutableArr removeObject:appUser.username];
    otherUser[@"friendRequestsArrayIncoming"] = [NSArray arrayWithArray:mutableArr];
    
    [AppMethods postOtherUser:otherUser];
    [AppMethods postUser:appUser];
}

//Send friend request
+(void) sendFriendRequestOnUser:(PFUser *) otherUser {
    //Sending a friend request
    PFUser *appUser = [PFUser currentUser];
    NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithArray:appUser[@"friendRequestsArrayOutgoing"]];
    [mutableArr addObject:otherUser.username];
    appUser[@"friendRequestsArrayOutgoing"] = [NSArray arrayWithArray:mutableArr];
    
    mutableArr = [NSMutableArray arrayWithArray:otherUser[@"friendRequestsArrayIncoming"]];
    [mutableArr addObject:appUser.username];
    otherUser[@"friendRequestsArrayIncoming"] = [NSArray arrayWithArray:mutableArr];
    NSLog(@"FRIEND REQUESTED: %@", otherUser[@"friendRequestsArrayIncoming"]);
    
    [AppMethods postUser:appUser];
    [AppMethods postOtherUser:otherUser];
}

//Blocks a user then prevents an alert on the view controller specified
+(void) blockUser:(PFUser *) otherUser onViewController:(UIViewController *) viewController {
    PFUser *currentUser = [PFUser currentUser];
    // Ask the user if they would also like to block the user of this profile
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Block user"
                                                                               message:@"Would you like to block this user? Users can be unblocked later in settings"
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                       style:UIAlertActionStyleDestructive
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                             // handle response here.
        //Creates a mutable array with teh arrays from the database, adds or removes the username from block list or friends list and saves it
        NSMutableArray *blockArray = [[NSMutableArray alloc] initWithArray:currentUser[@"blockedUsers"]];
        [blockArray addObject:otherUser.username];
        NSMutableArray *friendsArray = [[NSMutableArray alloc] initWithArray:currentUser[@"friendsArray"]];
        [friendsArray removeObject:otherUser.username];
        currentUser[@"blockedUsers"] = [[NSArray alloc] initWithArray: blockArray];
        currentUser[@"friendsArray"] = [[NSArray alloc] initWithArray:friendsArray];
        
        NSMutableArray *otherFriend = [[NSMutableArray alloc] initWithArray:otherUser[@"friendsArray"]];
        [otherFriend removeObject:currentUser.username];
        otherUser[@"friendsArray"] = [[NSArray alloc] initWithArray:otherFriend];
        
        otherFriend = [[NSMutableArray alloc] initWithArray:otherUser[@"blockedByArray"]];
        [otherFriend addObject:currentUser.username];
        otherUser[@"blockedByArray"] = [[NSArray alloc] initWithArray:otherFriend];
        
        [AppMethods postOtherUser:otherUser];
        [AppMethods postUser:currentUser];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadFriends" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadHome" object:nil];
        if([viewController isKindOfClass:[CommentsViewController class]]) {
            [viewController dismissViewControllerAnimated:true completion:nil];
        }
        
                                                     }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                             // handle response here.
                                                     }];
    [alert addAction:yesAction];
    [alert addAction:noAction];
    [viewController presentViewController:alert animated:YES completion:nil];
}

+ (void)unblockUser:(PFUser *)otherUser {
    PFUser *currentUser = [PFUser currentUser];
    NSMutableArray *blockedUsers = [[NSMutableArray alloc] initWithArray:currentUser[@"blockedUsers"]];
    [blockedUsers removeObject:otherUser.username];
    currentUser[@"blockedUsers"] = [[NSArray alloc] initWithArray:blockedUsers];
    [AppMethods postUser:currentUser];
    
    blockedUsers = [[NSMutableArray alloc] initWithArray:otherUser[@"blockedByArray"]];
    [blockedUsers removeObject:currentUser.username];
    otherUser[@"blockedByArray"] = [[NSArray alloc] initWithArray:blockedUsers];
    [AppMethods postOtherUser:otherUser];
}

+(void) reportUser:(PFUser *)otherUser onViewController:(UIViewController *)viewController {
    PFUser *currentUser = [PFUser currentUser];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report user"
                                                                               message:@"Please enter the reason for reporting this user:"
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Reason for report";
    }];
    
    //Cancel button
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                             // handle response here.
                                                     }];
    [alert addAction:cancelAction];
    
    //Adds the action for when a user clicks on report
    [alert addAction:[UIAlertAction actionWithTitle:@"Report" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSArray *textFields = alert.textFields;
        UITextField *text = textFields[0];
        
        //Checks if text field was empty and prompts the user to try again
        if([text.text isEqualToString:@""]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No report reason"
                                                                                       message:@"Please try again and enter a reason for report"
                                                                                preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                     // handle response here.
                                                             }];
            [alert addAction:okAction];
            [viewController presentViewController:alert animated:YES completion:nil];
            return;
        }
        if(![currentUser[@"reportedUsers"] containsObject:otherUser.username]) {
            //Create a piccy report object if none exist by this user already
            [ReportedUser reportUser:otherUser withReason:text.text withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if(error == nil) {
                    NSLog(@"User reported");
                    NSMutableArray *reportArray = [[NSMutableArray alloc] initWithArray:currentUser[@"reportedUsers"]];
                    [reportArray addObject:otherUser.username];
                    currentUser[@"reportedUsers"] = [[NSArray alloc] initWithArray:reportArray];
                     [AppMethods postUser:currentUser];
                } else {
                    NSLog(@"Could not report user: %@", error);
                }
            }];
        } else {
            //If a report already exists for this piccy by this user, alert them
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"User already reported"
                                                                                       message:@"This user was already reported by you."
                                                                                preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                     // handle response here.
                                                             }];
            [alert addAction:okAction];
            [viewController presentViewController:alert animated:YES completion:nil];
        }
        
        [AppMethods blockUser:otherUser onViewController:viewController];
        
    }]];
    
    [viewController presentViewController:alert animated:YES completion:nil];
}

+ (void)reportPiccy:(Piccy *)piccy onViewController:(UIViewController *)viewController {
    //Creates the alert controller with a text field for the reason for report
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report Piccy"
                                                                               message:@"Please enter the reason for reporting this Piccy:"
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Reason for report";
    }];
    
    //Cancel button
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                             // handle response here.
                                                     }];
    [alert addAction:cancelAction];
    
    //Adds the action for when a user clicks on report
    [alert addAction:[UIAlertAction actionWithTitle:@"Report" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSArray *textFields = alert.textFields;
        UITextField *text = textFields[0];
        
        //Checks if text field was empty and prompts the user to try again
        if([text.text isEqualToString:@""]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No report reason"
                                                                                       message:@"Please try again and enter a reason for report"
                                                                                preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                     // handle response here.
                                                             }];
            [alert addAction:okAction];
            [viewController presentViewController:alert animated:YES completion:nil];
            return;
        }
        PFUser *user = [PFUser currentUser];
        if(![user[@"reportedPiccys"] containsObject:piccy.objectId]) {
            //Create a piccy report object if none exist by this user already
            [ReportedPiccy reportPiccy:piccy withReason:text.text withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if(error == nil) {
                    NSLog(@"Piccy Reported");
                    NSMutableArray *reportArray = [[NSMutableArray alloc] initWithArray:user[@"reportedPiccys"]];
                    [reportArray addObject:piccy.objectId];
                    user[@"reportedPiccys"] = [[NSArray alloc] initWithArray:reportArray];
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if(error == nil)
                            NSLog(@"saved user report array");
                        else
                            NSLog(@"could not save user report array: %@", error);
                    }];
                } else {
                    NSLog(@"Error reporting piccy: %@", error);
                }
            }];
        } else {
            //If a report already exists for this piccy by this user, alert them
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Piccy already reported"
                                                                                       message:@"This piccy was already reported by you."
                                                                                preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                     // handle response here.
                                                             }];
            [alert addAction:okAction];
            [viewController presentViewController:alert animated:YES completion:nil];
        }
        
        // Ask the user if they would also like to block the user of the piccy they are reporting
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Block user"
                                                                                   message:@"Would you like to block the user who posted this Piccy as well? Users can be unblocked later in settings."
                                                                            preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                                 // handle response here.
            //Creates a mutable array with teh arrays from the database, adds or removes the username from block list or friends list and saves it
            NSMutableArray *blockArray = [[NSMutableArray alloc] initWithArray:user[@"blockedUsers"]];
            [blockArray addObject:piccy.user.username];
            NSMutableArray *friendsArray = [[NSMutableArray alloc] initWithArray:user[@"friendsArray"]];
            [friendsArray removeObject:piccy.user.username];
            user[@"blockedUsers"] = [[NSArray alloc] initWithArray: blockArray];
            user[@"friendsArray"] = [[NSArray alloc] initWithArray:friendsArray];
            
            PFUser *piccyUser = piccy.user;
            NSMutableArray *otherFriend = [[NSMutableArray alloc] initWithArray:piccyUser[@"friendsArray"]];
            [otherFriend removeObject:user.username];
            piccyUser[@"friendsArray"] = [[NSArray alloc] initWithArray:otherFriend];
            
            otherFriend = [[NSMutableArray alloc] initWithArray:piccyUser[@"blockedByArray"]];
            [otherFriend addObject:user.username];
            piccyUser[@"blockedByArray"] = [[NSArray alloc] initWithArray:otherFriend];
            
            [AppMethods postOtherUser:piccyUser];
            [AppMethods postUser:user];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loadHome" object:nil];
            if([viewController isKindOfClass:[CommentsViewController class]]) {
                [viewController dismissViewControllerAnimated:true completion:nil];
            }
            
                                                         }];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                                 // handle response here.
                                                         }];
        [alert addAction:yesAction];
        [alert addAction:noAction];
        [viewController presentViewController:alert animated:YES completion:nil];
    }]];
    
    [viewController presentViewController:alert animated:YES completion:nil];
    [AppMethods alertWithTitle:@"Success" message:@"Reported Piccy" onViewController:viewController];
}

//Returns true if the app user is under 18 and false otherwise
+(int) userAge {
    PFUser *currentUser = [PFUser currentUser];
    NSDate *dob = currentUser[@"dateOfBirth"];
    NSDate *currentDate = [NSDate date];

    NSTimeInterval secondsBetween = [currentDate timeIntervalSinceDate:dob];

    int days = secondsBetween / 86400;
    int years = days/364;

    if(years >= 18) {
        return 18;
    }
    if(years >= 13) {
        return 13;
    }
    return 12;
}


+(bool) isReportedPiccy:(Piccy *) piccy {
    PFQuery *query = [PFQuery queryWithClassName:@"ReportedPiccy"];
    [query includeKey:@"piccy"];
    [query whereKey:@"piccy" equalTo:piccy];
    [query setLimit:1];
    NSArray *piccys = [query findObjects];
    if([piccys count] > 0) {
        return true;
    }
    return false;
}

@end
