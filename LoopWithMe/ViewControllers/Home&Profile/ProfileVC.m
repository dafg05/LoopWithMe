//
//  ProfileVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/11/22.
//

#import "ProfileVC.h"
#import "Parse/Parse.h"
#import "SceneDelegate.h"

#import "LoginVC.h"
#import "LoopStackVC.h"
#import "PostCell.h"


@interface ProfileVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *givennameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITableView *postTableView;
@property (strong, nonatomic) NSArray *userLoops;

@end

@implementation ProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.user){
        self.user = [PFUser currentUser];
    }
    self.postTableView.dataSource = self;
    self.postTableView.delegate = self;
    self.usernameLabel.text = self.user.username;
    self.givennameLabel.text = self.user[@"givenName"];
    [self queryUserPosts];
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

- (void)queryUserPosts {
    PFQuery *query = [PFQuery queryWithClassName:@"Loop"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"postAuthor"];
    [query includeKey:@"tracks"];
    [query whereKey:@"postAuthor" equalTo:self.user];
    [query findObjectsInBackgroundWithBlock:^(NSArray *loops, NSError *error) {
        if (loops != nil) {
            NSLog(@"Queried for posts!");
            self.userLoops = loops;
            [self.postTableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserPostCell"];
    Loop *cellLoop = self.userLoops[indexPath.row];
    cell.loopNameLabel.text = cellLoop.name;
    cell.captionLabel.text = cellLoop.caption;
    cell.authorLabel.text = cellLoop.postAuthor.username;
    NSLog(@"%@", cell.loopNameLabel.text);
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%lu", (unsigned long)[self.userLoops count]);
    return [self.userLoops count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Loop *loop = self.userLoops[indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"LoopStackNavController"];
    LoopStackVC *vc = (LoopStackVC *) navController.topViewController;
    vc.loop = loop;
    vc.readOnly = YES;
    [self presentViewController:navController animated:YES completion:nil];
}

@end
