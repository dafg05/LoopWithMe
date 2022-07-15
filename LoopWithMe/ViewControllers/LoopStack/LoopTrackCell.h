//
//  LoopTrackCell.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/13/22.
//

#import <UIKit/UIKit.h>
#import "Track.h"
#import "PlayStopButton.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LoopTrackCellDelegate;

@interface LoopTrackCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *trackNumberLabel;
@property (strong, nonatomic) Track *track;
@property (weak, nonatomic) id<LoopTrackCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet PlayStopButton *playTrackButton;

@end

@protocol LoopTrackCellDelegate

- (void) playTrack:(Track *)track;

@end

NS_ASSUME_NONNULL_END
