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
#import <QuartzCore/QuartzCore.h>
#import "PiccyViewCell.h"
#import "DailyPiccyViewController.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *gifs;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *loops;
@property (nonatomic, strong) NSArray *piccys;
@property (weak, nonatomic) IBOutlet UILabel *piccyLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.allowsSelection = false;
    self.tableView.separatorColor = [UIColor clearColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadHome) name:@"loadHome" object:nil];
    //[self loadHome];
    [self setupActivityIndicator];
    // Do any additional setup after loading the view.
    [self queryLoop];
    
}

-(void) queryPiccys {
    PFUser *user = [PFUser currentUser];
    if([user[@"postedToday"] boolValue] == true) {
        NSString *word = self.loops[0][@"dailyWord"];
        self.piccyLabel.text = [NSString stringWithFormat:@"piccy: %@", [word lowercaseString]];
    }
    PFQuery *query = [PFQuery queryWithClassName:@"Piccy"];
    [query orderByDescending:@"createdAt"];
    query.limit = [user[@"friendsArray"] count] + 1;
    [query includeKey:@"resetDate"];
    [query includeKey:@"user"];
    [query includeKey:@"username"];
    [query whereKey:@"resetDate" equalTo:self.loops[0][@"dailyReset"]];
    [query whereKey:@"username" containedIn:user[@"friendsArray"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable piccys, NSError * _Nullable error) {
        if(piccys) {
            self.piccys = piccys;
            NSLog(@"%@", self.piccys);
            //If the piccy array is empty allow the user to be the first to post
            if([self.piccys count] == 0 && [user[@"postedToday"] boolValue] == false) {
                NSLog(@"no cells");
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x-125, self.view.center.y-150, 250, 50)];
                [button setTitle:@"Be the first to post today!" forState:UIControlStateNormal];
                button.tintColor = [UIColor orangeColor];
                button.backgroundColor = [UIColor systemRedColor];
                button.layer.cornerRadius = 10;
                button.clipsToBounds = YES;
                [button addTarget:self action:@selector(piccyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                
                [self.view addSubview:button];
            }
            [self.tableView reloadData];
        } else {
            NSLog(@"Error loading piccys ;-; :%@", error);
        }
        [self.activityIndicator stopAnimating];
    }];
}

- (void)piccyButtonClicked:(UIButton *)sender {
    NSLog(@"First to post button was tapped");
    [self performSegueWithIdentifier:@"piccySegue" sender:nil];
}

//Query to check if the day has changed and if the user is able to post
-(void) queryLoop {
    [self.activityIndicator startAnimating];
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
            //Now that the daily loop has been checked we can query for piccys
            [self queryPiccys];
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
        self.view.backgroundColor = [UIColor blackColor];
    } else {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
        self.view.backgroundColor = [UIColor whiteColor];
    }
    [self queryPiccys];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.piccys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PiccyViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PiccyViewCell"];
    Piccy *piccy = self.piccys[indexPath.row];
    
    cell.username.text = [NSString stringWithFormat:@"@%@", piccy.user[@"username"]];
    cell.name.text = piccy.user[@"name"];
    cell.caption.text = piccy[@"caption"];
    cell.timeSpent.text = piccy[@"timeSpent"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    formatter.dateStyle = NSDateFormatterNoStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    NSDate *timePosted = piccy.createdAt;
    cell.timeOfPost.text = [formatter stringFromDate:timePosted];
    
    cell.profilePic.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:piccy.user[@"profilePictureURL"]]];
    cell.profilePic.layer.masksToBounds = false;
    cell.profilePic.layer.cornerRadius = cell.profilePic.bounds.size.width/2;
    cell.profilePic.clipsToBounds = true;
    cell.profilePic.contentMode = UIViewContentModeScaleAspectFill;
    cell.profilePic.layer.borderWidth = 0.05;
    
    cell.postImage.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:piccy.postGifUrl]];
    cell.postImage.layer.masksToBounds = false;
    cell.postImage.layer.cornerRadius = cell.postImage.bounds.size.width/12;
    cell.postImage.clipsToBounds = true;
    cell.postImage.contentMode = UIViewContentModeScaleAspectFill;
    cell.postImage.layer.borderWidth = 0.05;
    
    if([PFUser.currentUser[@"postedToday"] boolValue] != true) {
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];

        UIVisualEffectView *visualEffectView;
        visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];

        visualEffectView.frame = cell.postImage.bounds;
        [cell.postImage addSubview:visualEffectView];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(cell.postImage.center.x-95, cell.postImage.center.y-25, 190, 50)];
        [button setTitle:@"Post to reveal Piccy!" forState:UIControlStateNormal];
        button.tintColor = [UIColor orangeColor];
        button.backgroundColor = [UIColor systemRedColor];
        button.layer.cornerRadius = 10;
        button.clipsToBounds = YES;
        [button addTarget:self action:@selector(piccyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:button];
    }
    
    return cell;
}

-(void) setupActivityIndicator{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.activityIndicator.center = self.view.center;
    self.activityIndicator.hidesWhenStopped = true;
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleMedium];
    [self.view addSubview:self.activityIndicator];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"piccySegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        DailyPiccyViewController *piccyController = (DailyPiccyViewController*)navigationController.topViewController;
        piccyController.piccyLoop = self.loops[0];
    }
}


@end
