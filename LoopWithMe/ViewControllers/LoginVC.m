//
//  LoginVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/10/22.
//

#import "LoginVC.h"
#import "Parse/Parse.h"

@interface LoginVC ()
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.errorLabel.text = @"";
    // Set up custom placeholders
    self.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: UIColor.systemGrayColor}];
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: UIColor.systemGrayColor}];
}

- (IBAction)didTapLogin:(id)sender {
    [self loginUser];
}

- (void)loginUser {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            // TODO: remove hardcoding
            if ([error.localizedDescription isEqualToString:@"username/email is required."]){
                self.errorLabel.text = @"username is required.";
            }
            else{
                self.errorLabel.text = error.localizedDescription;
            }
            
        } else {
            NSLog(@"User logged in successfully");
            
            [self performSegueWithIdentifier:@"LoginSegue" sender:nil];
        }
    }];
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
