//
//  OtherProfileViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/11/22.
//

#import "OtherProfileViewController.h"
#import "UIImage+animatedGIF.h"
#import "ReportedUser.h"
#import "MagicalEnums.h"
#import "AppMethods.h"

@interface OtherProfileViewController ()
@property (weak, nonatomic) IBOutlet UIButton *optionsButton;
@property (strong, nonatomic) UIMenu* menu;
@property (weak, nonatomic) IBOutlet UIButton *denyFriendRequestButton;
@property (strong, nonatomic) NSMutableArray* actions;
@end

@implementation OtherProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.name.text = self.user[@"name"];
    self.username.text = self.user.username;
    self.bio.text = self.user[@"bio"];
    
    self.profileImage = [AppMethods roundImageView:self.profileImage withURL:self.user[@"profilePictureURL"]];
    
    PFUser *currentUser = [PFUser currentUser];
    if([currentUser[@"friendRequestsArrayIncoming"] containsObject:self.user.username]) {
        [self.denyFriendRequestButton setUserInteractionEnabled:YES];
        [self.denyFriendRequestButton setAlpha:1];
    } else {
        [self.denyFriendRequestButton setUserInteractionEnabled:NO];
        [self.denyFriendRequestButton setAlpha:0];
    }
    
    [self setupMenu];

    [self updateLabels];
    
    [self blurEffect];
}



- (IBAction)downButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadFriends" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadHome" object:nil];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)denyFriendRequestPressed:(id)sender {
    //Denying a friend request
    [AppMethods denyFriendRequestFromUser:self.user];
    [self updateLabels];
}

-(void) removeFriend {
    [AppMethods removeFriendUser:self.user];
    [self updateLabels];
}

- (IBAction)addButton:(id)sender {
    PFUser *appUser = [PFUser currentUser];
    //If the user is already added, they can be removed
    if([appUser[@"friendsArray"] containsObject:self.user.username]) {
        [self removeFriend];
    } else if ([appUser[@"friendRequestsArrayIncoming"] containsObject:self.user.username]) {
        [AppMethods addFriendUser:self.user];
        [self updateLabels];
    } else if ([appUser[@"friendRequestsArrayOutgoing"] containsObject:self.user.username]) {
        [AppMethods cancelFriendRequestOnUser:self.user];
        [self updateLabels];
    } else {
        [AppMethods sendFriendRequestOnUser:self.user];
        [self updateLabels];
    }
}

-(void) updateLabels {
    PFUser *appUser = [PFUser currentUser];
    if([appUser[@"friendsArray"] containsObject:self.user.username]) {
        [self.addButton setTitle:@"Remove friend" forState:UIControlStateNormal];
        [self.addButton setTintColor:[UIColor systemRedColor]];
    } else if ([appUser[@"friendRequestsArrayOutgoing"] containsObject:self.user.username]) {
        [self.addButton setTitle:@"Cancel friend request" forState:UIControlStateNormal];
        [self.addButton setTintColor:[UIColor systemTealColor]];
    } else if ([appUser[@"friendRequestsArrayIncoming"] containsObject:self.user.username]) {
        [self.addButton setTitle:@"Accept friend request" forState:UIControlStateNormal];
        [self.addButton setTintColor:[UIColor systemOrangeColor]];
    } else {
        [self.addButton setTitle:@"Add friend" forState:UIControlStateNormal];
        [self.addButton setTintColor:[UIColor systemIndigoColor]];
        [self.actions removeLastObject];
        self.menu =
        [UIMenu menuWithTitle:@"Options"
                     children:self.actions];
        [self.optionsButton setMenu:self.menu];
    }
    if([appUser[@"friendRequestsArrayIncoming"] containsObject:self.user.username]) {
        [self.denyFriendRequestButton setUserInteractionEnabled:YES];
        [self.denyFriendRequestButton setAlpha:1];
    } else {
        [self.denyFriendRequestButton setUserInteractionEnabled:NO];
        [self.denyFriendRequestButton setAlpha:0];
    }
}


-(void) blurEffect {
    //cool blur effect https://stackoverflow.com/questions/17041669/creating-a-blurring-overlay-view
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.view.backgroundColor = [UIColor clearColor];

        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        //always fill the view
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view insertSubview:blurEffectView atIndex:0]; //if you have more UIViews, use an insertSubview API to place it where needed
    } else {
        self.view.backgroundColor = [UIColor blackColor];
    }
}

//Sets up menu which shows when button is pressed
-(void) setupMenu {
    //setting the default behavior of the button to this
    [self.optionsButton setShowsMenuAsPrimaryAction:YES];
    
    //Array of actions shown in the menu
    self.actions = [[NSMutableArray alloc] init];
    [self.actions addObject:[UIAction actionWithTitle:@"📝 Report"
                                           image:nil
                                      identifier:nil
                                         handler:^(__kindof UIAction* _Nonnull action) {
        [AppMethods reportUser:self.user onViewController:self];
    }]];
    
    [self.actions addObject:[UIAction actionWithTitle:@"🧱 Block"
                                           image:nil
                                      identifier:nil
                                         handler:^(__kindof UIAction* _Nonnull action) {
        
        [AppMethods blockUser:self.user onViewController:self];
    }]];
    
    PFUser *appUser = [PFUser currentUser];
    if([appUser[@"friendsArray"] containsObject:self.user.username]) {
        [self.actions addObject:[UIAction actionWithTitle:@"Remove friend"
                                                                        image:nil
                                                                   identifier:nil
                                                                      handler:^(__kindof UIAction* _Nonnull action) {
                                     [self removeFriend];
                                 }]];
    }
   
    
    self.menu =
    [UIMenu menuWithTitle:@"Options"
                 children:self.actions];
    
    
    [self.optionsButton setMenu:self.menu];
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
