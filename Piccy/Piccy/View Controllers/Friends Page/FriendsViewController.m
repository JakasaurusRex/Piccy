//
//  FriendsViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/7/22.
//

#import "FriendsViewController.h"
#import <Parse/Parse.h>
#import "FriendsViewCell.h"
#import "OtherProfileViewController.h"
#import "UIImage+animatedGIF.h"
#import <ContactsKit/ContactsKit.h>

@interface FriendsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) PFUser *user;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segCtrl;
@property (nonatomic, strong) NSArray *friends;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSArray *phoneNumbers;
@property (strong, nonatomic) NSDictionary *friendsOfFriends;
@property (strong, nonatomic) NSArray *contactUsers;
@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //setting the delegates and datasources to this class
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    //allows for the keyboard to go away by scrolling
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.searchBar.delegate = self;
    
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    //allows the cell to call a function in this class
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFriends) name:@"loadFriends" object:nil];
    
    [self setupActivityIndicator];
    
    self.user = [PFUser currentUser];

    //checks if there is a friend request and changes the icon of the bell to notify the user
    if([self.user[@"friendRequestsArrayIncoming"] count] != 0) {
        
        [self.segCtrl setImage:[UIImage systemImageNamed:@"bell.badge.fill"] forSegmentAtIndex:2];
    } else {
        [self.segCtrl setImage:[UIImage systemImageNamed:@"bell"] forSegmentAtIndex:2];
    }
    
    //sets the default view to the friends view
    [self loadFriends];
    [self.tableView reloadData];
    
    CKAddressBook *addressBook = [[CKAddressBook alloc] init];
        
    [addressBook requestAccessWithCompletion:^(NSError *error) {
        if (! error) {
            // Everything fine you can get contacts
            NSLog(@"Contacts accepted");
            CKContactField mask = CKContactFieldFirstName | CKContactFieldPhones;
                
            // Final sort of the contacts array based on first name
            NSArray *sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES] ];
            [addressBook contactsWithMask:mask uinify:NO sortDescriptors:sortDescriptors
                                   filter:nil completion:^(NSArray *contacts, NSError *error) {
                    if (! error) {
                        NSMutableArray *mutPhoneNumbers = [[NSMutableArray alloc] init];
                        //Get all the phone numbers and set the phone numbers array equal to all of them
                        for(int i = 0; i < [contacts count]; i++) {
                            CKContact *contact = contacts[i];
                            CKPhone *phone = contact.phones[0];
                            [mutPhoneNumbers addObject:[phone.number stringByReplacingOccurrencesOfString:@"-" withString:@""]];
                        }
                        self.phoneNumbers = [[NSArray alloc] initWithArray:mutPhoneNumbers];
                    }
            }];
        }
        else {
            // The app doesn't have a permission for getting contacts
            // You have to go to the settings and turn on contacts
            NSLog(@"Contacts denied");
        }
    }];
}

//function that gets called from the notification in friendsviewcell
-(void) loadFriends {
    if(self.segCtrl.selectedSegmentIndex == 1) {
        [self friendQuery:self.searchBar.text];
    } else if(self.segCtrl.selectedSegmentIndex == 2) {
        [self requestQuery:self.searchBar.text];
    } else if(self.segCtrl.selectedSegmentIndex == 0) {
        [self addQuery:self.searchBar.text withLimit:10];
    }
    
    if([self.user[@"friendRequestsArrayIncoming"] count] != 0) {
        [self.segCtrl setImage:[UIImage systemImageNamed:@"bell.badge.fill"] forSegmentAtIndex:2];
    } else {
        [self.segCtrl setImage:[UIImage systemImageNamed:@"bell"] forSegmentAtIndex:2];
    }
    
    [self.tableView reloadData];
}

//go back to previous page needs to be updated with better animation
- (IBAction)backButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadHome" object:nil];
    [self dismissViewControllerAnimated:true completion:nil];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendsViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FriendsCell"];
    PFUser *friend = self.friends[indexPath.row];
    cell.cellUser = friend;
    cell.nameView.text = friend[@"name"];
    cell.usernameView.text = friend[@"username"];
    cell.foundInContacts.alpha = 0;
    
    if(![cell.cellUser[@"profilePictureURL"] isEqualToString:@""]) {
        cell.profilePicture.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:cell.cellUser[@"profilePictureURL"]]];
        cell.profilePicture.layer.masksToBounds = false;
        cell.profilePicture.layer.cornerRadius = cell.profilePicture.bounds.size.width/2;
        cell.profilePicture.clipsToBounds = true;
        cell.profilePicture.contentMode = UIViewContentModeScaleAspectFill;
        cell.profilePicture.layer.borderWidth = 0.05;
    }
    
    //cells are different depending upon what tab is selected 0 is add page, 1 is friends, and 2 is requests
    if(self.segCtrl.selectedSegmentIndex == 1) {
        [cell.friendButton setTitle:@"Remove" forState:UIControlStateNormal];
        [cell.friendButton setTintColor:[UIColor systemRedColor]];
        cell.cellMode = 1;
        [cell.denyFriendRequestButton setUserInteractionEnabled:NO];
        [cell.denyFriendRequestButton setAlpha:0];
    } else if (self.segCtrl.selectedSegmentIndex == 0) {
        [cell.friendButton setTitle:@"Add" forState:UIControlStateNormal];
        cell.cellMode = 0;
        if([self.user[@"friendRequestsArrayOutgoing"] containsObject:friend.username]) {
            cell.friendButton.tintColor = [UIColor systemTealColor];
            [cell.friendButton setTitle:@"Cancel" forState:UIControlStateNormal];
        } else {
            [cell.friendButton setTintColor:[UIColor systemIndigoColor]];
        }
        if([self.phoneNumbers containsObject:cell.cellUser[@"phoneNumber"]]) {
            cell.foundInContacts.alpha = 1;
        } else if([[self.friendsOfFriends valueForKey:cell.cellUser.username] intValue] == 1) {
            cell.foundInContacts.text = [NSString stringWithFormat:@"1 mutual friend"];
            cell.foundInContacts.alpha = 1;
        } else if([[self.friendsOfFriends valueForKey:cell.cellUser.username] intValue] > 1) {
            cell.foundInContacts.text = [NSString stringWithFormat:@"%d mutual friends", [[self.friendsOfFriends valueForKey:cell.cellUser.username] intValue]];
            cell.foundInContacts.alpha = 1;
        }
        
        [cell.denyFriendRequestButton setUserInteractionEnabled:NO];
        [cell.denyFriendRequestButton setAlpha:0];
    } else {
        [cell.friendButton setTitle:@"Accept" forState:UIControlStateNormal];
        [cell.friendButton setTintColor:[UIColor systemOrangeColor]];
        cell.cellMode = 2;
        [cell.denyFriendRequestButton setUserInteractionEnabled:YES];
        [cell.denyFriendRequestButton setAlpha:1];
    }
    return cell;
}

//Query for the friends list
-(void) friendQuery:(NSString *)container {
    // construct query
    [self.tableView reloadData];
    [self.activityIndicator startAnimating];
    PFQuery *query = [PFUser query];
    query.limit = [self.user[@"friendsArray"] count];
    [query includeKey:@"username"];
    [query whereKey:@"username" containedIn:self.user[@"friendsArray"]];
    [query includeKey:@"name"];
    // fetch data asynchronously
    if(![container isEqualToString:@""]) {
        //[query whereKey:@"username" containsString:container];
        [query whereKey:@"name" containsString:container];
    }
    __weak __typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
               return;
       }
        if (friends != nil) {
            // do something with the array of object returned by the call
            strongSelf.friends = friends;
            NSLog(@"Received friends! %@", strongSelf.friends);
            
            //Add friends of friends to a dictionary and then the value is the amount of times they reappear as mutual friends
            NSMutableDictionary *friendDic = [[NSMutableDictionary alloc] init];
            for(int i = 0; i < [friends count]; i++) {
                NSArray *friendsOfFriend = friends[i][@"friendsArray"];
                for(int j = 0; j < [friendsOfFriend count]; j++) {
                    if([friendDic objectForKey:friendsOfFriend[j]] == nil) {
                        [friendDic setValue:@(1) forKey:friendsOfFriend[j]];
                    } else {
                        [friendDic setValue:@([[friendDic valueForKey:friendsOfFriend[j]] intValue] + 1) forKey:friendsOfFriend[j]];
                    }
                }
            }
            strongSelf.friendsOfFriends = [[NSDictionary alloc] initWithDictionary:friendDic];
            NSLog(@"friends of friends: %@", strongSelf.friendsOfFriends);
            

            [strongSelf.tableView reloadData];
            [strongSelf.activityIndicator stopAnimating];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        
    }];
}

//query for the adding friends feaure
-(void) addQuery:(NSString *)container withLimit:(int) limit {
    // construct query
    [self.tableView reloadData];
    [self.activityIndicator startAnimating];
    PFQuery *query = [PFUser query];
    query.limit = limit;
    [query includeKey:@"username"];
    
    //To make sure the user wasnt blocked or blocked the current user
    NSMutableArray *blockArray = [[NSMutableArray alloc] initWithArray:self.user[@"blockedUsers"]];
    [blockArray addObjectsFromArray:self.user[@"blockedByArray"]];
    [blockArray addObjectsFromArray:self.user[@"friendsArray"]];
    [query whereKey:@"username" notContainedIn:blockArray];
    
    [query whereKey:@"username" notEqualTo:self.user.username];
    if(![container isEqualToString:@""]) {
        [query whereKey:@"username" containsString:container];
    } else {
        NSMutableArray *defaultArray = [[NSMutableArray alloc] initWithArray:self.user[@"friendRequestsArrayOutgoing"]];
        [defaultArray addObjectsFromArray:[self.friendsOfFriends allKeys]];
        [query whereKey:@"username" containedIn:defaultArray];
        
    }
    // fetch data asynchronously
    __weak __typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
               return;
       }
        if (friends != nil) {
            // do something with the array of object returned by the call
            strongSelf.friends = friends;
            
            PFQuery *contactQuery = [PFUser query];
            [contactQuery includeKey:@"phoneNumber"];
            [contactQuery includeKey:@"username"];
            //To make sure the user wasnt blocked or blocked the current user
            NSMutableArray *blockArray = [[NSMutableArray alloc] initWithArray:self.user[@"blockedUsers"]];
            [blockArray addObjectsFromArray:strongSelf.user[@"blockedByArray"]];
            [blockArray addObjectsFromArray:strongSelf.user[@"friendsArray"]];
            [contactQuery whereKey:@"username" notContainedIn:blockArray];
            [contactQuery whereKey:@"phoneNumber" containedIn:strongSelf.phoneNumbers];
            [contactQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if(error == nil) {
                    strongSelf.contactUsers = objects;
                    [strongSelf.tableView reloadData];
                    [strongSelf.activityIndicator stopAnimating];
                } else {
                    NSLog(@"Error getting contacts: %@", error);
                }
            }];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.segCtrl.selectedSegmentIndex == 1 || self.segCtrl.selectedSegmentIndex == 2) {
        return 1;
    }
    return 2;
}

//pulls all friends
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.segCtrl.selectedSegmentIndex == 1 || self.segCtrl.selectedSegmentIndex == 2) {
        return [self.friends count];
    }
    if(section == 0) {
        return [self.contactUsers count];
    } else {
        return [self.friends count];
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(self.segCtrl.selectedSegmentIndex == 1 || self.segCtrl.selectedSegmentIndex == 2 || [self.contactUsers count] == 0) {
        return @"";
    } else if(section == 0) {
        return @"Add from contacts";
    } else {
        return @"Requested friends and Mutual friends";
    }
}

//Query for the friend requests tab
-(void) requestQuery:(NSString *)container {
    // construct query
    [self.tableView reloadData];
    [self.activityIndicator startAnimating];
    PFQuery *query = [PFUser query];
    query.limit = 50;
    [query includeKey:@"username"];
    [query whereKey:@"username" notContainedIn:self.user[@"friendsArray"]];
    [query whereKey:@"username" notEqualTo:self.user.username];
    [query whereKey:@"username" containedIn:self.user[@"friendRequestsArrayIncoming"]];
    if(![container isEqualToString:@""]) {
        [query whereKey:@"username" containsString:container];
    }
    // fetch data asynchronously
    __weak __typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
               return;
       }
        if (friends != nil) {
            // do something with the array of object returned by the call
            strongSelf.friends = friends;
            NSLog(@"Received friends! %@", strongSelf.friends);
            [strongSelf.tableView reloadData];
            [strongSelf.activityIndicator stopAnimating];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
    //Mkaes the animations nicer for when cells are selected
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
 }

// If the segment controller is changed, reload the information and requery
- (IBAction)segChanged:(id)sender {
    if(self.segCtrl.selectedSegmentIndex == 1) {
        self.friends = nil;
        [self friendQuery:self.searchBar.text];
    } else if(self.segCtrl.selectedSegmentIndex == 0) {
        self.friends = nil;
        [self addQuery:self.searchBar.text withLimit:10];
    } else {
        self.friends = nil;
        [self requestQuery:self.searchBar.text];
    }
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    self.searchBar.showsCancelButton = YES;
}

// Updates when the text on the search bar changes to allow for searching functionality
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if(self.segCtrl.selectedSegmentIndex == 1) {
        NSLog(@"%@", searchText);
        [self friendQuery:[searchText lowercaseString]];
        [self.tableView reloadData];
    } else if(self.segCtrl.selectedSegmentIndex == 0) {
        NSLog(@"%@", searchText);
        [self addQuery:[searchText lowercaseString] withLimit:10];
        [self.tableView reloadData];
    } else {
        NSLog(@"%@", searchText);
        [self requestQuery:[searchText lowercaseString]];
        [self.tableView reloadData];
    }
}

-(void) setupActivityIndicator{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.activityIndicator.center = self.view.center;
    self.activityIndicator.hidesWhenStopped = true;
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleMedium];
    [self.view addSubview:self.activityIndicator];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"otherProfileSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        OtherProfileViewController *profileVC = (OtherProfileViewController*)navigationController.topViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        PFUser *dataToPass = self.friends[indexPath.row];
        profileVC.user = dataToPass;
    }
}


@end
