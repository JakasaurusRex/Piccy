//
//  RegistrationViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/6/22.
//

#import "RegistrationViewController.h"
#import <Parse/Parse.h>

@interface RegistrationViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *reenterPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *dateOfBirthField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;

//date picker for DOB field
@property (strong, nonatomic) UIDatePicker *datePicker;

@end

@implementation RegistrationViewController

- (IBAction)pressedCreateAccount:(id)sender {
    if([self canUserRegister]) {
        [self registerUser];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createDatePicker];
    [self addDoneToTextField:self.phoneField];
    [self addDoneToTextField:self.nameField];
    [self addDoneToTextField:self.usernameField];
    [self addDoneToTextField:self.emailField];
    [self addDoneToTextField:self.passwordField];
    [self addDoneToTextField:self.reenterPasswordField];
    
    self.usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.nameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.reenterPasswordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
}

//Returns user to login screen if clicked back button
- (IBAction)didPressBack:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

//Register user helper method
- (void)registerUser {
    // initialize a user object
    PFUser *newUser = [PFUser user];
    
    // set user properties
    newUser.username = [self.usernameField.text lowercaseString];
    newUser.email = self.emailField.text;
    newUser.password = self.passwordField.text;
    newUser[@"name"] = self.nameField.text;
    newUser[@"phoneNumber"] = self.phoneField.text;
    newUser[@"dateOfBirth"] = self.datePicker.date;
    
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"User registered successfully");
            [self performSegueWithIdentifier:@"registerSegue" sender:nil];
            // manually segue to logged in view
        }
    }];
}

//helper to check if the user has filled out the fields correctly
- (BOOL) canUserRegister {
    if(![self.passwordField.text isEqualToString:self.reenterPasswordField.text]) {
        //TODO Popup that passwords dont match
        return NO;
    }
    if([self.usernameField.text isEqualToString:@""]) {
        //TODO Popup to enter a username
        return NO;
    } else if([self.nameField.text isEqualToString:@""]) {
        //TODO Popup to enter a name
        return NO;
    } else if([self.passwordField.text isEqualToString:@""]) {
        //TODO Popup to enter a password
        return NO;
    } else if([self.phoneField.text isEqualToString:@""]) {
        //TODO Popup to enter a phone number
        return NO;
    } else if([self.emailField.text isEqualToString:@""]) {
        //TODO Popup to enter a email
        return NO;
    }else if([self.dateOfBirthField.text isEqualToString:@""]) {
        //TODO Popup to enter a date of birth
        return NO;
    }
    return YES;
}

//Create a datePicker UI modal
-(void) createDatePicker {
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:@selector(donePressed)];
    NSArray *array = [[NSArray alloc] initWithObjects:doneButton, nil];
    [toolbar setItems:array animated:true];
    
    

    self.datePicker = [[UIDatePicker alloc] init];
    [self.dateOfBirthField setInputAccessoryView:toolbar];
    
    [self.dateOfBirthField setInputView:self.datePicker];
    
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    [self.datePicker setFrame:CGRectMake(0, UIScreen.mainScreen.bounds.size.height-200, self.view.frame.size.width, 200)];
}

//When you press the done button on the date selection menu
-(void) donePressed {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    
    self.dateOfBirthField.text = [formatter stringFromDate:self.datePicker.date];
    [self.view endEditing:true];
}

//Add done button to phone number field
-(void) addDoneToTextField:(UITextField *)field {
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:@selector(donePressedTextField)];
    NSArray *array = [[NSArray alloc] initWithObjects:doneButton, nil];
    [toolbar setItems:array animated:true];
    [field setInputAccessoryView:toolbar];
}

-(void) donePressedTextField {
    [self.view endEditing:true];
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
