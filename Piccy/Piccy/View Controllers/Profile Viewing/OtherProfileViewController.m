//
//  OtherProfileViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/11/22.
//

#import "OtherProfileViewController.h"
#import "UIImage+animatedGIF.h"

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
    
    if(![self.user[@"profilePictureURL"] isEqualToString:@""]) {
        self.profileImage.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:self.user[@"profilePictureURL"]]];
        self.profileImage.layer.masksToBounds = false;
        self.profileImage.layer.cornerRadius = self.profileImage.bounds.size.width/2;
        self.profileImage.clipsToBounds = true;
        self.profileImage.contentMode = UIViewContentModeScaleAspectFill;
        self.profileImage.layer.borderWidth = 0.05;
    }
    
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
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)denyFriendRequestPressed:(id)sender {
    //Denying a friend request
    PFUser *appUser = [PFUser currentUser];
    NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithArray:appUser[@"friendRequestsArrayIncoming"]];
    [mutableArr removeObject:self.user.username];
    appUser[@"friendRequestsArrayIncoming"] = [NSArray arrayWithArray:mutableArr];
    
    mutableArr = [NSMutableArray arrayWithArray:self.user[@"friendRequestsArrayOutgoing"]];
    [mutableArr removeObject:appUser.username];
    self.user[@"friendRequestsArrayOutgoing"] = [NSArray arrayWithArray:mutableArr];
    
    [self postOtherUser:self.user];
    [self postUser:appUser];
    [self updateLabels];
}

-(void) removeFriend {
    PFUser *appUser = [PFUser currentUser];
    NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithArray:appUser[@"friendsArray"]];
    [mutableArr removeObject:self.user.username];
    appUser[@"friendsArray"] = [NSArray arrayWithArray:mutableArr];
    
    mutableArr = [NSMutableArray arrayWithArray:self.user[@"friendsArray"]];
    [mutableArr removeObject:appUser.username];
    self.user[@"friendsArray"] = [NSArray arrayWithArray:mutableArr];
    
    [self postOtherUser:self.user];
    [self postUser:appUser];
    [self updateLabels];
}

- (IBAction)addButton:(id)sender {
    PFUser *appUser = [PFUser currentUser];
    //If the user is already added, they can be removed
    if([appUser[@"friendsArray"] containsObject:self.user.username]) {
        [self removeFriend];
    } else if ([appUser[@"friendRequestsArrayIncoming"] containsObject:self.user.username]) {
        //Accepting a friend request
        //in the requests tab you can accept friend requests.
        NSMutableArray *requests = [[NSMutableArray alloc] initWithArray:appUser[@"friendRequestsArrayIncoming"]];
        NSMutableArray *friends = [[NSMutableArray alloc] initWithArray:appUser[@"friendsArray"]];
        
        [requests removeObject:self.user.username];
        [friends addObject:self.user.username];
        
        appUser[@"friendRequestsArrayIncoming"] = [NSArray arrayWithArray:requests];
        appUser[@"friendsArray"] = [NSArray arrayWithArray:friends];
        
        requests = [[NSMutableArray alloc] initWithArray:self.user[@"friendRequestsArrayOutgoing"]];
        friends = [[NSMutableArray alloc] initWithArray:self.user[@"friendsArray"]];
        
        [requests removeObject:appUser.username];
        [friends addObject:appUser.username];
        
        self.user[@"friendRequestsArrayOutgoing"] = requests;
        self.user[@"friendsArray"] = friends;
        
        [self postUser:appUser];
        [self postOtherUser:self.user];
        
        
        [self updateLabels];
    } else if ([appUser[@"friendRequestsArrayOutgoing"] containsObject:self.user.username]) {
        //Canceling a friend request
        NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithArray:appUser[@"friendRequestsArrayOutgoing"]];
        [mutableArr removeObject:self.user.username];
        appUser[@"friendRequestsArrayOutgoing"] = [NSArray arrayWithArray:mutableArr];
        
        mutableArr = [NSMutableArray arrayWithArray:self.user[@"friendRequestsArrayIncoming"]];
        [mutableArr removeObject:appUser.username];
        self.user[@"friendRequestsArrayIncoming"] = [NSArray arrayWithArray:mutableArr];
        
        [self postOtherUser:self.user];
        [self postUser:appUser];
        [self updateLabels];
    } else {
        //Sending a friend request
        NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithArray:appUser[@"friendRequestsArrayOutgoing"]];
        [mutableArr addObject:self.user.username];
        appUser[@"friendRequestsArrayOutgoing"] = [NSArray arrayWithArray:mutableArr];
        
        mutableArr = [NSMutableArray arrayWithArray:self.user[@"friendRequestsArrayIncoming"]];
        [mutableArr addObject:appUser.username];
        self.user[@"friendRequestsArrayIncoming"] = [NSArray arrayWithArray:mutableArr];
        NSLog(@"FRIEND REQUESTED: %@", self.user[@"friendRequestsArrayIncoming"]);
        
        [self postUser:appUser];
        [self postOtherUser:self.user];
        
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

//Calls cloud function in Parse that changes the other user for me using a master key. this was becasue parse cannot save other users without them being logged in
-(void) postOtherUser:(PFUser *)otherUser {
    //creating a parameters dictionary with all the items in the user that need to be changed and saved
    NSMutableDictionary *paramsMut = [[NSMutableDictionary alloc] init];
    [paramsMut setObject:otherUser.username forKey:@"username"];
    [paramsMut setObject:otherUser[@"friendsArray"] forKey:@"friendsArray"];
    [paramsMut setObject:otherUser[@"friendRequestsArrayIncoming"] forKey:@"friendRequestsArrayIncoming"];
    [paramsMut setObject:otherUser[@"friendRequestsArrayOutgoing"] forKey:@"friendRequestsArrayOutgoing"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsMut];
    //calling the function in the parse cloud code
    [PFCloud callFunctionInBackground:@"saveOtherUser" withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
        if(!error) {
            NSLog(@"Saving other user worked");
        } else {
            NSLog(@"Error saving other user with mode");
        }
    }];
}


//Changes the current user of the app
-(void) postUser:(PFUser *)user {
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error == nil) {
            NSLog(@"Friend status changed");
        } else {
            NSLog(@"Error changing friend status");
        }
    }];
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
    [self.actions addObject:[UIAction actionWithTitle:@"???? Report"
                                           image:nil
                                      identifier:nil
                                         handler:^(__kindof UIAction* _Nonnull action) {
        
        // ...
    }]];
    
    [self.actions addObject:[UIAction actionWithTitle:@"???? Block"
                                           image:nil
                                      identifier:nil
                                         handler:^(__kindof UIAction* _Nonnull action) {
        
        // ...
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
