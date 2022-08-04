//
//  PostViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/15/22.
//
//Post screen
#import "PostViewController.h"
#import <Parse/Parse.h>
#import "UIImage+animatedGIF.h"
#import "Piccy.h"
#import "AppMethods.h"

@interface PostViewController ()
@property (weak, nonatomic) IBOutlet UILabel *piccyLabel;
@property (weak, nonatomic) IBOutlet UITextField *captionField;
@property (weak, nonatomic) IBOutlet UIImageView *piccyImage;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *postButton;

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addDoneToTextField:self.captionField];
    
    //set the views on the post screen
    self.piccyLabel.text = [NSString stringWithFormat:@"Daily Piccy: %@", self.piccyLoop.dailyWord];
    self.captionField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.timeLabel.text = self.timer;
    
    self.piccyImage = [AppMethods roundedCornerImageView:self.piccyImage withURL:self.piccyUrl];
    
    self.postButton.tintColor = [UIColor systemRedColor];
    self.postButton.backgroundColor = [UIColor systemRedColor];
}

- (IBAction)postPressed:(id)sender {
    [self postPiccy];
    [self dismissViewControllerAnimated:true completion:nil];
    //goes back to the homescreen and reloads it with the new piccy and now that the user has posted
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goHome" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadHome" object:nil];
}

-(void) postPiccy {
    //Makes api call to post the piccy and update the user
    [Piccy postPiccy:self.piccyUrl withCaption:self.captionField.text withDate:self.piccyLoop.dailyReset withTime:self.timer withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil) {
            NSLog(@"Piccy successfully posted");
            PFUser *user = [PFUser currentUser];
            user[@"postedToday"] = @(YES);
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(error == nil) {
                    NSLog(@"User posted today updated sucessfully");
                } else {
                    NSLog(@"Error updating user posted today %@", error);
                }
            }];
        }
    }];
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
