//
//  UserPiccyViewCell.h
//  Piccy
//
//  Created by Jake Torres on 7/18/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserPiccyViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *captionButton;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UIButton *postOptions;
@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *piccyButton;

@end

NS_ASSUME_NONNULL_END
