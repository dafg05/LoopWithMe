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
- (IBAction)didTapPlayTrack:(id)sender {
    [self.delegate playTrack:self.trackAudioUrl];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
