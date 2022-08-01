//
//  Piccy.m
//  Piccy
//
//  Created by Jake Torres on 7/12/22.
//

#import "Piccy.h"

@implementation Piccy
@dynamic caption;
@dynamic user;
@dynamic postGifUrl;
@dynamic resetDate;
@dynamic timeSpent;
@dynamic username;
@dynamic replyCount;
@dynamic discoverable;
@dynamic objectId;
@dynamic reactedUsernames;

+ (nonnull NSString *)parseClassName {
    return @"Piccy";
}

+ (void) postPiccy: ( NSString * _Nullable )postGifUrl withCaption: ( NSString * _Nullable )caption withDate: (NSDate *) date withTime:(NSString *) time withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Piccy *newPiccy = [Piccy new];
    
    newPiccy.caption = caption;
    newPiccy.postGifUrl = postGifUrl;
    PFUser *user = [PFUser currentUser];
    newPiccy.user = user;
    newPiccy.resetDate = date;
    newPiccy.timeSpent = time;
    newPiccy.username = user.username;
    newPiccy.replyCount = 0;
    user[@"postedToday"] = @(YES);
    
    if([user[@"privateAccount"] boolValue] == YES) {
        newPiccy.discoverable = NO;
    } else {
        newPiccy.discoverable = YES;
    }
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil)
            NSLog(@"User posted today updated");
        else
            NSLog(@"Error updating user posted today");
    }];
    
    
    [newPiccy saveInBackgroundWithBlock: completion];
}

@end
