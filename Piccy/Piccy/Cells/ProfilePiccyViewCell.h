//
//  ProfilePiccyViewCell.h
//  Piccy
//
//  Created by Jake Torres on 7/20/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProfilePiccyViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UILabel *piccyLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *piccyButton;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *visualEffect;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end

NS_ASSUME_NONNULL_END
