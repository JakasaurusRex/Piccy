//
//  RegistrationTableViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/26/22.
//

#import "RegistrationTableViewController.h"
#import "ProfilePictureViewController.h"
#import <Parse/Parse.h>

@interface RegistrationTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *reeneterPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UITextField *dateOfBirthField;

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
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
        } else {
            NSLog(@"User registered successfully");
            [self performSegueWithIdentifier:@"profilePictureSegue" sender:nil];
            // manually segue to logged in view
        }
    }];
}

- (IBAction)createAccountPressed:(id)sender {
    if([self canUserRegister]) {
        
    } else {
        [self alertWithTitle:@"Cannot create an account" message:@"Account could not be created. Please verify all of the fields have been filled out correctly."];
    }
}

//helper to check if the user has filled out the fields correctly
- (BOOL) canUserRegister {
    if(![self.passwordField.text isEqualToString:self.reeneterPasswordField.text]) {
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
    } else if([self.phoneNumberField.text isEqualToString:@""]) {
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

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section == 1) {
        return @"hi";
    }
    return @"";
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
