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
}

- (IBAction)backButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadHome" object:nil];
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
