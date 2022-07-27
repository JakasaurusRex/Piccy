//
//  FriendsViewCell.h
//  Piccy
//
//  Created by Jake Torres on 7/8/22.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface FriendsViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *usernameView;
@property (weak, nonatomic) IBOutlet UIButton *friendButton;
@property (strong, nonatomic) PFUser *cellUser;
@property (weak, nonatomic) IBOutlet UIButton *denyFriendRequestButton;
@property (weak, nonatomic) IBOutlet UILabel *foundInContacts;
@property (nonatomic) int cellMode; // 0 is add, 1 is friend, 2 is a friend request
@end

NS_ASSUME_NONNULL_END
