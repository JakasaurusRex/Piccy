//
//  RegistrationViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/6/22.
//

#import "RegistrationViewController.h"
#import <Parse/Parse.h>
#import "ProfilePictureViewController.h"

@interface RegistrationViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *reenterPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *dateOfBirthField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;



@end

@implementation RegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Move from here to home screen after selecting a profile picture
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newUserPFPSaved) name:@"newUserPFPSaved" object:nil];
    // Do any additional setup after loading the view.
    
}

-(void) newUserPFPSaved {
    [self performSegueWithIdentifier:@"registerSegue" sender:nil];
}

//Returns user to login screen if clicked back button
- (IBAction)didPressBack:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"profilePictureSegue"]) {
        //Passing the daily loop to the piccy screen
        UINavigationController *navigationController = [segue destinationViewController];
        ProfilePictureViewController *profilePictureViewController = (ProfilePictureViewController*)navigationController.topViewController;
        profilePictureViewController.newUser = true;
    }
}


@end
