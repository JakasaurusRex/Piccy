//
//  PiccyLoop.h
//  Piccy
//
//  Created by Jake Torres on 7/13/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface PiccyLoop : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *dailyWord;
@property (nonatomic, strong) NSDate *dailyReset;
+ (void) postPiccyLoopWithInt: (int) daysSince withCompletion: (PFBooleanResultBlock  _Nullable)completion;
@end

NS_ASSUME_NONNULL_END
