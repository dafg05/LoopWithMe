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


@interface ProfileVC ()<UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *givennameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITableView *postTableView;
@property (strong, nonatomic) NSArray *userLoops;

@end

@implementation ProfileVC


#pragma mark - Set up VC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.user){
        self.user = [PFUser currentUser];
    }
    self.profileImageView.layer.cornerRadius = 5;
    PFFileObject *imageFile = self.user[@"profilePic"];
    if (imageFile){
        self.profileImageView.image = [UIImage imageWithData:[imageFile getData]];
    }
    else{
        self.profileImageView.image = [UIImage systemImageNamed:@"person"];
    }
    self.postTableView.dataSource = self;
    self.postTableView.delegate = self;
    self.usernameLabel.text = self.user.username;
    self.givennameLabel.text = self.user[@"givenName"];
    [self queryUserPosts];
}

- (void)queryUserPosts {
    PFQuery *query = [PFQuery queryWithClassName:@"Loop"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"postAuthor"];
    [query includeKey:@"tracks"];
    [query whereKey:@"postAuthor" equalTo:self.user];
    [query findObjectsInBackgroundWithBlock:^(NSArray *loops, NSError *error) {
        if (loops != nil) {
            self.userLoops = loops;
            [self.postTableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

#pragma mark - UITableViewDataSource methods

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserPostCell"];
    Loop *cellLoop = self.userLoops[indexPath.row];
    cell.loopNameLabel.text = cellLoop.name;
    cell.captionLabel.text = cellLoop.caption;
    cell.authorLabel.text = cellLoop.postAuthor.username;
    // No need to download image for every post
    // since every post is from the same author
    cell.profileImageView.image = self.profileImageView.image;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.userLoops count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Loop *loop = self.userLoops[indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"LoopStackNavController"];
    LoopStackVC *vc = (LoopStackVC *) navController.topViewController;
    vc.loop = loop;
    vc.newLoop = NO;
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Image picker

- (IBAction)didTapSelectPP:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    UIImage *pickedImage = info[UIImagePickerControllerEditedImage];
    self.profileImageView.backgroundColor = [UIColor systemBackgroundColor];
    self.profileImageView.image = pickedImage;
    PFFileObject *imageFile = [PFFileObject fileObjectWithData:UIImagePNGRepresentation(pickedImage)];
    self.user[@"profilePic"] = imageFile;
    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil){
            NSLog(@"Error updating profile pic");
        }
        else{
            NSLog(@"Successfully updated profile pic!");
        }
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigaton

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
        }
    }];
}
@end
