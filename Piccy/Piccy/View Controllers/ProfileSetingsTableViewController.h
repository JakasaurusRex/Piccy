//
//  ProfileSetingsTableViewController.h
//  Piccy
//
//  Created by Jake Torres on 7/7/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProfileSetingsTableViewController : UITableViewController
- (IBAction)profilePictureButton:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *nameField;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UITextView *usernameField;
@property (weak, nonatomic) IBOutlet UITextView *bioField;
@property (weak, nonatomic) IBOutlet UITextView *emailField;
@property (weak, nonatomic) IBOutlet UITextView *passwordField;
@property (weak, nonatomic) IBOutlet UITextView *dateOfBirthField;
@property (weak, nonatomic) IBOutlet UITextView *phoneNumberField;
@property (strong, nonatomic) UIDatePicker *datePicker;
@end

NS_ASSUME_NONNULL_END
