//
//  DailyPiccyViewController.h
//  Piccy
//
//  Created by Jake Torres on 7/15/22.
//

#import <UIKit/UIKit.h>
#import "PiccyLoop.h"
#import "Piccy.h"

NS_ASSUME_NONNULL_BEGIN

@interface DailyPiccyViewController : UIViewController
@property (nonatomic, strong) PiccyLoop *piccyLoop;
@property (nonatomic) bool isReaction;
@property (nonatomic, strong) Piccy *piccy;
@end

NS_ASSUME_NONNULL_END
