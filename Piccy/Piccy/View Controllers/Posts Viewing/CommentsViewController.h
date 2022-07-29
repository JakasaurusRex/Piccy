//
//  CommentsViewController.h
//  Piccy
//
//  Created by Jake Torres on 7/19/22.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Piccy.h"


NS_ASSUME_NONNULL_BEGIN

@interface CommentsViewController : UIViewController
@property (nonatomic, strong) Piccy *piccy;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *reactionButton;
@property (nonatomic) bool isSelf;
@end

NS_ASSUME_NONNULL_END
