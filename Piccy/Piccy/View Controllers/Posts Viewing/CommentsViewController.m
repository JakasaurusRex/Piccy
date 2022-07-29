//
//  CommentsViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/19/22.
//

#import "CommentsViewController.h"
#import "CaptionViewCell.h"
#import "Comment.h"
#import "CommentViewCell.h"
#import "ReportedPiccy.h"
#import "ReactionViewCell.h"
#import "PiccyReaction.h"

@interface CommentsViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *optionsButton;
@property (nonatomic) bool canceled;
@property (nonatomic, strong) NSArray *comments;
@property (weak, nonatomic) IBOutlet UITextField *commentTextView;
@property (weak, nonatomic) IBOutlet UIButton *commentAddButton;
@property (nonatomic) bool commentIsReply;
@property (nonatomic) CGRect keyboard;
@property (nonatomic, strong) NSMutableArray *actions;
@property (nonatomic, strong) UIMenu *menu;
@property (nonatomic) int selectedSeg; // 0 is comments  1 is reactions
@property (nonatomic, strong) NSArray *reactions;
@end

@implementation CommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    self.commentTextView.delegate = self;
    
    //Differentiates how the text is started with the @ or not
    self.commentIsReply = false;
    
    [self queryComments];
    self.commentAddButton.userInteractionEnabled = false;
    self.commentAddButton.tintColor = [UIColor lightGrayColor];
    
    self.canceled = false;
    self.title = self.piccy.username;
    
    [self addDoneToField:self.commentTextView];
    
    //Allows the user to change the caption of the post if they are on thier own comments page
    if(self.isSelf == false) {
        [self.tableView setAllowsSelection:NO];
    }
    
    //Setting up the options menu
    [self setupMenu];
    
    //Keyboard notifications for moving the text box
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //Int for which mode we are on for the home screen
    if(self.reactionStart == false) {
        self.selectedSeg = 0;
        self.commentButton.tintColor = [UIColor blackColor];
        self.commentButton.backgroundColor = [UIColor whiteColor];
        self.reactionButton.tintColor = [UIColor lightGrayColor];
        self.reactionButton.backgroundColor = [UIColor clearColor];
        self.commentButton.layer.cornerRadius = 15;
    } else {
        self.selectedSeg = 1;
        self.reactionButton.tintColor = [UIColor blackColor];
        self.reactionButton.backgroundColor = [UIColor whiteColor];
        self.commentButton.tintColor = [UIColor lightGrayColor];
        self.commentButton.backgroundColor = [UIColor clearColor];
        self.reactionButton.layer.cornerRadius = 15;
        [self queryReactions:(int)[self.piccy[@"reactedUsernames"] count]];
        self.commentTextView.alpha = 0;
        self.commentTextView.userInteractionEnabled = false;
        self.commentAddButton.userInteractionEnabled = false;
        self.commentAddButton.alpha = 0;
    }
    
    
}

-(void) keyboardWillShow:(NSNotification *)notification {
    if(notification.userInfo != nil) {
        if(notification.userInfo[UIKeyboardFrameEndUserInfoKey] != nil) {
            if(self.commentTextView.frame.origin.y > 700) {
                NSValue *value = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
                CGRect rect = value.CGRectValue;
                CGRect viewFrame = self.commentTextView.frame;
                viewFrame.origin.y -= rect.size.height - 32;
                self.commentTextView.frame = viewFrame;
                
                viewFrame = self.commentView.frame;
                viewFrame.origin.y -= rect.size.height - 32;
                self.commentView.frame = viewFrame;
            
                viewFrame = self.commentAddButton.frame;
                viewFrame.origin.y -= rect.size.height - 32;
                self.commentAddButton.frame = viewFrame;
                
            }
        }
    }
}

-(void) keyboardWillHide:(NSNotification *)notification {
    if(self.commentTextView.frame.origin.y != 764) {
        CGRect viewFrame = self.commentTextView.frame;
        viewFrame.origin.y = 764;
        self.commentTextView.frame = viewFrame;
        
        viewFrame = self.commentView.frame;
        viewFrame.origin.y = 756;
        self.commentView.frame = viewFrame;
        
        viewFrame = self.commentAddButton.frame;
        viewFrame.origin.y = 768;
        self.commentAddButton.frame = viewFrame;
    }
}

- (IBAction)replyPressed:(id)sender {
    UIView *content = (UIView *)[(UIView *) sender superview];
    CommentViewCell *cell = (CommentViewCell *)[content superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Comment *comment = self.comments[indexPath.row];
    self.commentTextView.text = [NSString stringWithFormat:@"@%@ ",comment.commentUser.username];
    [self.commentTextView becomeFirstResponder];
    self.commentIsReply = true;
}

- (IBAction)backPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadHome" object:nil];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)optionsButtonPressed:(id)sender {
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.selectedSeg == 0) {
        return 1 + [self.comments count];
    } else {
        return [self.reactions count];
    }
    
}

- (IBAction)commentAddButtonPressed:(id)sender {
    self.commentAddButton.userInteractionEnabled = false;
    self.commentAddButton.tintColor = [UIColor lightGrayColor];
    __weak __typeof__(self) weakSelf = self;
    [weakSelf postComment];
    self.piccy.replyCount+=1;
    [self.piccy saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil) {
            NSLog(@"saved new piccy reply count");
        } else {
            NSLog(@"could not save new piccy reply count: %@", error);
        }
    }];
}

-(void) postComment {
    __weak __typeof(self) weakSelf = self;
    [Comment postComment:self.commentTextView.text onPiccy:self.piccy andIsReply:self.commentIsReply withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
               return;
       }
        if(error == nil) {
            [strongSelf->_commentTextView setText:@""];
            [strongSelf queryComments];
            NSLog(@"posted comment successfully");
        } else {
            NSLog(@"Could not post comment: %@", error);
        }
    }];
}

-(void) queryComments {
    __weak __typeof(self) weakSelf = self;
    __strong __typeof(self) strongSelf = weakSelf;
    if (!strongSelf) {
           return;
   }
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query orderByAscending:@"createdAt"];
    query.limit = 20;
    [query includeKey:@"commentUser"];
    [query includeKey:@"piccy"];
    [query whereKey:@"piccy" equalTo:strongSelf.piccy];
    strongSelf.comments = [query findObjects];
    if([strongSelf.comments isEqualToArray:@[]]) {
        NSLog(@"No users have commented");
        [strongSelf.tableView reloadData];
        return;
    }
    NSLog(@"%@", strongSelf.comments);
    [strongSelf.tableView reloadData];
}

-(void) queryReactions:(int) limit {
    PFQuery *query = [PFQuery queryWithClassName:@"PiccyReaction"];
    __weak __typeof(self) weakSelf = self;
    __strong __typeof(self) strongSelf = weakSelf;
    if (!strongSelf) {
           return;
   }
    [query orderByAscending:@"createdAt"];
    [query includeKey:@"piccy"];
    [query includeKey:@"user"];
    [query whereKey:@"piccy" equalTo:strongSelf.piccy];
    strongSelf.reactions = [query findObjects];
    if([strongSelf.reactions count] == 0) {
        NSLog(@"No reactions found");
    }
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0 && self.selectedSeg == 0) {
        CaptionViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CaptionViewCell"];
        cell.usernameLabel.text = self.piccy.username;
        
        cell.profileImage.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:self.piccy.user[@"profilePictureURL"]]];
        cell.profileImage.layer.masksToBounds = false;
        cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.size.width/2;
        cell.profileImage.clipsToBounds = true;
        cell.profileImage.contentMode = UIViewContentModeScaleAspectFill;
        cell.profileImage.layer.borderWidth = 0.05;
        
        if([self.piccy.caption isEqualToString:@""] && [self.piccy.username isEqualToString:PFUser.currentUser.username]) {
            cell.captionTextView.text = @"Add a caption...";
            cell.captionTextView.textColor = [UIColor lightGrayColor];
        } else if ([self.piccy.caption isEqualToString:@""]) {
            cell.captionTextView.text = @"no comment :/";
            cell.captionTextView.textColor = [UIColor systemRedColor];
        } else {
            cell.captionTextView.text = self.piccy.caption;
            cell.captionTextView.textColor = [UIColor whiteColor];
        }
        NSDate *date = self.piccy.createdAt;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mm:ss a"];
        cell.timeLabel.text = [dateFormatter stringFromDate:date];
        
        cell.captionTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        cell.captionTextView.delegate = self;
        [self addDoneAndCancelToTextField:cell.captionTextView];
        
        return cell;
    } else if(self.selectedSeg == 0) {
        CommentViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CommentViewCell"];
        cell.commentTextLabel.delegate = self;
        Comment *comment = self.comments[indexPath.row - 1];
        
        cell.comment = comment;
        cell.usernameLabel.text = comment.commentUser.username;
        cell.commentTextLabel.text = comment.commentText;
        
        NSDate *date = comment.createdAt;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mm:ss a"];
        cell.timeLabel.text = [dateFormatter stringFromDate:date];
        
        cell.profileImage.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:comment.commentUser[@"profilePictureURL"]]];
        cell.profileImage.layer.masksToBounds = false;
        cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.size.width/2;
        cell.profileImage.clipsToBounds = true;
        cell.profileImage.contentMode = UIViewContentModeScaleAspectFill;
        cell.profileImage.layer.borderWidth = 0.05;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
    } else { //when selected seg = 1
        ReactionViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ReactionViewCell"];
        PiccyReaction *reaction = self.reactions[indexPath.row];
        cell.nameLabel.text = reaction.user[@"name"];
        
        cell.reactionImage.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:reaction.reactionURL]];
        cell.reactionImage.layer.masksToBounds = false;
        cell.reactionImage.layer.cornerRadius = cell.reactionImage.bounds.size.width/2;
        cell.reactionImage.clipsToBounds = true;
        cell.reactionImage.contentMode = UIViewContentModeScaleAspectFill;
        cell.reactionImage.layer.borderWidth = 0.05;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        CaptionViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.captionTextView.userInteractionEnabled = true;
        [cell.captionTextView becomeFirstResponder];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    textView.text = @"";
    textView.textColor = [UIColor whiteColor];
}

//Add done button to phone number field
-(void) addDoneAndCancelToTextField:(UITextView *)field {
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:@selector(donePressedTextField)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:nil action:@selector(cancelPressedTextField)];
    NSArray *array = [[NSArray alloc] initWithObjects:doneButton, cancelButton, nil];
    [toolbar setItems:array animated:true];
    [field setInputAccessoryView:toolbar];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if(self.canceled == false) {
        self.piccy.caption = textView.text;
    } else {
        textView.text = self.piccy.caption;
    }
}

-(void) donePressedTextField {
    self.canceled = false;
    [self.view endEditing:true];
    [self saveCaption];
}

-(void) cancelPressedTextField {
    self.canceled = true;
    self.commentIsReply = false;
    [self.view endEditing:true];
}

-(void) saveCaption {
    [self.piccy saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil) {
            NSLog(@"saved new caption");
        } else {
            NSLog(@"could not save new caption");
        }
    }];
}

- (IBAction)commentTextFieldChanged:(id)sender {
    if([self.commentTextView.text isEqualToString:@""]) {
        self.commentAddButton.userInteractionEnabled = false;
        self.commentAddButton.tintColor = [UIColor lightGrayColor];
    } else {
        self.commentAddButton.userInteractionEnabled = true;
        self.commentAddButton.tintColor = [UIColor orangeColor];
    }
}

-(void) addDoneToField:(UITextField *)field {
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:@selector(donePressedComment)];
    NSArray *array = [[NSArray alloc] initWithObjects:doneButton, nil];
    [toolbar setItems:array animated:true];
    [field setInputAccessoryView:toolbar];
}

-(void) donePressedComment {
    [self.view endEditing:true];
}

-(void) setupMenu {
    //setting the default behavior of the button to this
    [self.optionsButton setShowsMenuAsPrimaryAction:YES];
    
    //Array of actions shown in the menu
    self.actions = [[NSMutableArray alloc] init];
    [self.actions addObject:[UIAction actionWithTitle:@"📝 Report Piccy"
                                           image:nil
                                      identifier:nil
                                         handler:^(__kindof UIAction* _Nonnull action) {
        
        [self report:self.piccy];
    }]];
    
    PFUser *user = [PFUser currentUser];
    if([self.piccy.user.username isEqualToString:user.username]) {
        [self.actions addObject:[UIAction actionWithTitle:@"Delete Piccy"
                                               image:nil
                                          identifier:nil
                                             handler:^(__kindof UIAction* _Nonnull action) {
            [self deletePiccy:self.piccy];
        }]];
    }
    
    self.menu =
    [UIMenu menuWithTitle:@"Options"
                 children:self.actions];
    
    
    [self.optionsButton setMenu:self.menu];
}

-(void) report: (Piccy *) piccy {
    //Creates the alert controller with a text field for the reason for report
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report Piccy"
                                                                               message:@"Please enter the reason for reporting this Piccy:"
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Reason for report";
    }];
    
    //Cancel button
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                             // handle response here.
                                                     }];
    [alert addAction:cancelAction];
    
    //Adds the action for when a user clicks on report
    [alert addAction:[UIAlertAction actionWithTitle:@"Report" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSArray *textFields = alert.textFields;
        UITextField *text = textFields[0];
        
        //Checks if text field was empty and prompts the user to try again
        if([text.text isEqualToString:@""]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No report reason"
                                                                                       message:@"Please try again and enter a reason for report"
                                                                                preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                     // handle response here.
                                                             }];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        PFUser *user = [PFUser currentUser];
        if(![user[@"reportedPiccys"] containsObject:piccy.objectId]) {
            //Create a piccy report object if none exist by this user already
            [ReportedPiccy reportPiccy:piccy withReason:text.text withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if(error == nil) {
                    NSLog(@"Piccy Reported");
                    NSMutableArray *reportArray = [[NSMutableArray alloc] initWithArray:user[@"reportedPiccys"]];
                    [reportArray addObject:piccy.objectId];
                    user[@"reportedPiccys"] = [[NSArray alloc] initWithArray:reportArray];
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if(error == nil)
                            NSLog(@"saved user report array");
                        else
                            NSLog(@"could not save user report array: %@", error);
                    }];
                } else {
                    NSLog(@"Error reporting piccy: %@", error);
                }
            }];
        } else {
            //If a report already exists for this piccy by this user, alert them
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Piccy already reported"
                                                                                       message:@"This piccy was already reported by you."
                                                                                preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                     // handle response here.
                                                             }];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        // Ask the user if they would also like to block the user of the piccy they are reporting
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Block user"
                                                                                   message:@"Would you like to block the user who posted this Piccy as well? Users can be unblocked later in settings."
                                                                            preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                                 // handle response here.
            //Creates a mutable array with teh arrays from the database, adds or removes the username from block list or friends list and saves it
            NSMutableArray *blockArray = [[NSMutableArray alloc] initWithArray:user[@"blockedUsers"]];
            [blockArray addObject:piccy.user.username];
            NSMutableArray *friendsArray = [[NSMutableArray alloc] initWithArray:user[@"friendsArray"]];
            [friendsArray removeObject:piccy.user.username];
            user[@"blockedUsers"] = [[NSArray alloc] initWithArray: blockArray];
            user[@"friendsArray"] = [[NSArray alloc] initWithArray:friendsArray];
            
            PFUser *piccyUser = piccy.user;
            NSMutableArray *otherFriend = [[NSMutableArray alloc] initWithArray:piccyUser[@"friendsArray"]];
            [otherFriend removeObject:user.username];
            piccyUser[@"friendsArray"] = [[NSArray alloc] initWithArray:otherFriend];
            
            otherFriend = [[NSMutableArray alloc] initWithArray:piccyUser[@"blockedByArray"]];
            [otherFriend addObject:user.username];
            piccyUser[@"blockedByArray"] = [[NSArray alloc] initWithArray:otherFriend];
            
            [self postOtherUser:piccyUser];
            
            __weak __typeof(self) weakSelf = self;
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                __strong __typeof(self) strongSelf = weakSelf;
                if (!strongSelf) {
                       return;
               }
                if(error == nil) {
                    NSLog(@"saved user blocked and friends arrays");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadHome" object:nil];
                    [strongSelf dismissViewControllerAnimated:true completion:nil];
                } else {
                    NSLog(@"could not save user blocked and friends arrays: %@", error);
                }
            }];
            
                                                         }];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                                 // handle response here.
                                                         }];
        [alert addAction:yesAction];
        [alert addAction:noAction];
        [self presentViewController:alert animated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

//Calls cloud function in Parse that changes the other user for me using a master key. this was becasue parse cannot save other users without them being logged in
-(void) postOtherUser:(PFUser *)otherUser {
    //creating a parameters dictionary with all the items in the user that need to be changed and saved
    NSMutableDictionary *paramsMut = [[NSMutableDictionary alloc] init];
    [paramsMut setObject:otherUser.username forKey:@"username"];
    [paramsMut setObject:otherUser[@"friendsArray"] forKey:@"friendsArray"];
    [paramsMut setObject:otherUser[@"blockedByArray"] forKey:@"blockedByArray"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsMut];
    //calling the function in the parse cloud code
    [PFCloud callFunctionInBackground:@"saveOtherUser" withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
        if(!error) {
            NSLog(@"Saving other user worked");
        } else {
            NSLog(@"Error saving other user with error: %@", error);
        }
    }];
}

-(void) deletePiccy:(Piccy *) piccy {
    PFUser *user = [PFUser currentUser];
    __weak __typeof(self) weakSelf = self;
    [piccy deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
               return;
       }
        if(error == nil) {
            NSLog(@"Piccy deleted");
            user[@"postedToday"] = @(NO);
            user[@"deletedToday"] = @(YES);
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(error == nil) {
                    NSLog(@"User posted today after deleting piccy saved");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadHome" object:nil];
                    [strongSelf dismissViewControllerAnimated:true completion:nil];
                }
            }];
        } else {
            NSLog(@"Could not delete piccy");
        }
        
    }];
}
- (IBAction)commentButtonPressed:(id)sender {
    if(self.selectedSeg == 1) {
        self.commentButton.tintColor = [UIColor blackColor];
        self.commentButton.backgroundColor = [UIColor whiteColor];
        self.reactionButton.tintColor = [UIColor lightGrayColor];
        self.reactionButton.backgroundColor = [UIColor clearColor];
        self.commentButton.layer.cornerRadius = 15;
        self.selectedSeg = 0;
        
        self.commentTextView.alpha = 1;
        self.commentTextView.userInteractionEnabled = true;
        self.commentAddButton.alpha = 1;
        self.commentAddButton.userInteractionEnabled = true;
        [self queryComments];
    }
    
}
- (IBAction)reactionButtonPressed:(id)sender {
    if(self.selectedSeg == 0) {
        self.commentButton.tintColor = [UIColor lightGrayColor];
        self.reactionButton.tintColor = [UIColor blackColor];
        self.reactionButton.backgroundColor = [UIColor whiteColor];
        self.commentButton.backgroundColor = [UIColor clearColor];
        self.reactionButton.layer.cornerRadius = 15;
        self.selectedSeg = 1;
        
        self.commentTextView.alpha = 0;
        self.commentTextView.userInteractionEnabled = false;
        self.commentAddButton.alpha = 0;
        self.commentAddButton.userInteractionEnabled = false;
        [self queryReactions:(int)[self.piccy[@"reactedUsernames"] count]];
    }
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
