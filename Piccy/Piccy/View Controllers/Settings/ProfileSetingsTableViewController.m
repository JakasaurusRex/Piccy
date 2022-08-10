//
//  ProfileSetingsTableViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/7/22.
//

//This class is for the Table View inside of the Profile Settings page
#import "ProfileSetingsTableViewController.h"
#import <Parse/Parse.h>
#import "UIImage+animatedGIF.h"
#import "ProfilePictureViewController.h"
#import "MagicalEnums.h"
#import "AppMethods.h"

@interface ProfileSetingsTableViewController () <UITextViewDelegate>

@end

@implementation ProfileSetingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bioField.delegate = self;
    self.nameField.delegate = self;
    self.emailField.delegate = self;
    self.nameField.delegate = self;
    self.passwordField.delegate = self;
    self.phoneNumberField.delegate = self;
    self.dateOfBirthField.delegate = self;
    //For loading new PFPS
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadProfileSettings) name:@"loadProfileSettings" object:nil];
    
    PFUser *currentUser = [PFUser currentUser];
    if([currentUser[@"darkMode"] isEqual:@(YES)]) {
        self.tableView.backgroundColor = [UIColor blackColor];
    } else {
        self.view.backgroundColor = [UIColor secondarySystemBackgroundColor];
    }
    [self createDatePicker];
    
    [self loadProfileSettings];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) loadProfileSettings {
    PFUser *user = [PFUser currentUser];
    self.usernameField.text = user[@"username"];
    self.nameField.text = user[@"name"];
    self.emailField.text = user[@"email"];
    self.passwordField.text = user[@"password"];
    self.bioField.text = user[@"bio"];
    
    NSDate *DOB = user[@"dateOfBirth"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    self.dateOfBirthField.text = [formatter stringFromDate:DOB];
    
    self.phoneNumberField.text = user[@"phoneNumber"];
    
    self.profilePicture = [AppMethods roundImageView:self.profilePicture withURL:user[@"profilePictureURL"]];
    self.saveButton.tintColor = [UIColor lightGrayColor];
    self.saveButton.userInteractionEnabled = false;
}

-(void) createDatePicker {
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:@selector(donePressed)];
    NSArray *array = [[NSArray alloc] initWithObjects:doneButton, nil];
    [toolbar setItems:array animated:true];
    
    

    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, UIScreen.mainScreen.bounds.size.height-200, self.view.frame.size.width, 200)];
    [self.dateOfBirthField setInputAccessoryView:toolbar];
    
    [self.dateOfBirthField setInputView:self.datePicker];
    
    [self.datePicker setPreferredDatePickerStyle:UIDatePickerStyleWheels];
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    [self.datePicker setFrame:CGRectMake(0, UIScreen.mainScreen.bounds.size.height-200, self.view.frame.size.width, 200)];
}

//When you press the done button on the date selection menu
-(void) donePressed {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    self.saveButton.tintColor = [UIColor colorWithRed:(235/255.0f) green:(120/255.0f) blue:(87/255.0f) alpha:1];
    [self.saveButton setUserInteractionEnabled:YES];
    self.dateOfBirthField.text = [formatter stringFromDate:self.datePicker.date];
    
    [self.view endEditing:true];
}

//Checks when text views are edited so I can highlight the save button trying to make it so that it will update the save buttom when a text field is edited
- (void)textViewDidChange:(UITextView *)textField  {
    self.saveButton.tintColor = [UIColor colorWithRed:(235/255.0f) green:(120/255.0f) blue:(87/255.0f) alpha:1];
    [self.saveButton setUserInteractionEnabled:YES];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 8;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    PFUser *user = [PFUser currentUser];
    if([user[@"darkMode"] boolValue]) {
        cell.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        cell.backgroundColor = [UIColor systemBackgroundColor];
    }
}


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

- (IBAction)profilePictureButton:(id)sender {
    ProfilePictureViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"profilePicVC"];
    nav.newUser = false;
    [self.navigationController pushViewController:nav animated:YES];
}

@end
