//
//  LoginVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/10/22.
//

#import "LoginVC.h"
#import "Parse/Parse.h"
#import "SceneDelegate.h"

@interface LoginVC () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpTextFields];
}

- (IBAction)didTapLogin:(id)sender {
    [self.spinner startAnimating];
    [self loginUser];
}

- (void)loginUser {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            if ([error.localizedDescription isEqualToString:@"username/email is required."]){
                self.errorLabel.text = @"username is required.";
            }
            else{
                self.errorLabel.text = error.localizedDescription;
            }
            
        } else {
            NSLog(@"User logged in successfully");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UITabBarController *mainTBC = [storyboard instantiateViewControllerWithIdentifier:@"TabBarVC"];
            mainTBC.tabBar.unselectedItemTintColor = [UIColor systemGrayColor];
            SceneDelegate *sceneDelegate = (SceneDelegate * ) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
            [sceneDelegate changeRootViewController:mainTBC];
        }
        [self.spinner stopAnimating];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void) setUpTextFields{
    self.errorLabel.text = @"";
    self.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: UIColor.systemGray2Color}];
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: UIColor.systemGray2Color}];
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
}

- (void) segue{
    // TODO: animation
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *mainTBC = [storyboard instantiateViewControllerWithIdentifier:@"TabBarVC"];
    SceneDelegate *sceneDelegate = (SceneDelegate * ) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
    [sceneDelegate changeRootViewController:mainTBC];
}


@end
