//
//  RegistrationTableViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/26/22.
//

#import "RegistrationTableViewController.h"
#import "ProfilePictureViewController.h"
#import <Parse/Parse.h>
#import "MagicalEnums.h"
#import "AppMethods.h"

@interface RegistrationTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *reeneterPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UITextField *dateOfBirthField;

@property (nonatomic) bool usernameTaken;
@property (nonatomic) bool usernameTooShort;
@property (nonatomic) bool usernameHasWeirdCharacters;
@property (nonatomic) bool passwordsDontMatch;
@property (nonatomic) bool passwordTooShort;
@property (nonatomic) bool emailTaken;
@property (nonatomic) bool emailInvalid;
@property (nonatomic) bool phoneNumberInUse;
@property (nonatomic) bool phoneNumberInvalid;
@property (nonatomic) bool nameInvalid;
@property (nonatomic) bool dateInvalid;

//date picker for DOB field
@property (strong, nonatomic) UIDatePicker *datePicker;

@end

@implementation RegistrationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createDatePicker];
    
    self.usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.nameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.reeneterPasswordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    [self addDoneToTextField:self.phoneNumberField];
    [self addDoneToTextField:self.nameField];
    [self addDoneToTextField:self.usernameField];
    [self addDoneToTextField:self.emailField];
    [self addDoneToTextField:self.passwordField];
    [self addDoneToTextField:self.reeneterPasswordField];
   
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
    newUser[@"phoneNumber"] = self.phoneNumberField.text;
    newUser[@"dateOfBirth"] = self.datePicker.date;
    
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            if(error.code == ParseErrorUsernameTaken) {
                self.usernameTaken = true;
            } else {
                self.usernameTaken = false;
                if(error.code == ParseErrorEmailInvalid) {
                    self.emailInvalid = true;
                } else {
                    self.emailInvalid = false;
                    if(error.code == ParseErrorEmailTaken) {
                        self.emailTaken = true;
                    } else {
                        self.emailTaken = false;
                    }
                }
            }
            [self.tableView reloadData];
            return;
        } else {
            NSLog(@"User registered successfully");
            [self performSegueWithIdentifier:@"profilePictureSegue" sender:nil];
            // manually segue to logged in view
        }
    }];
}

- (IBAction)createAccountPressed:(id)sender {
    if([self canUserRegister]) {
        [self registerUser];
    } else {
        [AppMethods alertWithTitle:@"Cannot create an account" message:@"Account could not be created. Please verify all of the fields have been filled out correctly." onViewController:self];
    }
}

//helper to check if the user has filled out the fields correctly
- (BOOL) canUserRegister {
    if(![self.passwordField.text isEqualToString:self.reeneterPasswordField.text]) {
        self.passwordsDontMatch = true;
    } else {
        self.passwordsDontMatch = false;
    }
    
    if([self.usernameField.text isEqualToString:@""] || self.usernameField.text.length <= RegistrationRequirementsUsernameLength) {
        self.usernameTooShort = true;
    } else {
        self.usernameTooShort = false;
    }
    
    if([self.nameField.text isEqualToString:@""]) {
        self.nameInvalid = true;
    } else {
        self.nameInvalid = false;
    }
    
    if(self.passwordField.text.length < RegistrationRequirementsPasswordLength) {
        self.passwordTooShort = true;
    } else {
        self.passwordTooShort = false;
    }
    
    if(self.phoneNumberField.text.length < 10 || self.phoneNumberField.text.length > 12) {
        self.phoneNumberInvalid = true;
    } else {
        self.phoneNumberInvalid = false;
    }
    
    [self checkPhoneNumberInDb:self.phoneNumberField.text];
   
    if([self.dateOfBirthField.text isEqualToString:@""]) {
        self.dateInvalid = true;
    } else {
        self.dateInvalid = false;
    }
    if(![self isAlphaNumeric:self.usernameField.text]) {
        self.usernameHasWeirdCharacters = true;
    } else {
        self.usernameHasWeirdCharacters = false;
    }
    
    if(self.emailField.text.length < RegistrationRequirementsEmailLength) {
        self.emailInvalid = true;
    } else {
        self.emailInvalid = false;
    }
    
    if(self.usernameTaken || self.usernameTooShort || self.usernameHasWeirdCharacters || self.passwordsDontMatch || self.passwordTooShort || self.nameInvalid || self.phoneNumberInvalid || self.phoneNumberInUse || self.dateInvalid || self.emailTaken || self.emailInvalid) {
        [self.tableView reloadData];
        return NO;
    }
    
    return YES;
}

-(void) checkPhoneNumberInDb:(NSString *) phoneNumber {
    PFQuery *query = [PFUser query];
    [query includeKey:@"phoneNumber"];
    [query whereKey:@"phoneNumber" equalTo:phoneNumber];
    
    __weak __typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
               return;
       }
        if(error == nil) {
            NSLog(@"Could query phone numbers");
            if([objects count] == 0) {
                NSLog(@"No phone numbers found");
                strongSelf.phoneNumberInUse = false;
            } else {
                self.phoneNumberInUse = true;
            }
        } else {
            NSLog(@"Couldn't query phone numbers: %@", error);
            strongSelf.phoneNumberInUse = true;
        }
    }];
    
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

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section == 0 && self.usernameTooShort) {
        return @"Please enter a username longer than 3 characters";
    } else if(section == RegistrationPageSectionsUsernameSection && self.usernameHasWeirdCharacters) {
        return @"Username can only have alpha numberic characters";
    } else if(section == RegistrationPageSectionsUsernameSection && self.usernameTaken) {
        return @"Username already taken";
    } else if(section == RegistrationPageSectionsPasswordSection && self.passwordsDontMatch) {
        return @"Passwords do not match";
    } else if(section == RegistrationPageSectionsNameSection && self.nameInvalid) {
        return @"Please enter a name";
    } else if(section == RegistrationPageSectionsEmailSection && self.emailTaken) {
        return @"Email already in use";
    } else if(section == RegistrationPageSectionsEmailSection && self.emailInvalid) {
        return @"Please enter a valid email address";
    } else if(section == RegistrationPageSectionsPasswordSection && self.passwordTooShort) {
        return @"Please enter a password 8 characters or longer";
    } else if(section == RegistrationPageSectionsPhoneSection && self.phoneNumberInUse) {
        return @"Phone number already in use";
    } else if(section == RegistrationPageSectionsPhoneSection && self.phoneNumberInvalid) {
        return @"Please enter a valid phone number";
    } else if(section == RegistrationPageSectionsDOBSection && self.dateInvalid) {
        return @"Please enter your date of birth";
    }
    return @"";
}

- (BOOL) isAlphaNumeric:(NSString *) string
{
    NSCharacterSet *alphaSet = [NSCharacterSet alphanumericCharacterSet];
    BOOL valid = [[string stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""];
    return valid;
}

-(void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor systemRedColor]];
}


#pragma mark - Table view data source

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"profilePictureSegue"]) {
        //Passing the daily loop to the piccy screen
        UINavigationController *navigationController = [segue destinationViewController];
        ProfilePictureViewController *profilePictureViewController = (ProfilePictureViewController*)navigationController.topViewController;
        profilePictureViewController.newUser = true;
    }
}


@end
