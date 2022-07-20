//
//  CommentViewCell.h
//  Piccy
//
//  Created by Jake Torres on 7/20/22.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

NS_ASSUME_NONNULL_BEGIN

@interface CommentViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextView *commentTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (strong, nonatomic) Comment *comment;
@end

NS_ASSUME_NONNULL_END
