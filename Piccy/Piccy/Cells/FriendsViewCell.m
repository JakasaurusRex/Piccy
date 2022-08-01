//
//  FriendsViewCell.m
//  Piccy
//
//  Created by Jake Torres on 7/8/22.
//

#import "FriendsViewCell.h"
#import "MagicalEnums.h"
#import "AppMethods.h"

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
    //if the seg controller is set to add then we configure the cell based on that
    if(self.cellMode == FriendTabModeAddFriends) {
        //the users in teh add tab can be requested or the request by the app user can be canceled
        if([user[@"friendRequestsArrayOutgoing"] containsObject:self.cellUser.username]) {
            [AppMethods sendFriendRequestOnUser:self.cellUser];
            [self updateLabels];
        } else {
            [AppMethods cancelFriendRequestOnUser:self.cellUser];
            [self updateLabels];
        }
    } else if(self.cellMode == FriendTabModeUserFriends) {
        //in the friends tab you can unfriend your friends by removing them
        [AppMethods removeFriendUser:self.cellUser];
        [self updateLabels];
        
    } else if(self.cellMode == FriendTabModeFriendRequests) {
        //in the requests tab you can accept friend requests.
        [AppMethods addFriendUser:self.cellUser];
        [self updateLabels];
        
    }
}

- (IBAction)denyFriendRequestButton:(id)sender {
    //Denying a friend request
    [AppMethods denyFriendRequestFromUser:self.cellUser];
    [self updateLabels];
}


//updates the labels of the items in the cell based on the user action
-(void) updateLabels {
    if(self.cellMode == FriendTabModeAddFriends) {
        //if the they are in outgoing, the user can cancel the friend reqeust
        if([PFUser.currentUser[@"friendRequestsArrayOutgoing"] containsObject:self.cellUser.username]) {
            self.friendButton.tintColor = [UIColor systemTealColor];
            [self.friendButton setTitle:@"Cancel" forState:UIControlStateNormal];
        } else {
            //otherwise they can add them in the add tab
            self.friendButton.tintColor = [UIColor systemIndigoColor];
            [self.friendButton setTitle:@"Add" forState:UIControlStateNormal];
        }
    } else if(self.cellMode == FriendTabModeUserFriends) {
        //calls function in friends view controller so that cells get removed or added from the list if they are removed or accepted as friends
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadFriends" object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadFriends" object:nil];
    }
    PFUser *appUser = [PFUser currentUser];
    if([appUser[@"friendRequestsArrayIncoming"] containsObject:self.cellUser.username]) {
        [self.denyFriendRequestButton setUserInteractionEnabled:YES];
        [self.denyFriendRequestButton setAlpha:1];
    } else {
        [self.denyFriendRequestButton setUserInteractionEnabled:NO];
        [self.denyFriendRequestButton setAlpha:0];
    }
   
}

@end
