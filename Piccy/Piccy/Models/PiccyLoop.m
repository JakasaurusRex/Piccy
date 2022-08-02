//
//  PiccyLoop.m
//  Piccy
//
//  Created by Jake Torres on 7/13/22.
//

#import "PiccyLoop.h"
#import <Parse/Parse.h>
#import <time.h>

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
    
    //Query to get yesterdays piccy loop so we can get the date and we can add 24 hours to it - i made it query 30 so we can check if a word has appeared in the last 30 days
    PFQuery *query = [PFQuery queryWithClassName:@"PiccyLoop"];
    [query orderByDescending:@"createdAt"];
    
    query.limit = 30;
    [query includeKey:@"dailyWord"];
    NSMutableArray *dailyWords = [[NSMutableArray alloc] init];
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *loops, NSError *error) {
        if (loops != nil) {
            // getting yesertdays day
            NSDate *date= loops[0][@"dailyReset"];
            //adding a 24 hour time interval and setting the new objects date equal to that
            NSTimeInterval secondsIn24Hours = 24 * 60 * 60 * daysSince;
            newPiccyLoop.dailyReset = [date dateByAddingTimeInterval:secondsIn24Hours];
            
            for(int i = 0; i < [loops count]; i++) {
                [dailyWords addObject:loops[i][@"dailyWord"]];
            }
        } else {
            NSLog(@"Error getting past daily loops: %@", error.localizedDescription);
        }
    }];
    
    //Querying for the random word of the day
    //dispatch group to make multiple calls and check for a new word
    NSMutableArray *chosenWords = [[NSMutableArray alloc] init];
    dispatch_group_t group = dispatch_group_create();
  
    //Loop 15 times and make 15 calls to the website to get random words from one of 4 categories
    for(int i = 0; i < 10; i++) {
        NSArray *addOnArray = @[@"noun", @"verb", @"1-word-quotes", @"2-word-quotes"];
        srand((int)time(NULL));
        int count = rand() % addOnArray.count;
        NSString *randomAddOn = [addOnArray objectAtIndex:count];
        NSString *queryString = [NSString stringWithFormat:@"https://random-words-api.vercel.app/word/%@", randomAddOn];
        NSURL *url = [NSURL URLWithString:queryString];
        NSURLSession *session = [NSURLSession sharedSession];
        
        //enter the dispatch group right before the api call is made
        dispatch_group_enter(group);
        NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
            NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSLog(@"Random word found: %@", json[0][@"word"]);
            
            //add the random word to the chosen words list after making sure its only alphabetical
            NSCharacterSet *setToRemove =
                [NSCharacterSet characterSetWithCharactersInString:@"qwertyuiopasdfghjklzxcvbnm -"];
            NSCharacterSet *setToKeep = [setToRemove invertedSet];

            NSString *finalWordString =
                    [[json[0][@"word"] componentsSeparatedByCharactersInSet:setToKeep]
                        componentsJoinedByString:@""];
            
            [chosenWords addObject:[NSString stringWithString:finalWordString]];
            dispatch_group_leave(group); 
        }];
        
        [task resume];
    }
    
    //After all the api calls are made, go through the list and check if there are any words that are not duplicates and use the first one
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        for(int i = 0; i < [chosenWords count]; i++) {
            if(![dailyWords containsObject:chosenWords[i]]) {
                newPiccyLoop.dailyWord = chosenWords[i];
                NSLog(@"Random word today: %@", chosenWords[i]);
                [newPiccyLoop saveInBackgroundWithBlock:completion];
                return;
            }
        }
    });
   
}

@end
