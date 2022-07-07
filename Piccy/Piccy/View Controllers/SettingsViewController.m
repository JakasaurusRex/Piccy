//
//  SettingsViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/6/22.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property int rows;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
    // Do any additional setup after loading the view.
}

- (IBAction)backButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadProfile" object:nil];
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
