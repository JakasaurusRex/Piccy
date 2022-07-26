//
//  ReportedPiccy.m
//  Piccy
//
//  Created by Jake Torres on 7/25/22.
//

#import "ReportedPiccy.h"

@implementation ReportedPiccy
@dynamic piccyUser;
@dynamic piccyUsername;
@dynamic reasonForReport;
@dynamic reporterUser;
@dynamic piccy;

+ (nonnull NSString *)parseClassName {
    return @"ReportedPiccy";
}

+ (void)reportPiccy:(Piccy *)piccy withReason:(NSString *)reason withCompletion:(PFBooleanResultBlock)completion {
    ReportedPiccy *reportedPiccy = [ReportedPiccy new];
    
    reportedPiccy.piccyUser = piccy.user;
    reportedPiccy.piccyUsername = piccy.user.username;
    reportedPiccy.reasonForReport = reason;
    reportedPiccy.reporterUser = PFUser.currentUser;
    reportedPiccy.piccy = piccy;
    
    [reportedPiccy saveInBackgroundWithBlock:completion];
}

@end
