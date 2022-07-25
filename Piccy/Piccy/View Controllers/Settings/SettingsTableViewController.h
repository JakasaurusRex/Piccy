//
//  SettingsTableViewController.h
//  Piccy
//
//  Created by Jake Torres on 7/7/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingsTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UISwitch *darkModeSwitch;
@property (strong, nonatomic) UILabel *navbarLabel;
@property (weak, nonatomic) IBOutlet UISwitch *privateAccountSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@end

NS_ASSUME_NONNULL_END
