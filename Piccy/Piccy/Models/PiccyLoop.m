//
//  PiccyLoop.m
//  Piccy
//
//  Created by Jake Torres on 7/13/22.
//

#import "PiccyLoop.h"
#import <Parse/Parse.h>

@implementation PiccyLoop
@dynamic dailyWord;
@dynamic dailyReset;

+ (nonnull NSString *)parseClassName {
    return @"PiccyLoop";
}

//Called when we want to create a new piccy loop (on daily reset)
+ (void) postPiccyLoopWithInt: (int) daysSince withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    //Creating a new Piccy Loop object
    PiccyLoop *newPiccyLoop = [PiccyLoop new];
    
    //Query to get yesterdays piccy loop so we can get the date and we can add 24 hours to it
    PFQuery *query = [PFQuery queryWithClassName:@"PiccyLoop"];
    [query orderByDescending:@"createdAt"];
    
    //One object because we are just checking the last one to see if it was today
    query.limit = 1;
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *loops, NSError *error) {
        if (loops != nil) {
            // getting yesertdays day
            NSDate *date= loops[0][@"dailyReset"];
            //adding a 24 hour time interval and setting the new objects date equal to that
            NSTimeInterval secondsIn24Hours = 24 * 60 * 60 * daysSince;
            newPiccyLoop.dailyReset = [date dateByAddingTimeInterval:secondsIn24Hours];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
    //Querying for the random word of the day, will add error checking for duplicate words in the future
    NSString *queryString = [NSString stringWithFormat:@"https://random-words-api.vercel.app/word/noun"];
    NSURL *url = [NSURL URLWithString:queryString];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

        NSLog(@"Random word today: %@", json[0][@"word"]);
        
        newPiccyLoop.dailyWord = [NSString stringWithString:json[0][@"word"]];
        
        [newPiccyLoop saveInBackgroundWithBlock:completion];
        
    }];
    
    [task resume];
    
   
}

@end
