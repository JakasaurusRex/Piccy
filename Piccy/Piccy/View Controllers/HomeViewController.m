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
#import "CommentsViewController.h"
#import "OtherProfileViewController.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *gifs;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *loops;
@property (nonatomic, strong) NSArray *piccys;
@property (nonatomic, strong) NSArray *userPiccy;
@property (weak, nonatomic) IBOutlet UILabel *piccyLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) PFUser *user;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.allowsSelection = false;
    self.tableView.separatorColor = [UIColor clearColor];
    
    self.user = [PFUser currentUser];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadHome) name:@"loadHome" object:nil];
    //[self loadHome];
    [self setupActivityIndicator];
    // Do any additional setup after loading the view.
    self.piccys = [[NSArray alloc] init];
    [self queryLoop];
    
}

-(void) queryPiccys {
    PFQuery *query = [PFQuery queryWithClassName:@"Piccy"];
    [query orderByDescending:@"createdAt"];
    query.limit = [self.user[@"friendsArray"] count] + 1;
    [query includeKey:@"resetDate"];
    [query includeKey:@"user"];
    [query includeKey:@"username"];
    [query whereKey:@"resetDate" equalTo:self.loops[0][@"dailyReset"]];
    [query whereKey:@"username" containedIn:self.user[@"friendsArray"]];

    __weak __typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable piccys, NSError * _Nullable error) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
               return;
       }
        if(piccys) {
            strongSelf.piccys = piccys;
            NSLog(@"%@", strongSelf.piccys);
            //If the piccy array is empty allow the user to be the first to post
            if([strongSelf.piccys count] == 0 && [strongSelf.user[@"postedToday"] boolValue] == NO) {
                NSLog(@"no cells");
                strongSelf.button = [[UIButton alloc] initWithFrame:CGRectMake(strongSelf.view.center.x-125, strongSelf.view.center.y-150, 250, 50)];
                [strongSelf.button setTitle:@"Be the first to post today!" forState:UIControlStateNormal];
                strongSelf.button.tintColor = [UIColor orangeColor];
                strongSelf.button.backgroundColor = [UIColor systemRedColor];
                strongSelf.button.layer.cornerRadius = 10;
                strongSelf.button.clipsToBounds = YES;
                [strongSelf.button addTarget:strongSelf action:@selector(piccyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                
                [strongSelf.view addSubview:strongSelf.button];
                [strongSelf.tableView reloadData];
            } else {
                [strongSelf.button removeFromSuperview];
                [strongSelf queryUserPiccy];
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
    __weak __typeof(self) weakSelf = self;
    __strong __typeof(self) strongSelf = weakSelf;
    if (!strongSelf) {
           return;
   }
    PFQuery *query = [PFQuery queryWithClassName:@"Piccy"];
    [query orderByDescending:@"createdAt"];
    query.limit = 1;
    [query includeKey:@"resetDate"];
    [query includeKey:@"user"];
    [query includeKey:@"username"];
    [query whereKey:@"resetDate" equalTo:strongSelf.loops[0][@"dailyReset"]];
    [query whereKey:@"username" equalTo:strongSelf.user.username];
    NSMutableArray *piccyArray = [[NSMutableArray alloc] initWithArray:self.piccys];
    strongSelf.userPiccy = [query findObjects];
    if([strongSelf.userPiccy isEqualToArray:@[]]) {
        NSLog(@"User has not posted");
        [strongSelf.activityIndicator stopAnimating];
        [strongSelf.tableView reloadData];
        return;
    }
    [piccyArray insertObject:strongSelf.userPiccy[0] atIndex:0];
    strongSelf.piccys = [[NSArray alloc] initWithArray:piccyArray];
    NSLog(@"%@", strongSelf.userPiccy);
    [strongSelf.activityIndicator stopAnimating];
    [strongSelf.tableView reloadData];
}



//Query to check if the day has changed and if the user is able to post
-(void) queryLoop {
    [self.activityIndicator startAnimating];
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"PiccyLoop"];
    [query orderByDescending:@"createdAt"];
    query.limit = 1;
    // fetch data asynchronously
    __weak __typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *loops, NSError *error) {
        if (loops != nil) {
            // do something with the array of object returned by the call
            __strong __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                   return;
           }
            strongSelf.loops = loops;
            
            NSDate *curDate = [NSDate date];
            NSTimeInterval diff = [curDate timeIntervalSinceDate:loops[0][@"dailyReset"]];
            NSInteger interval = diff;
            long hoursSince = interval/3600;
            if(hoursSince >= 24) {
                [PiccyLoop postPiccyLoopWithInt: (int) hoursSince/24 withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                    if(error == nil) {
                        NSLog(@"New piccy loop created");
                        strongSelf.gifs = [[NSArray alloc] init];
                        strongSelf.user[@"postedToday"] = @(NO);
                        [strongSelf.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            if(error == nil) {
                                NSLog(@"User posted today updated sucessfully");
                                [strongSelf queryPiccys];
                            } else {
                                NSLog(@"Error updating user posted today %@", error);
                            }
                        }];
                    } else {
                        NSLog(@"Piccy loop could not be created");
                    }
                }];
            } else {
                NSLog(@"Piccy has happened withijn the last 24 hours");
               
                [strongSelf checkPostedToday];
            }
            //Now that the daily loop has been checked we can query for piccys
            [strongSelf queryPiccys];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

//check if a user has posted within the daily reset by checking the created at of their last post
-(void) checkPostedToday {
    PFQuery *query = [PFQuery queryWithClassName:@"Piccy"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"user"];
    [query whereKey:@"user" equalTo:self.user];
    query.limit = 1;
    __weak __typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable piccys, NSError * _Nullable error) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
               return;
       }
        if(piccys) {
            if([piccys isEqualToArray:@[]]) {
                NSLog(@"User has never posted");
                return;
            }
            NSLog(@"check %@", piccys);
            NSDate *lastPostDate = piccys[0][@"resetDate"];
            NSDate *curDate = [NSDate date];
            //calls the function below this to check if the date of the last reset is between the current date and the date of the last reset
            NSString *word = strongSelf.loops[0][@"dailyWord"];
            if([strongSelf date:lastPostDate isBetweenDate:strongSelf.loops[0][@"dailyReset"] andDate:curDate]) {
                strongSelf.user[@"postedToday"] = @(YES);
                strongSelf.piccyLabel.text = [NSString stringWithFormat:@"piccy: %@", [word lowercaseString]];
                [strongSelf.button removeFromSuperview];
            }else{
                strongSelf.user[@"postedToday"] = @(NO);
                strongSelf.piccyLabel.text = [NSString stringWithFormat:@"piccy"];
            }
            NSLog(@"%@", strongSelf.user[@"postedToday"]);
            [strongSelf.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(error == nil)
                    NSLog(@"Saved user posted today");
                else
                    NSLog(@"Error saving user posted today: %@", error);
                [strongSelf queryPiccys];
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
    if([self.user[@"postedToday"] boolValue] == true) {
        [self.button removeFromSuperview];
        [self.tableView reloadData];
    }
    if([self.user[@"darkMode"] boolValue] == YES) {
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
    //If the cell is the first in the tableview and the user posted today, then we add the user cell
    if(indexPath.row == 0 && [self.user[@"postedToday"] boolValue] == YES) {
        UserPiccyViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UserPiccyViewCell"];
        Piccy *piccy = self.userPiccy[0];
        [self.button removeFromSuperview];
        
        cell.nameLabel.text = self.user[@"name"];
        
        [cell.piccyButton setTitle:@"" forState:UIControlStateNormal];
        
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
        
        [cell.nameButton setTitle:@"" forState:UIControlStateNormal];
        [cell.pfpButton setTitle:@"" forState:UIControlStateNormal];
        [cell.piccyButton setTitle:@"" forState:UIControlStateNormal];
        
        if(piccy.replyCount == 0) {
            [cell.otherCaptionButton setTitle:@"add a comment" forState:UIControlStateNormal];
        } else if(piccy.replyCount == 1){
            [cell.otherCaptionButton setTitle:@"view comment" forState:UIControlStateNormal];
        } else {
            NSString *commentString = [NSString stringWithFormat:@"view %d comments", piccy.replyCount];
            [cell.otherCaptionButton setTitle:commentString forState:UIControlStateNormal];
        }
       
        
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
        
        
        if([self.user[@"postedToday"] boolValue] != true) {
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
    } else if([segue.identifier isEqualToString:@"commentsSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        CommentsViewController *commentsController = (CommentsViewController*)navigationController.topViewController;
        commentsController.piccy = self.userPiccy[0];
        commentsController.isSelf = true;
    } else if([segue.identifier isEqualToString:@"otherCommentsSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        CommentsViewController *commentsController = (CommentsViewController*)navigationController.topViewController;
        UIView *content = (UIView *)[(UIView *) sender superview];
        PiccyViewCell *cell = (PiccyViewCell *)[content superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        Piccy *piccyToPass = self.piccys[indexPath.item];
        commentsController.piccy = piccyToPass;
        commentsController.isSelf = false;
    } else if([segue.identifier isEqualToString:@"otherProfileSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        OtherProfileViewController *commentsController = (OtherProfileViewController*)navigationController.topViewController;
        UIView *content = (UIView *)[(UIView *) sender superview];
        PiccyViewCell *cell = (PiccyViewCell *)[content superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        Piccy *piccyToPass = self.piccys[indexPath.row];
        commentsController.user = piccyToPass.user;
    }
}


@end
