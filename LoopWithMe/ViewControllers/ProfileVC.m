//
//  ProfileVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/11/22.
//

#import "ProfileVC.h"
#import "Parse/Parse.h"
#import "LoginVC.h"
#import "SceneDelegate.h"

@interface ProfileVC ()

@end

@implementation ProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)didTapLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (error != nil){
            NSLog(@"Error logging out: %@", error.localizedDescription);
        }
        else{
            SceneDelegate *sceneDelegate = (SceneDelegate *) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginVC *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
            sceneDelegate.window.rootViewController = loginViewController;
            NSLog(@"Logout success!!!");
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
