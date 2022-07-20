//
//  LoopTrackCell.m
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/13/22.
//

#import "LoopTrackCell.h"

@implementation LoopTrackCell

- (IBAction)didTapPlayTrack:(id)sender {
    [self.delegate playTrack:self.trackAudioUrl];
}

@end
