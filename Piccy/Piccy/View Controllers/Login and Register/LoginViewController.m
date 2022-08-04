//
//  LoginViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/6/22.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "AppMethods.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:@selector(donePressedTextField)];
    [AppMethods addDoneToUITextField:self.usernameField withBarButtonItem:doneButton];
    [AppMethods addDoneToUITextField:self.passwordField withBarButtonItem:doneButton];
}

-(void) donePressedTextField {
    [self.view endEditing:true];
}

//When the login button is pressed call the helper method
- (IBAction)loginButtonPressed:(id)sender {
    [self loginUser];
}

//Forgot your password feature
- (IBAction)forgotYourPassword:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset password"
                                                                               message:@"Please enter the email you added on your profile:"
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Email";
    }];
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                             // handle response here.
                                                     }];
    [alert addAction:cancelAction];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSArray *textFields = alert.textFields;
        UITextField *text = textFields[0];
        [self resetPassword:text.text];
        [AppMethods pauseWithActivityIndicator:self.activityIndicator onView:self.view];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

//Helper function called to create alerts and make the parse request
- (void) resetPassword: (NSString *)email {
    NSString *emailLower = [email lowercaseString];
    emailLower = [emailLower stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [PFUser requestPasswordResetForEmailInBackground:emailLower block:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil) {
            [AppMethods alertWithTitle:@"Success" message:@"Success! Check your email for further instructions. Please allow up to 5 minutes to receive your email." onViewController:self];
        } else {
            [AppMethods alertWithTitle:@"Error!" message:@"Could not complete request." onViewController:self];
        }
        [AppMethods unpauseWithActivityIndicator:self.activityIndicator onView:self.view];
    }];
}

//Helper function for when a user clicks the login button
- (void)loginUser {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    //call to Parse to check is the user is in the database
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            //In this case the user is not able to login
            NSLog(@"User log in failed: %@", error.localizedDescription);
            [AppMethods alertWithTitle:@"Invalid login information" message:@"Please check that you entered the correct login information." onViewController:self];
        } else {
            //If the user does have an account and entered the correct password
            
            NSLog(@"User logged in successfully");
            PFUser.currentUser[@"updatedPassword"] = @(NO);
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
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
