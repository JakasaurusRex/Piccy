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
            
            mutableArr = [NSMutableArray arrayWithArray:self.cellUser[@"friendRequestsArrayIncoming"]];
            [mutableArr removeObject:user.username];
            self.cellUser[@"friendRequestsArrayIncoming"] = [NSArray arrayWithArray:mutableArr];
            
            [self postUser:self.cellUser];
            [self postUser:user];
            [self updateLabels];
        } else {
            NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithArray:user[@"friendRequestsArrayOutgoing"]];
            [mutableArr addObject:self.cellUser.username];
            user[@"friendRequestsArrayOutgoing"] = [NSArray arrayWithArray:mutableArr];
            
            mutableArr = [NSMutableArray arrayWithArray:self.cellUser[@"friendRequestsArrayIncoming"]];
            [mutableArr addObject:user.username];
            self.cellUser[@"friendRequestsArrayIncoming"] = [NSArray arrayWithArray:mutableArr];
            NSLog(@"FRIEND REQUESTED: %@", self.cellUser[@"friendRequestsArrayIncoming"]);
            
            [self postUser:user];
            [self postUser:self.cellUser];
            
            [self updateLabels];
        }
    } else if(self.cellMode == 1) {
        NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithArray:user[@"friendsArray"]];
        [mutableArr removeObject:self.cellUser.username];
        user[@"friendsArray"] = [NSArray arrayWithArray:mutableArr];
        
        mutableArr = [NSMutableArray arrayWithArray:self.cellUser[@"friendsArray"]];
        [mutableArr removeObject:user.username];
        self.cellUser[@"friendsArray"] = [NSArray arrayWithArray:mutableArr];
        
        [self postUser:self.cellUser];
        [self postUser:user];
        [self updateLabels];
    } else if(self.cellMode == 2) {
        NSMutableArray *requests = [[NSMutableArray alloc] initWithArray:user[@"friendRequestsArrayIncoming"]];
        NSMutableArray *friends = [[NSMutableArray alloc] initWithArray:user[@"friendsArray"]];
        
        [requests removeObject:self.cellUser.username];
        [friends addObject:self.cellUser.username];
        user[@"friendRequestArrayIncoming"] = [NSArray arrayWithArray:requests];
        user[@"friendsArray"] = [NSArray arrayWithArray:friends];
        
        requests = [NSMutableArray arrayWithArray:self.cellUser[@"friendRequestsArrayOutgoing"]];
        friends = [NSMutableArray arrayWithArray:self.cellUser[@"friendsArray"]];
        
        [requests removeObject:user.username];
        [friends addObject:user.username];
        
        [self postUser:user];
        [self postUser:self.cellUser];
        
        
        [self updateLabels];
        
    }
}

-(void) postOtherUser:(PFUSer *)otherUser {
    
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
    } else if(self.cellMode == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadFriends" object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadFriends" object:nil];
    }
   
}

@end
