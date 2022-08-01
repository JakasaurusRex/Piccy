//
//  PiccyDetailViewController.m
//  Piccy
//
//  Created by Jake Torres on 7/21/22.
//

#import "PiccyDetailViewController.h"
#import "AppMethods.h"

@interface PiccyDetailViewController ()

@end

@implementation PiccyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.postImage.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:self.piccy.postGifUrl]];
    if(self.piccy.replyCount == 0) {
        self.commentLabel.text = @"";
    } else if(self.piccy.replyCount == 1) {
        self.commentLabel.text = [NSString stringWithFormat:@"1 comment"];
    } else {
        self.commentLabel.text = [NSString stringWithFormat:@"%d comments", self.piccy.replyCount];
    }
    
}

//Instagram feature that was being worked on
- (IBAction)instagramButtonPressed:(id)sender {
    // Objective-C
    [self backgroundImage:UIImagePNGRepresentation([UIImage imageNamed:@"backgroundImage"])];

    
}

- (void)backgroundImage:(NSData *)backgroundImage {

  // Verify app can open custom URL scheme, open if able
  NSURL *urlScheme = [NSURL URLWithString:@"instagram-stories://share?source_application=com.my.app"];
  if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
  
        // Assign background image asset to pasteboard
        NSArray *pasteboardItems = @[@{@"com.instagram.sharedSticker.backgroundImage" : backgroundImage}];
        NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
        // This call is iOS 10+, can use 'setItems' depending on what versions you support
        [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];
    
        [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
  } else {
      // Handle older app versions or app not installed case
      [AppMethods alertWithTitle:@"Instagram not installed" message:@"Please download Instagram if you wish to share your Piccy there." onViewController:self];
  }
}


- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
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
