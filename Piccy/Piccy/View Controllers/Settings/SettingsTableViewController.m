//
//  SettingsTableViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/7/22.
//

#import "SettingsTableViewController.h"
#import <Parse/Parse.h>
#import "UIImage+animatedGIF.h"
#import "MagicalEnums.h"
#import "AppMethods.h"
@import BonsaiController;

@interface SettingsTableViewController () <BonsaiControllerDelegate>
@property (nonatomic) int direction;
@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Sliding segue
    self.direction = SegueDirectionsFromBottom;
    
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
    NSLog(@"%@", user[@"darkMode"]);
    if(![user[@"darkMode"] isEqual:@(NO)]) {
        [self.darkModeSwitch setOn:YES animated:YES];
        self.view.backgroundColor = [UIColor blackColor];
        self.navbarLabel.textColor = [UIColor labelColor];
    } else {
        [self.darkModeSwitch setOn:NO animated:YES];
        self.navbarLabel.textColor = [UIColor labelColor];
        self.view.backgroundColor = [UIColor secondarySystemBackgroundColor];
    }
    
    if([user[@"privateAccount"] boolValue] == YES) {
        [self.privateAccountSwitch setOn:YES animated:YES];
    } else {
        [self.privateAccountSwitch setOn:NO animated:YES];
    }
    
    self.profilePicture = [AppMethods roundImageView:self.profilePicture withURL:user[@"profilePictureURL"]];
    
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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loadNav" object:nil];
            [self loadSettings];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loadProfile" object:nil];
        } else {
            NSLog(@"Error changing dark mode");
        }
    }];
    
}

- (IBAction)switchPrivateAccountSwitch:(id)sender {
    PFUser *user = [PFUser currentUser];
    NSLog(@"swtich changed");
    if([sender isOn]) {
        user[@"privateAccount"] = @(YES);
    } else {
        user[@"privateAccount"] = @(NO);
    }
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil) {
            NSLog(@"Privacy mode changed");
        } else {
            NSLog(@"Error changing privacy mode");
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
    } else if(indexPath.section == 2) {
        UIViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutVC"];
        [self.navigationController pushViewController:nav animated:YES];
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
    
    PFUser *user = [PFUser currentUser];
    if([user[@"darkMode"] boolValue]) {
        cell.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        cell.backgroundColor = [UIColor systemBackgroundColor];
    }
    //cell.tintColor = [UIColor whiteColor];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"settingsTableSegue"]) {
        self.direction = SegueDirectionsFromRight;
        segue.destinationViewController.transitioningDelegate = self;
        segue.destinationViewController.modalPresentationStyle = UIModalPresentationCustom;
    } else if([segue.identifier isEqualToString:@"blockSegue"]) {
        self.direction = SegueDirectionsFromRight;
        segue.destinationViewController.transitioningDelegate = self;
        segue.destinationViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
}


// MARK:- Bonsai Controller Delegate
- (CGRect)frameOfPresentedViewIn:(CGRect)containerViewFrame {
    if(self.direction == SegueDirectionsFromBottom) {
        return CGRectMake(0, containerViewFrame.size.height / 4, containerViewFrame.size.width, containerViewFrame.size.height / (4.0 / 3.0));
    }
    return CGRectMake(0, 0, containerViewFrame.size.width, containerViewFrame.size.height);
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    if(self.direction == SegueDirectionsFromBottom) {
        // Slide animation from .left, .right, .top, .bottom
        return [[BonsaiController alloc] initFromDirection:DirectionBottom blurEffectStyle:UIBlurEffectStyleSystemUltraThinMaterialDark presentedViewController:presented delegate:self];
    } else if(self.direction == SegueDirectionsFromLeft) {
        return [[BonsaiController alloc] initFromDirection:DirectionLeft blurEffectStyle:UIBlurEffectStyleSystemUltraThinMaterialDark presentedViewController:presented delegate:self];
    } else if(self.direction == SegueDirectionsFromTop) {
        return [[BonsaiController alloc] initFromDirection:DirectionTop blurEffectStyle:UIBlurEffectStyleSystemUltraThinMaterialDark presentedViewController:presented delegate:self];
    } else {
        return [[BonsaiController alloc] initFromDirection:DirectionRight blurEffectStyle:UIBlurEffectStyleSystemUltraThinMaterialDark presentedViewController:presented delegate:self];
    }
    
}


@end
