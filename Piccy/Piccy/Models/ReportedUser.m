//
//  ReportedUser.m
//  Piccy
//
//  Created by Jake Torres on 7/26/22.
//

#import "ReportedUser.h"

@implementation ReportedUser
@dynamic user;
@dynamic username;
@dynamic reasonForReport;
@dynamic reporterUser;

+ (nonnull NSString *)parseClassName {
    return @"ReportedUser";
}

+(void) reportUser:(PFUser *)user withReason:(NSString *)reason withCompletion:(PFBooleanResultBlock)completion {
    ReportedUser *reportedUser = [ReportedUser new];
    
    reportedUser.user = user;
    reportedUser.username = user.username;
    reportedUser.reasonForReport = reason;
    reportedUser.reporterUser = PFUser.currentUser;
    
    [reportedUser saveInBackgroundWithBlock:completion];
}
@end
