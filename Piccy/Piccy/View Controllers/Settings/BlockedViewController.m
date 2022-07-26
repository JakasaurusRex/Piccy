//
//  BlockedViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/26/22.
//

#import "BlockedViewController.h"
#import <Parse/Parse.h>
#import "BlockedViewCell.h"

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
    [self unblockUser:cell.blockedUser];
}

//called functon when the user clicks the unblock button, called in the action method
-(void) unblockUser: (PFUser *)user{
    NSMutableArray *blockedUsers = [[NSMutableArray alloc] initWithArray:self.user[@"blockedUsers"]];
    [blockedUsers removeObject:user.username];
    self.user[@"blockedUsers"] = [[NSArray alloc] initWithArray:blockedUsers];
    [self postUser:self.user];
    
    blockedUsers = [[NSMutableArray alloc] initWithArray:user[@"blockedByArray"]];
    [blockedUsers removeObject:self.user.username];
    user[@"blockedByArray"] = [[NSArray alloc] initWithArray:blockedUsers];
    [self postOtherUser:user];
    
    [self.tableView reloadData];
    
}

//Changes the current user of the app and reloads the table view
-(void) postUser:(PFUser *)user {
    __weak __typeof(self) weakSelf = self;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil) {
            __strong __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                   return;
           }
            NSLog(@"Unblocked user");
            [strongSelf.tableView reloadData];
        } else {
            NSLog(@"Error changing unblocking user: %@", error);
        }
    }];
}

//Calls cloud function in Parse that changes the other user for me using a master key. this was becasue parse cannot save other users without them being logged in
-(void) postOtherUser:(PFUser *)otherUser {
    //creating a parameters dictionary with all the items in the user that need to be changed and saved
    NSMutableDictionary *paramsMut = [[NSMutableDictionary alloc] init];
    [paramsMut setObject:otherUser.username forKey:@"username"];
    [paramsMut setObject:otherUser[@"blockedByArray"] forKey:@"blockedByArray"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsMut];
    //calling the function in the parse cloud code
    [PFCloud callFunctionInBackground:@"saveOtherUser" withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
        if(!error) {
            NSLog(@"Saving other user worked");
        } else {
            NSLog(@"Error saving other user: %@", error);
        }
    }];
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
