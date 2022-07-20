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
@property (nonatomic) bool isSelf;
@end

NS_ASSUME_NONNULL_END
