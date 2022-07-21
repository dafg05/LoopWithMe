//
//  FeedCell.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/20/22.
//

#import "FeedCell.h"

@implementation FeedCell

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.playStopButton initWithColor:[UIColor whiteColor]];
    [self.playStopButton UIPlay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (IBAction)didTapPlayStop:(id)sender {
    [self.delegate playStopMix:self.loop];
}

@end
