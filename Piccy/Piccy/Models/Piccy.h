//
//  Piccy.h
//  Piccy
//
//  Created by Jake Torres on 7/12/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "UIImage+animatedGIF.h"

NS_ASSUME_NONNULL_BEGIN

@interface Piccy : PFObject<PFSubclassing>
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSString *postGifUrl;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSDate *resetDate;
@property (nonatomic, strong) NSString *timeSpent;
+ (void) postPiccy: ( NSString * _Nullable )postGifUrl withCaption: ( NSString * _Nullable )caption withDate:(NSDate *) resetDate withTime:(NSString *) time withCompletion: (PFBooleanResultBlock  _Nullable)completion;
@end

NS_ASSUME_NONNULL_END
