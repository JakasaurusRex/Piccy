//
//  ReportedPiccy.h
//  Piccy
//
//  Created by Jake Torres on 7/25/22.
//

#import <Parse/Parse.h>
#import "Piccy.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReportedPiccy : PFObject<PFSubclassing>
@property (nonatomic, strong) PFUser *piccyUser;
@property (nonatomic, strong) NSString *reasonForReport;
@property (nonatomic, strong) NSString *piccyUsername;
@property (nonatomic, strong) PFUser *reporterUser;
@property (nonatomic, strong) Piccy *piccy;
+ (void) reportPiccy: ( Piccy * _Nullable )piccy withReason: ( NSString * _Nullable )reason withCompletion: (PFBooleanResultBlock  _Nullable)completion;
@end

NS_ASSUME_NONNULL_END
