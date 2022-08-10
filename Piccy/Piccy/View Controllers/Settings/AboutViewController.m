//
//  AboutViewController.m
//  Piccy
//
//  Created by Jake Torres on 8/10/22.
//

#import "AboutViewController.h"
#import <Parse/Parse.h>

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PFUser *currentUser = [PFUser currentUser];
    if([currentUser[@"darkMode"] isEqual:@(YES)])
        self.view.backgroundColor = [UIColor blackColor];
    else
        self.view.backgroundColor = [UIColor systemBackgroundColor];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
