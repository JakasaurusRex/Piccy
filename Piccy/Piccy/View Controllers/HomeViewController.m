//
//  HomeViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/6/22.
//

#import "HomeViewController.h"
#import <Parse/Parse.h>
#import "APIManager.h"
#import "UIImage+animatedGIF.h"
#import "PiccyLoop.h"
#import "Piccy.h"

@interface HomeViewController ()
@property (nonatomic, strong) NSArray *gifs;
@property (nonatomic, strong) NSArray *loops;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadHome) name:@"loadHome" object:nil];
    [self loadHome];
    // Do any additional setup after loading the view.
    [self queryLoop];
    
    
}

//Query to check if the day has changed and if the user is able to post
-(void) queryLoop {
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"PiccyLoop"];
    [query orderByDescending:@"createdAt"];
    query.limit = 1;
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *loops, NSError *error) {
        if (loops != nil) {
            // do something with the array of object returned by the call
            self.loops = loops;
            
            NSDate *curDate = [NSDate date];
            NSTimeInterval diff = [curDate timeIntervalSinceDate:loops[0][@"dailyReset"]];
            NSInteger interval = diff;
            long hoursSince = interval/3600;
            if(hoursSince >= 24) {
                [PiccyLoop postPiccyLoopWithCompletion:^(NSError * _Nonnull error) {
                    if(error == nil) {
                        NSLog(@"New piccy loop created");
                        PFUser *user = [PFUser currentUser];
                        user[@"postedToday"] = @(NO);
                        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            if(error == nil)
                                NSLog(@"User posted today updated sucessfully");
                            else
                                NSLog(@"Error updating user posted today %@", error);
                        }];
                    } else {
                        NSLog(@"Piccy loop could not be created");
                    }
                }];
            } else {
                NSLog(@"Piccy has happened withijn the last 24 hours");
                [self checkPostedToday];
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

//check if a user has posted within the daily reset by checking the created at of their last post
-(void) checkPostedToday {
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Piccy"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"user"];
    [query whereKey:@"user" equalTo:user];
    query.limit = 1;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable piccys, NSError * _Nullable error) {
        if(piccys) {
            if([piccys isEqualToArray:@[]]) {
                NSLog(@"User has never posted");
                return;
            }
            NSDate *lastPostDate = piccys[0][@"createdAt"];
            NSDate *curDate = [NSDate date];
            NSTimeInterval diffToCurDate = [curDate timeIntervalSinceDate:lastPostDate];
            NSTimeInterval diffCurDateToReset = [curDate timeIntervalSinceDate:self.loops[0][@"dailyReset"]];
            NSInteger interval1 = diffToCurDate;
            NSInteger interval2 = diffCurDateToReset;
            //the time from now to the daily reset - the time since last post if its less than zero, than the user can post, if its equal to 0 then they posted at reset exactly, if its greater than zero they posted within the reset time
            if(interval2 - interval1 < 0) {
                user[@"postedToday"] = @(NO);
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(error == nil)
                        NSLog(@"Saved user posted today");
                    else
                        NSLog(@"Error saving user posted today: %@", error);
                }];
            }
            
        } else {
            NSLog(@"Error checking if user posted today: %@", error);
        }
    }];
}

-(void) loadHome {
    if([PFUser.currentUser[@"darkMode"] boolValue] == YES) {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
        self.view.backgroundColor = [UIColor colorWithRed:(23/255.0f) green:(23/255.0f) blue:(23/255.0f) alpha:1];
    } else {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
        self.view.backgroundColor = [UIColor whiteColor];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
