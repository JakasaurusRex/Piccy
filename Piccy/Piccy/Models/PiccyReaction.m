//
//  PiccyReaction.m
//  Piccy
//
//  Created by Jake Torres on 7/29/22.
//

#import "PiccyReaction.h"

@implementation PiccyReaction
@dynamic user;
@dynamic piccy;
@dynamic username;
@dynamic reactionURL;
@dynamic createdAt;

+ (nonnull NSString *)parseClassName {
    return @"PiccyReaction";
}

+ (void) postReaction: (NSString *) reactionURL onPiccy:(Piccy *) piccy withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    PiccyReaction *newReaction = [PiccyReaction new];
    newReaction.user = [PFUser currentUser];
    newReaction.piccy = piccy;
    newReaction.username = newReaction.user.username;
    newReaction.reactionURL = reactionURL;
    
    [newReaction saveInBackgroundWithBlock: completion];
}
@end
