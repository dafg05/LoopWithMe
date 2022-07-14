//
//  LoopTrackCell.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/13/22.
//

#import <UIKit/UIKit.h>
#import "Track.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LoopTrackCellDelegate;

@interface LoopTrackCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *trackNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *playStopButton;
@property (strong, nonatomic) Track *track;

-(void) didTapPlayStop;

@end

NS_ASSUME_NONNULL_END
