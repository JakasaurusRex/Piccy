//
//  PostViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/15/22.
//

#import "PostViewController.h"
#import <Parse/Parse.h>
#import "UIImage+animatedGIF.h"
#import "Piccy.h"

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
    
    self.piccyLabel.text = [NSString stringWithFormat:@"Daily Piccy: %@", self.piccyLoop.dailyWord];
    self.timeLabel.text = self.timer;
    self.piccyImage.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:self.piccyUrl]];
    self.piccyImage.layer.masksToBounds = false;
    self.piccyImage.layer.cornerRadius =  self.piccyImage.bounds.size.width/12;
    self.piccyImage.clipsToBounds = true;
    self.piccyImage.contentMode = UIViewContentModeScaleAspectFill;
    self.piccyImage.layer.borderWidth = 0.05;
    
    self.postButton.tintColor = [UIColor orangeColor];
}

- (IBAction)postPressed:(id)sender {
    [self postPiccy];
    [self dismissViewControllerAnimated:true completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goHome" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadHome" object:nil];
}

-(void) postPiccy {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
