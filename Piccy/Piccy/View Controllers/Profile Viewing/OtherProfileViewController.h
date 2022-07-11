//
//  OtherProfileViewController.h
//  Piccy
//
//  Created by Jake Torres on 7/11/22.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface OtherProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (nonatomic, strong) PFUser *user;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *bio;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@end

NS_ASSUME_NONNULL_END
