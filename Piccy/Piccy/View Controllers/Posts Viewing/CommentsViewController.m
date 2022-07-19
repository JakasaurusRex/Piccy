//
//  CommentsViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/19/22.
//

#import "CommentsViewController.h"
#import "CaptionViewCell.h"

@interface CommentsViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *optionsButton;
@property (nonatomic) bool canceled;

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
    
    self.canceled = false;
    self.title = self.piccy.username;
}

- (IBAction)backPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadHome" object:nil];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)optionsButtonPressed:(id)sender {
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
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
    }
    return nil;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
