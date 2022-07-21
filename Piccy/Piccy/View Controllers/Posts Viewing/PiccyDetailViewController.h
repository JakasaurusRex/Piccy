//
//  PiccyDetailViewController.h
//  Piccy
//
//  Created by Jake Torres on 7/21/22.
//

#import <UIKit/UIKit.h>
#import "Piccy.h"

NS_ASSUME_NONNULL_BEGIN

@interface PiccyDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (nonatomic, strong) Piccy *piccy;
@end

NS_ASSUME_NONNULL_END
