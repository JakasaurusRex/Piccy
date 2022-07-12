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

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *gifView;
@property (nonatomic, strong) NSArray *gifs;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadHome) name:@"loadHome" object:nil];
    [self loadHome];
    // Do any additional setup after loading the view.
    
    [[APIManager shared] getGifsWithSearchString:@"dog" limit:8 completion:^(NSDictionary *gifs, NSError *error) {
        if(error == nil) {
            NSLog(@"%@", gifs[@"results"]);
            self.gifs = [[NSArray alloc] initWithArray:gifs[@"results"]];
            
            //what the dog doin
            dispatch_async(dispatch_get_main_queue(), ^{
                self.gifView.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:self.gifs[0][@"media_formats"][@"gif"][@"url"]]];
            });

           
        } else {
            NSLog(@"Error loading gifs: %@", error);
        }
    }];
    
    
}

-(void) loadHome {
    if([PFUser.currentUser[@"darkMode"] boolValue] == YES) {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
        self.view.backgroundColor = [UIColor colorWithRed:(23/255.0f) green:(23/255.0f) blue:(23/255.0f) alpha:1];
    } else {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
        self.view.backgroundColor = [UIColor whiteColor];
    }
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
