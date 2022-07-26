//
//  LoginViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/6/22.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
        [self pause];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

//Helper function called to create alerts and make the parse request
- (void) resetPassword: (NSString *)email {
    NSString *emailLower = [email lowercaseString];
    emailLower = [emailLower stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [PFUser requestPasswordResetForEmailInBackground:emailLower block:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil) {
            [self alertWithTitle:@"Success" message:@"Success! Check your email for further instructions. Please allow up to 5 minutes to receive your email."];
        } else {
            [self alertWithTitle:@"Error!" message:@"Could not complete request."];
        }
        [self unpause];
    }];
}

//Pauses the screen with an activity indicator while waiting for parse to respond about the request
-(void) pause {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.activityIndicator.center = self.view.center;
    self.activityIndicator.hidesWhenStopped = true;
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleMedium];
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    [self.view setUserInteractionEnabled:NO];
}

//unpauses the screen
-(void) unpause{
    [self.activityIndicator stopAnimating];
    [self.view setUserInteractionEnabled:YES];
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
            [self alertWithTitle:@"Invalid login information" message:@"Please check that you entered the correct login information."];
        } else {
            //If the user does have an account and entered the correct password
            
            NSLog(@"User logged in successfully");
            PFUser.currentUser[@"updatedPassword"] = @(NO);
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
}

//Method to create an alert on the login screen.
- (void) alertWithTitle: (NSString *)title message:(NSString *)text {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                               message:text
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                             // handle response here.
                                                     }];
    // add the OK action to the alert controller
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{
        // optional code for what happens after the alert controller has finished presenting
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
