//
//  LoopTrackCell.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/13/22.
//

#import "LoopTrackCell.h"

@implementation LoopTrackCell

- (void)awakeFromNib {
    [super awakeFromNib];
}
- (IBAction)didTapPlayStopTrack:(id)sender {
    [self.delegate playTrack:self.track];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
