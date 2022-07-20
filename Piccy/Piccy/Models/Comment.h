//
//  Comment.h
//  Piccy
//
//  Created by Jake Torres on 7/19/22.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>
#import "Piccy.h"

NS_ASSUME_NONNULL_BEGIN

@interface Comment : PFObject<PFSubclassing>
@property (nonatomic, strong) Piccy *piccy;
@property (nonatomic, strong) PFUser *commentUser;
@property (nonatomic, strong) NSString *commentText;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic) bool isReply;
@end

NS_ASSUME_NONNULL_END
