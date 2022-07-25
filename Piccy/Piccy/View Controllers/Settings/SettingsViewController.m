//
//  SettingsViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/6/22.
//

#import "SettingsViewController.h"
#import "SettingsTableViewController.h"


@interface SettingsViewController () 
@property int rows;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
}

- (IBAction)backButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadProfile" object:nil];
    [self dismissViewControllerAnimated:true completion:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"settingsEmbed"]) {
        SettingsTableViewController *tableViewController = [segue destinationViewController];
        tableViewController.navbarLabel = self.settingsLabel;
    }
}


@end
