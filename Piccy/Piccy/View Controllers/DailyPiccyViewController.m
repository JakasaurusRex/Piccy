//
//  DailyPiccyViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/15/22.
//

#import "DailyPiccyViewController.h"
#import "GifCollectionViewCell.h"
#import "APIManager.h"
#import <Parse/Parse.h>
#import "UIImage+animatedGIF.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "PostViewController.h"
#import "PiccyReaction.h"
#import "AppMethods.h"

@interface DailyPiccyViewController () <UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSArray *gifs;
@property (strong, nonatomic) NSTimer *timer;
@property int secs;
@property int mins;
@property (nonatomic, strong) NSMutableArray *cellSizes;
@property (nonatomic, strong) NSString *gifUrl;
@property (nonatomic) bool late;
@property (nonatomic, strong) NSString *searchText;
@property (nonatomic) bool reachedEnd;
@property (nonatomic, strong) NSString *next;

@property (weak, nonatomic) IBOutlet UILabel *noPiccyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *noPiccyImage;

@end

@implementation DailyPiccyViewController


-(void)viewWillAppear:(BOOL)animated {
    //Setup the activity indicators to notify the user gifs are being loaded
    self.activityIndicator = [AppMethods setupActivityIndicator:self.activityIndicator onView:self.view];
    [self loadGifs];
    //Sets the topic label to the new daily word
    if(!self.isReaction) {
        self.topicLabel.text = [self.piccyLoop.dailyWord lowercaseString];
    } else {
        self.topicLabel.text = @"";
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //Adding notification so the user can go back home after posting on the new view controller
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goHome) name:@"goHome" object:nil];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    //turn off autocapitalization of text field
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.delegate = self;
    
    //Alert to inform the user what to do and make sure they are ready
    PFUser *user = [PFUser currentUser];
    if(self.isReaction == false) {
        [self.nextButton setTitle:@"Next" forState:UIControlStateNormal];
        NSLog(@"user deleted today: %@", user[@"deletedToday"]);
        if([user[@"deletedToday"] boolValue] == 0) {
            [self alertWithTitle:@"Daily Piccy" message:@"You will have 1 minute to find a GIF for the random daily topic at the top of the screen. If you take longer than 1 minute, your Piccy will be considered late. Press ok to start Piccying."];
            
            self.timerLabel.textColor = [UIColor labelColor];
            self.mins = 1;
            self.secs = 00;
        } else {
            self.timerLabel.text = @"Time: 0:00";
            [self alertWithTitle:@"Daily Piccy" message:@"Since you started or deleted your Piccy today, your post will be considered late. Press ok to start Piccying."];
            self.timerLabel.textColor = [UIColor labelColor];
            self.mins = 0;
            self.secs = 00;
        }
        
        //Making it so it says user deleted today so if you delete your piccy and you redo it, its considered late
        user[@"deletedToday"] = @(YES);
        user[@"deletedUpdate"] = [NSDate date];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(error == nil) {
                NSLog(@"Saved user deleted today");
            } else {
                NSLog(@"Error saving user deleted today");
            }
        }];
        
        
    } else {
        [self.nextButton setTitle:@"Post reaction" forState:UIControlStateNormal];
        self.timerLabel.text = @"Time: 0:30";
        self.mins = 0;
        self.secs = 30;
        [self alertWithTitle:@"Piccy Reaction" message:@"You will have 30 seconds to find a reaction to your friends Piccy. If you do not find one in 30 seconds, this screen will dismiss. Click Ok to begin."];
    }
    self.late = false;
    
    self.noPiccyLabel.alpha = 0;
    self.noPiccyImage.alpha = 0;
    
    if([user[@"darkMode"] isEqual:@(YES) ]) {
        self.view.backgroundColor = [UIColor blackColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
}

//Function called when the user posts a piccy
-(void) goHome {
    [self dismissViewControllerAnimated:true completion:nil];
}

//Countdown timer accounting for if the user is posting late
-(void) countdownTimer {
    if((self.mins>0 || self.secs>=0) && (self.mins>=0 && !self.late))
    {
        if(self.secs==0 && self.mins != 0)
        {
            self.mins-=1;
            self.secs=59;
        }
        else if(self.secs>0)
        {
            self.secs-=1;
            if(self.secs < 15 && self.mins < 1) {
                self.timerLabel.textColor = [UIColor redColor];
                
            } else if (self.secs < 30 && self.mins < 1) {
                self.timerLabel.textColor = [UIColor systemOrangeColor];
            } else {
                self.timerLabel.textColor = [UIColor labelColor];
            }
        } else if(self.secs == 0 && self.mins == 0) {
            self.late = true;
        }
        if(self.mins>-1)
        [self.timerLabel setText:[NSString stringWithFormat:@"%@%d%@%02d",@"Time: ",self.mins,@":",self.secs]];
    } else {
        if(self.isReaction) {
            [self goHome];
        }
        self.timerLabel.textColor = [UIColor redColor];
        if(self.secs == 59) {
            self.mins += 1;
            self.secs = 00;
        } else {
            self.secs += 1;
        }
        [self.timerLabel setText:[NSString stringWithFormat:@"%@%d%@%02d",@"Time: -",self.mins,@":",self.secs]];
    
    }
}

//Same gif loading process done in the profile picture selection
-(void) loadGifs {
    self.noPiccyImage.alpha = 0;
    self.noPiccyLabel.alpha = 0;
    [self.activityIndicator startAnimating];
    __weak __typeof(self) weakSelf = self;
    if([self.searchBar.text isEqualToString:@""]) {
        [[APIManager shared] getFeaturedGifs:30 completion:^(NSDictionary *gifs, NSError *error) {
            __strong __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                   return;
           }
            if(error == nil) {
                
                strongSelf.next = gifs[@"next"];
                if([strongSelf.next isEqualToString:@""]) {
                    strongSelf.reachedEnd = true;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.collectionView reloadData];
                        [strongSelf.activityIndicator stopAnimating];
                    });
                } else {
                    strongSelf.reachedEnd = false;
                }
                
                strongSelf.gifs = [[NSArray alloc] initWithArray:gifs[@"results"]];
                strongSelf.cellSizes = [[NSMutableArray alloc] init];

                for(int i = 0; i < [strongSelf.gifs count]; i++) {
                    UIImage *image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:strongSelf.gifs[i][@"media_formats"][@"tinygif"][@"url"]]];
                    [strongSelf.cellSizes addObject:[NSValue valueWithCGSize:CGSizeMake(image.size.width, image.size.height)]];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.collectionView reloadData];
                    [strongSelf.activityIndicator stopAnimating];
                });
            } else {
                NSLog(@"Error loading gifs: %@", error);
            }
        }];
    } else {
        [[APIManager shared] getGifsWithSearchString:self.searchBar.text limit:21 completion:^(NSDictionary *gifs, NSError *error, NSString *searchString) {
            __strong __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                   return;
           }
            if(error == nil) {
                
                
                if([gifs[@"results"] count] == 0) {
                    strongSelf.noPiccyImage.alpha = 1;
                    strongSelf.noPiccyLabel.alpha = 1;
                    strongSelf.noPiccyImage = [AppMethods roundedCornerImageView:strongSelf.noPiccyImage withURL:@"https://c.tenor.com/5UteYmq1UIIAAAAC/grill-sponge-bob.gif"];
                }
                
                strongSelf.next = gifs[@"next"];
                if([strongSelf.next isEqualToString:@""]) {
                    strongSelf.reachedEnd = true;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.collectionView reloadData];
                        [strongSelf.activityIndicator stopAnimating];
                    });
                } else {
                    strongSelf.reachedEnd = false;
                }
                
                strongSelf.gifs = [[NSArray alloc] initWithArray:gifs[@"results"]];
                if(![searchString isEqualToString:strongSelf.searchText]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.activityIndicator startAnimating];
                    });
                    return;
                }
                for(int i = 0; i < [strongSelf.gifs count]; i++) {
                    UIImage *image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:strongSelf.gifs[i][@"media_formats"][@"tinygif"][@"url"]]];
                    [strongSelf.cellSizes addObject:[NSValue valueWithCGSize:CGSizeMake(image.size.width, image.size.height)]];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.collectionView reloadData];
                    [strongSelf.activityIndicator stopAnimating];
                });
            } else {
                NSLog(@"Error loading gifs: %@", error);
            }
        }];
    }
}

//Infinite scroll
-(void) loadNextGifs {
    self.noPiccyImage.alpha = 0;
    self.noPiccyLabel.alpha = 0;
    __weak __typeof(self) weakSelf = self;
    if([self.searchBar.text isEqualToString:@""]) {
        [[APIManager shared] getFeaturedGifs:21 withPos:self.next completion:^(NSDictionary *gifs, NSError *error) {
            __strong __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                   return;
           }
            if(error == nil) {
                
                strongSelf.next = gifs[@"next"];
                if([strongSelf.next isEqualToString:@""]) {
                    strongSelf.reachedEnd = true;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.collectionView reloadData];
                        [strongSelf.activityIndicator stopAnimating];
                    });
                } else {
                    strongSelf.reachedEnd = false;
                }
                
                NSMutableArray *mutGifs = [[NSMutableArray alloc] initWithArray:strongSelf.gifs];
                [mutGifs addObjectsFromArray:gifs[@"results"]];
                strongSelf.gifs = [[NSArray alloc] initWithArray:mutGifs];
                
                strongSelf.cellSizes = [[NSMutableArray alloc] init];

                for(int i = 0; i < [strongSelf.gifs count]; i++) {
                    UIImage *image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:strongSelf.gifs[i][@"media_formats"][@"tinygif"][@"url"]]];
                    [strongSelf.cellSizes addObject:[NSValue valueWithCGSize:CGSizeMake(image.size.width, image.size.height)]];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.collectionView reloadData];
                    [strongSelf.activityIndicator stopAnimating];
                });
            } else {
                NSLog(@"Error loading gifs: %@", error);
            }
        }];
    } else {
        [[APIManager shared] getGifsWithSearchString:self.searchBar.text limit:21 withPos:self.next completion:^(NSDictionary *gifs, NSError *error, NSString *searchString) {
            __strong __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                   return;
           }
            if(error == nil) {
                
                //check if we have reached the end of the search
                strongSelf.next = gifs[@"next"];
                if([strongSelf.next isEqualToString:@""]) {
                    strongSelf.reachedEnd = true;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.collectionView reloadData];
                        [strongSelf.activityIndicator stopAnimating];
                    });
                } else {
                    strongSelf.reachedEnd = false;
                }
                NSMutableArray *mutGifs = [[NSMutableArray alloc] initWithArray:strongSelf.gifs];
                [mutGifs addObjectsFromArray:gifs[@"results"]];
                strongSelf.gifs = [[NSArray alloc] initWithArray:mutGifs];
                if(![strongSelf.searchText isEqualToString: searchString]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.activityIndicator startAnimating];
                    });
                    return;
                }
                for(int i = 0; i < [strongSelf.gifs count]; i++) {
                    UIImage *image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:strongSelf.gifs[i][@"media_formats"][@"tinygif"][@"url"]]];
                    //Adds the size of the image so that we can use that as a basis for the waterfall collection layout later
                    [strongSelf.cellSizes addObject:[NSValue valueWithCGSize:CGSizeMake(image.size.width, image.size.height)]];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.collectionView reloadData];
                    [strongSelf.activityIndicator stopAnimating];
                });
            } else {
                NSLog(@"Error loading gifs: %@", error);
            }
        }];
    }
}

//Same collection view process as profile picture selection too
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GifCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"GifViewCell" forIndexPath:indexPath];
    //what the dog doin
    cell.gifImageView.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:self.gifs[indexPath.item][@"media_formats"][@"tinygif"][@"url"]]];
    
    [self.activityIndicator stopAnimating];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.item + 5 == [self.gifs count]){
    //Last cell was drawn
        if(!self.reachedEnd) {
            [self loadNextGifs];
        }
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.gifs count];
}

//When the user clicks on a gif
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for(int i = 0; i < [self.gifs count]; i++) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
        GifCollectionViewCell *cell = (GifCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:index];
        if([index isEqual:indexPath]) {
            [cell.highlightView setAlpha:0.7];
            self.gifUrl = self.gifs[i][@"media_formats"][@"tinygif"][@"url"];
        } else {
            [cell.highlightView setAlpha:0];
        }
    }
    self.nextButton.tintColor = [UIColor systemRedColor];
    self.nextButton.userInteractionEnabled = YES;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if([self.cellSizes count] == 0 || indexPath.item >= [self.cellSizes count]) {
        return CGSizeZero;
    }
  return [self.cellSizes[indexPath.item] CGSizeValue];
}

// Updates when the text on the search bar changes to allow for searching functionality
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //Making it so the user cant search the daily word
    NSLog(@"daily word: %@ searchText: %@", self.piccyLoop.dailyWord, searchText);
    if([searchBar.text isEqualToString:self.piccyLoop.dailyWord] || [[searchBar.text lowercaseString] isEqualToString:[self.piccyLoop.dailyWord lowercaseString]] || [[searchBar.text lowercaseString] containsString:[self.piccyLoop.dailyWord lowercaseString]]) {
        [self.timer invalidate];
        [self alertWithTitle:@"Cheating is cheating and cheating is bad" message:@"Don't just look up the daily word! Get more creative!"];
        self.searchBar.text = @"";
        self.searchText = @"";
        self.gifs = [[NSArray alloc] init];
        self.next = @"";
        [self.collectionView reloadData];
        [self loadGifs];
        return;
    }
    if([searchBar.text isEqualToString:@""] && [self.searchText isEqualToString:@""]) {
        return;
    }
    self.gifs = [[NSArray alloc] init];
    self.next = @"";
    [self.collectionView reloadData];
    self.searchText = searchText;
    [self loadGifs];
}

/*
-(void) searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.gifs = [[NSArray alloc] init];
    [self.collectionView reloadData];
    self.searchText = searchBar.text;
    [self loadGifs];
}*/

- (void) alertWithTitle: (NSString *)title message:(NSString *)text {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                               message:text
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
            self.timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdownTimer) userInfo:nil repeats:YES];
        
                                                     }];
    // add the OK action to the alert controller
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{
        // optional code for what happens after the alert controller has finished presenting
    }];
}


//Segue to the post piccy screen
- (IBAction)nextButtonPressed:(id)sender {
    if(!self.isReaction) {
        NSLog(@"Next pressed");
        [self performSegueWithIdentifier:@"postSegue" sender:nil];
    } else {
        [self postReaction];
        [self goHome];
    }
    
}

-(void) postReaction {
    __weak __typeof(self) weakSelf = self;
    [PiccyReaction postReaction:self.gifUrl onPiccy:self.piccy withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
               return;
       }
        if(error == nil) {
            NSLog(@"Succesfully posted reaction");
            PFUser *user = [PFUser currentUser];
            NSMutableArray *reactedUsers = [[NSMutableArray alloc] initWithArray:strongSelf.piccy[@"reactedUsernames"]];
            [reactedUsers addObject:user.username];
            strongSelf.piccy[@"reactedUsernames"] = [[NSArray alloc] initWithArray:reactedUsers];
            [strongSelf.piccy saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(error == nil) {
                    NSLog(@"Saved Piccy with new username");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadHome" object:nil];
                } else {
                    NSLog(@"Error saving piccy with reaction username: %@", error);
                }
            }];
        } else {
            NSLog(@"Error posting reaction: %@", error);
        }
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"postSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        PostViewController *postController = (PostViewController*)navigationController.topViewController;
        postController.piccyUrl = self.gifUrl;
        postController.piccyLoop = self.piccyLoop;
        
        //changes the type of text sent to the post piccy screen depending upon if the user was late or not
        if(!self.late) {
            postController.timer = [NSString stringWithFormat:@"Time left: %d:%02d", self.mins, self.secs];
        } else {
            postController.timer = [NSString stringWithFormat:@"Late Piccy: -%d:%02d", self.mins, self.secs];
        }
    }
}


@end
