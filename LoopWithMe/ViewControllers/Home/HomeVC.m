//
//  HomeVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/20/22.
//

#import "HomeVC.h"
#import "FeedCell.h"

@interface HomeVC () <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *feedTableView;

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.feedTableView.dataSource = self;
}




- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell"];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

@end
