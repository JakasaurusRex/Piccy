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
#import "UserPiccyViewCell.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *gifs;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *loops;
@property (nonatomic, strong) NSArray *piccys;
@property (nonatomic, strong) NSArray *userPiccy;
@property (weak, nonatomic) IBOutlet UILabel *piccyLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIButton *button;
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
            if([self.piccys count] == 0 && [user[@"postedToday"] boolValue] == NO) {
                NSLog(@"no cells");
                self.button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x-125, self.view.center.y-150, 250, 50)];
                [self.button setTitle:@"Be the first to post today!" forState:UIControlStateNormal];
                self.button.tintColor = [UIColor orangeColor];
                self.button.backgroundColor = [UIColor systemRedColor];
                self.button.layer.cornerRadius = 10;
                self.button.clipsToBounds = YES;
                [self.button addTarget:self action:@selector(piccyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                
                [self.view addSubview:self.button];
                [self.tableView reloadData];
            } else {
                [self queryUserPiccy];
            }
            

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

-(void) queryUserPiccy {
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Piccy"];
    [query orderByDescending:@"createdAt"];
    query.limit = 1;
    [query includeKey:@"resetDate"];
    [query includeKey:@"user"];
    [query includeKey:@"username"];
    [query whereKey:@"resetDate" equalTo:self.loops[0][@"dailyReset"]];
    [query whereKey:@"username" equalTo:user.username];
    NSMutableArray *piccyArray = [[NSMutableArray alloc] initWithArray:self.piccys];
    self.userPiccy = [query findObjects];
    if([self.userPiccy isEqualToArray:@[]]) {
        NSLog(@"User has not posted");
        [self.activityIndicator stopAnimating];
        [self.tableView reloadData];
        return;
    }
    [piccyArray insertObject:self.userPiccy[0] atIndex:0];
    self.piccys = [[NSArray alloc] initWithArray:piccyArray];
    NSLog(@"%@", self.userPiccy);
    [self.activityIndicator stopAnimating];
    [self.tableView reloadData];
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
                [PiccyLoop postPiccyLoopWithInt: (int) hoursSince/24 withCompletion:^(NSError * _Nonnull error) {
                    if(error == nil) {
                        NSLog(@"New piccy loop created");
                        self.gifs = [[NSArray alloc] init];
                        [self.tableView reloadData];
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
            NSLog(@"check %@", piccys);
            NSDate *lastPostDate = piccys[0][@"resetDate"];
            NSDate *curDate = [NSDate date];
            //calls the function below this to check if the date of the last reset is between the current date and the date of the last reset
            NSString *word = self.loops[0][@"dailyWord"];
            if([self date:lastPostDate isBetweenDate:self.loops[0][@"dailyReset"] andDate:curDate]) {
                user[@"postedToday"] = @(YES);
                self.piccyLabel.text = [NSString stringWithFormat:@"piccy: %@", [word lowercaseString]];
                [self.button removeFromSuperview];
            }else{
                user[@"postedToday"] = @(NO);
                self.piccyLabel.text = [NSString stringWithFormat:@"piccy"];
            }
            NSLog(@"%@", user[@"postedToday"]);
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(error == nil)
                    NSLog(@"Saved user posted today");
                else
                    NSLog(@"Error saving user posted today: %@", error);
                [self queryPiccys];
            }];
            
        } else {
            NSLog(@"Error checking if user posted today: %@", error);
        }
    }];
}

//Checks if a date is between 2 dates used for checking if the last post was between now and the last reset
- (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;

    if ([date compare:endDate] == NSOrderedDescending)
        return NO;

    return YES;
}

-(void) loadHome {
    if([PFUser.currentUser[@"darkMode"] boolValue] == YES) {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
        self.view.backgroundColor = [UIColor blackColor];
    } else {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
        self.view.backgroundColor = [UIColor whiteColor];
    }
    [self queryLoop];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.piccys count];
}

//Updating all the piccys in the table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFUser *user = [PFUser currentUser];
    //If the cell is the first in the tableview and the user posted today, then we add the user cell
    if(indexPath.row == 0 && [user[@"postedToday"] boolValue] == YES) {
        UserPiccyViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UserPiccyViewCell"];
        Piccy *piccy = self.userPiccy[0];
        [self.button removeFromSuperview];
        
        cell.nameLabel.text = user[@"name"];
        
        cell.postImage.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:piccy.postGifUrl]];
        cell.postImage.layer.masksToBounds = false;
        cell.postImage.layer.cornerRadius = cell.postImage.bounds.size.width/12;
        cell.postImage.clipsToBounds = true;
        cell.postImage.contentMode = UIViewContentModeScaleAspectFill;
        cell.postImage.layer.borderWidth = 0.05;
        
        if([piccy.caption isEqualToString:@""]) {
            cell.captionLabel.text = @"Add a caption";
        } else {
            cell.captionLabel.text = piccy.caption;
        }
        
        [cell.postOptions setShowsMenuAsPrimaryAction:YES];
        
        //Array of actions shown in the menu
        NSMutableArray *actions = [[NSMutableArray alloc] init];
        [actions addObject:[UIAction actionWithTitle:@"Delete piccy"
                                               image:nil
                                          identifier:nil
                                             handler:^(__kindof UIAction* _Nonnull action) {
            
            // ...
        }]];
        UIMenu *menu =
        [UIMenu menuWithTitle:@""
                     children:actions];
        
        
        [cell.postOptions setMenu:menu];
        
        return cell;
        
    } else {
        NSLog(@"%@ hello", self.piccys);
        Piccy *piccy = self.piccys[indexPath.row];
        NSLog(@"Piccys: %@", self.piccys);
        
        PiccyViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PiccyViewCell"];
        
        
        cell.username.text = [NSString stringWithFormat:@"@%@", piccy.user[@"username"]];
        cell.name.text = piccy.user[@"name"];
        
        cell.timeSpent.text = piccy[@"timeSpent"];
        
        //Time of post
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        formatter.dateStyle = NSDateFormatterNoStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
        NSDate *timePosted = piccy.createdAt;
        cell.timeOfPost.text = [formatter stringFromDate:timePosted];
        
        //Profile picture
        cell.profilePic.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:piccy.user[@"profilePictureURL"]]];
        cell.profilePic.layer.masksToBounds = false;
        cell.profilePic.layer.cornerRadius = cell.profilePic.bounds.size.width/2;
        cell.profilePic.clipsToBounds = true;
        cell.profilePic.contentMode = UIViewContentModeScaleAspectFill;
        cell.profilePic.layer.borderWidth = 0.05;
        
        //Post image
        cell.postImage.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:piccy.postGifUrl]];
        cell.postImage.layer.masksToBounds = false;
        cell.postImage.layer.cornerRadius = cell.postImage.bounds.size.width/12;
        cell.postImage.clipsToBounds = true;
        cell.postImage.contentMode = UIViewContentModeScaleAspectFill;
        cell.postImage.layer.borderWidth = 0.05;
        
        //Blurs the image and add the post button if the user hasnt posted today
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];

        UIVisualEffectView *visualEffectView;
        visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];

        visualEffectView.frame = cell.postImage.bounds;
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(cell.postImage.center.x-95, cell.postImage.center.y-25, 190, 50)];
        [button setTitle:@"Post to reveal Piccy!" forState:UIControlStateNormal];
        button.tintColor = [UIColor orangeColor];
        button.backgroundColor = [UIColor systemRedColor];
        button.layer.cornerRadius = 10;
        button.clipsToBounds = YES;
        [button addTarget:self action:@selector(piccyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if([PFUser.currentUser[@"postedToday"] boolValue] != true) {
            [cell.postImage addSubview:visualEffectView];
            cell.caption.text = @"";
            [cell addSubview:button];
        } else {
            //Doesnt show the caption unless you have already posted
            cell.caption.text = piccy[@"caption"];
            [visualEffectView removeFromSuperview];
            [button removeFromSuperview];
        }
        
        [cell.optionsButton setShowsMenuAsPrimaryAction:YES];
        
        //Array of actions shown in the menu
        NSMutableArray *actions = [[NSMutableArray alloc] init];
        [actions addObject:[UIAction actionWithTitle:@"📝 Report"
                                               image:nil
                                          identifier:nil
                                             handler:^(__kindof UIAction* _Nonnull action) {
            
            // ...
        }]];
        UIMenu *menu =
        [UIMenu menuWithTitle:@""
                     children:actions];
        
        
        [cell.optionsButton setMenu:menu];
        
        return cell;
    }
}

//Activity indicator for loading piccys
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
        //Passing the daily loop to the piccy screen
        UINavigationController *navigationController = [segue destinationViewController];
        DailyPiccyViewController *piccyController = (DailyPiccyViewController*)navigationController.topViewController;
        piccyController.piccyLoop = self.loops[0];
    }
}


@end
