//
//  PostViewController.h
//  Piccy
//
//  Created by Jake Torres on 7/15/22.
//

#import <UIKit/UIKit.h>
#import "PiccyLoop.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostViewController : UIViewController
@property (nonatomic, strong) NSString *piccyUrl;
@property (nonatomic, strong) NSString *timer;
@property (nonatomic, strong) PiccyLoop *piccyLoop;
@end

NS_ASSUME_NONNULL_END
