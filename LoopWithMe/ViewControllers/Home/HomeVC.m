//
//  HomeVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/20/22.
//

#import "HomeVC.h"
#import "FeedCell.h"
#import "Parse/Parse.h"

@interface HomeVC () <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *feedTableView;
@property (strong, nonatomic) NSMutableArray *loops;

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.feedTableView.dataSource = self;
    [self queryLoops];
}

- (void)queryLoops {
    PFQuery *query = [PFQuery queryWithClassName:@"Loop"];
    [query orderByDescending:@"createdAt"];
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:^(NSArray *loops, NSError *error) {
        if (loops != nil) {
            self.loops = (NSMutableArray *)loops;
            [self.feedTableView reloadData];
            NSLog(@"Successfully queried loops");
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell"];
    cell.layer.cornerRadius = 5;
    Loop *cellLoop = self.loops[indexPath.row];
    cell.loop = cellLoop;
    cell.loopNameLabel.text = cellLoop.name;
    cell.captionLabel.text = cellLoop.caption;
    cell.authorLabel.text = cellLoop.postAuthor.username;
    NSLog(@"%@", cellLoop.postAuthor.username);
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.loops count];
}

@end
