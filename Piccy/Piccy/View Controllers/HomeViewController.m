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
#import "PiccyDetailViewController.h"
#import "ReportedPiccy.h"
#import "PiccyReaction.h"
#import "AppMethods.h"
#import "MagicalEnums.h"
@import BonsaiController;


@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource, BonsaiControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSArray *gifs;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *loops;
@property (nonatomic, strong) NSArray *piccys;
@property (nonatomic, strong) NSArray *userPiccy;
@property (weak, nonatomic) IBOutlet UILabel *piccyLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) PFUser *user;
@property (nonatomic) int direction; //1 is bottom, 2 is top, 3 is left, 4 is right
@property (weak, nonatomic) IBOutlet UILabel *noOnePostedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *noOnePostedImage;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (nonatomic) int segSelected; // 0 is home 1 is discovery
@property bool endDiscovery;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.allowsSelection = false;
    self.tableView.separatorColor = [UIColor clearColor];
    
    //Int for transition direction
    self.direction = SegueDirectionsFromBottom;
    
    self.endDiscovery = false;
    
    //Int for which mode we are on for the home screen
    self.segSelected = 0;
    self.homeButton.tintColor = [UIColor blackColor];
    self.homeButton.backgroundColor = [UIColor whiteColor];
    self.discoveryButton.tintColor = [UIColor lightGrayColor];
    self.discoveryButton.backgroundColor = [UIColor clearColor];
    self.homeButton.layer.cornerRadius = 15;
    
    self.user = [PFUser currentUser];
    
    //Notification for loading home
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadHome) name:@"loadHome" object:nil];
    
    //sets up the activity indicator
    self.activityIndicator = [AppMethods setupActivityIndicator:self.activityIndicator onView:self.view];
    
    // Do any additional setup after loading the view.
    self.piccys = [[NSArray alloc] init];
    
    //Sets up the be the first to post today button
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x-125, self.view.center.y-150, 250, 50)];
    [self.button setTitle:@"Be the first to post today!" forState:UIControlStateNormal];
    self.button.tintColor = [UIColor orangeColor];
    self.button.backgroundColor = [UIColor systemRedColor];
    self.button.layer.cornerRadius = 10;
    self.button.clipsToBounds = YES;
    [self.button addTarget:self action:@selector(piccyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    self.button.userInteractionEnabled = false;
    self.button.alpha = 0;
    
    //Gesture to make buttons hide
    UIPanGestureRecognizer* tablePanGesture =[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [tablePanGesture setCancelsTouchesInView:NO];
    tablePanGesture.delegate = self;
    [self.tableView addGestureRecognizer:tablePanGesture];
    
    self.noOnePostedLabel.alpha = 0;
    self.noOnePostedImage.alpha = 0;
    
    self.profileImage = [AppMethods roundImageView:self.profileImage withURL:self.user[@"profilePictureURL"]];
    
    //Querys da loop
    [self queryLoop];
}


-(void) queryPiccys {
    self.noOnePostedLabel.alpha = 0;
    self.noOnePostedImage.alpha = 0;
    PFQuery *query = [PFQuery queryWithClassName:@"Piccy"];
    [query orderByDescending:@"createdAt"];
    query.limit = [self.user[@"friendsArray"] count] + 1;
    [query includeKey:@"resetDate"];
    [query includeKey:@"user"];
    [query includeKey:@"username"];
    [query includeKey:@"objectId"];
    [query whereKey:@"resetDate" equalTo:self.loops[0][@"dailyReset"]];
    [query whereKey:@"username" containedIn:self.user[@"friendsArray"]];
    [query whereKey:@"objectId" notContainedIn:self.user[@"reportedPiccys"]];

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
                strongSelf.button.userInteractionEnabled = true;
                strongSelf.button.alpha = 1;
                [strongSelf.tableView reloadData];
            } else {
                strongSelf.button.userInteractionEnabled = false;
                strongSelf.button.alpha = 0;
                [strongSelf queryUserPiccy];
            }
            

        } else {
            NSLog(@"Error loading piccys ;-; :%@", error);
        }
        [self.activityIndicator stopAnimating];
    }];
}

- (void) queryDiscovery:(int) limit {
    [self.activityIndicator startAnimating];
    self.endDiscovery = false;
    PFQuery *query = [PFQuery queryWithClassName:@"Piccy"];
    [query orderByDescending:@"createdAt"];
    query.limit = limit;
    [query includeKey:@"resetDate"];
    [query includeKey:@"user"];
    [query includeKey:@"username"];
    [query includeKey:@"discoverable"];
    [query includeKey:@"objectId"];
    [query whereKey:@"resetDate" equalTo:self.loops[0][@"dailyReset"]];
    [query whereKey:@"username" notEqualTo:self.user.username];
    [query whereKey:@"discoverable" equalTo:@(YES)];
    [query whereKey:@"objectId" notContainedIn:self.user[@"reportedPiccys"]];
    
    
    NSMutableArray *blockArray = [[NSMutableArray alloc] initWithArray:self.user[@"blockedUsers"]];
    [blockArray addObjectsFromArray:self.user[@"blockedByArray"]];
    [blockArray addObjectsFromArray:self.user[@"friendsArray"]];
    [query whereKey:@"username" notContainedIn:blockArray];

    __weak __typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable piccys, NSError * _Nullable error) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
               return;
       }
        if(piccys) {
            strongSelf.piccys = piccys;
            NSLog(@"Discovery piccys: %@", strongSelf.piccys);
            //If the piccy array is empty allow the user to be the first to post
            if([strongSelf.piccys count] < limit) {
                strongSelf.endDiscovery = true;
            }
            if([strongSelf.piccys count] == 0 && [strongSelf.user[@"postedToday"] boolValue] == NO) {
                NSLog(@"no cells");
                strongSelf.button.userInteractionEnabled = true;
                strongSelf.button.alpha = 1;
                [strongSelf.tableView reloadData];
            } else {
                strongSelf.button.userInteractionEnabled = false;
                strongSelf.button.alpha = 0;
                [strongSelf.tableView reloadData];
                [strongSelf.activityIndicator stopAnimating];
                if([strongSelf.piccys count] == 0) {
                    strongSelf.noOnePostedLabel.alpha = 1;
                    strongSelf.noOnePostedImage.alpha = 1;
                    strongSelf.noOnePostedImage = [AppMethods roundedCornerImageView:strongSelf.noOnePostedImage withURL:@"https://c.tenor.com/alYWL8XaRPgAAAAC/peepo-xqc.gif"];
                }
            }
            

        } else {
            NSLog(@"Error loading discovery piccys ;-; :%@", error);
        }
        [strongSelf.activityIndicator stopAnimating];
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
                        strongSelf.user[@"deletedToday"] = @(NO);
                        strongSelf.user[@"deletedUpdate"] = [NSDate date];
                        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable loops, NSError * _Nullable error) {
                            if(error == nil) {
                                NSLog(@"got new loop: %@", loops);
                                strongSelf.loops = loops;
                                [strongSelf.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                    if(error == nil) {
                                        NSLog(@"User posted today updated sucessfully");
                                        strongSelf.piccys = [[NSArray alloc] init];
                                        [strongSelf.tableView reloadData];
                                        [strongSelf queryPiccys];
                                    } else {
                                        NSLog(@"Error updating user posted today %@", error);
                                    }
                                }];
                            } else {
                                NSLog(@"Error getting new loop: %@", error);
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
                [strongSelf queryPiccys];
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
                strongSelf.button.userInteractionEnabled = false;
                strongSelf.button.alpha = 0;
            }else{
                strongSelf.user[@"postedToday"] = @(NO);
                //Checking if the user was updated today
                NSDate *updateDate = strongSelf.user[@"deletedUpdate"];
                NSDate *resetDate = strongSelf.loops[0][@"dailyReset"];
                NSComparisonResult result = [resetDate compare:updateDate];
                if(result == NSOrderedDescending) {
                    strongSelf.user[@"deletedToday"] = @(NO);
                    strongSelf.user[@"deletedUpdate"] = [NSDate date];
                }
                strongSelf.piccyLabel.text = [NSString stringWithFormat:@"piccy"];
            }
            NSLog(@"%@", strongSelf.user[@"postedToday"]);
            [strongSelf.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(error == nil)
                    NSLog(@"Saved user posted today");
                else
                    NSLog(@"Error saving user posted today: %@", error);
                if(strongSelf.segSelected == 0)
                    [strongSelf queryPiccys];
                else
                    [strongSelf queryDiscovery:10];
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
        self.button.userInteractionEnabled = false;
        self.button.alpha = 0;
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
    if(indexPath.row == 0 && [self.user[@"postedToday"] boolValue] == YES && self.segSelected == 0) {
        UserPiccyViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UserPiccyViewCell"];
        if([self.userPiccy count] == 0) {
            return cell;
        }
        Piccy *piccy = self.userPiccy[0];
        self.button.alpha = 0;
        self.button.userInteractionEnabled = false;
        
        cell.nameLabel.text = self.user[@"name"];
        
        [cell.piccyButton setTitle:@"" forState:UIControlStateNormal];
        
        cell.postImage = [AppMethods roundedCornerImageView:cell.postImage withURL:piccy.postGifUrl];
        
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
            
            [self deletePiccy:piccy];
        }]];
        UIMenu *menu =
        [UIMenu menuWithTitle:@""
                     children:actions];
        
        
        [cell.postOptions setMenu:menu];
        
        return cell;
        
    } else {
        Piccy *piccy = self.piccys[indexPath.row];
        PiccyViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PiccyViewCell"];
        
        cell.username.text = [NSString stringWithFormat:@"@%@", piccy.user[@"username"]];
        cell.name.text = piccy.user[@"name"];
        
        cell.timeSpent.text = piccy[@"timeSpent"];
        
        [cell.nameButton setTitle:@"" forState:UIControlStateNormal];
        [cell.usernameButton setTitle:@"" forState:UIControlStateNormal];
        [cell.pfpButton setTitle:@"" forState:UIControlStateNormal];
        [cell.piccyButton setTitle:@"" forState:UIControlStateNormal];
        
        NSLog(@"Self user posted today: %d", [self.user[@"postedToday"] boolValue]);
        if(piccy.replyCount == 0 && [self.user[@"postedToday"] boolValue] == 1) {
            [cell.otherCaptionButton setTitle:@"add a comment" forState:UIControlStateNormal];
        } else if(piccy.replyCount == 1 && [self.user[@"postedToday"] boolValue] == 1){
            [cell.otherCaptionButton setTitle:@"view comment" forState:UIControlStateNormal];
        } else if([self.user[@"postedToday"] boolValue] == 1){
            NSString *commentString = [NSString stringWithFormat:@"view %d comments", piccy.replyCount];
            [cell.otherCaptionButton setTitle:commentString forState:UIControlStateNormal];
        } else {
            [cell.otherCaptionButton setTitle:@"" forState:UIControlStateNormal];
            cell.otherCaptionButton.alpha = 0;
        }
       
        
        //Time of post
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        formatter.dateStyle = NSDateFormatterNoStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
        NSDate *timePosted = piccy.createdAt;
        cell.timeOfPost.text = [formatter stringFromDate:timePosted];
        
        //Profile picture
        cell.profilePic = [AppMethods roundImageView:cell.profilePic withURL:piccy.user[@"profilePictureURL"]];
        
        //Post image
        cell.postImage = [AppMethods roundedCornerImageView:cell.postImage withURL:piccy.postGifUrl];
        
        //Blurs the image and add the post button if the user hasnt posted today
        cell.visualEffect.frame = cell.postImage.bounds;
        cell.visualEffect.layer.masksToBounds = false;
        cell.visualEffect.layer.cornerRadius = cell.visualEffect.bounds.size.width/12;
        cell.visualEffect.clipsToBounds = true;
        
        [cell.postButton addTarget:self action:@selector(piccyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.postButton.layer.cornerRadius = 10;
        cell.postButton.clipsToBounds = YES;
        
        if([self.user[@"postedToday"] boolValue] != true) {
            cell.visualEffect.alpha = 1;
            cell.caption.text = @"";
            cell.postButton.alpha = 1;
            cell.postButton.userInteractionEnabled = true;
            cell.otherCaptionButton.alpha = 0;
            cell.otherCaptionButton.userInteractionEnabled = false;
        } else {
            //Doesnt show the caption unless you have already posted
            cell.caption.text = piccy[@"caption"];
            cell.visualEffect.alpha = 0;
            cell.postButton.alpha = 0;
            cell.postButton.userInteractionEnabled = false;
            cell.otherCaptionButton.alpha = 1;
            cell.otherCaptionButton.userInteractionEnabled = true;
        }
        
        //Options button and menu
        [cell.optionsButton setShowsMenuAsPrimaryAction:YES];
        
        //Array of actions shown in the menu
        NSMutableArray *actions = [[NSMutableArray alloc] init];
        [actions addObject:[UIAction actionWithTitle:@"📝 Report"
                                               image:nil
                                          identifier:nil
                                             handler:^(__kindof UIAction* _Nonnull action) {
            [AppMethods reportPiccy:self.piccys[indexPath.row] onViewController:self];
            
        }]];
        UIMenu *menu =
        [UIMenu menuWithTitle:@""
                     children:actions];
        
        
        [cell.optionsButton setMenu:menu];
        
        //turning off comments button if on the discovery page
        if(self.segSelected == 1) {
            cell.otherCaptionButton.alpha = 0;
            cell.otherCaptionButton.userInteractionEnabled = false;
            cell.reactionImage.alpha = 0;
            cell.reactionButton.alpha = 0;
            cell.reactionButton.userInteractionEnabled = false;
        } else {
            cell.otherCaptionButton.alpha = 1;
            cell.otherCaptionButton.userInteractionEnabled = true;
            cell.reactionImage.alpha = 1;
            cell.reactionButton.alpha = 1;
            cell.reactionButton.userInteractionEnabled = true;
        }
        
        if([piccy[@"reactedUsernames"] containsObject:self.user.username] && self.segSelected == 0) {
            cell.reactionImage.alpha = 1;
            PiccyReaction *reaction = [self queryReaction:piccy];
            cell.reactionImage = [AppMethods roundImageView:cell.reactionImage withURL:reaction.reactionURL];
            
            [cell.reactionButton setImage:nil forState:UIControlStateNormal];
            
        } else if(self.segSelected == 0){
            cell.reactionImage.alpha = 0;
            cell.reactionButton.alpha = 1;
            cell.reactionButton.userInteractionEnabled = 1;
            [cell.reactionButton setImage:[UIImage systemImageNamed:@"plus.circle.fill"] forState:UIControlStateNormal];
        }
        
        return cell;
    }
}

-(PiccyReaction *) queryReaction:(Piccy *) piccy {
    PFQuery *query = [PFQuery queryWithClassName:@"PiccyReaction"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"username"];
    [query includeKey:@"piccy"];
    [query whereKey:@"username" equalTo:self.user.username];
    [query whereKey:@"piccy" equalTo: piccy];
    NSArray *reaction = [query findObjects];
    if([reaction count] == 0) {
        NSLog(@"Error getting reaction");
        return nil;
    }
    return reaction[0];
}

//Deleting piccy functionality different from refactored one
-(void) deletePiccy:(Piccy *) piccy {
    __weak __typeof(self) weakSelf = self;
    [piccy deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
               return;
       }
        if(error == nil) {
            NSLog(@"Piccy deleted");
            NSMutableArray *mutPiccys = [[NSMutableArray alloc] initWithArray:self.piccys];
            [mutPiccys removeObject:piccy];
            strongSelf.piccys = [[NSArray alloc] initWithArray:mutPiccys];
            strongSelf.user[@"postedToday"] = @(NO);
            strongSelf.user[@"deletedToday"] = @(YES);
            strongSelf.user[@"deletedUpdate"] = [NSDate date];
            [strongSelf.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(error == nil) {
                    NSLog(@"User posted today after deleting piccy saved");
                    [strongSelf queryPiccys];
                }
            }];
        } else {
            NSLog(@"Could not delete piccy");
        }
        
    }];
}


//These are for when you click on either of the different buttons to swap tabs
- (IBAction)homeClicked:(id)sender {
    if(self.segSelected == 1) {
        [AppMethods button:self.homeButton swapStateWithButton:self.discoveryButton];
        self.homeButton.layer.cornerRadius = 15;
        self.segSelected = 0;
        [self queryPiccys];
    }
}

- (IBAction)discoveryClicked:(id)sender {
    if(self.segSelected == 0) {
        [AppMethods button:self.discoveryButton swapStateWithButton:self.homeButton];
        self.discoveryButton.layer.cornerRadius = 15;
        self.segSelected = 1;
        [self queryDiscovery:10];
    }
}
//When the reaction button is clicked
- (IBAction)reactionClicked:(id)sender {
    UIView *content = (UIView *)[(UIView *) sender superview];
    PiccyViewCell *cell = (PiccyViewCell *)[content superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Piccy *piccy = self.piccys[indexPath.row];
    if(![piccy.reactedUsernames containsObject:self.user.username]) {
        [self performSegueWithIdentifier:@"reactionSegue" sender:sender];
    } else {
        [self performSegueWithIdentifier:@"reactionPageSegue" sender:sender];
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row + 1 == self.piccys.count && self.segSelected == 1 && self.endDiscovery == false) {
        [self queryDiscovery:(int)(self.piccys.count + 10)];
    }
}

//Gesture stuff
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{

    return YES;
}

- (void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint velocity = [gestureRecognizer velocityInView:self.tableView];
     if(velocity.y > 0) {
        [self fadeIn:self.homeButton];
         [self fadeIn:self.discoveryButton];
    } else {
        [self fadeOut:self.homeButton];
         [self fadeOut:self.discoveryButton];
    }
}

//fade in and out for buttons
-(void) fadeIn: (UIButton *) button {
    [UIView animateWithDuration:0.2f animations:^{
        [button setAlpha:1.0f];
        [button setUserInteractionEnabled:true];
    }];
}

-(void) fadeOut: (UIButton *) button{
    [UIView animateWithDuration:0.2f animations:^{
        [button setAlpha:0.0f];
        [button setUserInteractionEnabled:false];
    }];
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
        piccyController.isReaction = false;
    } else if([segue.identifier isEqualToString:@"commentsSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        CommentsViewController *commentsController = (CommentsViewController*)navigationController.topViewController;
        commentsController.piccy = self.userPiccy[0];
        commentsController.isSelf = true;
        commentsController.reactionStart = false;
    } else if([segue.identifier isEqualToString:@"otherCommentsSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        CommentsViewController *commentsController = (CommentsViewController*)navigationController.topViewController;
        UIView *content = (UIView *)[(UIView *) sender superview];
        PiccyViewCell *cell = (PiccyViewCell *)[content superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        Piccy *piccyToPass = self.piccys[indexPath.item];
        commentsController.piccy = piccyToPass;
        commentsController.isSelf = false;
        commentsController.reactionStart = false;
    } else if([segue.identifier isEqualToString:@"otherProfileSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        OtherProfileViewController *commentsController = (OtherProfileViewController*)navigationController.topViewController;
        UIView *content = (UIView *)[(UIView *) sender superview];
        PiccyViewCell *cell = (PiccyViewCell *)[content superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        Piccy *piccyToPass = self.piccys[indexPath.row];
        commentsController.user = piccyToPass.user;
    } else if([segue.identifier isEqualToString:@"detailsSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        PiccyDetailViewController *detailsController = (PiccyDetailViewController*)navigationController.topViewController;
        UIView *content = (UIView *)[(UIView *) sender superview];
        PiccyViewCell *cell = (PiccyViewCell *)[content superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        Piccy *piccyToPass = self.piccys[indexPath.row];
        detailsController.piccy = piccyToPass;
        self.direction = 1;
        segue.destinationViewController.transitioningDelegate = self;
        segue.destinationViewController.modalPresentationStyle = UIModalPresentationCustom;
    } else if([segue.identifier isEqualToString:@"profileSegue"]) {
        self.direction = 4;
        segue.destinationViewController.transitioningDelegate = self;
        segue.destinationViewController.modalPresentationStyle = UIModalPresentationCustom;
    } else if([segue.identifier isEqualToString:@"friendsSegue"]) {
        self.direction = 3;
        segue.destinationViewController.transitioningDelegate = self;
        segue.destinationViewController.modalPresentationStyle = UIModalPresentationCustom;
    } else if([segue.identifier isEqualToString:@"reactionSegue"]) {
        //Passing the daily loop to the piccy screen
        UINavigationController *navigationController = [segue destinationViewController];
        DailyPiccyViewController *piccyController = (DailyPiccyViewController*)navigationController.topViewController;
        piccyController.isReaction = true;
        UIView *content = (UIView *)[(UIView *) sender superview];
        piccyController.piccyLoop = self.loops[0];
        PiccyViewCell *cell = (PiccyViewCell *)[content superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        Piccy *piccyToPass = self.piccys[indexPath.row];
        piccyController.piccy = piccyToPass;
    } else if([segue.identifier isEqualToString:@"reactionPageSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        CommentsViewController *commentsController = (CommentsViewController*)navigationController.topViewController;
        UIView *content = (UIView *)[(UIView *) sender superview];
        PiccyViewCell *cell = (PiccyViewCell *)[content superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        Piccy *piccyToPass = self.piccys[indexPath.item];
        commentsController.piccy = piccyToPass;
        commentsController.isSelf = false;
        commentsController.reactionStart = true;
    }
}

// MARK:- Bonsai Controller Delegate
- (CGRect)frameOfPresentedViewIn:(CGRect)containerViewFrame {
    if(self.direction == 1) {
        return CGRectMake(0, containerViewFrame.size.height / 4, containerViewFrame.size.width, containerViewFrame.size.height / (4.0 / 3.0));
    }
    return CGRectMake(0, 0, containerViewFrame.size.width, containerViewFrame.size.height);
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    if(self.direction == 1) {
        // Slide animation from .left, .right, .top, .bottom
        return [[BonsaiController alloc] initFromDirection:DirectionBottom blurEffectStyle:UIBlurEffectStyleRegular presentedViewController:presented delegate:self];
    } else if(self.direction == 3) {
        return [[BonsaiController alloc] initFromDirection:DirectionLeft blurEffectStyle:UIBlurEffectStyleSystemUltraThinMaterialDark presentedViewController:presented delegate:self];
    } else if(self.direction == 2) {
        return [[BonsaiController alloc] initFromDirection:DirectionTop blurEffectStyle:UIBlurEffectStyleRegular presentedViewController:presented delegate:self];
    } else {
        return [[BonsaiController alloc] initFromDirection:DirectionRight blurEffectStyle:UIBlurEffectStyleSystemUltraThinMaterialDark presentedViewController:presented delegate:self];
    }
    
}

@end
