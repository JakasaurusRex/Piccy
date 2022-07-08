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
@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [PFUser currentUser];
    // Do any additional setup after loading the view.
}
- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self.user[@"friendsArray"] count] == 0) {
        return 1;
    }
    return [self.user[@"friendsArray"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendsViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"friendsCell"];
    
    return cell;
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
