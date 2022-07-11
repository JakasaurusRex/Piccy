//
//  FriendsViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/7/22.
//

#import "FriendsViewController.h"
#import <Parse/Parse.h>
#import "FriendsViewCell.h"

@interface FriendsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
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
    self.searchBar.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFriends) name:@"loadFriends" object:nil];
    
    self.user = [PFUser currentUser];
    
    // Do any additional setup after loading the view.
    [self friendQuery:self.searchBar.text];
    [self.tableView reloadData];
}

-(void) loadFriends {
    if(self.segCtrl.selectedSegmentIndex == 1) {
        [self friendQuery:self.searchBar.text];
    } else if(self.segCtrl.selectedSegmentIndex == 2) {
        [self requestQuery:self.searchBar.text];
    }
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
    cell.cellUser = friend;
    cell.nameView.text = friend[@"name"];
    cell.usernameView.text = friend[@"username"];
    if(self.segCtrl.selectedSegmentIndex == 1) {
        [cell.friendButton setTitle:@"Remove" forState:UIControlStateNormal];
        cell.cellMode = 1;
    } else if (self.segCtrl.selectedSegmentIndex == 0) {
        [cell.friendButton setTitle:@"Add" forState:UIControlStateNormal];
        cell.cellMode = 0;
        if([self.user[@"friendRequestsArrayOutgoing"] containsObject:friend.username]) {
            cell.friendButton.tintColor = [UIColor systemTealColor];
            [cell.friendButton setTitle:@"Cancel" forState:UIControlStateNormal];
        }
    } else {
        [cell.friendButton setTitle:@"Accept" forState:UIControlStateNormal];
        cell.cellMode = 2;
    }
    return cell;
}

//Query for the friends list
-(void) friendQuery:(NSString *)container {
    // construct query
    PFQuery *query = [PFUser query];
    query.limit = [self.user[@"friendsArray"] count];
    [query includeKey:@"username"];
    [query whereKey:@"username" containedIn:self.user[@"friendsArray"]];
    [query includeKey:@"name"];
    // fetch data asynchronously
    if(![container isEqualToString:@""]) {
        //[query whereKey:@"username" containsString:container];
        [query whereKey:@"name" containsString:container];
    }
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

//query for the adding friends feaure
-(void) addQuery:(NSString *)container {
    // construct query
    [self.tableView reloadData];
    PFQuery *query = [PFUser query];
    query.limit = 50;
    [query includeKey:@"username"];
    [query whereKey:@"username" notContainedIn:self.user[@"friendsArray"]];
    [query whereKey:@"username" notEqualTo:self.user.username];
    if(![container isEqualToString:@""]) {
        [query whereKey:@"username" containsString:container];
    } else {
        [query whereKey:@"username" containedIn:self.user[@"friendRequestsArrayOutgoing"]];
    }
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

//Query for the friend requests tab
-(void) requestQuery:(NSString *)container {
    // construct query
    [self.tableView reloadData];
    PFQuery *query = [PFUser query];
    query.limit = 50;
    [query includeKey:@"username"];
    [query whereKey:@"username" notContainedIn:self.user[@"friendsArray"]];
    [query whereKey:@"username" notEqualTo:self.user.username];
    [query whereKey:@"username" containedIn:self.user[@"friendRequestsArrayIncoming"]];
    if(![container isEqualToString:@""]) {
        [query whereKey:@"username" containsString:container];
    }
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
        self.friends = nil;
        [self friendQuery:self.searchBar.text];
    } else if(self.segCtrl.selectedSegmentIndex == 0) {
        self.friends = nil;
        [self addQuery:self.searchBar.text];
    } else {
        self.friends = nil;
        [self requestQuery:self.searchBar.text];
    }
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    self.searchBar.showsCancelButton = YES;
}

//For searching for friends or new users
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if(self.segCtrl.selectedSegmentIndex == 1) {
        NSLog(@"%@", searchText);
        [self friendQuery:searchText];
        [self.tableView reloadData];
    } else if(self.segCtrl.selectedSegmentIndex == 0) {
        NSLog(@"%@", searchText);
        [self addQuery:searchText];
        [self.tableView reloadData];
    } else {
        NSLog(@"%@", searchText);
        [self requestQuery:searchText];
        [self.tableView reloadData];
    }
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
