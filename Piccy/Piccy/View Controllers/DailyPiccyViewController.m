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
@end

@implementation DailyPiccyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Adding notification so the user can go back home after posting on the new view controller
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goHome) name:@"goHome" object:nil];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.delegate = self;
    
    //Setup the activity indicators to notify the user gifs are being loaded
    [self setupActivityIndicator];
    [self loadGifs];
    
    //Sets the topic label to the new daily word
    self.topicLabel.text = self.piccyLoop.dailyWord;
    
    //Alert to inform the user what to do and make sure they are ready
    [self alertWithTitle:@"Daily Piccy" message:@"You will have 1 minute to find a GIF for the random daily topic at the top of the screen. If you take longer than 1 minute, your Piccy will be considered late. Press ok to start Piccying."];
    
    self.timerLabel.textColor = [UIColor whiteColor];
    self.mins = 1;
    self.secs = 00;
    self.late = false;
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
                self.timerLabel.textColor = [UIColor whiteColor];
            }
        } else if(self.secs == 0 && self.mins == 0) {
            self.late = true;
        }
        if(self.mins>-1)
        [self.timerLabel setText:[NSString stringWithFormat:@"%@%d%@%02d",@"Time: ",self.mins,@":",self.secs]];
    }
    else
    {
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

//Same collection view process as profile picture selection too
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GifCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"GifViewCell" forIndexPath:indexPath];
    //what the dog doin
    cell.gifImageView.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:self.gifs[indexPath.item][@"media_formats"][@"tinygif"][@"url"]]];
    
    return cell;
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
    self.nextButton.tintColor = [UIColor orangeColor];
    self.nextButton.userInteractionEnabled = YES;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return [self.cellSizes[indexPath.item] CGSizeValue];
}

// Updates when the text on the search bar changes to allow for searching functionality
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.gifs = [[NSArray alloc] init];
    [self.collectionView reloadData];
    [self loadGifs];
}

-(void) setupActivityIndicator{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.activityIndicator.center = self.view.center;
    self.activityIndicator.hidesWhenStopped = true;
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleMedium];
    [self.view addSubview:self.activityIndicator];
}

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

//Segue to the post piccy screen
- (IBAction)nextButtonPressed:(id)sender {
    NSLog(@"Next pressed");
    [self performSegueWithIdentifier:@"postSegue" sender:nil];
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
