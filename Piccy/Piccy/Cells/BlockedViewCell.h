//
//  BlockedViewCell.h
//  Piccy
//
//  Created by Jake Torres on 7/26/22.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface BlockedViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) PFUser *blockedUser;
@end

NS_ASSUME_NONNULL_END
