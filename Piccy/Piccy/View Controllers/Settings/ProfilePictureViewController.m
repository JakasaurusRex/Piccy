//
//  ProfilePictureViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/13/22.
//

#import "ProfilePictureViewController.h"
#import "GifCollectionViewCell.h"
#import "APIManager.h"
#import <Parse/Parse.h>
#import "UIImage+animatedGIF.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "MagicalEnums.h"
#import "AppMethods.h"

@interface ProfilePictureViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, CHTCollectionViewDelegateWaterfallLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) NSArray *gifs;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSTimer *timer;
@property int secs;
@property int mins;
@property NSMutableArray *cellSizes;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) NSString *gifUrl;
@property (nonatomic) bool leaving;
@property (nonatomic, strong) NSString *searchText;
@property (nonatomic) bool reachedEnd;
@property (nonatomic, strong) NSString *next;
@property (weak, nonatomic) IBOutlet UILabel *noPiccyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *noPiccyImage;

@end

@implementation ProfilePictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    self.searchBar.delegate = self;
    self.activityIndicator = [AppMethods setupActivityIndicator:self.activityIndicator onView:self.view];
    
    [self loadGifs: 21];
    
    self.timerLabel.textColor = [UIColor whiteColor];
    self.mins = ProfilePictureMinuteStart;
    self.secs = ProfilePictureSecondStart;
    self.leaving = false;
    
    if(self.newUser == true) {
        [self.backButton setUserInteractionEnabled:NO];
        [self.backButton setAlpha:0];
        [AppMethods pauseWithActivityIndicator:self.activityIndicator onView:self.view];
        [self alertWithTitle:@"Welcome to Piccy!" message:@"Welcome to Piccy. Before you start playing with friends, this will act as a tutorial to learn how to play. You will have 1 minute to search for a gif related to a topic of the day and find a funny GIF by searching through tenors GIF library. Right now you can learn how to use this feature by selecting a profile picture related to you. Click ok to begin searching for a profile picture and save to save your selection (you can always change it later)!"];
    }
    self.noPiccyImage.alpha = 0;
    self.noPiccyLabel.alpha = 0;
    
    self.timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdownTimer) userInfo:nil repeats:YES];
}

//Countdown timer for user to pick a pfp
-(void) countdownTimer {
    if((self.mins>0 || self.secs>=0) && self.mins>=0)
    {
        if(self.secs==0)
        {
            self.mins-=1;
            self.secs=59;
        }
        else if(self.secs>0)
        {
            self.secs-=1;
            if(self.secs < ProfilePictureSecondRed && self.mins < 1) {
                self.timerLabel.textColor = [UIColor redColor];
                
            } else if (self.secs < ProfilePictureSecondOrange && self.mins < 1) {
                self.timerLabel.textColor = [UIColor systemOrangeColor];
            } else {
                self.timerLabel.textColor = [UIColor whiteColor];
            }
        }
        if(self.mins>-1)
        [self.timerLabel setText:[NSString stringWithFormat:@"%@%d%@%02d",@"Time: ",self.mins,@":",self.secs]];
    }
    else
    {
        if(self.newUser == true) {
            [AppMethods pauseWithActivityIndicator:self.activityIndicator onView:self.view];
            [self alertWithTitle:@"Timer up!" message:@"Normally at this time, your time would be up to select a Piccy and it would be considered late. Since you are learning we will give you an extra minute to keep searching for a profile picture."];
            self.mins = ProfilePictureMinuteStart;
            self.secs = ProfilePictureSecondStart;
        } else {
            [self.timer invalidate];
            [self dismissViewControllerAnimated:true completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loadProfileSettings" object:nil];
        }
    }
}

//Calls the api when the user types or is on teh feature screen
-(void) loadGifs:(int) numGifs {
    self.noPiccyImage.alpha = 0;
    self.noPiccyLabel.alpha = 0;
    [self.activityIndicator startAnimating];
    __weak __typeof(self) weakSelf = self;
    if([self.searchBar.text isEqualToString:@""]) {
        [[APIManager shared] getFeaturedGifs:numGifs completion:^(NSDictionary *gifs, NSError *error) {
            __strong __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                   return;
           }
            if(error == nil) {
                NSLog(@"%@", gifs[@"results"]);
                
                //infinite scroll next
                self.next = gifs[@"next"];
                if([self.next isEqualToString:@""]) {
                    strongSelf.reachedEnd = true;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.collectionView reloadData];
                        [strongSelf.activityIndicator stopAnimating];
                    });
                } else {
                    self.reachedEnd = false;
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
        [[APIManager shared] getGifsWithSearchString:self.searchBar.text limit:numGifs completion:^(NSDictionary *gifs, NSError *error, NSString *searchString) {
            __strong __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                   return;
           }
            if(error == nil) {
                NSLog(@"%@", gifs[@"results"]);
                
                //check if we have reached the end of the search
                if([gifs[@"results"] count] == 0) {
                    strongSelf.noPiccyImage.alpha = 1;
                    strongSelf.noPiccyLabel.alpha = 1;
                    strongSelf.noPiccyImage = [AppMethods roundedCornerImageView:self.noPiccyImage withURL:@"https://c.tenor.com/5UteYmq1UIIAAAAC/grill-sponge-bob.gif"];
                }
                
                self.next = gifs[@"next"];
                if([self.next isEqualToString:@""]) {
                    strongSelf.reachedEnd = true;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.collectionView reloadData];
                        [strongSelf.activityIndicator stopAnimating];
                    });
                } else {
                    self.reachedEnd = false;
                }
                
                strongSelf.gifs = [[NSArray alloc] initWithArray:gifs[@"results"]];
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
                NSLog(@"%@", gifs[@"results"]);
                
                self.next = gifs[@"next"];
                if([self.next isEqualToString:@""]) {
                    strongSelf.reachedEnd = true;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.collectionView reloadData];
                        [strongSelf.activityIndicator stopAnimating];
                    });
                } else {
                    self.reachedEnd = false;
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
                NSLog(@"%@", gifs[@"results"]);
                
                //check if we have reached the end of the search
                self.next = gifs[@"next"];
                if([self.next isEqualToString:@""]) {
                    strongSelf.reachedEnd = true;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.collectionView reloadData];
                        [strongSelf.activityIndicator stopAnimating];
                    });
                } else {
                    self.reachedEnd = false;
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

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
    //Tells the profile settings to load the potentially new pfp
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadProfileSettings" object:nil];
}

- (IBAction)saveButton:(id)sender {
    [self savePFP];
    if(self.newUser == true) {
        [AppMethods pauseWithActivityIndicator:self.activityIndicator onView:self.view];
        self.leaving = true;
        [self alertWithTitle:@"Congrats!" message:@"Congrats on picking your profile picture and completing your first Piccy! After clicking ok you will be sent to the home screen, you can customize your profile picture at any time by navigating to settings on your profile page. Have fun and thanks for downloading Piccy!"];
    }
}

//Called when user clicks the save pfp button
-(void) savePFP {
    [AppMethods pauseWithActivityIndicator:self.activityIndicator onView:self.view];
    PFUser *user = [PFUser currentUser];
    user[@"profilePictureURL"] = self.gifUrl;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil) {
            NSLog(@"Profile picture saved");
            [self alertWithTitle:@"Profile picture saved" message:@"Successfully saved profile picture!"];
            [AppMethods unpauseWithActivityIndicator:self.activityIndicator onView:self.view];
        } else {
            NSLog(@"Profile picture failed");
            [self alertWithTitle:@"Profile picture could not be saved" message:@"Unuccessful saving profile picture!"];
            [AppMethods unpauseWithActivityIndicator:self.activityIndicator onView:self.view];
        }
    }];
}

//Just sets the collection view image to the respective gif
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

//Returns the number of gifs in teh collection
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.gifs count];
}

//When the user clicks on a gif
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for(int i = 0; i < [self.gifs count]; i++) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
        GifCollectionViewCell *cell = (GifCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:index];
        if([index isEqual:indexPath]) {
            //Highlighs, allows the user to save, and stors the gif url
            [cell.highlightView setAlpha:0.7];
            self.gifUrl = self.gifs[i][@"media_formats"][@"tinygif"][@"url"];
            self.saveButton.userInteractionEnabled = true;
            self.saveButton.tintColor = [UIColor orangeColor];
        } else {
            //sets highlight to none bc the user didnt click on this
            [cell.highlightView setAlpha:0];
        }
    }
}

//Used to implement the waterfall style collection view layout (tumblr or pintrest style)
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //gets the size of an item at any give index
  return [self.cellSizes[indexPath.item] CGSizeValue];
}

// Updates when the text on the search bar changes to allow for searching functionality
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.gifs = [[NSArray alloc] init];
    [self.collectionView reloadData];
    self.searchText = searchText;
    [self loadGifs: 21];
    self.next = @"";
    self.saveButton.userInteractionEnabled = false;
    self.saveButton.tintColor = [UIColor lightGrayColor];
}


//Alert used to alert user when saving different than other alerts so i didnt refactor
- (void) alertWithTitle: (NSString *)title message:(NSString *)text {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                               message:text
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                             // handle response here.
        [AppMethods unpauseWithActivityIndicator:self.activityIndicator onView:self.view];
        if(self.leaving) {
            [self dismissViewControllerAnimated:true completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"newUserPFPSaved" object:nil];
        }
                                                     }];
    // add the OK action to the alert controller
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{
        // optional code for what happens after the alert controller has finished presenting
    }];
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
