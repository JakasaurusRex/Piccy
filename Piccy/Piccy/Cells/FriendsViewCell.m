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
    //if the seg controller is set to add then we configure the cell based on that
    if(self.cellMode == 0) {
        //the users in teh add tab can be requested or the request by the app user can be canceled
        if([user[@"friendRequestsArrayOutgoing"] containsObject:self.cellUser.username]) {
            NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithArray:user[@"friendRequestsArrayOutgoing"]];
            [mutableArr removeObject:self.cellUser.username];
            user[@"friendRequestsArrayOutgoing"] = [NSArray arrayWithArray:mutableArr];
            
            mutableArr = [NSMutableArray arrayWithArray:self.cellUser[@"friendRequestsArrayIncoming"]];
            [mutableArr removeObject:user.username];
            self.cellUser[@"friendRequestsArrayIncoming"] = [NSArray arrayWithArray:mutableArr];
            
            [self postOtherUser:self.cellUser];
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
            [self postOtherUser:self.cellUser];
            
            [self updateLabels];
        }
    } else if(self.cellMode == 1) {
        //in the friends tab you can unfriend your friends by removing them
        NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithArray:user[@"friendsArray"]];
        [mutableArr removeObject:self.cellUser.username];
        user[@"friendsArray"] = [NSArray arrayWithArray:mutableArr];
        
        mutableArr = [NSMutableArray arrayWithArray:self.cellUser[@"friendsArray"]];
        [mutableArr removeObject:user.username];
        self.cellUser[@"friendsArray"] = [NSArray arrayWithArray:mutableArr];
        
        [self postOtherUser:self.cellUser];
        [self postUser:user];
        [self updateLabels];
        
    } else if(self.cellMode == 2) {
        //in the requests tab you can accept friend requests.
        NSMutableArray *requests = [[NSMutableArray alloc] initWithArray:user[@"friendRequestsArrayIncoming"]];
        NSMutableArray *friends = [[NSMutableArray alloc] initWithArray:user[@"friendsArray"]];
        
        [requests removeObject:self.cellUser.username];
        [friends addObject:self.cellUser.username];
        
        user[@"friendRequestsArrayIncoming"] = [NSArray arrayWithArray:requests];
        user[@"friendsArray"] = [NSArray arrayWithArray:friends];
        
        requests = [[NSMutableArray alloc] initWithArray:self.cellUser[@"friendRequestsArrayOutgoing"]];
        friends = [[NSMutableArray alloc] initWithArray:self.cellUser[@"friendsArray"]];
        
        [requests removeObject:user.username];
        [friends addObject:user.username];
        
        self.cellUser[@"friendRequestsArrayOutgoing"] = requests;
        self.cellUser[@"friendsArray"] = friends;
        
        [self postUser:user];
        [self postOtherUser:self.cellUser];
        
        
        [self updateLabels];
        
    }
}

//Calls cloud function in Parse that changes the other user for me using a master key. this was becasue parse cannot save other users without them being logged in
-(void) postOtherUser:(PFUser *)otherUser {
    //creating a parameters dictionary with all the items in the user that need to be changed and saved
    NSMutableDictionary *paramsMut = [[NSMutableDictionary alloc] init];
    [paramsMut setObject:otherUser.username forKey:@"username"];
    [paramsMut setObject:otherUser[@"friendsArray"] forKey:@"friendsArray"];
    [paramsMut setObject:otherUser[@"friendRequestsArrayIncoming"] forKey:@"friendRequestsArrayIncoming"];
    [paramsMut setObject:otherUser[@"friendRequestsArrayOutgoing"] forKey:@"friendRequestsArrayOutgoing"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsMut];
    //calling the function in the parse cloud code
    [PFCloud callFunctionInBackground:@"saveOtherUser" withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
        if(!error) {
            NSLog(@"Saving other user worked with mode: %d", self.cellMode);
        } else {
            NSLog(@"Error saving other user with mode: %d", self.cellMode);
        }
    }];
}


//Changes the current user of the app
-(void) postUser:(PFUser *)user {
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil) {
            NSLog(@"Friend status changed mode: %d", self.cellMode);
        } else {
            NSLog(@"Error changing friend status");
        }
    }];
}


//updates the labels of the items in the cell based on the user action
-(void) updateLabels {
    if(self.cellMode == 0) {
        //if the they are in outgoing, the user can cancel the friend reqeust
        if([PFUser.currentUser[@"friendRequestsArrayOutgoing"] containsObject:self.cellUser.username]) {
            self.friendButton.tintColor = [UIColor systemTealColor];
            [self.friendButton setTitle:@"Cancel" forState:UIControlStateNormal];
        } else {
            //otherwise they can add them in the add tab
            self.friendButton.tintColor = [UIColor orangeColor];
            [self.friendButton setTitle:@"Add" forState:UIControlStateNormal];
        }
    } else if(self.cellMode == 1) {
        //calls function in friends view controller so that cells get removed or added from the list if they are removed or accepted as friends
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadFriends" object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadFriends" object:nil];
    }
   
}

@end
