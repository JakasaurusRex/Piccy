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
    NSLog(@"%lu", [self.user[@"friendsArray"] count]);
    [self query];
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
    return cell;
}

-(void) query {
    // construct query
    PFQuery *query = [PFUser query];
    [query orderByDescending:@"createdAt"];
    query.limit = 20; //[self.user[@"friendsArray"] count];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
