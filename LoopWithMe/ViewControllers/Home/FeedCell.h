//
//  FeedCell.h
//  LoopWithMe
//
//  Created by Daniel Flores Garcia on 7/20/22.
//

#import <UIKit/UIKit.h>

#import "PlayStopButton.h"
#import "Loop.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FeedCellDelegate

- (void)playStopMix:(Loop *)loop;

@end

@interface FeedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *loopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet PlayStopButton *playStopButton;
@property (weak, nonatomic) id<FeedCellDelegate> delegate;
@property (strong, nonatomic) Loop *loop;

@end

NS_ASSUME_NONNULL_END
