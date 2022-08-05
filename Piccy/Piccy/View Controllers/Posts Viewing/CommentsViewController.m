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
#import "MagicalEnums.h"
#import "AppMethods.h"
#import "OtherProfileViewController.h"

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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentTextFieldTopView;
@property (weak, nonatomic) IBOutlet UILabel *noReactionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *noReactionImage;

@property (strong, nonatomic) PFUser *replyUser;
@property (strong, nonatomic)PFUser *segueUser;

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
    
    self.replyUser = nil;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:@selector(donePressedComment)];
    [AppMethods addDoneToUITextField:self.commentTextView withBarButtonItem:doneButton];
    
    //Allows the user to change the caption of the post if they are on thier own comments page
    if(self.isSelf == false) {
        [self.tableView setAllowsSelection:NO];
    }
    
    self.noReactionImage.alpha = 0;
    self.noReactionLabel.alpha = 0;
    
    //Setting up the options menu
    [self setupMenu];
    
    //Keyboard notifications for moving the text box
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //Int for which mode we are on for the home screen
    if(self.reactionStart == false) {
        self.selectedSeg = CommentsTabModeComments;
        self.commentButton.tintColor = [UIColor blackColor];
        self.commentButton.backgroundColor = [UIColor whiteColor];
        self.reactionButton.tintColor = [UIColor lightGrayColor];
        self.reactionButton.backgroundColor = [UIColor clearColor];
        self.commentButton.layer.cornerRadius = UIIntValuesPillButtonCornerRadius;
    } else {
        self.selectedSeg = CommentsTabModeReactions;
        self.reactionButton.tintColor = [UIColor blackColor];
        self.reactionButton.backgroundColor = [UIColor whiteColor];
        self.commentButton.tintColor = [UIColor lightGrayColor];
        self.commentButton.backgroundColor = [UIColor clearColor];
        self.reactionButton.layer.cornerRadius = UIIntValuesPillButtonCornerRadius;
        [self queryReactions:(int)[self.piccy[@"reactedUsernames"] count]];
        self.commentTextView.alpha = 0;
        self.commentTextView.userInteractionEnabled = false;
        self.commentAddButton.userInteractionEnabled = false;
        self.commentAddButton.alpha = 0;
        self.commentView.alpha = 0;
    }
    self.commentButton.layer.cornerRadius = UIIntValuesPillButtonCornerRadius;
    self.reactionButton.layer.cornerRadius = UIIntValuesPillButtonCornerRadius;
}

//Keyboard showing code with comment bar
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
                
                self.commentTextFieldTopView.constant -= rect.size.height - 32;
            }
        }
    }
}

//Keyboard hiding code with comment bar
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
        
        self.commentTextFieldTopView.constant = 0;
    }
}

//What happens when you press the reply button
- (IBAction)replyPressed:(id)sender {
    UIView *content = (UIView *)[(UIView *) sender superview];
    CommentViewCell *cell = (CommentViewCell *)[content superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Comment *comment = self.comments[indexPath.row-1];
    self.commentTextView.text = [NSString stringWithFormat:@"@%@ ",comment.commentUser.username];
    [self.commentTextView becomeFirstResponder];
    self.commentIsReply = true;
    self.replyUser = comment.commentUser;
}

//dismisses the view controller and loads home when you press back
- (IBAction)backPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadHome" object:nil];
    [self dismissViewControllerAnimated:true completion:nil];
}

//When you press the options button
- (IBAction)optionsButtonPressed:(id)sender {
    
}

//Number of rows in table view if in comments or reactions, comments has 1 more beacuse of the user caption
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.selectedSeg == CommentsTabModeComments) {
        return 1 + [self.comments count];
    } else {
        return [self.reactions count];
    }
    
}
//When the add button is pressed, the color of the button and interaction turns off, the reply count gets upped and the comment is posted and piccy is saved with new comment
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

//Code that calls on the comment class to create a new comment object
-(void) postComment {
    __weak __typeof(self) weakSelf = self;
    [Comment postComment:self.commentTextView.text onPiccy:self.piccy andIsReply:self.commentIsReply toUser:self.replyUser withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
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

//Querys the reply count amount of comments to display on the comments table view page
-(void) queryComments {
    __weak __typeof(self) weakSelf = self;
    __strong __typeof(self) strongSelf = weakSelf;
    if (!strongSelf) {
           return;
   }
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query orderByAscending:@"createdAt"];
    query.limit = self.piccy.replyCount;
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

//Queries parse for the reactions and logs if none are found
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
        strongSelf.noReactionLabel.alpha = 1;
        strongSelf.noReactionImage.alpha = 1;
        strongSelf.noReactionImage = [AppMethods roundedCornerImageView:strongSelf.noReactionImage withURL:@"https://c.tenor.com/B-dfHiL950AAAAAd/sadge-pepe-sadge.gif"];
    }
    [self.tableView reloadData];
}

//Creates each cell in the table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0 && self.selectedSeg == CommentsTabModeComments) {
        CaptionViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CaptionViewCell"];
        cell.usernameLabel.text = self.piccy.username;
        
        cell.profileImage = [AppMethods roundImageView:cell.profileImage withURL:self.piccy.user[@"profilePictureURL"]];
        
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
        cell.timeLabel.text = [AppMethods dateToHMSString:date];
        
        cell.captionTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        cell.captionTextView.delegate = self;
        [self addDoneAndCancelToTextField:cell.captionTextView];
        
        return cell;
    } else if(self.selectedSeg == CommentsTabModeComments) {
        CommentViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CommentViewCell"];
        cell.commentTextLabel.delegate = self;
        Comment *comment = self.comments[indexPath.row - 1];
        
        cell.comment = comment;
        cell.usernameLabel.text = comment.commentUser.username;
        
        //Change color of @
        if(cell.comment.isReply && cell.comment.commentText.length > 0 && [[cell.comment.commentText substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"@"]) {
            int spaceIndex = -1;
            bool isShort = false;
            for(int i = 0; i < cell.comment.commentText.length; i++) {
                NSString *substring = [cell.comment.commentText substringWithRange:NSMakeRange(i, 1)];
                if([substring isEqualToString:@" "]) {
                    spaceIndex = i;
                    break;
                }
            }
            if(spaceIndex == -1) {
                spaceIndex = (int) cell.comment.commentText.length;
                isShort = true;
            }
            
            UIColor *color = [UIColor linkColor];
            NSDictionary *attrs = @{ NSForegroundColorAttributeName : color };
            UIColor *color2 = [UIColor whiteColor];
            NSDictionary *attrs2 = @{ NSForegroundColorAttributeName : color2 };
            NSAttributedString *nameStr = [[NSAttributedString alloc] initWithString:[cell.comment.commentText substringWithRange:NSMakeRange(0, spaceIndex)] attributes:attrs];
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
            [string appendAttributedString:nameStr];
            if(!isShort) {
                NSAttributedString *rest = [[NSAttributedString alloc] initWithString:[cell.comment.commentText substringWithRange:NSMakeRange(spaceIndex, cell.comment.commentText.length - spaceIndex)] attributes:attrs2];
                [string appendAttributedString:rest];
            }
            cell.commentTextLabel.attributedText = string;
            
            //Add clickable button to see profile
            NSRange range = [cell.comment.commentText rangeOfString:[cell.comment.commentText substringWithRange:NSMakeRange(0, spaceIndex)]];
            cell.commentTextLabel.selectedRange = range;
            UITextRange *textRange = [cell.commentTextLabel selectedTextRange];
            CGRect textRect = [cell.commentTextLabel firstRectForRange:textRange];
            CGRect convertedRect = [cell convertRect:textRect fromView:cell.commentTextLabel];

            UIButton *button = [[UIButton alloc]initWithFrame:convertedRect];
            [button setBackgroundColor:[UIColor clearColor]];
            [button addTarget:self action:@selector(textTapped:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
            [cell bringSubviewToFront:button];
        } else {
            cell.commentTextLabel.text = comment.commentText;
        }
        
        NSDate *date = self.piccy.createdAt;
        cell.timeLabel.text = [AppMethods dateToHMSString:date];
        
        cell.profileImage = [AppMethods roundImageView:cell.profileImage withURL:self.piccy.user[@"profilePictureURL"]];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
    } else { //when selected seg = 1
        ReactionViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ReactionViewCell"];
        PiccyReaction *reaction = self.reactions[indexPath.row];
        cell.nameLabel.text = reaction.user[@"name"];
        
        cell.reactionImage = [AppMethods roundImageView:cell.reactionImage withURL:reaction.reactionURL];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
    }
}

-(void) textTapped:(id) sender {
    CommentViewCell *content = (CommentViewCell *)[(UIView *) sender superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:content];
    Comment *comment = self.comments[indexPath.row-1];
    if(comment.replyingTo != nil) {
        PFQuery *query = [PFUser query];
        [query includeKey:@"username"];
        [query whereKey:@"username" equalTo:comment.replyingTo];
        [query setLimit:1];
        NSArray *userArray = [query findObjects];
        PFUser *replyingTo = userArray[0];
        self.segueUser = replyingTo;
        [self performSegueWithIdentifier:@"commentUserSegue" sender:nil];
    }
}

//User interaction is only enabled in the caption cell but double checking to make sure that is the one selected and enabling response
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0 && self.selectedSeg == CommentsTabModeComments) {
        CaptionViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.captionTextView.userInteractionEnabled = true;
        [cell.captionTextView becomeFirstResponder];
    }
}


//Text view delegate method to clear the text view when the user starts typing
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

//When the text view is done editing set the caption equal to the text if the editing wasnt canceled
- (void)textViewDidEndEditing:(UITextView *)textView {
    if(self.canceled == false) {
        self.piccy.caption = textView.text;
    } else {
        textView.text = self.piccy.caption;
    }
}

//Editing is not canceled if done is pressed
-(void) donePressedTextField {
    self.canceled = false;
    [self.view endEditing:true];
    [self saveCaption];
}

//Editing is canceled for the caption if the cancel button is pressed or the user scrolls away the keyboard
-(void) cancelPressedTextField {
    self.canceled = true;
    self.commentIsReply = false;
    [self.view endEditing:true];
}

//Saves the updated caption
-(void) saveCaption {
    [self.piccy saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil) {
            NSLog(@"saved new caption");
        } else {
            NSLog(@"could not save new caption");
        }
    }];
}

//Checks if the comment field was changed to update the add button to add the new caption
- (IBAction)commentTextFieldChanged:(id)sender {
    if([self.commentTextView.text isEqualToString:@""]) {
        self.commentAddButton.userInteractionEnabled = false;
        self.commentAddButton.tintColor = [UIColor lightGrayColor];
    } else {
        self.commentAddButton.userInteractionEnabled = true;
        self.commentAddButton.tintColor = [UIColor orangeColor];
    }
}



//Ends editing when done is pressed on the comment field
-(void) donePressedComment {
    [self.view endEditing:true];
}

//Sets up the menu when clicking the options menu button
-(void) setupMenu {
    //setting the default behavior of the button to this
    [self.optionsButton setShowsMenuAsPrimaryAction:YES];
    
    //Array of actions shown in the menu
    self.actions = [[NSMutableArray alloc] init];
    [self.actions addObject:[UIAction actionWithTitle:@"📝 Report Piccy"
                                           image:nil
                                      identifier:nil
                                         handler:^(__kindof UIAction* _Nonnull action) {
        
        [AppMethods reportPiccy:self.piccy onViewController:self];
    }]];
    
    PFUser *user = [PFUser currentUser];
    if([self.piccy.user.username isEqualToString:user.username]) {
        [self.actions addObject:[UIAction actionWithTitle:@"Delete Piccy"
                                               image:nil
                                          identifier:nil
                                             handler:^(__kindof UIAction* _Nonnull action) {
            [AppMethods deletePiccy:self.piccy];
            [self dismissViewControllerAnimated:true completion:nil];
        }]];
    }
    
    self.menu =
    [UIMenu menuWithTitle:@"Options"
                 children:self.actions];
    
    
    [self.optionsButton setMenu:self.menu];
}



//Changes the table view when the done button is pressed and the user currently has reactions selected
- (IBAction)commentButtonPressed:(id)sender {
    if(self.selectedSeg == CommentsTabModeReactions) {
        [AppMethods button:self.commentButton swapStateWithButton:self.reactionButton];
        self.selectedSeg = CommentsTabModeComments;
        self.noReactionLabel.alpha = 0;
        self.noReactionImage.alpha = 0;
        self.commentView.alpha = 1;
        self.commentAddButton.alpha = 1;
        self.commentTextView.alpha = 1;
        [self queryComments];
    }
    
}
- (IBAction)reactionButtonPressed:(id)sender {
    if(self.selectedSeg == CommentsTabModeComments) {
        [AppMethods button:self.reactionButton swapStateWithButton:self.commentButton];
        self.selectedSeg = CommentsTabModeReactions;
        self.noReactionLabel.alpha = 0;
        self.noReactionImage.alpha = 0;
        self.commentView.alpha = 0;
        self.commentAddButton.alpha = 0;
        self.commentTextView.alpha = 0;
        [self queryReactions:(int)[self.piccy[@"reactedUsernames"] count]];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"commentUserSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        OtherProfileViewController *otherProfile = (OtherProfileViewController*)navigationController.topViewController;
        NSLog(@"%@: %@, %@", self.segueUser, self.segueUser.username, self.segueUser[@"name"]);
        otherProfile.user = self.segueUser;
    }
}


@end
