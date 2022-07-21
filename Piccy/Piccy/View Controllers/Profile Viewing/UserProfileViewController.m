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

@interface UserProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *nameView;
@property (weak, nonatomic) IBOutlet UILabel *usernameView;
@property (weak, nonatomic) IBOutlet UILabel *bioView;
@property (weak, nonatomic) IBOutlet UILabel *profileView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *piccys;
@property (strong, nonatomic) NSArray *piccyLoops;
@property (strong, nonatomic) NSMutableDictionary *piccyDic;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadProfile) name:@"loadProfile" object:nil];
    // Do any additional setup after loading the view.
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    PBDCarouselCollectionViewLayout *layout = [[PBDCarouselCollectionViewLayout alloc] init];
    layout.itemSize = CGSizeMake(260, 260);
    layout.interItemSpace = 40;
    self.collectionView.collectionViewLayout = layout;

    
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
        self.view.backgroundColor = [UIColor colorWithRed:(23/255.0f) green:(23/255.0f) blue:(23/255.0f) alpha:1];
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
        self.profilePictureView.layer.cornerRadius = self.profilePictureView.bounds.size.width/2;
        self.profilePictureView.clipsToBounds = true;
        self.profilePictureView.contentMode = UIViewContentModeScaleAspectFill;
        self.profilePictureView.layer.borderWidth = 0.05;
    }
}

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
        } else {
            NSLog(@"Piccys could not be retrived: %@", error);
        }
    }];
}

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

- (IBAction)backButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadHome" object:nil];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if([self.piccyLoops count] > 14) {
        return 14;
    }
    return [self.piccyLoops count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProfilePiccyViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"ProfilePiccyViewCell" forIndexPath:indexPath];
    
    [cell.piccyButton setTitle:@"" forState:UIControlStateNormal];
    
    PiccyLoop *piccyLoop = self.piccyLoops[indexPath.item];
    Piccy *piccy = self.piccyDic[piccyLoop.dailyReset];
    
    cell.visualEffect.layer.masksToBounds = false;
    cell.visualEffect.layer.cornerRadius = cell.visualEffect.bounds.size.width/12;
    cell.visualEffect.clipsToBounds = true;
    cell.visualEffect.contentMode = UIViewContentModeScaleAspectFill;
    cell.visualEffect.layer.borderWidth = 0.05;
    
    if(piccy != nil) {
        //change cell;
        //Post image
        cell.postImage.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:piccy.postGifUrl]];
        cell.postImage.layer.masksToBounds = false;
        cell.postImage.layer.cornerRadius = cell.postImage.bounds.size.width/12;
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
        
    } else if(indexPath.item == 0){
        //special case for first cell
        cell.postImage.layer.masksToBounds = false;
        cell.postImage.layer.cornerRadius = cell.postImage.bounds.size.width/12;
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
        
        
    } else {
        //special case for first cell
        cell.postImage.layer.masksToBounds = false;
        cell.postImage.layer.cornerRadius = cell.postImage.bounds.size.width/12;
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
    }
    
    
    return cell;
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
