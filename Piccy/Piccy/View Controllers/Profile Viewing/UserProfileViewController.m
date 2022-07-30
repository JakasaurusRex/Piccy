//
//  UserProfileViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/6/22.
//

#import "UserProfileViewController.h"
#import <Parse/Parse.h>
#import "UIImage+animatedGIF.h"
#import "ProfilePiccyViewCell.h"
#import "PBDCarouselCollectionViewLayout.h"
#import "Piccy.h"
#import "PiccyLoop.h"
#import "PiccyDetailViewController.h"
#import "APIManager.h"
#import <time.h>
#import "MagicalEnums.h"
@import BonsaiController;

@interface UserProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource, BonsaiControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *nameView;
@property (weak, nonatomic) IBOutlet UILabel *usernameView;
@property (weak, nonatomic) IBOutlet UILabel *bioView;
@property (weak, nonatomic) IBOutlet UILabel *profileView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *piccys;
@property (strong, nonatomic) NSArray *piccyLoops;
@property (strong, nonatomic) NSMutableDictionary *piccyDic;
@property (strong, nonatomic) NSArray *gifs;
@property (nonatomic) int direction;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadProfile) name:@"loadProfile" object:nil];
    // Do any additional setup after loading the view.
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    PBDCarouselCollectionViewLayout *layout = [[PBDCarouselCollectionViewLayout alloc] init];
    layout.itemSize = CGSizeMake(UserProfileLayoutDimensions, UserProfileLayoutDimensions);
    layout.interItemSpace = UserProfileItemSpacing;
    self.collectionView.collectionViewLayout = layout;

    self.direction = SegueDirectionsFromBottom; //Sets it to the bottom by default for the details page
    
    self.piccyLoops = [[NSArray alloc] init];
    
    [self loadProfile];
    [self queryUserPiccys];
    [self queryPiccyLoops];
    
}

-(void) loadProfile{
    PFUser *user = [PFUser currentUser];
    self.nameView.text = user[@"name"];
    self.usernameView.text = user[@"username"];
    self.bioView.text = user[@"bio"];
    if([user[@"darkMode"] boolValue] == YES) {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
        self.view.backgroundColor = [UIColor blackColor];
        self.nameView.textColor = [UIColor whiteColor];
        self.usernameView.textColor = [UIColor whiteColor];
        self.profileView.textColor = [UIColor whiteColor];
    } else {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
        self.view.backgroundColor = [UIColor whiteColor];
        self.nameView.textColor = [UIColor blackColor];
        self.usernameView.textColor = [UIColor blackColor];
        self.profileView.textColor = [UIColor blackColor];
    }
    if(![user[@"profilePictureURL"] isEqualToString:@""]) {
        self.profilePictureView.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:user[@"profilePictureURL"]]];
        self.profilePictureView.layer.masksToBounds = false;
        self.profilePictureView.layer.cornerRadius = self.profilePictureView.bounds.size.width/UIIntValuesCircularIconDivisor;
        self.profilePictureView.clipsToBounds = true;
        self.profilePictureView.contentMode = UIViewContentModeScaleAspectFill;
        self.profilePictureView.layer.borderWidth = 0.05;
    }
    [self loadRandomGifs];
}

//Query the last 14 user Piccys which I add to a dictionary with keys as the reset date since the last 14 piccys may not correspond to the last 14 daily resets
-(void) queryUserPiccys {
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Piccy"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"user"];
    [query whereKey:@"user" equalTo:user];
    query.limit = 14;
    __weak __typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
               return;
       }
        if(error == nil) {
            NSLog(@"Piccys successfully retrieved");
            strongSelf.piccys = objects;
            strongSelf.piccyDic = [[NSMutableDictionary alloc] initWithCapacity:14];
            for(int i = 0; i < [strongSelf.piccys count]; i++) {
                Piccy *piccy = strongSelf.piccys[i];
                [strongSelf.piccyDic setObject:piccy forKey:piccy.resetDate];
            }
            [strongSelf.collectionView reloadData];
        } else {
            NSLog(@"Piccys could not be retrived: %@", error);
        }
    }];
}

//Queries the last 14 piccy reset loops
-(void) queryPiccyLoops {
    PFQuery *query = [PFQuery queryWithClassName:@"PiccyLoop"];
    [query orderByDescending:@"createdAt"];
    query.limit = 14;
    __weak __typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
               return;
       }
        if(error == nil) {
            NSLog(@"PiccyLoops successfully retrieved");
            strongSelf.piccyLoops = objects;
            [strongSelf.collectionView reloadData];
        } else {
            NSLog(@"PiccyLoops could not be retrived: %@", error);
        }
    }];
}

//Dismisses the view controller and loads home when pressing back
- (IBAction)backButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadHome" object:nil];
    [self dismissViewControllerAnimated:true completion:nil];
}

//Returns the last 14 or the total amount of piccy loops if there arent 14
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if([self.piccyLoops count] > 14) {
        return 14;
    }
    return [self.piccyLoops count];
}

//Creates each piccy cell in the horizontal collection view
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProfilePiccyViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"ProfilePiccyViewCell" forIndexPath:indexPath];
    
    [cell.piccyButton setTitle:@"" forState:UIControlStateNormal];
    
    PiccyLoop *piccyLoop = self.piccyLoops[indexPath.item];
    Piccy *piccy = self.piccyDic[piccyLoop.dailyReset];
    
    cell.visualEffect.layer.masksToBounds = false;
    cell.visualEffect.layer.cornerRadius = cell.visualEffect.bounds.size.width/UIIntValuesRoundedCornerDivisor;
    cell.visualEffect.clipsToBounds = true;
    cell.visualEffect.contentMode = UIViewContentModeScaleAspectFill;
    cell.visualEffect.layer.borderWidth = 0.05;
    
    cell.piccyLabel.strokeSize = 0.5;
    cell.piccyLabel.strokeColor = [UIColor blackColor];
    cell.timeLabel.strokeSize = 0.5;
    cell.timeLabel.strokeColor = [UIColor blackColor];
    cell.dateLabel.strokeSize = 0.5;
    cell.dateLabel.strokeColor = [UIColor blackColor];
    
    if(piccy != nil) {
        //change cell;
        //Post image
        cell.postImage.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:piccy.postGifUrl]];
        cell.postImage.layer.masksToBounds = false;
        cell.postImage.layer.cornerRadius = cell.postImage.bounds.size.width/UIIntValuesRoundedCornerDivisor;
        cell.postImage.clipsToBounds = true;
        cell.postImage.contentMode = UIViewContentModeScaleAspectFill;
        cell.postImage.layer.borderWidth = 0.05;
        
        
        cell.piccyLabel.text = piccyLoop.dailyWord;
        
        NSDate *date = piccyLoop.dailyReset;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
        
        cell.dateLabel.text = [formatter stringFromDate:date];
        
        cell.timeLabel.text = piccy.timeSpent;
        
        [cell setUserInteractionEnabled:true];
        
    } else if(indexPath.item == 0){
        //special case for first cell
        UIImage *image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:self.gifs[indexPath.item][@"media_formats"][@"tinygif"][@"url"]]];
        cell.postImage.image = image;
        
        cell.postImage.layer.masksToBounds = false;
        cell.postImage.layer.cornerRadius = cell.postImage.bounds.size.width/UIIntValuesRoundedCornerDivisor;
        cell.postImage.clipsToBounds = true;
        cell.postImage.contentMode = UIViewContentModeScaleAspectFill;
        cell.postImage.layer.borderWidth = 0.05;
         
        NSDate *date = piccyLoop.dailyReset;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
        
        cell.dateLabel.text = [formatter stringFromDate:date];
        
        cell.timeLabel.text = @"Piccy not completed yet";
        cell.piccyLabel.text = @"???";
        
        [cell setUserInteractionEnabled:false];
        
    } else {
        //special case for first cell
        UIImage *image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:self.gifs[indexPath.item][@"media_formats"][@"tinygif"][@"url"]]];
        cell.postImage.image = image;
        
        cell.postImage.layer.masksToBounds = false;
        cell.postImage.layer.cornerRadius = cell.postImage.bounds.size.width/UIIntValuesRoundedCornerDivisor;
        cell.postImage.clipsToBounds = true;
        cell.postImage.contentMode = UIViewContentModeScaleAspectFill;
        cell.postImage.layer.borderWidth = 0.05;
        
        NSDate *date = piccyLoop.dailyReset;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
        
        cell.dateLabel.text = [formatter stringFromDate:date];
        
        cell.timeLabel.text = @"Piccy not completed";
        cell.piccyLabel.text = piccyLoop.dailyWord;
        
        [cell setUserInteractionEnabled:false];
    }
    
    
    return cell;
}

-(void) loadRandomGifs {
    __weak __typeof(self) weakSelf = self;
    NSArray *wordArray = @[@"sad", @"sadge", @"frown", @"sad troll"];
    srand(time(NULL));
    int count = rand() % wordArray.count;
    NSString *randomString = [wordArray objectAtIndex:count];
    
    [[APIManager shared] getGifsWithSearchString:randomString limit:21 completion:^(NSDictionary *gifs, NSError *error, NSString *searchString) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
               return;
       }
        if(error == nil) {
            NSLog(@"%@", gifs[@"results"]);
            strongSelf.gifs = [[NSArray alloc] initWithArray:gifs[@"results"]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.collectionView reloadData];
            });
        } else {
            NSLog(@"Error loading gifs: %@", error);
        }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"detailsSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        PiccyDetailViewController *detailsController = (PiccyDetailViewController*)navigationController.topViewController;
        UIView *content = (UIView *)[(UIView *) sender superview];
        ProfilePiccyViewCell *cell = (ProfilePiccyViewCell *)[content superview];
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        PiccyLoop *loop = self.piccyLoops[indexPath.item];
        Piccy *piccyToPass = self.piccyDic[loop.dailyReset];
        detailsController.piccy = piccyToPass;
        self.direction = SegueDirectionsFromBottom;
        segue.destinationViewController.transitioningDelegate = self;
        segue.destinationViewController.modalPresentationStyle = UIModalPresentationCustom;
    } else if([segue.identifier isEqualToString:@"profileSettingsSegue"]) {
        self.direction = SegueDirectionsFromRight;
        segue.destinationViewController.transitioningDelegate = self;
        segue.destinationViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
}

// MARK:- Bonsai Controller Delegate - Stuff done by Bonsai Automatically
- (CGRect)frameOfPresentedViewIn:(CGRect)containerViewFrame {
    if(self.direction == SegueDirectionsFromBottom) {
        return CGRectMake(0, containerViewFrame.size.height / 4, containerViewFrame.size.width, containerViewFrame.size.height / (4.0 / 3.0));
    }
    return CGRectMake(0, 0, containerViewFrame.size.width, containerViewFrame.size.height);
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    if(self.direction == SegueDirectionsFromBottom) {
        // Slide animation from .left, .right, .top, .bottom
        return [[BonsaiController alloc] initFromDirection:DirectionBottom blurEffectStyle:UIBlurEffectStyleRegular presentedViewController:presented delegate:self];
    } else if(self.direction == SegueDirectionsFromLeft) {
        return [[BonsaiController alloc] initFromDirection:DirectionLeft blurEffectStyle:UIBlurEffectStyleSystemUltraThinMaterialDark presentedViewController:presented delegate:self];
    } else if(self.direction == SegueDirectionsFromTop) {
        return [[BonsaiController alloc] initFromDirection:DirectionTop blurEffectStyle:UIBlurEffectStyleRegular presentedViewController:presented delegate:self];
    } else {
        return [[BonsaiController alloc] initFromDirection:DirectionRight blurEffectStyle:UIBlurEffectStyleSystemUltraThinMaterialDark presentedViewController:presented delegate:self];
    }
    
}

@end
