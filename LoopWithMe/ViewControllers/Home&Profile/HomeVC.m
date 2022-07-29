//
//  HomeVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/20/22.
//

#import "HomeVC.h"
#import "PostCell.h"
#import "Parse/Parse.h"
#import "AVFoundation/AVFAudio.h"
#import "ShareVC.h"
#import "ProfileVC.h"

#import "LoopStackVC.h"

@interface HomeVC () <UITableViewDataSource, UITableViewDelegate, PostCellDelegate>;

@property (weak, nonatomic) IBOutlet UITableView *postTableView;
@property (strong, nonatomic) NSArray *loops;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property AVAudioEngine *audioEngine;
@property AVAudioMixerNode *mixerNode;

@end

@implementation HomeVC

/* Refresh control should be nil if not refreshing*/
- (void)queryLoops:(nullable UIRefreshControl *)refreshControl {
    PFQuery *query = [PFQuery queryWithClassName:@"Loop"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"postAuthor"];
    [query includeKey:@"tracks"];
    query.limit = 10;
    [query findObjectsInBackgroundWithBlock:^(NSArray *loops, NSError *error) {
        if (loops != nil) {
            self.loops = loops;
            [self.postTableView reloadData];
            NSLog(@"Successfully queried loops");
            if (refreshControl) [refreshControl endRefreshing];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.postTableView.dataSource = self;
    self.postTableView.delegate = self;
    [self queryLoops:nil];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor whiteColor];
    [self.postTableView insertSubview:refreshControl atIndex:0];
}

#pragma mark - UITableViewDataSourceMethods

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell"];
    cell.layer.cornerRadius = 5;
    cell.delegate = self;
    Loop *cellLoop = self.loops[indexPath.row];
    cell.loop = cellLoop;
    cell.loopNameLabel.text = cellLoop.name;
    cell.captionLabel.text = cellLoop.caption;
    cell.authorDescription.attributedText = [self getAuthorDescriptionString:cellLoop];
    PFFileObject *imageFile = cellLoop.postAuthor[@"profilePic"];
    if (imageFile){
        cell.profileImageView.image = [UIImage imageWithData:[imageFile getData]];
    }
    else{
        cell.profileImageView.image = [UIImage systemImageNamed:@"person"];
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.loops count];
}

#pragma mark - UITableViewDelegateMethods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Loop *loop = self.loops[indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"LoopStackNavController"];
    LoopStackVC *vc = (LoopStackVC *) navController.topViewController;
    vc.loop = loop;
    vc.readOnly = YES;
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Misc

- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [self queryLoops:refreshControl];
}

/* ShareVC delegate method */
- (void)didShare {
    [self queryLoops:nil];
}

- (void)postCell:(nonnull PostCell *)postCell didTap:(nonnull PFUser *)user {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProfileVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"ProfileVC"];
    vc.user = user;
    [[self navigationController] pushViewController:vc animated:YES];
}


@end
