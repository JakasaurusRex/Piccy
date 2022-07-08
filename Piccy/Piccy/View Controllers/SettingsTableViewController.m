//
//  SettingsTableViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/7/22.
//

#import "SettingsTableViewController.h"
#import <Parse/Parse.h>

@interface SettingsTableViewController ()


@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    //self.tableView.backgroundColor = [UIColor colorWithRed:(23/255.0f) green:(23/255.0f) blue:(23/255.0f) alpha:1];
    //If the user is coming back from the profile editing page call this method to update the profile
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadSettings) name:@"loadSettings" object:nil];
    
    [self loadSettings];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) loadSettings {
    
    PFUser *user = [PFUser currentUser];
    self.username.text = user[@"username"];
    self.name.text = user[@"name"];
    
    if([PFUser.currentUser[@"darkMode"] boolValue] == YES) {
        [self.darkModeSwitch setOn:YES animated:YES];
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
        self.navbarLabel.textColor = [UIColor whiteColor];
    } else {
        [self.darkModeSwitch setOn:NO animated:YES];
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
        self.navbarLabel.textColor = [UIColor blackColor];
    }
    
}

- (IBAction)switchFlip:(id)sender {
    PFUser *user = [PFUser currentUser];
    NSLog(@"swtich changed");
    if([sender isOn]) {
        user[@"darkMode"] = @(YES);
    } else {
        user[@"darkMode"] = @(NO);
    }
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil) {
            NSLog(@"Dark mode changed");
        } else {
            NSLog(@"Error changing dark mode");
        }
    }];
    [self loadSettings];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0 && indexPath.section == 3) {
        [self logoutUser];
    }
    //Fade out highlighting of cell
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



//Called when user clicks on the logout button
-(void) logoutUser {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if(error != nil) {
            NSLog(@"rip cant logout: %@", error);
        } else {
            NSLog(@"User logged out successfully");
            // display view controller that needs to shown after successful login
            [self performSegueWithIdentifier:@"logoutSegue" sender:nil];
        }
    }];
}

//Code to make the seperator the full length of the cell
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    cell.tintColor = [UIColor whiteColor];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }

    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
