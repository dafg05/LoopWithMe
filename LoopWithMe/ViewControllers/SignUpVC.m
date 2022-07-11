//
//  SignUpVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/10/22.
//

#import "SignUpVC.h"
#import "Parse/Parse.h"

@interface SignUpVC ()

@property (weak, nonatomic) IBOutlet UITextField *givenNameField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPWField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;


@end

@implementation SignUpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.errorLabel.text = @"";
    // Set up custom placeholders
    self.givenNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter your name" attributes:@{NSForegroundColorAttributeName: UIColor.systemGrayColor}];
    self.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: UIColor.systemGrayColor}];
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: UIColor.systemGrayColor}];
    self.confirmPWField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Confirm password" attributes:@{NSForegroundColorAttributeName: UIColor.systemGrayColor}];
    self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: UIColor.systemGrayColor}];
    
}

- (IBAction)didTapSignUp:(id)sender {
    [self registerUser];
}


- (void)registerUser {
    
    if (self.checkForEmptyFields){
        self.errorLabel.text = @"One or more fields are empty.";
        return;
    }
        
    if (![self.passwordField.text isEqualToString:self.confirmPWField.text]){
        NSLog(@"Passwords don't match!");
        self.errorLabel.text = @"Passwords don't match.";
        return;
    }
    
    PFUser *newUser = [PFUser user];

    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    newUser.email = self.emailField.text;
    newUser[@"givenName"] = self.givenNameField.text;

    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            self.errorLabel.text = error.localizedDescription;
        } else {
            NSLog(@"User registered successfully");
            [self performSegueWithIdentifier:@"SignUpSegue" sender:nil];
        }
    }];
}

- (BOOL) checkForEmptyFields{
    BOOL givenNameEmpty = ([self.givenNameField.text isEqualToString:@""]) ? TRUE : FALSE;
    BOOL usernameEmpty = ([self.usernameField.text isEqualToString:@""]) ? TRUE : FALSE;
    BOOL emailEmpty = ([self.emailField.text isEqualToString:@""]) ? TRUE : FALSE;
    BOOL passwordEmpty = ([self.passwordField.text isEqualToString:@""]) ? TRUE : FALSE;
    BOOL confirmPWEmpty = ([self.confirmPWField.text isEqualToString:@""]) ? TRUE : FALSE;
    
    return (givenNameEmpty || usernameEmpty || emailEmpty || passwordEmpty || confirmPWEmpty);
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
