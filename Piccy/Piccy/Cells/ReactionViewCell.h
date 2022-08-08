//
//  ReactionViewCell.h
//  Piccy
//
//  Created by Jake Torres on 7/29/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReactionViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *reactionImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *nameButton;

@end

NS_ASSUME_NONNULL_END
