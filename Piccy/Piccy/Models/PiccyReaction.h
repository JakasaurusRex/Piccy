//
//  PiccyReaction.h
//  Piccy
//
//  Created by Jake Torres on 7/29/22.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>
#import "Piccy.h"

NS_ASSUME_NONNULL_BEGIN

@interface PiccyReaction : PFObject<PFSubclassing>
@property (nonatomic, strong) Piccy *piccy;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSString *reactionURL;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSString *username;
+ (void) postReaction: (NSString *) reactionURL onPiccy:(Piccy *) piccy withCompletion: (PFBooleanResultBlock  _Nullable)completion;
@end

NS_ASSUME_NONNULL_END
