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

@interface ProfileSetingsTableViewController () <UITextViewDelegate>

@end

@implementation ProfileSetingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //For loading new PFPS
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadProfileSettings) name:@"loadProfileSettings" object:nil];
    
    if([PFUser.currentUser[@"darkMode"] boolValue] == YES) {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
    } else {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
        self.view.backgroundColor = [UIColor whiteColor];
        [self.tableView setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
    }
    [self createDatePicker];
    
    [self loadProfileSettings];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:(23/255.0f) green:(23/255.0f) blue:(23/255.0f) alpha:1];
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
    
    self.profilePicture.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:user[@"profilePictureURL"]]];
    self.profilePicture.layer.masksToBounds = false;
    self.profilePicture.layer.cornerRadius = self.profilePicture.bounds.size.width/2;
    self.profilePicture.clipsToBounds = true;
    self.profilePicture.contentMode = UIViewContentModeScaleAspectFill;
    self.profilePicture.layer.borderWidth = 0.05;
    
}

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

//Checks when text views are edited so I can highlight the save button trying to make it so that it will update the save buttom when a text field is edited
- (void)textFieldDidBeginEditing:(UITextField *)textField  {
    NSLog(@"Not working");
    self.saveButton.tintColor = [UIColor colorWithRed:(235/255.0f) green:(120/255.0f) blue:(87/255.0f) alpha:1];
    [self.saveButton setUserInteractionEnabled:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 8;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)profilePictureButton:(id)sender {
}
@end
