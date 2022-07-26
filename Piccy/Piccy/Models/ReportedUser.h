//
//  ReportedUser.h
//  Piccy
//
//  Created by Jake Torres on 7/26/22.
//

#import <Parse/Parse.h>
#import "Piccy.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReportedUser : PFObject<PFSubclassing>
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSString *reasonForReport;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) PFUser *reporterUser;
+ (void) reportUser: ( PFUser * _Nullable )user withReason: ( NSString * _Nullable )reason withCompletion: (PFBooleanResultBlock  _Nullable)completion;
@end

NS_ASSUME_NONNULL_END
