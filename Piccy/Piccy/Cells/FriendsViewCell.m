//
//  FriendsViewCell.m
//  Piccy
//
//  Created by Jake Torres on 7/8/22.
//

#import "FriendsViewCell.h"

@implementation FriendsViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)friendButtonPressed:(id)sender {
    PFUser *user = [PFUser currentUser];
    if(self.cellMode == 0) {
        if([user[@"friendRequestsArrayOutgoing"] containsObject:self.cellUser.username]) {
            NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithArray:user[@"friendRequestsArrayOutgoing"]];
            [mutableArr removeObject:self.cellUser.username];
            user[@"friendRequestsArrayOutgoing"] = [NSArray arrayWithArray:mutableArr];
            [self postUser:user];
            [self updateLabels];
        } else {
            NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithArray:user[@"friendRequestsArrayOutgoing"]];
            [mutableArr addObject:self.cellUser.username];
            user[@"friendRequestsArrayOutgoing"] = [NSArray arrayWithArray:mutableArr];
            [self postUser:user];
            [self updateLabels];
        }
    } else if(self.cellMode == 1) {
        
    }
}

-(void) postUser:(PFUser *)user {
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil) {
            NSLog(@"Friend status changed mode: %d", self.cellMode);
        } else {
            NSLog(@"Error changing friend status");
        }
    }];
}

-(void) updateLabels {
    if(self.cellMode == 0) {
        if([PFUser.currentUser[@"friendRequestsArrayOutgoing"] containsObject:self.cellUser.username]) {
            self.friendButton.tintColor = [UIColor systemTealColor];
            [self.friendButton setTitle:@"Cancel" forState:UIControlStateNormal];
        } else {
            self.friendButton.tintColor = [UIColor orangeColor];
            [self.friendButton setTitle:@"Add" forState:UIControlStateNormal];
        }
    }
   
}

@end
