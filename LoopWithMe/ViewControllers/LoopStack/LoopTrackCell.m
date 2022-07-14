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
    // Initialization code
}
- (IBAction)didTapPlayStopTrack:(id)sender {
    [self.delegate playStopTrack];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
