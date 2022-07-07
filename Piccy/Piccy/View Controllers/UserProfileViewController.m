//
//  UserProfileViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/6/22.
//

#import "UserProfileViewController.h"
#import <Parse/Parse.h>

@interface UserProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *nameView;
@property (weak, nonatomic) IBOutlet UILabel *usernameView;
@property (weak, nonatomic) IBOutlet UILabel *bioView;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
    // Do any additional setup after loading the view.
    PFUser *user = [PFUser currentUser];
    self.nameView.text = user[@"name"];
    self.usernameView.text = user[@"username"];
    self.bioView.text = user[@"bio"];
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
