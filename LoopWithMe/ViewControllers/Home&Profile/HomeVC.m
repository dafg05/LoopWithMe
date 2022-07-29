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
#import "Home&ProfileStrings.h"

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
    PFQuery *query = [PFQuery queryWithClassName:QUERY_CLASSNAME];
    [query orderByDescending:QUERY_ORDER];
    [query includeKey:QUERY_AUTHOR_KEY];
    [query includeKey:QUERY_TRACKS_KEY];
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
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:FEED_CELL_IDENT];
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
        cell.profileImageView.image = [UIImage systemImageNamed:DEFAULT_PROFILE_PIC_IMAGE];
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
    UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:LOOPSTACK_NAVCONTROL_IDENT];
    LoopStackVC *vc = (LoopStackVC *) navController.topViewController;
    vc.loop = loop;
    vc.newLoop = NO;
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
    ProfileVC *vc = [storyboard instantiateViewControllerWithIdentifier:PROFILE_VC_IDENT];
    vc.user = user;
    [[self navigationController] pushViewController:vc animated:YES];
}


@end
