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

@interface ProfilePictureViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) NSArray *gifs;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation ProfilePictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    self.searchBar.delegate = self;
    [self setupActivityIndicator];
    
    [self loadGifs];
}

-(void) loadGifs {
    [self.activityIndicator startAnimating];
    if([self.searchBar.text isEqualToString:@""]) {
        [[APIManager shared] getFeaturedGifs:10 completion:^(NSDictionary *gifs, NSError *error) {
            if(error == nil) {
                NSLog(@"%@", gifs[@"results"]);
                self.gifs = [[NSArray alloc] initWithArray:gifs[@"results"]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                    [self.activityIndicator stopAnimating];
                });
            } else {
                NSLog(@"Error loading gifs: %@", error);
            }
        }];
    } else {
        [[APIManager shared] getGifsWithSearchString:self.searchBar.text limit:10 completion:^(NSDictionary *gifs, NSError *error) {
            if(error == nil) {
                NSLog(@"%@", gifs[@"results"]);
                self.gifs = [[NSArray alloc] initWithArray:gifs[@"results"]];
                
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
}

- (IBAction)saveButton:(id)sender {
    
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GifCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"GifViewCell" forIndexPath:indexPath];
    //what the dog doin
    cell.gifImageView.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:self.gifs[indexPath.item][@"media_formats"][@"gif"][@"url"]]];
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.gifs count];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for(int i = 0; i < [self.gifs count]; i++) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
        GifCollectionViewCell *cell = (GifCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:index];
        if([index isEqual:indexPath]) {
            [cell.highlightView setAlpha:0.7];
        } else {
            [cell.highlightView setAlpha:0];
        }
    }
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
