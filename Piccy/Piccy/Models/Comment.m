//
//  Comment.m
//  Piccy
//
//  Created by Jake Torres on 7/19/22.
//

#import "Comment.h"

@implementation Comment
@dynamic commentUser;
@dynamic piccy;
@dynamic commentText;
@dynamic isReply;
@dynamic createdAt;

+ (nonnull NSString *)parseClassName {
    return @"Comment";
}

+ (void) postComment: (NSString *) commentText onPiccy:(Piccy *) piccy andIsReply: (bool) isReply withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Comment *newComment = [Comment new];
    newComment.commentUser = [PFUser currentUser];
    newComment.piccy = piccy;
    newComment.isReply = isReply;
    newComment.commentText = commentText;
    
    [newComment saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil) {
            NSLog(@"Comment posted successfully");
        } else {
            NSLog(@"Comment could not be posted: %@", error);
        }
    }];
}

@end
