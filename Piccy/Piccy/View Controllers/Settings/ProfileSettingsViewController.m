//
//  ProfileSettingsViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/7/22.
//

#import "ProfileSettingsViewController.h"
#import "ProfileSetingsTableViewController.h"
#import <Parse/Parse.h>
#import "AppMethods.h"


@interface ProfileSettingsViewController () 
@property (nonatomic, strong) ProfileSetingsTableViewController *tableViewController;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) int direction;
@end

@implementation ProfileSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([PFUser.currentUser[@"darkMode"] boolValue] == YES) {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
    } else {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
        self.view.backgroundColor = [UIColor whiteColor];
    }
}

- (IBAction)backButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadSettings" object:nil];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)saveButtonPressed:(id)sender {
    if([self isSame]) {
        NSLog(@"Nothing to save");
    } else {
        NSLog(@"Changes saved");
        [self saveProfile];
    }
}

-(BOOL) isSame {
    PFUser *user = [PFUser currentUser];
    if(![self.tableViewController.nameField.text isEqualToString:user[@"name"]]) {
        NSLog(@"Name changed");
        return false;
    } else if(![self.tableViewController.usernameField.text isEqualToString:user[@"username"]]) {
        NSLog(@"Username changed");
        return false;
    } else if(![self.tableViewController.phoneNumberField.text isEqualToString:user[@"phoneNumber"]]) {
        NSLog(@"Phone number changed");
        return false;
    } else if(![self.tableViewController.passwordField.text isEqualToString:@""]) {
        NSLog(@"Password changed");
        return false;
    } else if(![self.tableViewController.emailField.text isEqualToString:user[@"email"]]) {
        NSLog(@"Email changed");
        return false;
    }  else if(![self.tableViewController.bioField.text isEqualToString:user[@"bio"]]) {
        NSLog(@"Bio changed");
        return false;
    } else {
        NSDate *DOB = user[@"dateOfBirth"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
        NSString *date = [formatter stringFromDate:DOB];
        if(![date isEqualToString:self.tableViewController.dateOfBirthField.text]) {
            NSLog(@"DOB changed");
            return false;
        }
    }
    return true;
}

-(void) saveProfile {
    [AppMethods pauseWithActivityIndicator:self.activityIndicator onView:self.view];
    PFUser *user = [PFUser currentUser];
    if(![self.tableViewController.usernameField.text isEqualToString:user.username]) {
        user.username = self.tableViewController.usernameField.text;
        NSLog(@"username attemped updated");
        user[@"updatedPassword"] = @(YES);
    } else {
        user[@"updatedPassword"] = @(NO);
    }
    user.email = self.tableViewController.emailField.text;
    user[@"name"] = self.tableViewController.nameField.text;
    user[@"phoneNumber"] = self.tableViewController.phoneNumberField.text;
    user[@"dateOfBirth"] = self.tableViewController.datePicker.date;
    user[@"bio"] = self.tableViewController.bioField.text;
    if(![self.tableViewController.passwordField.text isEqualToString:@""]) {
        user[@"password"] = self.tableViewController.passwordField.text;
        NSLog(@"Password updated");
        user[@"updatedPassword"] = @(YES);
    } else {
        user[@"updatedPassword"] = @(NO);
    }
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil) {
            NSLog(@"New user info saved");
            [AppMethods alertWithTitle:@"Saved profile" message:@"Saving successful!" onViewController:self];
            [AppMethods unpauseWithActivityIndicator:self.activityIndicator onView:self.view];
        } else {
            NSLog(@"Error saving user information");
            [AppMethods alertWithTitle:@"Couldn't save profile" message:@"Saving unsuccessful, please try again." onViewController:self];
            [AppMethods unpauseWithActivityIndicator:self.activityIndicator onView:self.view];
        }
    }];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"embedSegue"]) {
        ProfileSetingsTableViewController *tableViewController = [segue destinationViewController];
        self.tableViewController = tableViewController;
        tableViewController.saveButton = self.saveButton;
    } 
}

@end
