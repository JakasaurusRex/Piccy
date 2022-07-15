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

+ (nonnull NSString *)parseClassName {
    return @"Piccy";
}

+ (void) postPiccy: ( NSString * _Nullable )postGifUrl withCaption: ( NSString * _Nullable )caption withDate: (NSDate *) date withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Piccy *newPiccy = [Piccy new];
    
    newPiccy.caption = caption;
    newPiccy.postGifUrl = postGifUrl;
    PFUser *user = [PFUser currentUser];
    newPiccy.user = user;
    newPiccy.resetDate = date;
    user[@"postedToday"] = @(YES);
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil)
            NSLog(@"User posted today updated");
        else
            NSLog(@"Error updating user posted today");
    }];
    
    
    [newPiccy saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil)
            NSLog(@"Piccy posted successfully");
        else
            NSLog(@"Error posting piccy: %@", error);
    }];
}

@end
