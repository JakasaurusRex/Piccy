//
//  BlockedViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/26/22.
//

#import "BlockedViewController.h"
#import <Parse/Parse.h>
#import "BlockedViewCell.h"
#import "AppMethods.h"

@interface BlockedViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSArray *blockedUsers;
@end

@implementation BlockedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.allowsSelection = false;
    self.user = [PFUser currentUser];
    // Do any additional setup after loading the view.
    [self queryBlockedUsers];
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

//Querys for users in the blocked users list of the current app user
-(void) queryBlockedUsers {
    PFQuery *query = [PFUser query];
    query.limit = [self.user[@"blockedUsers"] count];
    [query includeKey:@"username"];
    [query whereKey:@"username" containedIn:self.user[@"blockedUsers"]];
    __weak __typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
               return;
       }
        if(error == nil) {
            strongSelf.blockedUsers = objects;
            NSLog(@"blocked users retrived: %@", objects);
            [strongSelf.tableView reloadData];
        } else {
            NSLog(@"Error loading blocked users: %@", error);
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.blockedUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BlockedViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BlockedViewCell"];
    PFUser *blockedUser = self.blockedUsers[indexPath.row];
    cell.username.text = blockedUser.username;
    cell.name.text = blockedUser[@"name"];
    cell.blockedUser = blockedUser;
    return cell;
}

- (IBAction)blockButtonPressed:(id)sender {
    BlockedViewCell *cell = (BlockedViewCell *)[(UIView *)[(UIView *)sender superview] superview];
    [AppMethods unblockUser:cell.blockedUser];
    [self queryBlockedUsers];
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
