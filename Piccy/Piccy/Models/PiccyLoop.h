//
//  PiccyLoop.h
//  Piccy
//
//  Created by Jake Torres on 7/13/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PiccyLoop : NSObject
@property (nonatomic, strong) NSString *dailyWord;
@property (nonatomic, strong) NSDate *dailyReset;
@end

NS_ASSUME_NONNULL_END
