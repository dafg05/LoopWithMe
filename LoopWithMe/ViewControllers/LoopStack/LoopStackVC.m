//
//  LoopStackVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/10/22.
//

#import "LoopStackVC.h"
#import "LoopTrackCell.h"

@interface LoopStackVC () <UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *loopNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *trackTableView;

@end

@implementation LoopStackVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.trackTableView.dataSource = self;
    self.loopNameLabel.text = self.loop.name;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    LoopTrackCell *cell = [self.trackTableView dequeueReusableCellWithIdentifier:
                           @"LoopTrackCell"];
    cell.track = self.loop.tracks[indexPath.row];
    cell.trackNumberLabel.text = [NSString stringWithFormat:@"Track %lu", indexPath.row + 1];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.loop.tracks count];
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
