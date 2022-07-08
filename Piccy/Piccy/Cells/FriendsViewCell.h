//
//  FriendsViewCell.h
//  Piccy
//
//  Created by Jake Torres on 7/8/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FriendsViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *usernameView;
@property (weak, nonatomic) IBOutlet UIButton *friendButton;

@end

NS_ASSUME_NONNULL_END
