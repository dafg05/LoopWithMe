//
//  LoopStackVC.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/10/22.
//

#import "LoopStackVC.h"

@interface LoopStackVC ()
@property (weak, nonatomic) IBOutlet UILabel *loopNameLabel;

@end

@implementation LoopStackVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loopNameLabel.text = self.loop.name;
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
