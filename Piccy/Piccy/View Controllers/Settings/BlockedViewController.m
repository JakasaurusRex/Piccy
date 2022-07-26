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

@end

@implementation BlockedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [PFUser currentUser];
    // Do any additional setup after loading the view.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.user[@"blockedUsers"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BlockedViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BlockedViewCell"];
    
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
