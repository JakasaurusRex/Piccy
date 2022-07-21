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
    
    self.commentIsReply = false;
    
    [self queryComments];
    self.commentAddButton.userInteractionEnabled = false;
    self.commentAddButton.tintColor = [UIColor lightGrayColor];
    
    self.canceled = false;
    self.title = self.piccy.username;
    
    [self addDoneToField:self.commentTextView];
    
    if(self.isSelf == false) {
        [self.tableView setAllowsSelection:NO];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];

    
}

- (void)keyboardWillChange:(NSNotification *)notification {
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboard = [self.view convertRect:keyboardRect fromView:nil]; //this is it!
    [UIView animateWithDuration:0.25 animations:^
     {
         CGRect newFrame = [self.commentTextView frame];
        newFrame.origin.y -= self.keyboard.size.height; // tweak here to adjust the moving position
         [self.commentTextView setFrame:newFrame];

     }completion:^(BOOL finished)
     {

     }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)replyPressed:(id)sender {
    UIView *content = (UIView *)[(UIView *) sender superview];
    CommentViewCell *cell = (CommentViewCell *)[content superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Comment *comment = self.comments[indexPath.row];
    self.commentTextView.text = [NSString stringWithFormat:@"@%@",comment.commentUser.username];
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
    return 1 + [self.comments count];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        CaptionViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CaptionViewCell"];
        cell.usernameLabel.text = self.piccy.username;
        
        cell.profileImage.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:self.piccy.user[@"profilePictureURL"]]];
        cell.profileImage.layer.masksToBounds = false;
        cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.size.width/2;
        cell.profileImage.clipsToBounds = true;
        cell.profileImage.contentMode = UIViewContentModeScaleAspectFill;
        cell.profileImage.layer.borderWidth = 0.05;
        
        if([self.piccy.caption isEqualToString:@""]) {
            cell.captionTextView.text = @"Add a caption...";
            cell.captionTextView.textColor = [UIColor lightGrayColor];
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
    } else {
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
    [UIView animateWithDuration:0.25 animations:^
     {
         CGRect newFrame = [self.commentTextView frame];
         newFrame.origin.y += self.keyboard.size.height; // tweak here to adjust the moving position
         [self.commentTextView setFrame:newFrame];

     }completion:^(BOOL finished)
     {

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
