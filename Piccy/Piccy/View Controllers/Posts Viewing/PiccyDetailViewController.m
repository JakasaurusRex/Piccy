//
//  PiccyDetailViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/21/22.
//

#import "PiccyDetailViewController.h"

@interface PiccyDetailViewController ()

@end

@implementation PiccyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.postImage.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:self.piccy.postGifUrl]];
    if(self.piccy.replyCount == 0) {
        self.commentLabel.text = @"";
    } else if(self.piccy.replyCount == 1) {
        self.commentLabel.text = [NSString stringWithFormat:@"1 comment"];
    } else {
        self.commentLabel.text = [NSString stringWithFormat:@"%d comments", self.piccy.replyCount];
    }
    
}

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
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
