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
@end

@implementation ProfilePictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    self.searchBar.delegate = self;
    [self setupActivityIndicator];
    
    [self loadGifs];
    
    self.timerLabel.textColor = [UIColor whiteColor];
    self.mins = 1;
    self.secs = 00;
    self.leaving = false;
    
    if(self.newUser == true) {
        [self.backButton setUserInteractionEnabled:NO];
        [self.backButton setAlpha:0];
        [self pause];
        [self alertWithTitle:@"Welcome to Piccy!" message:@"Welcome to Piccy. Before you start playing with friends, this will act as a tutorial to learn how to play. You will have 1 minute to search for a gif related to a topic of the day and find a funny GIF by searching through tenors GIF library. Right now you can learn how to use this feature by selecting a profile picture related to you. Click ok to begin searching for a profile picture and save to save your selection (you can always change it later)!"];
    }
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
            if(self.secs < 15 && self.mins < 1) {
                self.timerLabel.textColor = [UIColor redColor];
                
            } else if (self.secs < 30 && self.mins < 1) {
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
            [self pause];
            [self alertWithTitle:@"Timer up!" message:@"Normally at this time, your time would be up to select a Piccy and it would be considered late. Since you are learning we will give you an extra minute to keep searching for a profile picture."];
            self.mins = 1;
            self.secs = 00;
        } else {
            [self.timer invalidate];
            [self dismissViewControllerAnimated:true completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loadProfileSettings" object:nil];
        }
    }
}

//Calls the api when the user types or is on teh feature screen
-(void) loadGifs {
    [self.activityIndicator startAnimating];
    if([self.searchBar.text isEqualToString:@""]) {
        [[APIManager shared] getFeaturedGifs:30 completion:^(NSDictionary *gifs, NSError *error) {
            if(error == nil) {
                NSLog(@"%@", gifs[@"results"]);
                self.gifs = [[NSArray alloc] initWithArray:gifs[@"results"]];
                self.cellSizes = [[NSMutableArray alloc] init];

                for(int i = 0; i < [self.gifs count]; i++) {
                    UIImage *image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:self.gifs[i][@"media_formats"][@"tinygif"][@"url"]]];
                    [self.cellSizes addObject:[NSValue valueWithCGSize:CGSizeMake(image.size.width, image.size.height)]];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                    [self.activityIndicator stopAnimating];
                });
            } else {
                NSLog(@"Error loading gifs: %@", error);
            }
        }];
    } else {
        [[APIManager shared] getGifsWithSearchString:self.searchBar.text limit:21 completion:^(NSDictionary *gifs, NSError *error) {
            if(error == nil) {
                NSLog(@"%@", gifs[@"results"]);
                self.gifs = [[NSArray alloc] initWithArray:gifs[@"results"]];
                
                for(int i = 0; i < [self.gifs count]; i++) {
                    UIImage *image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:self.gifs[i][@"media_formats"][@"tinygif"][@"url"]]];
                    //Adds the size of the image so that we can use that as a basis for the waterfall collection layout later
                    [self.cellSizes addObject:[NSValue valueWithCGSize:CGSizeMake(image.size.width, image.size.height)]];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                    [self.activityIndicator stopAnimating];
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
        [self pause];
        self.leaving = true;
        [self alertWithTitle:@"Congrats!" message:@"Congrats on picking your profile picture and completing your first Piccy! After clicking ok you will be sent to the home screen, you can customize your profile picture at any time by navigating to settings on your profile page. Have fun and thanks for downloading Piccy!"];
    }
}

//Called when user clicks the save pfp button
-(void) savePFP {
    [self pause];
    PFUser *user = [PFUser currentUser];
    user[@"profilePictureURL"] = self.gifUrl;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil) {
            NSLog(@"Profile picture saved");
            [self alertWithTitle:@"Profile picture saved" message:@"Successfully saved profile picture!"];
            [self unpause];
        } else {
            NSLog(@"Profile picture failed");
            [self alertWithTitle:@"Profile picture could not be saved" message:@"Unuccessful saving profile picture!"];
            [self unpause];
        }
    }];
}

//Just sets the collection view image to the respective gif
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GifCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"GifViewCell" forIndexPath:indexPath];
    //what the dog doin
    cell.gifImageView.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:self.gifs[indexPath.item][@"media_formats"][@"tinygif"][@"url"]]];
    
    return cell;
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
    [self loadGifs];
    self.saveButton.userInteractionEnabled = false;
    self.saveButton.tintColor = [UIColor lightGrayColor];
}

//Used to show loading indicator while user is waiting for gifs to load
-(void) setupActivityIndicator{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.activityIndicator.center = self.view.center;
    self.activityIndicator.hidesWhenStopped = true;
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleMedium];
    [self.view addSubview:self.activityIndicator];
}

//Alert used to alert user when saving
- (void) alertWithTitle: (NSString *)title message:(NSString *)text {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                               message:text
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                             // handle response here.
        [self unpause];
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

//Pausing used for the saving alert as well

//Pauses the screen with an activity indicator while waiting for parse to respond about the request
-(void) pause {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.activityIndicator.center = self.view.center;
    self.activityIndicator.hidesWhenStopped = true;
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleMedium];
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    [self.view setUserInteractionEnabled:NO];
}

//unpauses the screen
-(void) unpause{
    [self.activityIndicator stopAnimating];
    [self.view setUserInteractionEnabled:YES];
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
