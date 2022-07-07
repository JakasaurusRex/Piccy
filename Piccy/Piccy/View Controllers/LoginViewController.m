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

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
    // Do any additional setup after loading the view.
}

//When the login button is pressed call the helper method
- (IBAction)loginButtonPressed:(id)sender {
    [self loginUser];
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
