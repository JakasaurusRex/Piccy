//
//  APIManager.h
//  Piccy
//
//  Created by Jake Torres on 7/12/22.
//

@interface APIManager : NSObject
+ (instancetype)shared;

-(void)getGifsWithSearchString:(NSString *)searchString limit:(int) limit completion:(void (^)(NSDictionary *, NSError *)) completion;

-(void)getFeaturedGifs:(int) limit completion:(void (^)(NSDictionary *, NSError *)) completion;
@end
