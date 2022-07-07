//
//  ProfileSettingsViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/7/22.
//

#import "ProfileSettingsViewController.h"
#import "ProfileSetingsTableViewController.h"
#import <Parse/Parse.h>

@interface ProfileSettingsViewController ()
@property (nonatomic, strong) ProfileSetingsTableViewController *tableViewController;
@end

@implementation ProfileSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
    // Do any additional setup after loading the view.
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
    } else if(![self.tableViewController.emailField.text isEqualToString:user[@"bio"]]) {
        NSLog(@"Bio changed");
        return false;
    } else if(![self.tableViewController.bioField.text isEqualToString:user[@"bio"]]) {
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
    PFUser *user = [PFUser currentUser];
    user.username = self.tableViewController.usernameField.text;
    user.email = self.tableViewController.emailField.text;
    user[@"name"] = self.tableViewController.nameField.text;
    user[@"phoneNumber"] = self.tableViewController.phoneNumberField.text;
    user[@"dateOfBirth"] = self.tableViewController.datePicker.date;
    user[@"bio"] = self.tableViewController.bioField.text;
    if(![self.tableViewController.passwordField.text isEqualToString:@""]) {
        user[@"password"] = self.tableViewController.passwordField.text;
    }
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil) {
            NSLog(@"New user info saved");
        } else {
            NSLog(@"Error saving user information");
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
