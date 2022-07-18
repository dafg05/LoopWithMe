//
//  SignUpVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/10/22.
//

#import "SignUpVC.h"
#import "Parse/Parse.h"
#import "SceneDelegate.h"

@interface SignUpVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *givenNameField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPWField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property NSArray *fieldsArray;

@end

@implementation SignUpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.errorLabel.text = @"";
    self.fieldsArray = @[self.usernameField, self.passwordField, self.givenNameField, self.confirmPWField, self.emailField];
    for (UITextField *textField in self.fieldsArray){
        textField.delegate = self;
    }
    [self setUpTextFieldsPlaceholders];
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
            [self segue];
        }
    }];
}

- (BOOL) checkForEmptyFields{
    for (UITextField *textField in self.fieldsArray){
        if ([textField.text isEqualToString:@""] || textField.text == nil){
            return YES;
        }
    }
    return NO;
}

- (IBAction)didTapCancel:(id)sender {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)setUpTextFieldsPlaceholders{
    // Note: writing a for loop to do this would require setting up a dictionary with the keys being NSValues of the text fields, and the elements being the placeholder strings
    // This would be just as cumbersome, if not more than the current implementation
    self.givenNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter your name" attributes:@{NSForegroundColorAttributeName: UIColor.systemGrayColor}];
    self.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: UIColor.systemGrayColor}];
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: UIColor.systemGrayColor}];
    self.confirmPWField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Confirm password" attributes:@{NSForegroundColorAttributeName: UIColor.systemGrayColor}];
    self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: UIColor.systemGrayColor}];
}

- (void) segue{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *mainTBC = [storyboard instantiateViewControllerWithIdentifier:@"TabBarVC"];
    SceneDelegate *sceneDelegate = (SceneDelegate * ) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
    [sceneDelegate changeRootViewController:mainTBC];
    
    // TODO: animation
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