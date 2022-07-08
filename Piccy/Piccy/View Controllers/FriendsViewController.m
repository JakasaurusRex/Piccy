//
//  FriendsViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/7/22.
//

#import "FriendsViewController.h"
#import <Parse/Parse.h>
#import "FriendsViewCell.h"

@interface FriendsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) PFUser *user;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segCtrl;
@property (nonatomic, strong) NSArray *friends;
@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    self.user = [PFUser currentUser];
    
    // Do any additional setup after loading the view.
    [self friendQuery];
    [self.tableView reloadData];
}
- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendsViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FriendsCell"];
    PFUser *friend = self.friends[indexPath.row];
    cell.nameView.text = friend[@"name"];
    cell.usernameView.text = friend[@"username"];
    if(self.segCtrl.selectedSegmentIndex == 1) {
        [cell.friendButton setTitle:@"Remove" forState:UIControlStateNormal];
    } else if (self.segCtrl.selectedSegmentIndex == 0) {
        [cell.friendButton setTitle:@"Add" forState:UIControlStateNormal];
        if([self.user[@"friendRequestsArrayOutgoing"] containsObject:friend.username]) {
            cell.friendButton.tintColor = [UIColor blueColor];
            [cell.friendButton setTitle:@"Cancel" forState:UIControlStateNormal];
        }
    } else {
        [cell.friendButton setTitle:@"Accept" forState:UIControlStateNormal];
    }
    return cell;
}

-(void) friendQuery {
    // construct query
    PFQuery *query = [PFUser query];
    query.limit = [self.user[@"friendsArray"] count];
    [query includeKey:@"username"];
    [query whereKey:@"username" containedIn:self.user[@"friendsArray"]]; //add more filters when searching for friends
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (friends != nil) {
            // do something with the array of object returned by the call
            self.friends = friends;
            NSLog(@"Received friends! %@", self.friends);
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

-(void) addQuery {
    // construct query
    PFQuery *query = [PFUser query];
    query.limit = [self.user[@"friendsArray"] count];
    [query includeKey:@"username"];
    [query whereKey:@"username" containedIn:self.user[@"friendsArray"]]; //add more filters when searching for friends
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (friends != nil) {
            // do something with the array of object returned by the call
            self.friends = friends;
            NSLog(@"Received friends! %@", self.friends);
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
    //Change the selected background view of the cell.
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
 }

- (IBAction)segChanged:(id)sender {
    if(self.segCtrl.selectedSegmentIndex == 1) {
        [self friendQuery];
    } else if(self.segCtrl.selectedSegmentIndex == 0) {
        [self addQuery];
    }
    [self.tableView reloadData];
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
