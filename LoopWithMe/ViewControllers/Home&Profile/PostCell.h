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

@protocol PostCellDelegate;

@interface PostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *loopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) Loop *loop;
@property (strong, nonatomic) id<PostCellDelegate> delegate;

@end

@protocol PostCellDelegate

- (void)postCell:(PostCell *) postCell didTap: (PFUser *)user;

@end

NS_ASSUME_NONNULL_END
